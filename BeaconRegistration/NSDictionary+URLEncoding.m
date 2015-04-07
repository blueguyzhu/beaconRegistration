//
//  NSDictionary+URLEncoding.m
//  TempusBrukermøte
//
//  Created by Wenlu Zhang on 11/05/14.
//  Copyright (c) 2014 TEMPUS. All rights reserved.
//

#import "NSDictionary+URLEncoding.h"

@implementation NSDictionary (UrlEncoding)
static NSString *toString(id object) {
    return [NSString stringWithFormat: @"%@", object];
}

static NSString *urlEncode(id object) {
    NSString *string = toString(object);
    return [string stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
}

-(NSString*) urlEncodedString {
    NSMutableArray *parts = [NSMutableArray array];
    for (id key in self) {
        id value = [self objectForKey: key];
        NSString *part = [NSString stringWithFormat: @"%@=%@", urlEncode(key), urlEncode(value)];
        [parts addObject: part];
    }
    return [parts componentsJoinedByString: @"&"];
}

@end
