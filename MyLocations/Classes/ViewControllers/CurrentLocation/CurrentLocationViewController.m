//
//  FirstViewController.m
//  MyLocations
//
//  Created by Joe Gesualdo on 9/4/14.
//  Copyright (c) 2014 Joe Gesualdo. All rights reserved.
//

#import "CurrentLocationViewController.h"
#import "LocationDetailsViewController.h"

@interface CurrentLocationViewController () <UITabBarControllerDelegate>

@end

@implementation CurrentLocationViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self updateLabels];
  [self configureGetButton];
  // Do any additional setup after loading the view, typically from a nib.
  
  // tell the tab bar that the view controller is its delegate
  self.tabBarController.delegate = self;
  self.tabBarController.tabBar.translucent = NO;
}

//  This create The CLLocationManager property  and CLGeoder property
- (id)initWithCoder:(NSCoder *)aDecoder {
  if ((self = [super initWithCoder:aDecoder])) {
    self.locationManager = [[CLLocationManager alloc] init];
    self.geocoder = [[CLGeocoder alloc]init];
  }
  return self;
}

#pragma mark - Segue

  // When the segue is performed, the coordinate and address should be given to the Tag Location screen.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  // obtain the proper destination view controller and then set its properties.
  if ([segue.identifier isEqualToString:@"TagLocation"]) {
    UINavigationController *navigationController =
        segue.destinationViewController;
    LocationDetailsViewController *controller =
        (LocationDetailsViewController *)navigationController.topViewController;
    controller.coordinate = self.location.coordinate;
    controller.placemark = self.placemark;
    controller.managedObjectContext = self.managedObjectContext;
  }
}

#pragma mark - IBOutlets

- (void)getLocation:(id)sender {
  
  if (self.updatingLocation) {
    [self stopLocationManager];
  } else {
    self.location = nil;
    self.lastLocationError = nil;
    self.placemark = nil;
    self.lastGeocodingError = nil;
    
    [self startLocationManager];
  }
  
  [self updateLabels];
  [self configureGetButton];
}

#pragma mark - UIMethods

// If there is a location object (self.location is not nil) then this converts
// the latitude and longitude, which are values with datatype double, into
// strings and put them into the labels.
- (void)updateLabels {
  if (self.location != nil) {
    // The %.8f format specifier in stringWithFormat does the same thing as the
    // %f that you’ve seen earlier: it takes a decimal number and puts it in the
    // string. The .8 part means that there should always be 8 digits behind the
    // decimal point.
    self.latitudeLabel.text =
        [NSString stringWithFormat:@"%.8f", self.location.coordinate.latitude];
    self.longitudeLabel.text =
        [NSString stringWithFormat:@"%.8f", self.location.coordinate.longitude];
    self.tagButton.hidden = NO;
    self.messageLabel.text = @"";
    
    // Nest this in (self.location !=nil) because you only do the address lookup once the app has a location
    if (self.placemark != nil) {
      self.addressLabel.text = [self stringFromPlacemark:
                                self.placemark];
    } else if (self.performingReverseGeocoding) { self.addressLabel.text = @"Searching for Address...";
    } else if (self.lastGeocodingError != nil) { self.addressLabel.text = @"Error Finding Address";
    } else {
      self.addressLabel.text = @"No Address Found";
    }
  } else {
    // This else statement determines what to put in the messageLabel at the top
    // of the screen. It uses a bunch of if-statements to figure out what the
    // current status of the app is.
    self.latitudeLabel.text = @"";
    self.longitudeLabel.text = @"";
    self.addressLabel.text = @"";
    self.tagButton.hidden = YES;
    NSString *statusMessage;
    if (self.lastLocationError != nil) {
      if ([self.lastLocationError.domain isEqualToString:kCLErrorDomain] &&
          self.lastLocationError.code == kCLErrorDenied) {
        statusMessage = @"Location Services Disabled";
      } else {
        statusMessage = @"Error Getting Location";
      }
    } else if (![CLLocationManager locationServicesEnabled]) {
      statusMessage = @"Location Services Disabled";
    } else if (self.updatingLocation) {
      statusMessage = @"Searching...";
    } else {
      statusMessage = @"Press the Button to Start";
    }
    self.messageLabel.text = statusMessage;
  }
}

