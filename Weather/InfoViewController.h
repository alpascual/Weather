//
//  InfoViewController.h
//  Weather
//
//  Created by Albert Pascual on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iAd/ADBannerView.h"

#import "WeatherProtocol.h"


@interface InfoViewController : UIViewController <ADBannerViewDelegate>

@property (strong, nonatomic) id <WeatherProtocol> weatherDelegate;
@property (strong, nonatomic) IBOutlet ADBannerView *banner;
@property (strong, nonatomic) IBOutlet UISwitch *lockEnabled;


@end
