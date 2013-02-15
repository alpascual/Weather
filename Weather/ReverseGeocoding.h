//
//  ReverseGeocoding.h
//  Weather
//
//  Created by Albert Pascual on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CJSONDeserializer.h"
#import "NSDictionary_JSONExtensions.h"

@interface ReverseGeocoding : NSObject


- (NSString *) GetAddressFromLatLon:(NSString *)Lat Long:(NSString *)Lon;

@end
