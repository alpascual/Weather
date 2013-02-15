//
//  ReverseGeocoding.m
//  Weather
//
//  Created by Albert Pascual on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ReverseGeocoding.h"

@implementation ReverseGeocoding


- (NSString *) GetAddressFromLatLon:(NSString *)Lat Long:(NSString *)Lon;
{
    //http://maps.googleapis.com/maps/api/geocode/json?latlng=40.714224,-73.961452&sensor=true
    
    NSString *myRequestFriends = [[NSString alloc] initWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%@,%@&sensor=true", Lat,Lon];
    NSURLRequest *request2 = [NSURLRequest requestWithURL:[NSURL URLWithString:myRequestFriends]];
    NSData *response2 = [NSURLConnection sendSynchronousRequest:request2 returningResponse:nil error:nil];
    NSString *responseString = [[NSString alloc] initWithData:response2 encoding:NSUTF8StringEncoding];
    
    NSLog(@" Response %@", responseString);
    
    NSError *error = nil;
    NSDictionary *theDictionary = [NSDictionary dictionaryWithJSONString:responseString error:&error];
    NSLog(@"dictionary %@", theDictionary);
    
    NSArray *data2 = [theDictionary objectForKey:@"results"];
    NSLog(@"Data %@ and count %d", data2, data2.count);
    
    int numberObject = data2.count - 1;
    
    NSDictionary *currentDictionaty = [data2 objectAtIndex:numberObject];
    
    NSString  *myAddress = [currentDictionaty objectForKey:@"formatted_address"];
    NSLog(@"Address %@", myAddress);
    
    return myAddress;
    
}
@end
