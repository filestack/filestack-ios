//
//  ViewController.h
//  Filestack-Mac-Demo
//
//  Created by Łukasz Cichecki on 01/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewControllerMac : NSViewController

@property (weak) IBOutlet NSButtonCell *multipartUploadBtn;
@property (unsafe_unretained) IBOutlet NSTextView *resultsTextView;
@property (weak) IBOutlet NSProgressIndicator *uploadProgressIndicator;

@end
