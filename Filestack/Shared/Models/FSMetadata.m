//
//  FSMetadata.m
//  Filestack
//
//  Created by Łukasz Cichecki on 20/01/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSMetadata.h"

@interface FSMetadata ()

@property (nonatomic, readwrite, assign) NSInteger size;
@property (nonatomic, readwrite, copy) NSString *mimeType;
@property (nonatomic, readwrite, copy) NSString *fileName;
@property (nonatomic, readwrite, assign) NSInteger width;
@property (nonatomic, readwrite, assign) NSInteger height;
@property (nonatomic, readwrite, assign) NSInteger uploaded;
@property (nonatomic, readwrite, strong) NSNumber *writeable;
@property (nonatomic, readwrite, copy) NSString *md5;
@property (nonatomic, readwrite, copy) NSString *location;
@property (nonatomic, readwrite, copy) NSString *path;
@property (nonatomic, readwrite, copy) NSString *container;

@end

@implementation FSMetadata

- (NSString *)s3url {
    if (self.container && self.path) {
        return [NSString stringWithFormat:@"https://%@.s3.amazonaws.com/%@", self.container, self.path];
    }
    return nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"\nsize: %ld\nfilename: %@\nmimetype: %@\nwidth: %ld\nheight: %ld\nuploaded: %ld\nwriteable: %@\nmd5: %@\nlocation: %@\npath: %@\ncontainer: %@\ns3url: %@",
            (long)self.size, self.fileName, self.mimeType, (long)self.width, (long)self.height, (long)self.uploaded, self.writeable, self.md5, self.location, self.path, self.container, self.s3url];
}

@end
