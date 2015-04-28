//
//  ItemOneViewController.m
//  BeaconRegistration
//
//  Created by Wenlu Zhang on 28/04/15.
//  Copyright (c) 2015 TEMPUS. All rights reserved.
//
#define kUUID_STR                   @"f7826da6-4fa2-4e98-8024-bc5b71e0893e"

#import "ItemOneViewController.h"
#import "DeviceDataManager.h"
#import "ServerRequest.h"


@interface ItemOneViewController ()
@property (nonatomic, strong) DeviceDataManager *deviceManager;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLBeaconRegion *monitoredRegion;
@property (nonatomic, strong) NSMutableArray *registeredBeaconMajor;
@property (nonatomic, strong) NSMutableDictionary *beaconsState;
@end

@implementation ItemOneViewController

- (void) viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [WLLog setLogDest:DOC];
    [WLLog setLogLevel:ALL];
    [WLLog outputToStd:YES];
    
    
    _deviceManager = [DeviceDataManager sharedManager];
    
    if (![_deviceManager loadData]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot find beacon info"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    [WLLog logWithLevel:INFO withTime:nil withContent:@"Load data from database successfully"];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
        [_locationManager requestAlwaysAuthorization];
    
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:kUUID_STR];
    _monitoredRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"brukermøte"];
    _monitoredRegion.notifyEntryStateOnDisplay = YES;
    _monitoredRegion.notifyOnEntry = YES;
    _monitoredRegion.notifyOnExit = YES;
    
    
    [_locationManager startMonitoringForRegion:_monitoredRegion];
    //_broadcasting = YES;
    //[_broadcastSwitch setSelectedSegmentIndex:1];
    //_broadcasting = NO;
    
    _registeredBeaconMajor = [[NSMutableArray alloc] init];
    _beaconsState = [[NSMutableDictionary alloc] init];

    
}


#pragma mark - delegate of CLLocationManager
- (void) locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
    [WLLog logWithLevel:INFO withTime:nil withContent:@"Start to monito region %@", beaconRegion.identifier];
    [manager startRangingBeaconsInRegion:beaconRegion];
}

- (void) locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
    [WLLog logWithLevel:ERROR
               withTime:nil
            withContent:@"Monitor region %@ failed. Reason: %@. %@", beaconRegion.identifier, error.localizedDescription, error.localizedFailureReason];
}


- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [WLLog logWithLevel:ERROR
               withTime:nil
            withContent:@"Location manager failed to retrieve location value. Reason is %@. %@", error.localizedDescription, error.localizedFailureReason];
}


- (void) locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
    
    if (CLRegionStateInside == state) {
        [WLLog logWithLevel:INFO withTime:nil withContent:@"Region state is inside"];
        [manager startRangingBeaconsInRegion:beaconRegion];
    }else if(CLRegionStateOutside == state) {
        [manager stopRangingBeaconsInRegion:beaconRegion];
        [WLLog logWithLevel:INFO withTime:nil withContent:@"Region state is outside"];
    }else {
        [WLLog logWithLevel:WARN withTime:nil withContent:@"Region state is unknown"];
    }
}


- (void) locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    [WLLog logWithLevel:INFO withTime:nil withContent:@"Did enter region"];
    CLBeaconRegion *beaconRegion = (CLBeaconRegion *) region;
    [manager startRangingBeaconsInRegion:beaconRegion];
}


- (void) locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    [WLLog logWithLevel:INFO withTime:nil withContent:@"Did exit region"];
    CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
    [manager stopRangingBeaconsInRegion:beaconRegion];
}


