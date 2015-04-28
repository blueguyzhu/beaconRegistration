//
//  SecondViewController.m
//  BeaconRegistration
//
//  Created by Wenlu Zhang on 17/09/14.
//  Copyright (c) 2014 TEMPUS. All rights reserved.
//

#import "SecondViewController.h"
#import "DeviceDataManager.h"
#import "Ansatt.h"
#import "QRScannerViewController.h"

@interface SecondViewController ()
@property (nonatomic, strong) DeviceDataManager *deviceManager;
@property (nonatomic, strong) QRScannerViewController *scannerViewController;
@property (nonatomic, strong) NSString *scanedCode;
@end

@implementation SecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _deviceManager = [DeviceDataManager sharedManager];
    [_deviceManager loadData];
    
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDataSource Methods
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
    }
    
    Ansatt *ansatt = [_deviceManager.ansattList objectAtIndex:indexPath.row];
    
    [cell.textLabel setText:ansatt.name];
    if (ansatt.shortId && ansatt.shortId.length > 0)
        [cell.detailTextLabel setText:ansatt.shortId];
    else
        [cell.detailTextLabel setText:nil];
    
    return cell;
}



#pragma mark - UITableViewDelegate Methods
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
    
//    [_tableView setDataSource:nil];
    [_tableView reloadData];
    
    //Update DB;
}


#pragma mark - IBAction methods
- (IBAction)scanBtnPressed:(id)sender{
    if (sender != self.scanBtn)
        return;
    
    [self createScannerView];
    [self presentViewController:_scannerViewController animated:YES completion:nil];
}


- (IBAction)goBtnPressed:(id)sender
{
    if (sender != _goBtn)
        return;
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://go.tempus.no/077098253052151214133068147153084103098204010133#_home"]];
}



#pragma mark - private methods
- (void) createScannerView
{
    if (!_scannerViewController) {
        _scannerViewController = [[QRScannerViewController alloc] initWithNibName:@"QRScannerView" bundle:nil];
        __weak SecondViewController *weakSelf = self;
        _scannerViewController.dismissMe = ^void (NSString *code){
            if (code) {
                weakSelf.scanedCode = [NSString stringWithString:code];
            
                [weakSelf.scannerViewController dismissViewControllerAnimated:YES completion:nil];
            
//                [weakSelf.tableView setDataSource:weakSelf];
                [weakSelf.tableView reloadData];
            }
            else {
                [weakSelf.scannerViewController dismissViewControllerAnimated:YES completion:nil];
            }
        };
    }
}

@end
