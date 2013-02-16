//
//  ProcessImageRunner.m
//  Weather
//
//  Created by Albert Pascual on 2/15/13.
//
//

#import "ProcessImageRunner.h"

@implementation ProcessImageRunner

- (NSMutableArray *) checkLocation:(CLLocation *)newLocation manager:(CLLocationManager *)locManager list:(NSMutableArray *)listOfDaysClass theX:(NSString*)X theY:(NSString*)Y label:(UILabel *)noWhereLabel F:(UILabel *)temperatureF C:(UILabel*)temperatureC message:(UILabel*) statusMessage image:(UIImageView *)backgroundImage status:(UIImageView *)statusImage low:(UILabel *)temperatureLow high:(UILabel *)temperatureHigh table:(UITableView *)tableView spinner:(UIActivityIndicatorView *)activity
{
    NSTimeInterval ageInSeconds = [newLocation.timestamp timeIntervalSinceNow];
    
    //ensure you have an accurate and non-cached reading in meters 500 and in seconds 10
    if( newLocation.horizontalAccuracy > 500.0 || fabs(ageInSeconds) > 10 )
        return nil;
    
    self.locMgr = locManager;
    //this puts the GPS to sleep, saving power
    [self.locMgr stopUpdatingLocation];
    self.locMgr = nil;
    if ( listOfDaysClass != nil )
        return nil;
    
    // Save X and Y
    X = [[NSString alloc] initWithFormat:@"%f", newLocation.coordinate.latitude];
    Y = [[NSString alloc] initWithFormat:@"%f", newLocation.coordinate.longitude];
    
    ReverseGeocoding *reverse = [[ReverseGeocoding alloc] init];
    noWhereLabel.text = [reverse GetAddressFromLatLon:X Long:Y];
    
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
    
    temperatureF.text = [temp objectForKey:@"temp_F"];
    temperatureC.text = [temp objectForKey:@"temp_C"];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[temperatureF.text intValue]];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = [temperatureF.text intValue];
    
    id weatherDesc = [temp objectForKey:@"weatherDesc"];
    NSDictionary *weatherValues = [weatherDesc objectAtIndex:0];
    statusMessage.text = [weatherValues objectForKey:@"value"];
    
    NSLog(@"Status String: %@", statusMessage.text);
    NSString *weatherCode = [temp objectForKey:@"weatherCode"];
    int iWeatherCode = [weatherCode intValue];
    
    // Mist and Cloudy
    if ( iWeatherCode < 200 ) {
        backgroundImage.image = [UIImage imageNamed:@"clouds.jpg"];
        
    }
    // Snow and Freezing
    else if ( iWeatherCode < 300 ) {
        backgroundImage.image = [UIImage imageNamed:@"winter.jpg"];
    }
    // Rain
    else if ( iWeatherCode < 400 ) {
        backgroundImage.image = [UIImage imageNamed:@"rain.jpg"];
    }
    // Sunny?
    else
    {
        backgroundImage.image = [UIImage imageNamed:@"spring.jpg"];
    }
    
    
    
    NSArray *arrayUrl = [temp objectForKey:@"weatherIconUrl"];
    NSDictionary *urlDic = [arrayUrl objectAtIndex:0];
    statusImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[urlDic objectForKey:@"value"]]]];
    
    // Parsing every day
    NSArray *weather = [data objectForKey:@"weather"];
    
    NSDictionary *todayDic = [weather objectAtIndex:0];
    temperatureHigh.text = [[NSString alloc] initWithFormat:@"Max %@F", [todayDic objectForKey:@"tempMaxF"]];
    temperatureLow.text = [[NSString alloc] initWithFormat:@"Min %@F", [todayDic objectForKey:@"tempMinF"]];
    
    // Create a Array with a custom class for that
    listOfDaysClass = [[NSMutableArray alloc] initWithCapacity:weather.count];
    
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
        
        [listOfDaysClass addObject:weatherItem];
    }
    
    //[tableView reloadData];
    [activity stopAnimating];
    
    return listOfDaysClass;
}

@end
