//
//  FirstViewController.m
//  MyLocations
//
//  Created by Joe Gesualdo on 9/4/14.
//  Copyright (c) 2014 Joe Gesualdo. All rights reserved.
//

#import "CurrentLocationViewController.h"

@interface CurrentLocationViewController ()

@end

@implementation CurrentLocationViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self updateLabels];
  [self configureGetButton];
  // Do any additional setup after loading the view, typically from a nib.
}

//  This create The CLLocationManager property we defined (self.locationManager)
//  object.
- (id)initWithCoder:(NSCoder *)aDecoder {
  if ((self = [super initWithCoder:aDecoder])) {
    self.locationManager = [[CLLocationManager alloc] init];
  }
  return self;
}

#pragma mark - IBOutlets

- (void)getLocation:(id)sender {
  
  if (self.updatingLocation) {
    [self stopLocationManager];
  } else {
    self.location = nil;
    self.lastLocationError = nil;
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
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
    self.updatingLocation = NO;
    NSLog(@"location manager has been stopped");
  }
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
      
    }
  }
}
@end
