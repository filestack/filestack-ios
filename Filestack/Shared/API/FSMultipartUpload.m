//
//  FSMultipartUpload.m
//  Filestack
//
//  Created by Kevin Minnick on 3/8/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

#import "FSMultipartUpload.h"
#import "FSAPIClient.h"
#import "FSAPIURL.h"
#import "FSSessionSettings.h"
#import <CommonCrypto/CommonDigest.h> // Need to import for CC_MD5 access

typedef void(^OnStartHandler)();
typedef void(^ProgressHandler)(NSProgress*);
typedef void(^CompletionHandler)(NSDictionary*, NSError*);

@interface NSData (MyAdditions)
- (NSString*)md5;
@end

@implementation NSData (MyAdditions)
- (NSString*)md5
{
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( self.bytes, (int)self.length, result ); // This is the md5 call

    NSData *plainData = [NSData dataWithBytes:result length:CC_MD5_DIGEST_LENGTH];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    
    return base64String;
}
@end

@interface FSMultipartUpload ()

@property (nonatomic, copy) FSUploadOptions *uploadOptions;
@property (nonatomic, copy) FSStoreOptions *storeOptions;
@property (nonatomic, copy) FSSessionSettings *sessionSettings;
@property (nonatomic, copy) NSData *file;
@property (nonatomic, strong) NSDictionary *uploadData;
@property (nonatomic, copy) NSString *apiKey;
@property (nonatomic) NSNumber *currentUploads;

// Parts info
@property (nonatomic) NSNumber *currentPart;
@property (nonatomic) NSNumber *totalParts;
@property (nonatomic) NSMutableArray *uploadedParts;
@property (nonatomic) NSMutableArray *failedParts;
@property (nonatomic, strong) NSMutableArray *progress;

@property (nonatomic, readonly) OnStartHandler onStartHandler;
@property (nonatomic, readonly) ProgressHandler progressHandler;
@property (nonatomic, readonly) CompletionHandler completionHandler;


@property (nonatomic, strong) NSProgress* progressTotal;

@end

@implementation FSMultipartUpload


- (instancetype) initWithOptions:(FSUploadOptions*)uploadOptions
                withStoreOptions:(FSStoreOptions*)storeOptions
                      withApiKey:(NSString*)apiKey
                         onStart:(void (^)())onStart
                        progress:(void (^)(NSProgress *uploadProgress))progress
               completionHandler:(void (^)(NSDictionary *result, NSError *error))completionHandler {
    self = [super init];
    if (self) {
        _uploadOptions = uploadOptions;
        _storeOptions = storeOptions;
        _sessionSettings = [[FSSessionSettings alloc] init];
        _sessionSettings.baseURL = FSURLUploadURL;
        _sessionSettings.paramsInURI = false;
        _uploadData = nil;
        _currentUploads = @0;
        _apiKey = apiKey;
        _currentPart = @0;
        _totalParts = @0;
        _uploadedParts = [[NSMutableArray alloc] init];
        _failedParts = [[NSMutableArray alloc] init];
        _progress = nil;
        _onStartHandler = onStart;
        _progressHandler = progress;
        _completionHandler = completionHandler;
        _progressTotal = nil;
    }
    return self;
}

- (void)upload:(NSData*)file {
    _file = file;
    
    _totalParts = @(ceil([file length] / [_uploadOptions.partSize floatValue])); // 1.0 so ceil works
    _progress = [[NSMutableArray alloc] initWithCapacity:[_totalParts intValue]];
    _progressTotal = [NSProgress progressWithTotalUnitCount:[_file length]];
    
    [self start:^(NSError *error) {
        if (error && _completionHandler) {
            _completionHandler(nil, error);
        } else {
            if (_onStartHandler) {
                _onStartHandler();
            }
            [self loadNextPart];
        }
    }];
}

// Make call to filestack to start multi-part upload
- (void)start:(void (^)(NSError *error))completionHandler {
    NSString *lengthStr = [[NSString alloc] initWithFormat:@"%lu", (unsigned long)[_file length]];
    NSDictionary *params = @{@"size" : lengthStr};
    
    NSDictionary *formData = [self createUploadFormData:params];
    
    FSAPIClient *apiClient = [[FSAPIClient alloc] init];
    [apiClient POST:FSURLMultiPartUploadStartPath
           formdata:formData
               data:nil
            options:_storeOptions
    sessionSettings:_sessionSettings
  completionHandler:^(NSDictionary *response, NSError *error) {
      if (error) {
          completionHandler(error);
      } else {
          _uploadData = response;
          completionHandler(nil);
      }
  }];
}

// Async read the file part that needs to be uploaded next
- (void)loadNextPart {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    // If all parts have completed, start complete call
    if ([_progressTotal completedUnitCount] == [_file length]) {
        [self complete];
        return;
    }
    
    // Don't keep reading / uploading unless there is an open slot
    // _currentUpload >= maxConcurrentUploads
    if ([_currentUploads compare:_uploadOptions.maxConcurrentUploads] != NSOrderedAscending) {
        return;
    }
    
    int partNumber = [_currentPart intValue];
    int totalParts = [_totalParts intValue];
    // If we've read all the parts, stop
    if (partNumber >= totalParts) {
        return;
    }
    _currentUploads = [NSNumber numberWithInt:[_currentUploads intValue] + 1]; // _currentUploads + 1
    
    int partSize = [_uploadOptions.partSize intValue];
    int start = partNumber * partSize;
    int fileSize = (int)[_file length];
    int end = ((start + partSize) >= fileSize) ? (fileSize - (partSize * partNumber)) : partSize;
    
    _currentPart = [NSNumber numberWithInt:[_currentPart intValue] + 1]; // _currentPart + 1
    
    // Create a thread to handle this chunck
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *chunk = [_file subdataWithRange:NSMakeRange(start, end)];
        NSString *md5 = [NSString stringWithString:[chunk md5]];
        [self getUploadData:chunk part:partNumber+1 md5:md5];
    });
    [self loadNextPart];
}

