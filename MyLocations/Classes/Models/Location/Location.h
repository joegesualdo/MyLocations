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
//  MKMapView expects an array of MKAnnotation objects, not your own Location class. So when we addannotations to a map, it doesn't want data with any type, but it wants data with MKAnnotation type. Luckily, MKAnnotation is a protocol, so you can turn the Location objects into map annotations by making the class conform to that protocol.
@interface Location : NSManagedObject <MKAnnotation>


// Even though you chose the datatype Double for latitude and longitude, these properties are listed as NSNumber objects instead of double values. Core Data stores everything as objects, not as primitive values. Anything that you would normally use an int, float, double or BOOL for will need to become an NSNumber in Core Data.
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * locationDescription;
// Because you made placemark a Transformable property, Xcode doesn’t really know what kind of object this will be, so it chose the generic datatype id. You know it’s going to be a CLPlacemark object, so you can make things easier for yourself by changing it. It used to be this:
// @property (nonatomic, retain) id placemark;
@property (nonatomic, retain) CLPlacemark *placemark;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSDate *date;

// way to associate a Location object with that image file.
@property (nonatomic, retain) NSNumber * photoId;

+ (NSInteger)nextPhotoId;
- (BOOL)hasPhoto;
- (NSString *)photoPath;
- (UIImage *)photoImage;
-(void)removePhotoFile;

@end
