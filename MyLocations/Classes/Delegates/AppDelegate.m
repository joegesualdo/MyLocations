//
//  AppDelegate.m
//  MyLocations
//
//  Created by Joe Gesualdo on 9/4/14.
//  Copyright (c) 2014 Joe Gesualdo. All rights reserved.
//

#import "AppDelegate.h"
#import "CurrentLocationViewController.h"
#import "LocationsViewController.h"
#import "MapViewController.h"

@interface AppDelegate ()
@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property(nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property(nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  // run this method which setups the appearance
  [self customizeAppearance];
  // Since we want to set a property on the CurrentViewController we have to look up these view controllers by digging through the storyboard. So in order to get a reference to the CurrentLocationViewController you first have to find the UITabBarController and then look at its viewControllers array.
  UITabBarController *tabBarController =
      (UITabBarController *)self.window.rootViewController;
  CurrentLocationViewController *currentLocationViewController =
      (CurrentLocationViewController *)tabBarController.viewControllers[0];
  // This uses self.managedObjectContext to get a pointer to the App Delegate’s NSManagedObjectContext object,
  currentLocationViewController.managedObjectContext = self.managedObjectContext;
  
  // This looks up the LocationsViewController in the storyboard and gives it a reference to the managed object context.
  UINavigationController *navigationController = (UINavigationController *)tabBarController.viewControllers[1];
  LocationsViewController *locationsViewController = (LocationsViewController *)
  navigationController.viewControllers[0];
  locationsViewController.managedObjectContext = self.managedObjectContext;
  
  // get the map view controller and set the managedObjectContext on it
  MapViewController *mapViewController =
  (MapViewController *)tabBarController.viewControllers[2];
  mapViewController.managedObjectContext = self.managedObjectContext;
  
  
  return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// CoreData ==============================
// This is the code you need to load the data model that you’ve defined earlier, and to connect it to an SQLite data store. This is very standard stuff that will be the same for almost any Core Data app you’ll write.
- (NSManagedObjectModel *)managedObjectModel {
  if (_managedObjectModel == nil) {
    NSString *modelPath =
        [[NSBundle mainBundle] pathForResource:@"DataModel" ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    _managedObjectModel =
        [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
  }
  return _managedObjectModel;
}
- (NSString *)documentsDirectory {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                       NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths lastObject];
  return documentsDirectory;
}

- (NSString *)dataStorePath {
  return [[self documentsDirectory] stringByAppendingPathComponent:@"DataStore.sqlite"];
}
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
  if(_persistentStoreCoordinator == nil){
    NSURL *storeURL = [NSURL fileURLWithPath:[self dataStorePath]];
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]  initWithManagedObjectModel:self.managedObjectModel];
    NSError *error;
    if (![_persistentStoreCoordinator
            addPersistentStoreWithType:NSSQLiteStoreType
                         configuration:nil
                                   URL:storeURL
                               options:nil
                                 error:&error]) {
      NSLog(@"Error adding persistent store %@, %@", error, [error userInfo]);
      abort();
    }
  }
  return _persistentStoreCoordinator;
}
- (NSManagedObjectContext *)managedObjectContext {
  if (_managedObjectContext == nil) {
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    if (coordinator != nil) {
      _managedObjectContext = [[NSManagedObjectContext alloc] init];
      [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
  }
  return _managedObjectContext;
}

// This changes the “bar tint” or background color of all navigation bars and tab bars in the app to black in one fell swoop. It also sets the color of the navigation bar’s title label to white.
- (void)customizeAppearance {
  // Keep in mind that the bar tint is not the true background color. The bars are still translucent, which is why they appear as a medium gray rather than pure black. That’s a bit of a problem on the main screen, where the dark gray tab bar still stands out too much:
  [[UINavigationBar appearance] setBarTintColor:[UIColor blackColor]];
  [[UINavigationBar appearance]
      setTitleTextAttributes:@{
                               NSForegroundColorAttributeName :
                                   [UIColor whiteColor],
                             }];
  [[UITabBar appearance] setBarTintColor:[UIColor blackColor]];
}

@end
