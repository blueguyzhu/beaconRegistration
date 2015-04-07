//
//  WLLog.m
//  BeaconRegistration
//
//  Created by Wenlu Zhang on 24/09/14.
//  Copyright (c) 2014 TEMPUS. All rights reserved.
//

#include "WLLog.h"



@interface WLLog ()
@end

@implementation WLLog
static bool gStdOutput = false;
static LOG_TYPE gLogType = DOC;
static LOG_LEVEL gLogLevel = FALTAL;
static NSString *gLogFileName = @"WL_log.log";


+ (void) outputToStd: (BOOL)y
{
    gStdOutput = y;
}

+ (void) setLogDest:(LOG_TYPE)logType
{
    gLogType = logType;
}


+ (void) setLogLevel:(LOG_LEVEL)logLevel
{
    gLogLevel = logLevel;
}


+ (void) logWithLevel:(LOG_LEVEL)logLevel withTime:(NSDate *)time withContent:(NSString *)format, ...
{
    if (logLevel < gLogLevel)
        return;
    
    static NSArray *depictor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        	depictor =  @[@"ALL",
                          @"DEBUG",
                          @"INFO",
                          @"WARN",
                          @"ERROR",
                          @"FATAL"
                          ];
    });
    
    NSString *path = nil;
    NSDate *logDate = time;
    if (!logDate)
        logDate = [NSDate date];
    
    if (DOC == gLogType) {
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        path = [paths objectAtIndex:0];
        path = [path stringByAppendingPathComponent:gLogFileName];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            if (![[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil])
                NSLog(@"Create log file %@ failed", path);
        }
    }else if (DB == gLogType) {
        
    }else
        return;
    
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [dateFormater stringFromDate:logDate];
    
    va_list args;
    va_start(args, format);
    NSString *str = [[NSString alloc] initWithFormat:format arguments:args];
    
    if (gStdOutput)
        NSLog(@"%@", str);
    
    if (DB == gLogType) {
        
    }else {
        NSString *content = [NSString stringWithFormat:@"%@\t\t%@", dateStr, str];
        content = [[depictor objectAtIndex:logLevel] stringByAppendingFormat:@" :: %@", content];
        NSFileHandle *handler = [NSFileHandle fileHandleForUpdatingAtPath:path];
        [handler seekToEndOfFile];
        [handler writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
        [handler closeFile];
    }
}

@end
