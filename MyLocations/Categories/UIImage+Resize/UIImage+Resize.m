//
//  UIImage+Resize.m
//  MyLocations
//
//  Created by Joe Gesualdo on 9/9/14.
//  Copyright (c) 2014 Joe Gesualdo. All rights reserved.
//

#import "UIImage+Resize.h"

@implementation UIImage (Resize)

- (UIImage *)resizedImageWithBounds:(CGSize)bounds {
  // This method first calculates how big the image can be in order to fit inside the bounds rectangle. It uses the “aspect fit” approach to keep the aspect ratio intact. Then it creates a new image context and draws the image into that. We haven’t really dealt with graphics contexts before, but they are an important concept in Core Graphics (it has nothing to do with the managed object context from Core Data).
  CGFloat horizontalRatio = bounds.width / self.size.width;
  CGFloat verticalRatio = bounds.height / self.size.height;
  CGFloat ratio = MIN(horizontalRatio, verticalRatio);
  CGSize newSize =
      CGSizeMake(self.size.width * ratio, self.size.height * ratio);
  UIGraphicsBeginImageContextWithOptions(newSize, YES, 0);
  [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return newImage;
}

@end
