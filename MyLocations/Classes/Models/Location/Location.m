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
@dynamic photoId;

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

// The hasPhoto method determines whether this Location object has a photo associated with it or not. You set the photoId property to -1 if it doesn’t, and to any positive integer if it does.
-(BOOL)hasPhoto
{
  return (self.photoId != nil) && ([self.photoId integerValue] != -1);
}

// The photoPath method returns the full path to the JPEG file for the photo. You’ll save these files inside the app’s Documents directory.

- (NSString *)photoPath {
  NSString *filename = [NSString stringWithFormat:@"Photo-%ld.jpg", (long)[self.photoId integerValue]];
  return [[self documentsDirectory] stringByAppendingPathComponent:filename];
}

// This method returns a UIImage object by loading the image file from the app’s Documents directory. You’ll need this later to show the photos for existing Location objects.
- (UIImage *)photoImage {
  // An assertion is a check that makes sure that what you’re doing is valid. It’s a form of defensive programming. (Most of the crashes you’ve seen so far were actually caused by assertions in UIKit.)
  // So this will
  NSAssert(self.photoId != nil, @"No photo ID set");
  NSAssert([self.photoId integerValue] != -1, @"Photo ID is -1");
  return [UIImage imageWithContentsOfFile:[self photoPath]];
}

#pragma mark - Helpers

// Note that documentsDirectory is only used inside this class, so it is not listed in the public @interface in the Location.h header file.
- (NSString *)documentsDirectory {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                       NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths lastObject];
  return documentsDirectory;
}

+ (NSInteger)nextPhotoId {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSInteger photoId = [defaults integerForKey:@"PhotoID"];
  [defaults setInteger:photoId+1 forKey:@"PhotoID"];
  [defaults synchronize];
  return photoId;
}

// This is a code snippet that you can use to remove any file or folder. The NSFileManager class has all kinds of useful methods for dealing with the file system.
- (void)removePhotoFile {
  NSString *path = [self photoPath];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  if ([fileManager fileExistsAtPath:path]) {
    NSError *error;
    if (![fileManager removeItemAtPath:path error:&error]) {
      NSLog(@"Error removing file: %@", error);
    }
  }
}

@end
