//
//  SecondViewController.h
//  BeaconRegistration
//
//  Created by Wenlu Zhang on 17/09/14.
//  Copyright (c) 2014 TEMPUS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIButton *scanBtn;
@property (nonatomic, weak) IBOutlet UIButton *goBtn;


-(IBAction)scanBtnPressed:(id)sender;
-(IBAction)goBtnPressed:(id)sender;


@end
