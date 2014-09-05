//
//  FirstViewController.h
//  MyLocations
//
//  Created by Joe Gesualdo on 9/4/14.
//  Copyright (c) 2014 Joe Gesualdo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CurrentLocationViewController : UIViewController <CLLocationManagerDelegate>


#pragma mark - Location Manger Properties

@property(strong, nonatomic)CLLocationManager *locationManager;
@property(strong,nonatomic) CLLocation *location;
@property(nonatomic)BOOL updatingLocation;
@property(strong, nonatomic)NSError *lastLocationError;

#pragma mark - Geocoding Properties

@property(strong, nonatomic)CLGeocoder *geocoder;
// CLPlacemark contains the address information – street name, city name, and so on – that you’ve obtained through reverse geocoding.
@property(strong, nonatomic)CLPlacemark *placemark;
@property(nonatomic)BOOL performingReverseGeocoding;
@property(strong, nonatomic)NSError *lastGeocodingError;

#pragma mark - UI Properties

@property(nonatomic, weak) IBOutlet UILabel *messageLabel;
@property(nonatomic, weak) IBOutlet UILabel *latitudeLabel;
@property(nonatomic, weak) IBOutlet UILabel *longitudeLabel;
@property(nonatomic, weak) IBOutlet UILabel *addressLabel;
@property(nonatomic, weak) IBOutlet UIButton *tagButton;
@property(nonatomic, weak) IBOutlet UIButton *getButton;

#pragma mark - UI Actions

- (IBAction)getLocation:(id)sender;

#pragma mark - methods

- (void)stopLocationManager;
@end