- (void)configureGetButton {
  if (self.updatingLocation) {
    [self.getButton setTitle:@"Stop" forState:UIControlStateNormal];
  } else {
    [self.getButton setTitle:@"Get My Location" forState:UIControlStateNormal];
  }
}

#pragma mark - starting/stoping location manger

- (void)startLocationManager {
  if ([CLLocationManager locationServicesEnabled]) {

    // tells the location manager that the view controller is its delegate

    self.locationManager.delegate = self;

    // tells the location manger that you want locations with an accuracy of up
    // to ten meters.

    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;

    // The new CLLocationManager object doesn’t give out GPS coordinates right
    // away. To begin receiving coordinates, you have to call the
    // startUpdatingLocation method first.
    // from that moment you call startUpdatingLocation it will send location
    // updates to the delegate, i.e. the view controller.

    [self.locationManager startUpdatingLocation];
    self.updatingLocation = YES;
    
    // schedules the operating system to send the didTimeOut: message to self after 60 seconds. didTimeOut: is of course the name of a method that you have to provide.
    [self performSelector:@selector(didTimeOut:) withObject:nil afterDelay:60];
  }
}

// To conserve battery power the app really should power down the iPhone’s
// radios as soon as it doesn’t need them anymore. If obtaining a location
// appears to be impossible for wherever the user currently is, then you’ll tell
// the location manager to stop.
- (void)stopLocationManager {
  // checks whether the boolean variable updatingLocation is YES or NO. If it is
  // NO, then the location manager wasn’t currently active and there’s no need
  // to stop it. The reason for having this _updatingLocation variable is that
  // you are going to change the appearance of the Get My Location button and
  // the status message label when the app is trying to obtain a location fix,
  // to let the user know the app is working on it.
  if (self.updatingLocation) {
    // Just as you scheduled the call to didTimeOut: from startLocationManager, you have to cancel this call from stopLocationManager just in case the location manager is stopped before the time-out fires
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(didTimeOut:) object:nil];
    
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
    self.updatingLocation = NO;
    NSLog(@"location manager has been stopped");
  }
}

#pragma mark - Helpers

- (void)didTimeOut:(id)obj {
  NSLog(@"*** Time out"); if (self.location == nil) {
    [self stopLocationManager];
    
    // error’s domain is not kCLErrorDomain because this error object does not come from Core Location but from within your own app. A domain is simply a string, so @"MyLocationsErrorDomain" will do. For the code I picked 1. The value of code doesn’t really matter at this point because you only have one custom error
    self.lastLocationError = [NSError errorWithDomain: @"MyLocationsErrorDomain" code:1 userInfo:nil];
    
    [self updateLabels];
    [self configureGetButton]; }
}

// TODO: This is duplicated code (also located in LocationDetailsViewController. Refactor method into a seperate class
- (NSString *)stringFromPlacemark:(CLPlacemark *)thePlacemark {
  // subThoroughfare    -- is the house number
  // thoroughfare       -- is the street name
  // locality           -- is the city
  // administrativeArea -- is the state or province
  // postalCode         -- is the zip code or postal code.
  
  
  // Create a mutable string object with room for 100 characters, initially. The string will expand to make more room if necessary.
  NSMutableString *line1 = [NSMutableString stringWithCapacity:100];

  // NSMutableString is a subclass of NSString, so all the regular NSString methods can be used here too, but appendString is new (there is also an appendFormat). If the placemark has a subThoroughfare, you add it to the string.
  if (thePlacemark.subThoroughfare != nil) {
    [line1 appendString:thePlacemark.subThoroughfare];
  }
  // Adding the thoroughfare is done similarly, but you also put a space between it and subThoroughfare so they don’t get glued together. If there was no subThoroughfare in the placemark, then you don’t want to add that space.
  if (thePlacemark.thoroughfare != nil) {
    if ([line1 length] > 0) {
      [line1 appendString:@" "];
    }
    [line1 appendString:thePlacemark.thoroughfare];
  }
  // The same logic goes for the second line. This adds the locality, administrative area, and postal code, with spaces between them where appropriate.
  NSMutableString *line2 = [NSMutableString stringWithCapacity:100];
  if (thePlacemark.locality != nil) {
    [line2 appendString:thePlacemark.locality];
  }
  if (thePlacemark.administrativeArea != nil) {
    if ([line2 length] > 0) {
      [line2 appendString:@" "];
    }
    [line2 appendString:thePlacemark.administrativeArea];
  }
  if (thePlacemark.postalCode != nil) {
    if ([line2 length] > 0) {
      [line2 appendString:@" "];
    }
    [line2 appendString:thePlacemark.postalCode];
  }
  // Finally, the two lines are concatenated (added together) with a newline character in between.
  [line1 appendString:@"\n"];
  [line1 appendString:line2];
  return line1;
}