// Send chunk meta data to filestack to get s3 info
- (void)getUploadData:(NSData*)chunk part:(int)partNumber md5:(NSString*)md5 {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    NSDictionary *params = @{@"part": [NSString stringWithFormat:@"%d", partNumber],
                             @"size": [NSString stringWithFormat:@"%ld", [chunk length]],
                             @"md5": md5};
    
    NSDictionary *formData = [self createUploadFormData:params];
    
    FSAPIClient *apiClient = [[FSAPIClient alloc] init];
    [apiClient POST:FSURLMultiPartUploadPath
           formdata:formData
               data:nil
            options:_storeOptions
    sessionSettings:_sessionSettings
  completionHandler:^(NSDictionary *response, NSError *error) {
      if (error) {
          // TODO - retry
      } else {
          [self uploadPart:chunk
                uploadData:response
                      part:partNumber];
      }
  }];
}

// upload chunk to s3
- (void)uploadPart:(NSData*)chunk uploadData:(NSDictionary*)uploadData part:(int)partNumber {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    FSAPIClient *apiClient = [[FSAPIClient alloc] init];
    [apiClient PUT:uploadData[@"url"]
          formdata:uploadData[@"headers"]
              data:chunk
          progress:^(NSProgress *uploadProgress) {
              dispatch_async(dispatch_get_main_queue(), ^{
                  NSLog(@"Part: %d - Progress: %f", partNumber, uploadProgress.fractionCompleted);
                  @try {
                      // Add child if not already added, only way is to try/catch
                      [_progressTotal addChild:uploadProgress withPendingUnitCount:[uploadProgress totalUnitCount]];
                  }
                  @catch (NSException *e) {}
                  
                  if(_progressHandler) {
                      _progressHandler(_progressTotal);
                  }
              });
          } completionHandler:^(NSDictionary *response, NSError *error) {
              // Signal main thread that this upload has completed, this should open up a new slot
              dispatch_async(dispatch_get_main_queue(), ^{
                  // store the returned e-tag
                  if (response) {
                      NSString *etag = [NSString stringWithString:response[@"ETag"]];
                      NSString *etagPart = [NSString stringWithFormat:@"%d:%@", partNumber, etag];
                      [_uploadedParts addObject:etagPart];
                  } else {
                      // This part failed to upload
                      NSLog(@"%@", error);
                      [_failedParts addObject:[NSNumber numberWithInt:partNumber]];
                  }
                  _currentUploads = [NSNumber numberWithInt:[_currentUploads intValue] - 1]; // _currentUpload - 1
                  [self loadNextPart];
              });
          }];
}

// Upload has finished to s3, call complete
- (void)complete {
    NSLog(@"%@", NSStringFromSelector(_cmd));


    NSString *mimetype;
    if (_storeOptions.mimeType) {
        mimetype = _storeOptions.mimeType;
    } else {
        mimetype = @"application/octet-stream";
    }
    
    NSDictionary *params = @{@"filename": _storeOptions.fileName,
                             @"size": [NSString stringWithFormat:@"%ld", [_file length]],
                             @"mimetype": mimetype,
                             @"parts": [_uploadedParts componentsJoinedByString:@";"]};
    
    NSDictionary *formData = [self createUploadFormData:params];
    
    FSAPIClient *apiClient = [[FSAPIClient alloc] init];
    [apiClient POST:FSURLMultiPartUploadCompletePath
           formdata:formData
               data:nil
            options:_storeOptions
    sessionSettings:_sessionSettings
  completionHandler:^(NSDictionary *response, NSError *error) {
      if (error && _completionHandler) {
          _completionHandler(nil, error);
      } else if(_completionHandler) {
          _completionHandler(response, nil);
      }
  }];

}

// Helper - Almost all calls to the api require the same set of form-fields passed
- (NSDictionary*) createUploadFormData:(NSDictionary*) dataFields {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:dataFields];

    if (_uploadData) {
        [params addEntriesFromDictionary:_uploadData];
    }
    
    if (_apiKey) {
        [params setObject:_apiKey forKey:@"apikey"];
    }
    
    if (_storeOptions.fileName) {
        [params setObject:_storeOptions.fileName forKey:@"filename"];
    }
    
    if (_storeOptions.mimeType) {
        [params setObject:_storeOptions.mimeType forKey:@"mimetype"];
    } else {
        [params setObject:@"application/octet-stream" forKey:@"mimetype"];
    }
    
    if (_storeOptions.path) {
        [params setObject:_storeOptions.path forKey:@"path"];
    }
    
    if (_storeOptions.container) {
        [params setObject:_storeOptions.container forKey:@"container"];
    }
    
    if (_storeOptions.security && _storeOptions.security.policy) {
        [params setObject:_storeOptions.security.policy forKey:@"policy"];
    }
    
    if (_storeOptions.security && _storeOptions.security.signature) {
        [params setObject:_storeOptions.security.signature forKey:@"signature"];
    }
    
    if (_storeOptions.access) {
        [params setObject:_storeOptions.access forKey:@"access"];
    }
    
    if (_storeOptions.location) {
        [params setObject:_storeOptions.storeLocation forKey:@"location"];
    } else {
        [params setObject:@"s3" forKey:@"location"];
    }
    
    if (_storeOptions.region) {
        [params setObject:_storeOptions.region forKey:@"region"];
    }
    
    return [NSDictionary dictionaryWithDictionary:params];
}


@end
