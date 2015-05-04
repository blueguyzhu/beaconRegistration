//
//  ItemTwoViewController.m
//  BeaconRegistration
//
//  Created by Wenlu Zhang on 28/04/15.
//  Copyright (c) 2015 TEMPUS. All rights reserved.
//

#import "ItemTwoViewController.h"
#import "DeviceDataManager.h"
#import "QRScannerViewController.h"

@interface ItemTwoViewController ()
@property (nonatomic, strong) DeviceDataManager *deviceManager;
@property (nonatomic, strong) QRScannerViewController *scannerViewController;
@property (nonatomic, strong) NSString *scanedCode;
@property (nonatomic, strong) UIBarButtonItem *rightBarBtn;
@end

@implementation ItemTwoViewController


- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear: animated];
    
    //[_employeeTableView setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f]];
}


- (void) viewDidLoad {
    [super viewDidLoad];
    
    _deviceManager = [DeviceDataManager sharedManager];
    [_deviceManager loadData];
    
    _rightBarBtn = [[UIBarButtonItem alloc]
                    initWithTitle:@"+"
                    style:UIBarButtonItemStylePlain
                    target:self
                    action:@selector(scanBtnPressed:)];
    self.navigationItem.rightBarButtonItem = _rightBarBtn;
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    _employeeTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetHeight(self.tabBarController.tabBar.frame), 0.0f);
    
    [self.view setBackgroundColor:[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background.png"]]];
    [_employeeTableView setBackgroundColor: [UIColor clearColor]];
    

    [self.tabBarController.view setBackgroundColor:[UIColor clearColor]];
    for (UIView *v in [self.tabBarController.view subviews]) {
        [v setBackgroundColor:[UIColor clearColor]];
    }
}


#pragma mark - delegata of UITableView
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!(_scanedCode && _scanedCode.length)) {
        Ansatt *ansatt = [_deviceManager.ansattList objectAtIndex:indexPath.row];
        if (ansatt.shortId && ansatt.shortId.length) {
            [_deviceManager.ansattRecords removeObjectForKey:ansatt.shortId];
            ansatt.shortId = NULL;
            [_deviceManager updateAnsattInfo:ansatt];
        }
        [tableView reloadData];
        return;
    }
    
    Ansatt *ansatt = [_deviceManager.ansattList objectAtIndex:indexPath.row];
    NSString *oldShortId = ansatt.shortId;
    ansatt.shortId = _scanedCode;
    [_deviceManager.ansattRecords setObject:ansatt forKey:ansatt.shortId];
    if (oldShortId && oldShortId.length)
        [_deviceManager.ansattRecords removeObjectForKey:oldShortId];
    
    //update DB
    BOOL suc = [_deviceManager updateAnsattInfo:ansatt];
    if (!suc)
        [WLLog logWithLevel:ERROR withTime:nil withContent:@"Update ansatt: %@ with short id: %@ to DB failed", ansatt.name, ansatt.shortId];
    
    _scanedCode = nil;
    
    //[tableView setDataSource:nil];
    [tableView reloadData];
    
    //Update DB;
}


#pragma mark - datasource of UITableView
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _deviceManager.ansattList.count;
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = NULL;
    static NSString *cellName = @"cellName";
    cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellName];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
    }
    
    Ansatt *ansatt = [_deviceManager.ansattList objectAtIndex:indexPath.row];
    
    [cell.textLabel setText:ansatt.name];
    if (ansatt.shortId && ansatt.shortId.length > 0)
        [cell.detailTextLabel setText:ansatt.shortId];
    else
        [cell.detailTextLabel setText:nil];
    
    return cell;
}


#pragma mark - IBAction methods
- (IBAction)scanBtnPressed:(id)sender{
    if (sender != self.rightBarBtn)
        return;
    
    [self createScannerView];
    [self presentViewController:_scannerViewController animated:YES completion:nil];
}


#pragma mark - private methods
- (void) createScannerView
{
    if (!_scannerViewController) {
        _scannerViewController = [[QRScannerViewController alloc] initWithNibName:@"QRScannerView_P" bundle:nil];
        __weak ItemTwoViewController *weakSelf = self;
        _scannerViewController.dismissMe = ^void (NSString *code){
            if (code) {
                weakSelf.scanedCode = [NSString stringWithString:code];
                
                [weakSelf.scannerViewController dismissViewControllerAnimated:YES completion:nil];
                
                [weakSelf.employeeTableView setDataSource:weakSelf];
                [weakSelf.employeeTableView reloadData];
            }
            else {
                [weakSelf.scannerViewController dismissViewControllerAnimated:YES completion:nil];
            }
        };
    }
}

@end
