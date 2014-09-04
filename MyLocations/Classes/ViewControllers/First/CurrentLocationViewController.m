//
//  FirstViewController.m
//  MyLocations
//
//  Created by Joe Gesualdo on 9/4/14.
//  Copyright (c) 2014 Joe Gesualdo. All rights reserved.
//

#import "CurrentLocationViewController.h"

@interface CurrentLocationViewController ()
{
  // The CLLocationManager is the object that will give you the GPS coordinates.
  CLLocationManager *_locationManager;
}

@end

@implementation CurrentLocationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

//  This create The CLLocationManager variable we defined above (_locationManager) object.
- (id)initWithCoder:(NSCoder *)aDecoder {
  if ((self = [super initWithCoder:aDecoder])) {
    _locationManager = [[CLLocationManager alloc] init];
  }
  return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getLocation:(id)sender
{
  // tells the location manager that the view controller is its delegate
  _locationManager.delegate = self;
  // tells the location manger that you want locations with an accuracy of up to ten meters.
  _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
  // The new CLLocationManager object doesn’t give out GPS coordinates right away. To begin receiving coordinates, you have to call the startUpdatingLocation method first.
  // from that moment you call startUpdatingLocation it will send location updates to the delegate, i.e. the view controller.
  [_locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate
// These are the delegate methods for the location manager.

// didFailWithError is called when the location manager wasn’t able to obtain a location. The reason why is described by an NSError object, which is the standard object that the iOS SDK uses to convey error information.
//Example Reasons:
//  1) user may have pressed 'Don't allow' Locations
//  2) Happens on the Simulator, because does not have a real GPS (although you can fake it)
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
  NSLog(@"didFailWithError %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
  CLLocation *newLocation = [locations lastObject];
  
  NSLog(@"didUpdateLocations %@", newLocation);
}
@end
