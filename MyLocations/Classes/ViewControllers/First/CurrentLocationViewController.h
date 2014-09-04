//
//  FirstViewController.h
//  MyLocations
//
//  Created by Joe Gesualdo on 9/4/14.
//  Copyright (c) 2014 Joe Gesualdo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface CurrentLocationViewController : UIViewController <CLLocationManagerDelegate>

@property(strong, nonatomic)CLLocationManager *locationManager;
@property(strong,nonatomic) CLLocation *location;

@property(nonatomic, weak) IBOutlet UILabel *messageLabel;
@property(nonatomic, weak) IBOutlet UILabel *latitudeLabel;
@property(nonatomic, weak) IBOutlet UILabel *longitudeLabel;
@property(nonatomic, weak) IBOutlet UILabel *addressLabel;
@property(nonatomic, weak) IBOutlet UIButton *tagButton;
@property(nonatomic, weak) IBOutlet UIButton *getButton;

@property(nonatomic)BOOL updatingLocation;
@property(strong, nonatomic)NSError *lastLocationError;

- (void)stopLocationManager;
- (IBAction)getLocation:(id)sender;

@end
