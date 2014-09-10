//
//  MyTabBarController.m
//  MyLocations
//
//  Created by Joe Gesualdo on 9/10/14.
//  Copyright (c) 2014 Joe Gesualdo. All rights reserved.
//

#import "MyTabBarController.h"

@interface MyTabBarController ()

@end

@implementation MyTabBarController

// This makes the status bar white
- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

// By returning nil from childViewControllerForStatusBarStyle, the tab bar controller will look at its own preferredStatusBarStyle method.
- (UIViewController *)childViewControllerForStatusBarStyle {
  return nil;
}

@end
