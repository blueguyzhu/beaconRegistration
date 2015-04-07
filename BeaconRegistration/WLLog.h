//
//  WLLog.h
//  BeaconRegistration
//
//  Created by Wenlu Zhang on 24/09/14.
//  Copyright (c) 2014 TEMPUS. All rights reserved.
//

#ifndef BeaconRegistration_WLLog_h
#define BeaconRegistration_WLLog_h


#endif
#import <Foundation/Foundation.h>

@interface WLLog : NSObject

typedef enum {
    DOC = 0,
    DB
} LOG_TYPE;


typedef enum {
    ALL = 0,
    DEV,
    INFO,
    WARN,
    ERROR,
    FALTAL
} LOG_LEVEL;

+ (void) outputToStd: (BOOL)y;
+ (void) setLogDest: (LOG_TYPE) logType;
+ (void) setLogLevel: (LOG_LEVEL) logLevel;
+ (void) logWithLevel: (LOG_LEVEL) logLevel withTime: (NSDate *)time withContent: (NSString *) format, ...;

@end