- (void) locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    for (CLBeacon *beacon in beacons) {
        if (beacon.major.integerValue == 42301) {
            [WLLog logWithLevel:ALL withTime:nil withContent:@"Beacon with ID: %@, major: %@, minor: %@ has accuracy %f", region.identifier,
             beacon.major, beacon.minor, beacon.accuracy];
        }
        
        //exist already
        if ([_registeredBeaconMajor containsObject:beacon.major]) {
            NSString *shortId = [_deviceManager customerIdByMajor:beacon.major andMinor:beacon.minor];
            if (shortId && shortId.length && ![_deviceManager.ansattRecords objectForKey:shortId]) {
                [WLLog logWithLevel:INFO withTime:nil withContent:@"Beacon with major: %@, minor: %@ has been removed from monitor list", beacon.major, beacon.minor];
                [_registeredBeaconMajor removeObject:beacon.major];
                [_beaconsState removeObjectForKey:beacon.major];
            }
            else {
                [_beaconsState setObject:[NSNumber numberWithInteger:0] forKey:beacon.major];
                [WLLog logWithLevel:INFO withTime:nil withContent:@"Beacon with major: %@, minor: %@ exists already, update count only", beacon.major, beacon.minor];
            }
            continue;
        }
        
        //new beacon detected
        NSString *shortId = [_deviceManager customerIdByMajor:beacon.major andMinor:beacon.minor];
        if (!shortId || shortId.length == 0) {
            [WLLog logWithLevel:DEV withTime:nil withContent:@"New beacon discovered with major: %@, minor: %@. But not in our list", beacon.major, beacon.minor];
            continue;
        }
        
        [WLLog logWithLevel:DEV withTime:nil withContent:@"New beacon discovered, beacon has short id: %@, major: %@, minor: %@", shortId, beacon.major, beacon.minor];
        
        Ansatt *ansatt = [_deviceManager.ansattRecords objectForKey:shortId];
        if (!ansatt) {
            [WLLog logWithLevel:DEV withTime:nil withContent:@"Beacon with short id: %@ is not registered in DB", shortId];
            continue;
        }
        
        [WLLog logWithLevel:INFO withTime:nil withContent:@"Find new registered beacon with major: %@, minor: %@, short id: %@. Start to register in server...", beacon.major,
         beacon.minor, shortId];
        NSDictionary *registerInfo = [self registerInfo:ansatt.num];
        if ([ServerRequest registerCustomer:registerInfo]) {
            [WLLog logWithLevel:INFO withTime:nil withContent:@"Register beacon with short id: %@ INN successfully", shortId];
            [_registeredBeaconMajor addObject:beacon.major];
            [_beaconsState setObject:[NSNumber numberWithInteger:0] forKey:beacon.major];
            NSDate *date = [NSDate date];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
            NSString *greetingMsg = [NSString stringWithFormat:@"%@ Register in %@", [formatter stringFromDate:date], ansatt.name];
            greetingMsg = [NSString stringWithFormat:@"%@\n%@", _greetingTextView.text, greetingMsg];
            [_greetingTextView setText:greetingMsg];
        }
        else {
            [WLLog logWithLevel:ERROR withTime:nil withContent:@"Register beaocon with short id: %@ INN failed", shortId];
        }
    }
    
    NSMutableDictionary *tempBeaconsState = [[NSMutableDictionary alloc] init];
    for (NSNumber *major in _beaconsState) {
        NSInteger count = [[_beaconsState objectForKey:major] integerValue];
        if (++count > 10) {
            [WLLog logWithLevel:INFO withTime:nil withContent:@"Beacon with major: %@ has been timeout", major];
            
            NSString *shortId = [_deviceManager customerIdByMajor:major];
            if (!shortId || shortId.length == 0) {
                [WLLog logWithLevel:FALTAL withTime:nil withContent:@"No short id associated with major: %@", major];
                continue;
            }
            
            Ansatt *ansatt = [_deviceManager.ansattRecords objectForKey:shortId];
            if (!ansatt) {
                [WLLog logWithLevel:FALTAL withTime:nil withContent:@"No ansatt info associated with major: %@", major];
                continue;
            }
            
#ifdef TRUCK_BEACON
            NSDictionary *registerInfo = [self antallRegOutInfo:ansatt.num];
#else
            NSDictionary *registerInfo = [self registerInfo:ansatt.num];
#endif
            [WLLog logWithLevel:INFO withTime:nil withContent:@"Start to regitster out beacon with short id: %@ in server...", shortId];
#ifdef TRUCK_BEACON
            BOOL suc = [ServerRequest antallRegIn:registerInfo];
#else
            BOOL suc = [ServerRequest goodbyeCustomer:registerInfo];
#endif
            if (!suc){
                [WLLog logWithLevel:ERROR withTime:nil withContent:@"Register beacon with short id: %@ UT failed.", shortId];
                [tempBeaconsState setObject:[NSNumber numberWithInteger:count] forKey:major];
            }
            else{
                [WLLog logWithLevel:ERROR withTime:nil withContent:@"Register beacon with short id: %@ UT successfully.", shortId];
                NSDate *date = [NSDate date];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
                NSString *greetingMsg = [NSString stringWithFormat:@"%@ Register ut %@", [formatter stringFromDate:date], ansatt.name];
                greetingMsg = [NSString stringWithFormat:@"%@\n%@", _greetingTextView.text, greetingMsg];
                [_greetingTextView setText:greetingMsg];
            }
        }
        else{
            [tempBeaconsState setObject:[NSNumber numberWithInteger:count] forKeyedSubscript:major];
            [WLLog logWithLevel:INFO withTime:nil withContent:@"Beacon with major: %@ has count num %d", major, count];
        }
    }
    
    [_beaconsState removeAllObjects];
    [_registeredBeaconMajor removeAllObjects];
    if (tempBeaconsState.count) {
        [_beaconsState setValuesForKeysWithDictionary:tempBeaconsState];
        [_registeredBeaconMajor addObjectsFromArray:[tempBeaconsState allKeys]];
    }
}


