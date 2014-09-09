//
//  MapViewController.m
//  MyLocations
//
//  Created by Joe Gesualdo on 9/9/14.
//  Copyright (c) 2014 Joe Gesualdo. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController () <MKMapViewDelegate>

// This has a private outlet property for the map view and two action methods that will be connected to the buttons in the navigation bar. The view controller is also the delegate of the map view.
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
// This will hold the locations
@property (nonatomic, strong) NSArray *locations;

@end

@implementation MapViewController

-(void)viewDidLoad
{
  [super viewDidLoad];
   // This fetches the Location objects and shows them on the map when the view loads. Nothing special here.
  [self updateLocations];
  if ([self.locations count] > 0) {
    [self showLocations];
  }
}
//  When you press the User button, it zooms in the map to a region that is 1000 by 1000 meters (a little more than half a mile in both directions) around the user’s position:
- (IBAction)showUser {
  MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(
      self.mapView.userLocation.coordinate, 1000, 1000);
  [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
}

- (IBAction)showLocations {
  MKCoordinateRegion region = [self regionForAnnotations:self.locations];
  [self.mapView setRegion:region animated:YES];
}

- (MKCoordinateRegion)regionForAnnotations:(NSArray *)annotations {
  MKCoordinateRegion region;
  // if There are no annotations. In that case you’ll center the map on the user’s current position.
  if ([annotations count] == 0) {
    region = MKCoordinateRegionMakeWithDistance(
        self.mapView.userLocation.coordinate, 1000, 1000);
  // if There is only one annotation. You’ll center the map on that one annotation.
  } else if ([annotations count] == 1) {
    id<MKAnnotation> annotation = [annotations lastObject];
    region =
        MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000, 1000);
  //  If there are two or more annotations. You’ll calculate the extent of their reach and add a little padding.
  } else {
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    for (id<MKAnnotation> annotation in annotations) {
      topLeftCoord.latitude =
          fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
      topLeftCoord.longitude =
          fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
      bottomRightCoord.latitude =
          fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
      bottomRightCoord.longitude =
          fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
      const double extraSpace = 1.1;
      region.center.latitude =
          topLeftCoord.latitude - (
              topLeftCoord.latitude - bottomRightCoord.latitude) /
          2.0;
      region.center.longitude =
          topLeftCoord.longitude - (
              topLeftCoord.longitude - bottomRightCoord.longitude) /
          2.0;
      region.span.latitudeDelta =
          fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * extraSpace;
      region.span.longitudeDelta =
          fabs(topLeftCoord.longitude - bottomRightCoord.longitude) *
          extraSpace;
    }
  }
  return [self.mapView regionThatFits:region];
}

// This will get all locations then display them on the map
- (void)updateLocations {
  // Get the entity
  NSEntityDescription *entity =
      [NSEntityDescription entityForName:@"Location"
                  inManagedObjectContext:self.managedObjectContext];
  // Init a fetch request and set the entity
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  [fetchRequest setEntity:entity];
  // Create an error object to store the error, if there is one
  NSError *error;
  // perform the fetch request and store thme in a variable
  NSArray *foundObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
  if (foundObjects == nil) {
    NSLog(@"%@", [error description]);
    return;
  }
  if (self.locations != nil) {
    [self.mapView removeAnnotations:self.locations];
  }
  self.locations = foundObjects;
  // Once you’ve obtained the Location objects, you call addAnnotations on the map view to add a pin for each location on the map.
  [self.mapView addAnnotations:self.locations];
}
  
@end

