//
//  QRScannerViewController.h
//  TempusBeacon
//
//  Created by Wenlu Zhang on 11/05/14.
//  Copyright (c) 2014 TEMPUS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface QRScannerViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, weak) IBOutlet UIView *viewPreview;
@property (nonatomic, weak) IBOutlet UIButton *cancelBtn;

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, copy) void (^dismissMe) (NSString *code);

- (IBAction)cancelBtnPressed:(id)sender;

@end
