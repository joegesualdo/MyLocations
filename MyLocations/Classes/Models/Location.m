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

@end
