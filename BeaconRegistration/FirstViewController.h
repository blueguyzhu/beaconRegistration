//
//  FirstViewController.h
//  BeaconRegistration
//
//  Created by Wenlu Zhang on 17/09/14.
//  Copyright (c) 2014 TEMPUS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface FirstViewController : UIViewController <CLLocationManagerDelegate>
@property (nonatomic, weak) IBOutlet UITextView *greetingTextView;
@end
