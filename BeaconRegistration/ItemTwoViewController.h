//
//  UIViewController_ItemTwoViewController.h
//  BeaconRegistration
//
//  Created by Wenlu Zhang on 28/04/15.
//  Copyright (c) 2015 TEMPUS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemTwoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *employeeTableView;
@property (nonatomic, weak) IBOutlet UIButton *scanBtn;

- (IBAction)scanBtnPressed:(id)sender;

@end