#pragma mark - CLLocationManagerDelegate
// These are the delegate methods for the location manager.

// didFailWithError is called when the location manager wasn’t able to obtain a
// location. The reason why is described by an NSError object, which is the
// standard object that the iOS SDK uses to convey error information.
// Example Reasons:
//  1) user may have pressed 'Don't allow' Locations
//  2) Happens on the Simulator, because does not have a real GPS (although you
//  can fake it)
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
  NSLog(@"didFailWithError %@", error);
  // The kCLErrorLocationUnknown error means the location manager was unable to
  // obtain a location right now, but that doesn’t mean all is lost. It might
  // just need another second or so to get an uplink to the GPS satellite. In
  // the mean time it’s letting you know that for now it could not get any
  // location information. When you get this error, you will simply keep trying
  // until you do find a location or receive a more serious error.
  // So if we get a kCLErrorLocationUnknow, we return and try again, we don't
  // execute the methods below
  if (error.code == kCLErrorLocationUnknown) {
    return;
  }
  // If we get an error that is other thatn kCErrorLocationunknow, the the
  // following method are executed

  // To conserve battery power the app really should power down the iPhone’s
  // radios as soon as it doesn’t need them anymore. If obtaining a location
  // appears to be impossible for wherever the user currently is, then you’ll
  // tell the location manager to stop.
  [self stopLocationManager];
  //  store the error object into a new instance variable, lastLocationError.
  //  That way, you can look up later what kind of error you were dealing with.
  self.lastLocationError = error;

  [self updateLabels];
  [self configureGetButton];
}

