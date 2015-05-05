//
//  ItemOneViewController.h
//  BeaconRegistration
//
//  Created by Wenlu Zhang on 28/04/15.
//  Copyright (c) 2015 TEMPUS. All rights reserved.
//

#ifndef BeaconRegistration_ItemOneViewController_h
#define BeaconRegistration_ItemOneViewController_h

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface ItemOneViewController : UIViewController <CLLocationManagerDelegate>
@property (nonatomic, weak) IBOutlet UIImageView *logoImgView;
@property (nonatomic, weak) IBOutlet UITextView *greetingTextView;
@end

#endif
