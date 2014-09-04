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

@property(nonatomic, weak) IBOutlet UILabel *messageLabel;
@property(nonatomic, weak) IBOutlet UILabel *latitudeLabel;
@property(nonatomic, weak) IBOutlet UILabel *longitudeLabel;
@property(nonatomic, weak) IBOutlet UILabel *addressLabel;
@property(nonatomic, weak) IBOutlet UIButton *tagButton;
@property(nonatomic, weak) IBOutlet UIButton *getButton;

- (IBAction)getLocation:(id)sender;

@end
