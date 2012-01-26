//
//  ViewController.m
//  Weather
//
//  Created by Albert Pascual on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize locMgr = _locMgr;
@synthesize temperatureC = _temperatureC;
@synthesize temperatureF = _temperatureF;
@synthesize temperatureLow = _temperatureLow;
@synthesize temperatureHigh = _temperatureHigh;
@synthesize statusMessage = _statusMessage;
@synthesize statusImage = _statusImage;
@synthesize listOfDaysClass = _listOfDaysClass;
@synthesize tableView = _tableView;
@synthesize noWhereLabel = _noWhereLabel;
@synthesize backgroundImage = _backgroundImage;
@synthesize banner = _banner;
@synthesize activity = _activity;

@synthesize X = _X;
@synthesize Y = _Y;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.locMgr = [[CLLocationManager alloc] init]; // Create new instance of locMgr
    self.locMgr.delegate = self; // Set the delegate as self.
    
    [self.locMgr startUpdatingLocation];
	
    //Social calls
    //http://weather.alsandbox.us/api.aspx?operation=list&username=alpascual
    //http://weather.alsandbox.us/api.aspx?operation=add&username=test1&x=12.2222&y=-12.11111
    
    self.banner.delegate = self;
   
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}


// Get the GPS
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation 
{
    
    NSTimeInterval ageInSeconds = [newLocation.timestamp timeIntervalSinceNow];
    
    //ensure you have an accurate and non-cached reading in meters 500 and in seconds 10
    if( newLocation.horizontalAccuracy > 500.0 || fabs(ageInSeconds) > 10 )
        return;
    
    //this puts the GPS to sleep, saving power
    [self.locMgr stopUpdatingLocation]; 
    self.locMgr = nil;
    if ( self.listOfDaysClass != nil )
        return;
    
    // Save X and Y
    self.X = [[NSString alloc] initWithFormat:@"%f", newLocation.coordinate.latitude];
    self.Y = [[NSString alloc] initWithFormat:@"%f", newLocation.coordinate.longitude];
    
    ReverseGeocoding *reverse = [[ReverseGeocoding alloc] init];
    self.noWhereLabel.text = [reverse GetAddressFromLatLon:self.X :self.Y];
    
    // Make request
    //Powered by World Weather Online
    NSString *myRequestString = [[NSString alloc] initWithFormat:@"http://free.worldweatheronline.com/feed/weather.ashx?q=%f,%f&format=json&num_of_days=5&key=5ac3984a51201927111608", newLocation.coordinate.latitude, newLocation.coordinate.longitude];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:myRequestString]];
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    NSString *JsonString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    
    NSError *error = nil;
    NSDictionary *theDictionary = [NSDictionary dictionaryWithJSONString:JsonString error:&error];
    
    NSDictionary *data = [theDictionary objectForKey:@"data"];
    NSArray *currentDictionaty = [data objectForKey:@"current_condition"];
    
    NSDictionary *temp = [currentDictionaty objectAtIndex:0];
    
    self.temperatureF.text = [temp objectForKey:@"temp_F"];
    self.temperatureC.text = [temp objectForKey:@"temp_C"];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[self.temperatureF.text intValue]];    
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = [self.temperatureF.text intValue];
    
    id weatherDesc = [temp objectForKey:@"weatherDesc"];
    NSDictionary *weatherValues = [weatherDesc objectAtIndex:0];
    self.statusMessage.text = [weatherValues objectForKey:@"value"];
    
    NSLog(@"Status String: %@", self.statusMessage.text);
    NSString *weatherCode = [temp objectForKey:@"weatherCode"];
    int iWeatherCode = [weatherCode intValue];
    
    // Mist and Cloudy
    if ( iWeatherCode < 200 ) {
        self.backgroundImage.image = [UIImage imageNamed:@"clouds.jpg"];
        
    }
    // Snow and Freezing
    else if ( iWeatherCode < 300 ) {
        self.backgroundImage.image = [UIImage imageNamed:@"winter.jpg"];
    }
    // Rain
    else if ( iWeatherCode < 400 ) {
        self.backgroundImage.image = [UIImage imageNamed:@"rain.jpg"];
    }
    // Sunny?
    else
    {
        self.backgroundImage.image = [UIImage imageNamed:@"spring.jpg"];
    }
        
    
    
    NSArray *arrayUrl = [temp objectForKey:@"weatherIconUrl"];
    NSDictionary *urlDic = [arrayUrl objectAtIndex:0];
    self.statusImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[urlDic objectForKey:@"value"]]]];
    
    // Parsing every day
    NSArray *weather = [data objectForKey:@"weather"];
    
    NSDictionary *todayDic = [weather objectAtIndex:0];
    self.temperatureHigh.text = [[NSString alloc] initWithFormat:@"Max %@F", [todayDic objectForKey:@"tempMaxF"]];
    self.temperatureLow.text = [[NSString alloc] initWithFormat:@"Min %@F", [todayDic objectForKey:@"tempMinF"]];
    
    // Create a Array with a custom class for that
    self.listOfDaysClass = [[NSMutableArray alloc] initWithCapacity:weather.count];  
    
    for ( int i=0; i< weather.count; i++) {
        NSDictionary *item = [weather objectAtIndex:i];
        WeatherDayClass *weatherItem = [[WeatherDayClass alloc] init];
        weatherItem.dateString = [item objectForKey:@"date"];
        weatherItem.precip = [item objectForKey:@"precipMM"];
        weatherItem.tempMaxC = [item objectForKey:@"tempMaxC"];
        weatherItem.tempMaxF = [item objectForKey:@"tempMaxF"];
        weatherItem.tempMinC = [item objectForKey:@"tempMinC"];
        weatherItem.tempMinF = [item objectForKey:@"tempMinF"];
        weatherItem.weatherCode = [item objectForKey:@"weatherCode"];
        
        NSArray *weatherDescItem = [item objectForKey:@"weatherDesc"];
        NSDictionary *weatherValues = [weatherDescItem objectAtIndex:0];
        weatherItem.weatherDescription = [weatherValues objectForKey:@"value"]; 
        
        NSArray *arrayUrl = [item objectForKey:@"weatherIconUrl"];
        NSDictionary *urlDic = [arrayUrl objectAtIndex:0];
        weatherItem.weatherIconUrl = [urlDic objectForKey:@"value"];
        
        [self.listOfDaysClass addObject:weatherItem];
    }
    
    [self.tableView reloadData];
    [self.activity stopAnimating];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listOfDaysClass.count;
}


// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Trying to return cell");
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
    }
    
    NSUInteger row = [indexPath row]; 
    
    WeatherDayClass *anItem = [self.listOfDaysClass objectAtIndex:row];
       
    cell.textLabel.text = [[NSString alloc] initWithFormat:@"High %@°F  Low %@°F", anItem.tempMaxF, anItem.tempMinF];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%@ %@", [anItem dateString], anItem.weatherDescription];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    cell.textLabel.numberOfLines = 5;
    
    // If extra information available then display this.
    /*if ([[self.resultData objectAtIndex:indexPath.row] objectForKey:@"details"]) {
     cell.detailTextLabel.text = [self.friendsNames objectAtIndex:indexPath.row];
     cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
     cell.detailTextLabel.lineBreakMode = UILineBreakModeCharacterWrap;
     cell.detailTextLabel.numberOfLines = 2;
     }*/
    // The object's image
    
    cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:anItem.weatherIconUrl]]];
    
    NSLog(@"Url or the icon %@", anItem.weatherIconUrl);
    
    UIImage *backImage = [UIImage imageNamed:@"MovieTransportBackground.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:backImage];   
    
    cell.backgroundView = imageView;
    
    //cell.textLabel.text = anObject;
    
    NSLog(@"Returning cell");
    return cell;
}

- (IBAction)twitterPress:(id)sender {
    
    TwitterViewController *twitter = [[TwitterViewController alloc] initWithNibName:@"TwitterViewController" bundle:nil];
    twitter.X = self.X;
    twitter.Y = self.Y;
    
    twitter.weatherDelegate = self;
    twitter.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [self presentModalViewController:twitter animated:YES];
}

- (IBAction)infoPressed:(id)sender {
    
    InfoViewController  *info = [[InfoViewController alloc] initWithNibName:@"InfoViewController" bundle:nil];
    
    info.weatherDelegate = self;
    
    info.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [self presentModalViewController:info animated:YES];
}

-(void) DonePressed
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
    // assumes the banner view is at the top of the screen.
    banner.frame = CGRectOffset(banner.frame, 0, -50);
    [UIView commitAnimations];
    
}

@end