// didUpdateLocations is called when the location manager was successfully able
// to obtain a location
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
  // didUpdateLocations delegate method gives you an array of CLLocation objects
  // that contain the current latitude and longitude coordinates of the user.
  // (These objects also have some additional information, such as the altitude
  // and speed, but you don’t use those in this app.)
  // You’ll take the last CLLocation object from the array – because that is the
  // most recent update – and display its coordinates in the labels that you added
  // to the screen earlier.
  
  CLLocation *newLocation = [locations lastObject];

  NSLog(@"didUpdateLocations %@", newLocation);
  NSLog(@"horizontalAccuracy -- %f\ntimeintervalSinceNow -- %f\n", newLocation.horizontalAccuracy, [newLocation.timestamp timeIntervalSinceNow]);

  // If the time at which the location object was determined is too long ago (5
  // seconds in this case), then this is a so-called cached result. Instead of
  // returning a new location fix, the location manager may initially give you
  // the most recently found location under the assumption that you might not
  // have moved much since last time (obviously this does not take into
  // consideration people with jet packs). You’ll simply ignore these cached
  // locations if they are too old.
  if ([newLocation.timestamp timeIntervalSinceNow] < -5.0) {
    return;
  }

  // You’re going to be using the horizontalAccuracy property of the location to
  // determine whether new readings are more accurate than previous ones.
  // However, sometimes locations may have a horizontalAccuracy that is less
  // than 0, in which case these measurements are invalid and you should ignore
  // them.
  if (newLocation.horizontalAccuracy < 0) {
    return;
  }
  
  // This calculates the distance between the new reading and the previous reading, if there was one. If there was no previous reading, then the distance is MAXFLOAT. That is a built-in constant that represents the maximum value that a floating-point number can have. This little trick gives it a gigantic distance if this is the very first reading. You’re doing that so any of the following calculations still work even if you weren’t able to calculate a true distance yet.
  CLLocationDistance distance = MAXFLOAT;
  if (self.location != nil) {
    distance = [newLocation distanceFromLocation:self.location];
  }
  
  // This is where you determine if the new reading is more useful than the
  // previous one. Generally speaking, Core Location starts out with a fairly
  // inaccurate reading and then gives you more and more accurate ones as time
  // passes. However, there are no guarantees here so you cannot assume that the
  // next reading truly is always more accurate.
  // Note that a larger accuracy value actually means less accurate – after all,
  // accurate up to 100 meters is worse than accurate up to 10 meters.
  if (self.location == nil ||
      self.location.horizontalAccuracy > newLocation.horizontalAccuracy) {
    // clear out the old error state. If you receive a valid coordinate, then
    // whatever previous error you may have encountered is no longer
    // applicable.
    self.lastLocationError = nil;
    self.location = newLocation;
    [self updateLabels];

    // If the new location’s accuracy is equal to or better than the desired
    // accuracy then you call it a day and you stop asking the location manager
    // for updates. When you started the location manager in
    // startLocationManager, you set the desired accuracy to 10 meters
    // (kCLLocationAccuracyNearestTenMeters), which is good enough for this
    // app.
    if (newLocation.horizontalAccuracy <=
                self.locationManager.desiredAccuracy) {
      NSLog(@"*** We're done!");
      [self stopLocationManager];
      [self configureGetButton];
      
      // This forces a reverse geocoding even if the app is already currently performing another geocoding request. Of course, if distance is 0, then this location is the same as the location from a previous reading and you don’t need to reverse geocode it anymore.
      // This is done because you absolutely want the address for that final location, as that is the most accurate location you’ve found. But if some previous location was still being reverse geocoded, that step would normally be skipped. Simply by setting _performingReverseGeocoding to NO, you always force the geocoding to be done for this final coordinate.
      if (distance > 0) {
        self.performingReverseGeocoding = NO;
      }
    }
    //the app should only perform a single request at a time, so first you check whether it is not busy yet
    if (!self.performingReverseGeocoding) {
      NSLog(@"*** Going to geocode");
      // start the geocoding
      self.performingReverseGeocoding = YES;
      // CLGeocoder does not use a delegate to tell you about the result, but rather a block.
      // give it the block. Inside the block, the first thing you do is an NSLog() just so you can see what is going on.
      [self.geocoder reverseGeocodeLocation:self.location
                completionHandler:^(NSArray *placemarks, NSError *error) {
                    NSLog(@"*** Found placemarks: %@, error: %@", placemarks,
                          error);
                  // store the error object so you can refer to it later,
                    self.lastGeocodingError = error;
                    if (error == nil && [placemarks count] > 0) {
                      // If there is no error and there are objects inside the placemarks array, then you take the last one. Usually there will be only one CLPlacemark object in the array but there is the odd situation where one location coordinate may refer to more than one address. This app can only handle one address, so you’ll just pick the last one (which usually is the only one).
                      self.placemark = [placemarks lastObject];
                    } else {
                      // If there was an error, you set _placemark to nil.
                      self.placemark = nil;
                    }
                    self.performingReverseGeocoding = NO;
                    [self updateLabels];
                }];
    }
    // If the coordinate from this reading is not significantly different from the previous reading and it has been more than 10 seconds since you’ve received that original reading, then it’s a good point to hang up your hat and stop. It’s safe to assume you’re not going to get a better coordinate than this and you stop fetching the location.
    // This is the improvement that was necessary to make my iPod touch stop. It wouldn’t give me a location with better accuracy than +/- 100 meters but it kept repeating the same one over and over. I picked a time limit of 10 seconds because that seemed to give good results.
  } else if (distance < 1.0) {
    NSTimeInterval timeInterval = [newLocation.timestamp timeIntervalSinceDate:self.location.timestamp];
     if (timeInterval > 10) {
        NSLog(@"*** Force done!");
       [self stopLocationManager];
       [self updateLabels];
       [self configureGetButton];
      }
  }
}

#pragma mark - UITabBarControllerDelegate

// This method gets called when the user switches tabs.
- (BOOL)tabBarController:(UITabBarController *)tabBarController
    shouldSelectViewController:(UIViewController *)viewController {
  // It sets the tab bar’s translucent property to YES if the newly selected view controller is not self, in other words if the Locations or Map screen becomes active. However, if the Current Location screen is the active tab, translucent becomes NO, making the tab bar pitch black.
  tabBarController.tabBar.translucent = (viewController != self);
  return YES;
}


@end
