//
//  InfoViewController.h
//  Weather
//
//  Created by Albert Pascual on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeatherProtocol.h"

@interface InfoViewController : UIViewController

@property (strong, nonatomic) id <WeatherProtocol> weatherDelegate;


@end
