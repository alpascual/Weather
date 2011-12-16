//
//  ViewController.h
//  Weather
//
//  Created by Albert Pascual on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "CJSONDeserializer.h"
#import "NSDictionary_JSONExtensions.h"
#import "WeatherDayClass.h"
#import "InfoViewController.h"

@interface ViewController : UIViewController <CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) CLLocationManager *locMgr;

@property (nonatomic, strong) IBOutlet UILabel *temperatureF;
@property (nonatomic, strong) IBOutlet UILabel *temperatureC;
@property (nonatomic, strong) IBOutlet UILabel *temperatureLow;
@property (nonatomic, strong) IBOutlet UILabel *temperatureHigh;
@property (nonatomic, strong) IBOutlet UILabel *statusMessage;
@property (nonatomic, strong) IBOutlet UIImageView *statusImage;
@property (nonatomic, strong) IBOutlet UIImageView *backgroundImage;

@property (nonatomic, strong) NSMutableArray *listOfDaysClass;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end
