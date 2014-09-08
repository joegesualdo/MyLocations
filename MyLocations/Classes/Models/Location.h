//
//  Location.h
//  MyLocations
//
//  Created by Joe Gesualdo on 9/8/14.
//  Copyright (c) 2014 Joe Gesualdo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


// the Location class extends NSManagedObject instead of the regular NSObject, because this represents a CoreData entity
@interface Location : NSManagedObject

// Even though you chose the datatype Double for latitude and longitude, these properties are listed as NSNumber objects instead of double values. Core Data stores everything as objects, not as primitive values. Anything that you would normally use an int, float, double or BOOL for will need to become an NSNumber in Core Data.
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * locationDescription;
// Because you made placemark a Transformable property, Xcode doesn’t really know what kind of object this will be, so it chose the generic datatype id. You know it’s going to be a CLPlacemark object, so you can make things easier for yourself by changing it. It used to be this:
// @property (nonatomic, retain) id placemark;
@property (nonatomic, retain) CLPlacemark *placemark;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSDate *date;

@end
