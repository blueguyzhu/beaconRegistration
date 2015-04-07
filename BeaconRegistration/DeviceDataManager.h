//
//  DeviceDataManager.h
//  TempusBrukermøte
//
//  Created by Wenlu Zhang on 11/05/14.
//  Copyright (c) 2014 TEMPUS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Ansatt.h"

@interface DeviceDataManager : NSObject

@property (nonatomic, strong) NSMutableDictionary *deviceRecords;
@property (nonatomic, strong) NSMutableDictionary *ansattRecords;
@property (nonatomic, strong) NSMutableArray *ansattList;

+ (DeviceDataManager *) sharedManager;

- (BOOL) loadData;
- (NSString *) customerIdByMajor: (NSNumber *)major andMinor: (NSNumber *)minor;
- (NSString *) customerIdByMajor:(NSNumber *)major;
- (BOOL) updateAnsattInfo: (Ansatt *)ansatt;
@end
