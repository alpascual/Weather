//
//  ProcessImageRunner.h
//  Weather
//
//  Created by Albert Pascual on 2/15/13.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ReverseGeocoding.h"
#import "WeatherDayClass.h"

@interface ProcessImageRunner : NSObject

@property (nonatomic,strong) CLLocationManager *locMgr;


- (NSMutableArray *) checkLocation:(CLLocation *)newLocation manager:(CLLocationManager *)locManager list:(NSMutableArray *)listOfDaysClass theX:(NSString*)X theY:(NSString*)Y label:(UILabel *)noWhereLabel F:(UILabel *)temperatureF C:(UILabel*)temperatureC message:(UILabel*) statusMessage image:(UIImageView *)backgroundImage status:(UIImageView *)statusImage low:(UILabel *)temperatureLow high:(UILabel *)temperatureHigh table:(UITableView *)tableView spinner:(UIActivityIndicatorView *)activity;

@end
