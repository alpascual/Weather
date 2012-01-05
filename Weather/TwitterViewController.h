//
//  TwitterViewController.h
//  Weather
//
//  Created by Albert Pascual on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeatherProtocol.h"
#import "FriendsClass.h"
#import "TwitterViewController.h"
#import <Twitter/Twitter.h>
#import "ReverseGeocoding.h"

@interface TwitterViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) id <WeatherProtocol> weatherDelegate;

@property (strong, nonatomic) IBOutlet UILabel *atSign;
@property (strong, nonatomic) IBOutlet UILabel *twitterTitle;
@property (strong, nonatomic) IBOutlet UIButton *searchButton;
@property (strong, nonatomic) IBOutlet UIImageView *twitterBackground;
@property (strong, nonatomic) IBOutlet UITextField *twitterUsername;

@property (strong, nonatomic) NSString *X;
@property (strong, nonatomic) NSString *Y;

@property (strong, nonatomic) NSMutableArray *friendsList;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@property (strong, nonatomic) NSTimer *startLookingTimer;

- (void) threadStartAnimating:(id)data;
- (void) parseAndRefresh:(NSString *) responseString;

@end
