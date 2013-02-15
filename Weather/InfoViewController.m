//
//  InfoViewController.m
//  Weather
//
//  Created by Albert Pascual on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "InfoViewController.h"

@implementation InfoViewController

@synthesize weatherDelegate = _weatherDelegate;
@synthesize banner = _banner;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
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
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Information";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *stringValue = [defaults objectForKey:@"lockscreenenable"];
    NSLog(@"%@", stringValue);

    if ( [stringValue isEqualToString:@"YES"] == YES)
        [self.lockEnabled setOn:YES];
    else
        [self.lockEnabled setOn:NO];
    
    self.banner.delegate = self;
}

- (IBAction)changeSwitch:(id)sender
{
    UISwitch *lockEnabledSwitch = (UISwitch*)sender;
    
    NSString *stringValue = @"NO";
    if ( lockEnabledSwitch.isOn == YES)
        stringValue = @"YES";
    
    NSLog(@"value %@", stringValue);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:stringValue forKey:@"lockscreenenable"];
    [defaults synchronize];
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

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
    // assumes the banner view is at the top of the screen.
    banner.frame = CGRectOffset(banner.frame, 0, -50);
    [UIView commitAnimations];
    
}

@end
