//
//  DeviceDataManager.m
//  TempusBrukermøte
//
//  Created by Wenlu Zhang on 11/05/14.
//  Copyright (c) 2014 TEMPUS. All rights reserved.
//
#define kSQLITE_DB_FILE     @"beaconReg"
#define kDEVICE_TABLE       @"devices"
#define kANSATT_TABLE       @"ansatt"

#import "DeviceDataManager.h"
#import <sqlite3.h>

@implementation DeviceDataManager

static sqlite3 *gDb = nil;

+ (DeviceDataManager *) sharedManager
{
    static DeviceDataManager *sharedManager = nil;
    if (sharedManager) {
        return sharedManager;
    }
    
    static dispatch_once_t onceToken = 0;
    
    dispatch_once(&onceToken, ^{
        sharedManager = [[DeviceDataManager alloc] initPrivate];
    });
    
    return sharedManager;
}


- (DeviceDataManager *) initPrivate
{
    self = [super init];
    
    if (self) {
        _deviceRecords = [[NSMutableDictionary alloc] init];
        _ansattRecords = [[NSMutableDictionary alloc] init];
        _ansattList = [[NSMutableArray alloc] init];
    }
    return self;
}


- (BOOL) loadData
{
    if (_deviceRecords.count && _ansattList.count) {
        return YES;
    }else {
        [_deviceRecords removeAllObjects];
        [_ansattList removeAllObjects];
        [_ansattRecords removeAllObjects];
    }
    
    NSString *pathStr = [self dbFilePath];
    if (!pathStr) {
        return NO;
    }
    
    sqlite3 *db = nil;
    int result = sqlite3_open([pathStr UTF8String], &db);
    if (SQLITE_OK != result) {
        NSLog(@"ERROR: Failed to open database");
        return NO;
    }
    
    NSString *query = @"SELECT * FROM devices";
    sqlite3_stmt *statement;
    result = sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil);
    if (SQLITE_OK != result) {
        NSLog(@"ERROR: Prepare statement failed");
        sqlite3_close(db);
        
        return NO;
    }
    
    //NSMutableDictionary *loadedDic = [[NSMutableDictionary alloc] init];
    while (sqlite3_step(statement) == SQLITE_ROW) {
        NSString *shortId = [NSString stringWithUTF8String: (char *)sqlite3_column_text(statement, 0)];
        NSNumber *major = [NSNumber numberWithInt: sqlite3_column_int(statement, 1)];
        NSNumber *minor = [NSNumber numberWithInt: sqlite3_column_int(statement, 2)];
        //NSNumber *ansattNr = [NSNumber numberWithInt:sqlite3_column_int(statement, 4)];

        if ([_deviceRecords objectForKey:major]) {
            NSMutableDictionary *mutDic = [_deviceRecords objectForKey:major];
            [mutDic setObject:shortId forKey:minor];
        }
        else{
            NSMutableDictionary *mutDic = [[NSMutableDictionary alloc] init];
            [mutDic setObject:shortId forKey:minor];

            [_deviceRecords setObject:mutDic forKey:major];
        }
    }
    
    sqlite3_finalize(statement);
    
    
    //load ansatt info from database
    query = [@"SELECT * FROM " stringByAppendingString:kANSATT_TABLE];
    result = sqlite3_prepare_v2(db, query.UTF8String, -1, &statement, nil);
    if (SQLITE_OK != result){
        NSLog(@"ERROR: Prepare statement for ansatt table failed");
        sqlite3_close(db);
        
        return NO;
    }
    
    while (sqlite3_step(statement) == SQLITE_ROW) {
        NSString *name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
        NSInteger ansattNr = sqlite3_column_int(statement, 2);
        char *cShortId = (char *)sqlite3_column_text(statement, 3);
        NSString *shortId = cShortId == NULL ? NULL : [NSString stringWithUTF8String:cShortId];
        
        Ansatt *ansatt = [[Ansatt alloc] init];
        ansatt.name = name;
        ansatt.num = ansattNr;
        ansatt.shortId = shortId;
        
        [_ansattList addObject:ansatt];
        
        if (shortId)
            [_ansattRecords setObject:ansatt forKey:shortId];
    }
    
    sqlite3_finalize(statement);
    sqlite3_close(db);
    
    return YES;
}


- (NSString *) customerIdByMajor:(NSNumber *)major andMinor:(NSNumber *)minor
{
    //return 157;
    
    NSDictionary *dict = [_deviceRecords objectForKeyedSubscript:major];
    if (dict) {
        NSString *shortId = [dict objectForKeyedSubscript:minor];
        return shortId;
    }
    else
        return NULL;
}


- (NSString *) customerIdByMajor:(NSNumber *)major
{
    NSDictionary *dict = [_deviceRecords objectForKeyedSubscript:major];
    if (dict) {
        for (NSNumber *minor in dict){
            if ([dict objectForKey:minor]) {
                return [dict objectForKey:minor];
            }else{
                return NULL;
            }
        }
        
        return NULL;
    }
    else
        return NULL;
}


- (NSString *) dbFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *pathStr = [paths lastObject];
    
   // NSString *pathStr = [[NSBundle mainBundle] pathForResource:kSQLITE_DB_FILE ofType:@"db"];
    
    pathStr = [[pathStr stringByAppendingPathComponent:kSQLITE_DB_FILE] stringByAppendingString:@".db"];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:pathStr])
        return pathStr;
    else
        return nil;
}


- (BOOL) updateAnsattInfo: (Ansatt *)ansatt
{
    int result = -1;
    if (!gDb) {
        result = sqlite3_open([[self dbFilePath] UTF8String], &gDb);
    
        if (SQLITE_OK != result)
            return NO;
    }
    
    NSString *query = [NSString stringWithFormat:@"UPDATE %@ SET short_id = ? WHERE ansatt_nr = ?", kANSATT_TABLE];
    sqlite3_stmt *stmt;
    
    result = sqlite3_prepare_v2(gDb, query.UTF8String, -1, &stmt, nil);
    if (SQLITE_OK != result) {
        [WLLog logWithLevel:ERROR withTime:nil withContent: [NSString stringWithFormat: @"Initiate sqlite statement failed when update ansatt info. Reason: %s",sqlite3_errmsg(gDb)]];
        return NO;
    }
    
    result = sqlite3_bind_text(stmt, 1, ansatt.shortId.UTF8String, -1, nil);
    if (SQLITE_OK != result) {
        [WLLog logWithLevel:ERROR withTime:nil withContent:[NSString stringWithFormat: @"Data binding failed when update ansatt info, index 1"]];
        sqlite3_finalize(stmt);
        return  NO;
    }

    result = sqlite3_bind_int64(stmt, 2, ansatt.num);
    if (SQLITE_OK != result) {
        [WLLog logWithLevel:ERROR withTime:nil withContent:[NSString stringWithFormat: @"Data binding failed when update ansatt info, index 2"]];
        sqlite3_finalize(stmt);
        return  NO;
    }
    
    result = sqlite3_step(stmt);
    if (SQLITE_DONE != result) {
        [WLLog logWithLevel:ERROR withTime:nil withContent:[NSString stringWithFormat:@"Execute update failed when update ansatt info, Reason: %s", sqlite3_errmsg(gDb)]];
        sqlite3_finalize(stmt);
        return NO;
    }
    
    [WLLog logWithLevel:INFO withTime:nil withContent:[NSString stringWithFormat:@"Update info of Ansatt %ld successfully. ShortId to %@", ansatt.num, ansatt.shortId]];
    sqlite3_finalize(stmt);
    return YES;
}
@end