#pragma - mark private methods
- (NSDictionary *) registerInfo: (NSInteger)customerId
{
    if (customerId <= 0) {
        return nil;
    }
    
    NSString *ansattNum = [NSString stringWithFormat:@"%ld", (long)customerId];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd.MM.yyyy"];
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"HH:mm"];
    NSDate *now = [[NSDate alloc] init];
    NSString *date = [dateFormat stringFromDate:now];
    NSString *time = [timeFormat stringFromDate:now];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    [dict setObject:ansattNum forKey:@"AnsattNr"];
    [dict setObject:[NSNumber numberWithInt:1] forKey:@"Sanntid"];
    [dict setObject:time forKey:@"StartKl"];
    [dict setObject:date forKey:@"StartDato"];
    [dict setObject:@"190" forKey:@"Tab2"];//kREGISTER_NO
    //[dict setObject:kREGISTER_NO forKey:@"Tab2"];;
    [dict setObject:@"0" forKey:@"Tab3"];
    //[dict setObject:@"0" forKey:@"Tab3"];
    [dict setObject:@"0" forKey:@"Tab4"];
    //[dict setObject:@"0" forKey:@"Tab4"];
    [dict setObject:@"" forKey:@"Tab5"];
    [dict setObject:@"" forKey:@"Tab6"];
    [dict setObject:@"" forKey:@"Tab7"];
    [dict setObject:@"" forKey:@"Tab8"];
    [dict setObject:@"This is development test" forKey:@"Melding"];
    [dict setObject:[NSNumber numberWithInt:0] forKey:@"Antall1"];
    [dict setObject:[NSNumber numberWithInt:0] forKey:@"Antall2"];
    [dict setObject:[NSNumber numberWithInt:0] forKey:@"Antall3"];
    
    return dict;
}


- (NSDictionary *) antallRegInInfo: (NSInteger)customerId
{
    if (customerId <= 0)
        return nil;
    NSString *ansattNum = [NSString stringWithFormat:@"%ld", (long)customerId];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd.MM.yyyy"];
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"HH:mm"];
    
    NSDate *now = [[NSDate alloc] init];
    NSString *date = [dateFormat stringFromDate:now];
    NSString *time = [timeFormat stringFromDate:now];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    [dict setObject:ansattNum forKey:@"AnsattNr"];
    [dict setObject:[NSNumber numberWithInt:0] forKey:@"Sanntid"];
    [dict setObject:time forKey:@"StartKl"];
    [dict setObject:date forKey:@"StartDato"];
    [dict setObject:[NSNumber numberWithInt:1] forKey:@"Tab2"];
    [dict setObject:@"0" forKey:@"Tab3"];
    [dict setObject:@"0" forKey:@"Tab4"];
    [dict setObject:@"0" forKey:@"Tab5"];
    [dict setObject:@"0" forKey:@"Tab6"];
    [dict setObject:@"0" forKey:@"Tab7"];
    [dict setObject:@"0" forKey:@"Tab8"];
    [dict setObject:@"0" forKey:@"Tab9"];
    [dict setObject:@"0" forKey:@"Tab10"];
    [dict setObject:@"iBeacon Test" forKey:@"Melding"];
    [dict setObject:@"1" forKey:@"Antall1"];
    [dict setObject:@"0" forKey:@"Antall2"];
    [dict setObject:@"0" forKey:@"Antall3"];
    
    return dict;
}


- (NSDictionary *) antallRegOutInfo: (NSInteger)customerId
{
    if (customerId <= 0)
        return nil;
    NSString *ansattNum = [NSString stringWithFormat:@"%ld", (long)customerId];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd.MM.yyyy"];
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"HH:mm"];
    
    NSDate *now = [[NSDate alloc] init];
    NSString *date = [dateFormat stringFromDate:now];
    NSString *time = [timeFormat stringFromDate:now];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    [dict setObject:ansattNum forKey:@"AnsattNr"];
    [dict setObject:[NSNumber numberWithInt:0] forKey:@"Sanntid"];
    [dict setObject:time forKey:@"StartKl"];
    [dict setObject:date forKey:@"StartDato"];
    [dict setObject:[NSNumber numberWithInt:1] forKey:@"Tab2"];
    [dict setObject:@"0" forKey:@"Tab3"];
    [dict setObject:@"0" forKey:@"Tab4"];
    [dict setObject:@"0" forKey:@"Tab5"];
    [dict setObject:@"0" forKey:@"Tab6"];
    [dict setObject:@"0" forKey:@"Tab7"];
    [dict setObject:@"0" forKey:@"Tab8"];
    [dict setObject:@"0" forKey:@"Tab9"];
    [dict setObject:@"0" forKey:@"Tab10"];
    [dict setObject:@"iBeacon Test" forKey:@"Melding"];
    [dict setObject:@"0" forKey:@"Antall1"];
    [dict setObject:@"1" forKey:@"Antall2"];
    [dict setObject:@"0" forKey:@"Antall3"];
    
    return dict;
}




@end