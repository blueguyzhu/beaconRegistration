//
//  ServerRequest.m
//  TempusBrukermøte
//
//  Created by Wenlu Zhang on 11/05/14.
//  Copyright (c) 2014 TEMPUS. All rights reserved.
//
#define kREGISTER_URL       @"http://go.tempus.no/Home/"
#define kREGISTER_QUERY     @"Jobbreg"
#define kLEAVE_QUERY        @"Avslutt"
#define kANTALL_QUERY       @"AntallReg"

#import "ServerRequest.h"

@implementation ServerRequest

+ (BOOL) registerCustomer: (NSDictionary *)userInfo
{
    NSString *urlStr = [[NSString alloc] initWithFormat:@"%@%@?%@", kREGISTER_URL, kREGISTER_QUERY, [userInfo urlEncodedString]];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setTimeoutInterval:10];
    
    NSURLResponse *response;
    NSError *error;

    NSData *postData = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:&response
                                                         error:&error];
    if (error) {
        return NO;
    }
    else {
        NSString *theReply = [[NSString alloc] initWithBytes:[postData bytes] length:[postData length] encoding: NSASCIIStringEncoding];
        NSLog(@"%@", theReply);
        
        return YES;
    }
}


+ (BOOL) goodbyeCustomer: (NSDictionary *)userInfo
{
    NSString *urlStr = [[NSString alloc] initWithFormat:@"%@%@?%@", kREGISTER_URL, kLEAVE_QUERY, [userInfo urlEncodedString]];

    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setTimeoutInterval:10];

    NSURLResponse *response;
    NSError *error;
    
    NSData *postData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error) {
        return NO;
    }
    else {
        NSString *theReply = [[NSString alloc] initWithBytes:[postData bytes] length:[postData length] encoding:NSASCIIStringEncoding];
        NSLog(@"%@", theReply);
        
        return YES;
    }
}


+ (BOOL) antallRegIn: (NSDictionary *)regInfo
{
    NSString *urlStr = [[NSString alloc] initWithFormat:@"%@%@?%@", kREGISTER_URL, kANTALL_QUERY, [regInfo urlEncodedString]];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forKey:@"Content-Type"];
    [request setTimeoutInterval:10];
    
    NSURLResponse *response;
    NSError *error;
    
    NSData *postData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error) {
        return NO;
    }
    else {
        NSString *theReply = [[NSString alloc] initWithBytes:[postData bytes] length:[postData length] encoding:NSASCIIStringEncoding];
        NSLog(@"%@", theReply);
        
        return YES;
    }
}
@end
