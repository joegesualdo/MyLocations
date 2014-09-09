//
//  MapViewController.m
//  MyLocations
//
//  Created by Joe Gesualdo on 9/9/14.
//  Copyright (c) 2014 Joe Gesualdo. All rights reserved.
//

#import "MapViewController.h"
#import "Location.h"
#import "LocationDetailsViewController.h"

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
-(id)initWithCoder:(NSCoder *)aDecoder
{
  if ((self = [super initWithCoder:aDecoder])) {
    // This tells the NSNotificationCenter to add self, i.e. this view controller, as an observer for the NSManagedObjectContextObjectsDidChangeNotification. This notification with the very long name is sent out by the managedObjectContext whenever the data store changes. In response you would like your contextDidChange: method to be called.
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(contextDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:self.managedObjectContext];
  }
  return self;
}

- (void)contextDidChange:(NSNotification *)notification {
  // updateLocations to fetch all the Location objects again. This throws away all the old pins and it makes new pins for all the newly fetched Location objects. Granted, it’s not a very efficient method if there are hundreds of annotation objects, but for now it gets the job done.
  if ([self isViewLoaded]) {
    [self updateLocations];
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

#pragma mark - MKMapViewDelegate

// This is a delegate method you need to customize the annotation of locations on map. For example, we change the pin color to green and add an info button
- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id<MKAnnotation>)annotation {
  
  // Because MKAnnotation is a protocol, there may be other objects than the Location object that want to be annotations on the map. An example is the blue dot that represents the user’s current location. You should leave such annotations alone, so you use the isKindOfClass: method to determine whether the annotation is really a Location object. If so, you continue.
  if ([annotation isKindOfClass:[Location class]]) {
    // This should look very familiar to creating a table view cell. You ask the map view to re-use an annotation view object. If it cannot find a recyclable annotation view, then you create a new one. Note that you’re not limited to MKPinAnnotationView. This is the standard annotation view class, but you can also create your own MKAnnotationView subclass and make it look like anything you want. Pins are only one option.
    static NSString *identifier = @"Location";
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)
        [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (annotationView == nil) {
      annotationView =
          [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                          reuseIdentifier:identifier];
      // This just sets some properties to configure the look and feel of the annotation view. Previously the pins were red, but you make them green here.
      annotationView.enabled = YES;
      annotationView.canShowCallout = YES;
      annotationView.animatesDrop = NO;
      annotationView.pinColor = MKPinAnnotationColorGreen;
      // This is the interesting bit. You create a new UIButton object that looks like a detail disclosure button (a blue circled i). You use the target-action pattern to hook up the button’s “Touch Up Inside” event with the showLocationDetails: method, and add the button to the annotation view’s accessory view.

      UIButton *rightButton =
          [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
      [rightButton addTarget:self
                      action:@selector(showLocationDetails:)
            forControlEvents:UIControlEventTouchUpInside];
      annotationView.rightCalloutAccessoryView = rightButton;
    } else {
      annotationView.annotation = annotation;
    }
    // Once the annotation view is constructed and configured, you obtain a reference to that detail disclosure button again and set its tag to the index of the Location object in the _locations array. That way you can find the Location object later in the showLocationDetails: method when the button is pressed.
    UIButton *button = (UIButton *)annotationView.rightCalloutAccessoryView;
    button.tag = [self.locations indexOfObject:(Location *)annotation];
    return annotationView;
  }
  return nil;
}

- (void)showLocationDetails:(UIButton *)button {
  // Because the segue isn’t connected to any particular control in the view controller, you have to trigger it manually. You send along the button object as the sender, so you can read its tag property in prepareForSegue.
  [self performSegueWithIdentifier:@"EditLocation" sender:button];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"EditLocation"]) {
    // get the Location object to edit from the _locations array, using the tag property of the button as the index in that array.
    UINavigationController *navigationController =
        segue.destinationViewController;
    LocationDetailsViewController *controller =
        (LocationDetailsViewController *)navigationController.topViewController;
    controller.managedObjectContext = self.managedObjectContext;
    UIButton *button = (UIButton *)sender;
    Location *location = self.locations[button.tag];
    controller.locationToEdit = location;
  }
}

// This method is called whenever a view is deallocated
- (void)dealloc {
  // tell the NSNotificationCenter to stop sending these notifications when the view controller is destroyed. You don’t want NSNotificationCenter to send notifications to an object that no longer exists, that’s just asking for trouble!
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

