//
//  WeatherDayClass.h
//  Weather
//
//  Created by Al Pascual on 12/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeatherDayClass : NSObject

@property (strong, nonatomic) NSString *dateString;
@property (strong, nonatomic) NSString *precip;
@property (strong, nonatomic) NSString *tempMaxC;
@property (strong, nonatomic) NSString *tempMaxF;
@property (strong, nonatomic) NSString *tempMinC;
@property (strong, nonatomic) NSString *tempMinF;
@property (strong, nonatomic) NSString *weatherCode;
@property (strong, nonatomic) NSString *weatherDescription;
@property (strong, nonatomic) NSString *weatherIconUrl;


@end
