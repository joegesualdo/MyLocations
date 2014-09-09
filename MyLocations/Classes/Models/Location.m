//
//  Location.m
//  MyLocations
//
//  Created by Joe Gesualdo on 9/8/14.
//  Copyright (c) 2014 Joe Gesualdo. All rights reserved.
//

#import "Location.h"


@implementation Location

// The @dynamic keyword tells the compiler that these properties will be resolved at runtime by Core Data. When you put a new value into one of these properties, Core Data will put that value into the data store for safekeeping, instead of in an instance variable. That’s all there is to it.
@dynamic latitude;
@dynamic longitude;
@dynamic locationDescription;
@dynamic placemark;
@dynamic category;
@dynamic date;

#pragma mark - MKAnnotation protocols
//The MKAnnotation protocol requires that the class implements the getters for three properties: coordinate, title and subtitle. It obviously needs to know the coordinate in order to place the pin in the correct place on the map. The title and subtitle are used for the “call-out” that appears when you tap on the pin.

- (CLLocationCoordinate2D)coordinate {
  return CLLocationCoordinate2DMake([self.latitude doubleValue],
                                    [self.longitude doubleValue]);
}
- (NSString *)title {
  if ([self.locationDescription length] > 0) {
    return self.locationDescription;
  } else {
    return @"(No Description)";
  }
}
- (NSString *)subtitle {
  return self.category;
}
@end
