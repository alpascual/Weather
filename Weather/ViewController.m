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
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ( [defaults objectForKey:@"lockscreenenable"] == nil) {
        [defaults setObject:@"YES" forKey:@"lockscreenenable"];
        [defaults synchronize];
    }
    
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
    
    //TODO
    ProcessImageRunner *process = [[ProcessImageRunner alloc] init];
    self.listOfDaysClass = [process checkLocation:newLocation manager:manager list:self.listOfDaysClass theX:self.X theY:self.Y label:self.noWhereLabel F:self.temperatureF C:self.temperatureC message:self.statusMessage image:self.backgroundImage status:self.statusImage low:self.temperatureLow high:self.temperatureHigh table:self.tableView spinner:self.activity];
    
    [self.tableView reloadData];
    
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
