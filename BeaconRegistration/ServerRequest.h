//
//  ServerRequest.h
//  TempusBrukermøte
//
//  Created by Wenlu Zhang on 11/05/14.
//  Copyright (c) 2014 TEMPUS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerRequest : NSObject
+ (BOOL) registerCustomer: (NSDictionary *)userInfo;
+ (BOOL) goodbyeCustomer: (NSDictionary *)userInfo;
+ (BOOL) antallRegIn: (NSDictionary *)regInfo;
@end
