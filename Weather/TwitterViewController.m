//
//  TwitterViewController.m
//  Weather
//
//  Created by Albert Pascual on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TwitterViewController.h"

@implementation TwitterViewController

@synthesize weatherDelegate = _weatherDelegate;
@synthesize atSign = _atSign;
@synthesize twitterTitle = _twitterTitle;
@synthesize searchButton = _searchButton;
@synthesize twitterBackground = _twitterBackground;
@synthesize twitterUsername = _twitterUsername;
@synthesize friendsList = _friendsList;
@synthesize tableView = _tableView;
@synthesize activity = _activity;
@synthesize startLookingTimer = _startLookingTimer;
@synthesize banner = _banner;

@synthesize X = _X;
@synthesize Y = _Y;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    self.banner.delegate = self;
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSUserDefaults *myPrefs = [NSUserDefaults standardUserDefaults]; 
    
    if ( [myPrefs objectForKey:@"mytwitterusername"] != nil )
        self.twitterUsername.text = [myPrefs objectForKey:@"mytwitterusername"];
    
    //Social calls
    //http://weather.alsandbox.us/api.aspx?operation=list&username=alpascual
    //http://weather.alsandbox.us/api.aspx?operation=add&username=test1&x=12.2222&y=-12.11111
    
          
    if ( [myPrefs objectForKey:@"friends"] != nil) {
        NSString *myFriends = [myPrefs objectForKey:@"friends"];
        [self parseAndRefresh:myFriends];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)donePressed:(id)sender {
    [self.weatherDelegate DonePressed];
}

- (IBAction)findFriends:(id)sender {
    self.atSign.hidden = NO;
    self.twitterTitle.hidden = NO;
    self.searchButton.hidden = NO;
    self.twitterBackground.hidden = NO;
    self.twitterUsername.hidden = NO;
}




- (IBAction)searchFriendPressed:(id)sender {
    
    self.activity.hidden = NO;
    [self.activity startAnimating];    
    
    self.startLookingTimer = [NSTimer scheduledTimerWithTimeInterval: 0.5 target: self selector: @selector(timerCallback:) userInfo: nil repeats: NO];    
}

- (void)timerCallback:(NSTimer *)timer {
    [self.twitterUsername resignFirstResponder];
    
    if ( self.twitterUsername.text.length > 0 ) {
        // Make request to add the user first and then get the friends
        NSString *myRequestString = [[NSString alloc] initWithFormat:@"http://weather.alsandbox.us/api.aspx?operation=add&username=%@&x=%@&y=%@", self.twitterUsername.text, self.X, self.Y];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:myRequestString]];
        [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        
        // get friends
        NSString *myRequestFriends = [[NSString alloc] initWithFormat:@"http://weather.alsandbox.us/api.aspx?operation=list&username=%@", self.twitterUsername.text];
        NSURLRequest *request2 = [NSURLRequest requestWithURL:[NSURL URLWithString:myRequestFriends]];
        NSData *response2 = [NSURLConnection sendSynchronousRequest:request2 returningResponse:nil error:nil];
        NSString *responseString = [[NSString alloc] initWithData:response2 encoding:NSUTF8StringEncoding];
        
        // save it
        NSUserDefaults *myPrefs = [NSUserDefaults standardUserDefaults];        
        [myPrefs setObject:responseString forKey:@"friends"];
        [myPrefs setObject:self.twitterUsername.text forKey:@"mytwitterusername"];
        [myPrefs synchronize];
        
        [self parseAndRefresh:responseString];
        
        [self.activity stopAnimating];
    }
}

- (void) parseAndRefresh:(NSString *) responseString
{
    // Parse the response
    NSRange firstRange = [responseString rangeOfString:@"|"];
    
    self.friendsList = [[NSMutableArray alloc] init];
    
    if ( firstRange.length > 0 )
    {
        NSArray *chunks = [responseString componentsSeparatedByString: @"|"];
        
        for (NSString *t in chunks) 
        {
            NSRange startRange = [t rangeOfString:@","];
            if ( startRange.length > 0 )
            {
                NSArray *fields = [t componentsSeparatedByString: @","];   
                
                FriendsClass *friend = [[FriendsClass alloc] init];
                friend.Username = [fields objectAtIndex:0];
                friend.X = [fields objectAtIndex:1];
                friend.Y = [fields objectAtIndex:2];
                
                NSLog(@"%@ %@ %@", friend.Username, friend.X, friend.Y);
                
                [self.friendsList addObject:friend];
            }
        }
    }
    
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( self.friendsList != nil )
        return self.friendsList.count;
    
    return 0;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO
    static NSString *CellIdentifier = @"Cell";
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        //cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        //cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    
    NSUInteger row = [indexPath row]; 
    
    FriendsClass *anObject = [self.friendsList objectAtIndex:row];
       
    cell.textLabel.text = anObject.Username;
    
    ReverseGeocoding *reverse = [[ReverseGeocoding alloc] init];       
    NSString *noWhereLabel = [reverse GetAddressFromLatLon:[[NSString alloc] initWithFormat:@"%@", anObject.X] :[[NSString alloc] initWithFormat:@"%@", anObject.Y]];
    
    // Request info
    NSString *myRequestString = [[NSString alloc] initWithFormat:@"http://free.worldweatheronline.com/feed/weather.ashx?q=%@,%@&format=json&num_of_days=5&key=5ac3984a51201927111608", anObject.X, anObject.Y];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:myRequestString]];    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];    
    NSString *JsonString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    
    NSError *error = nil;
    NSDictionary *theDictionary = [NSDictionary dictionaryWithJSONString:JsonString error:&error];    
    NSDictionary *data = [theDictionary objectForKey:@"data"];
    NSArray *currentDictionaty = [data objectForKey:@"current_condition"];    
    NSDictionary *temp = [currentDictionaty objectAtIndex:0];  
    // F tempeture
    NSString *fTempeture = [temp objectForKey:@"temp_F"];
    id weatherDesc = [temp objectForKey:@"weatherDesc"];
    NSDictionary *weatherValues = [weatherDesc objectAtIndex:0];
    // weather type
    NSString *typeOfWeather = [weatherValues objectForKey:@"value"];
    NSArray *arrayUrl = [temp objectForKey:@"weatherIconUrl"];
    NSDictionary *urlDic = [arrayUrl objectAtIndex:0];
    cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[urlDic objectForKey:@"value"]]]];
    
    
    cell.detailTextLabel.numberOfLines = 3;
    // Set the cell like cluody with 34F in 
    cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%@ %@F\n in %@", typeOfWeather, fTempeture, noWhereLabel];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    UIImage *backImage = [UIImage imageNamed:@"UITableSelection.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:backImage];   
    
    cell.backgroundView = imageView;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    
    return 85;
}



- (IBAction)inviteFriends:(id)sender
{
    NSString *myUsername = @"";
    
    NSUserDefaults *myPrefs = [NSUserDefaults standardUserDefaults]; 
    if ( [myPrefs objectForKey:@"mytwitterusername"] != nil )
        myUsername = [myPrefs objectForKey:@"mytwitterusername"];    
    
    TWTweetComposeViewController *twitterView = [[TWTweetComposeViewController alloc] init];
    
    [twitterView setInitialText:[[NSString alloc] initWithFormat:@"Connect with me at Weather with Friends: %@  #weatherfriends http://sprinkleware.com", myUsername]];
    
    [self presentModalViewController:twitterView animated:YES];
}


- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
    // assumes the banner view is at the top of the screen.
    banner.frame = CGRectOffset(banner.frame, 0, -50);
    [UIView commitAnimations];
    
}

@end
