//
//  LocationDetailsViewController.h
//  MyLocations
//
//  Created by Joe Gesualdo on 9/5/14.
//  Copyright (c) 2014 Joe Gesualdo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Location;

@interface LocationDetailsViewController : UITableViewController
// CLLocationCoordinate2D object is new. This contains the latitude and longitude from the CLLocation object that you received from the location manager. You only need those two fields, so there’s no point in sending along the entire CLLocation object.
// CLLocationCoordinate2D is not an object but a struct, that's why you don't need a pointer (* wehn declaring
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

// CLPlacemark contains the address information – street name, city name, and so on – that you’ve obtained through reverse geocoding.
@property (nonatomic, strong) CLPlacemark *placemark;

@property(strong, nonatomic)NSString *descriptionText;

@property(strong, nonatomic)NSString *categoryName;

@property (nonatomic, strong) Location *locationToEdit;

@property (nonatomic, strong) UIImage *image;

#pragma mark - CoreData Properties

// WE need somewhere to store the managed object context so we have reference to it later
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
