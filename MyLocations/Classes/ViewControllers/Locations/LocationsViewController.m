//
//  LocationsViewController.m
//  MyLocations
//
//  Created by Joe Gesualdo on 9/8/14.
//  Copyright (c) 2014 Joe Gesualdo. All rights reserved.
//

#import "LocationsViewController.h"
#import "Location.h"
#import "LocationCell.h"
#import "LocationDetailsViewController.h"
#import "UIImage+Resize.h"

@interface LocationsViewController () <NSFetchedResultsControllerDelegate>

@end

@implementation LocationsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSFetchedResultsController *)fetchedResultsController {
  // lazily loading objects.
  if (_fetchedResultsController == nil) {
    // make an NSFetchRequest and give it an entity description and a sort descriptor.
  // NSFetchRequest =================================
  // ask the managed object context for a list of all Location objects in the data store, sorted by date.
  
  // The NSFetchRequest is the object that describes which objects you’re going to fetch from the data store. To retrieve an object that you previously saved to the data store, you create a fetch request that describes the search parameters of the object – or multiple objects – that you’re looking for.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  //The NSEntityDescription tells the fetch request you’re looking for Location entities.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location"
                                              inManagedObjectContext:self.managedObjectContext]; [fetchRequest setEntity:entity];
  // The NSSortDescriptor tells the fetch request to sort on the date attribute, in ascending order. In order words, the Location objects that the user added first will be at the top of the list. You can sort on any attribute here (later in this tutorial you’ll sort on the Location’s category as well).
    // Why 2 sort descriptors -- First this sorts the Location objects by category and inside each of these groups it sorts by date.
    NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"category" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    [fetchRequest setSortDescriptors: @[sortDescriptor1, sortDescriptor2]];

    // If you have a huge table with hundreds of objects then it requires a lot of memory to keep all of these objects around, even though you can only see a handful of them at a time. The NSFetchedResultsController is pretty smart about this and will only fetch the objects that you can actually see, which cuts down on memory usage. This is all done in the background without you having to worry about it. The fetch batch size setting allows you to tweak how many objects will be fetched at a time.
    [fetchRequest setFetchBatchSize:20];
    // The cacheName needs to be a unique name that NSFetchedResultsController uses to cache the search results. It keeps this cache around even after your app quits, so the next time it starts up the fetch request is lightning fast, as the NSFetchedResultsController doesn’t have to make a round-trip to the database but can simply read from the cache.
    // What is sectionNameKeyPath?
    //  the fetched results controller will group the search results based on the value of the category attribute.
    _fetchedResultsController = [[NSFetchedResultsController alloc]
                                 initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"category" cacheName:@"Locations"];
    _fetchedResultsController.delegate = self;
  }
  return _fetchedResultsController;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Fixes nasty bug with Core Data in iOS 7.0 where app crashes after you tag a location then try to view it in locations table
  [NSFetchedResultsController deleteCacheWithName:@"Locations"];
  [self performFetch];
  
  // Many apps have an Edit button in the navigation bar that triggers a mode that also lets you delete (and sometimes move) rows. This is extremely easy to add.
  // This is all you need to make the list editable
  self.navigationItem.rightBarButtonItem = self.editButtonItem;
  

  // sets the background color for the table view
  self.tableView.backgroundColor = [UIColor blackColor];
  // set color of seperator lines on the table
  self.tableView.separatorColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
}
- (void)performFetch {
  // Now that you have the fetch request, you can tell the context to execute it. The executeFetchRequest method returns an NSArray with the sorted objects, or nil in case of an error. Since those errors shouldn’t really happen, you use the special macro to handle that situation.
  NSError *error;
  if (![self.fetchedResultsController performFetch:&error]) {
    NSLog(@"%@", [error description]);
    return; }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  // Return the number of sections.
  return [[self.fetchedResultsController sections] count];
}

- (NSString *)tableView:(UITableView *)tableView
  titleForHeaderInSection:
        (NSInteger)section
{
  //  You ask the fetcher object for a list of the sections, which is an NSArray of NSFetchedResultsSectionInfo objects, and then look inside that array to find out how many sections there are and what their names are.
  // What is this id<...> syntax?
  // means that Core Data gives you an object that conforms to the NSFetchedResultsSectionInfo protocol. That protocol contains methods for obtaining the name of the section and the list of objects that belong to that section. You don’t need to care about the actual datatype of the sectionInfo variable, only that you can treat it as a NSFetchedResultsSectionInfo object.
  id<NSFetchedResultsSectionInfo> sectionInfo =
              [self.fetchedResultsController sections][section];
  return [[sectionInfo name] uppercaseString];
}


- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  
  // You simply ask the fetched results controller for the number of rows and return it.
  id <NSFetchedResultsSectionInfo> sectionInfo =
  [self.fetchedResultsController sections][section];
  
  return [sectionInfo numberOfObjects];

}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Location"];
  // configureCell is a helper method we created that sets the description and address on the cell
  [self configureCell:cell atIndexPath:indexPath];
  return cell;
}

//This method gets the Location object from the selected row and then tells the context to delete that object. This will trigger the NSFetchedResultsController to send a notification to the delegate (NSFetchedResultsChangeDelete), which then removes the corresponding row from the table. That’s all you need to do!
- (void)tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    Location *location =
        [self.fetchedResultsController objectAtIndexPath:indexPath];
    [location removePhotoFile];
    [self.managedObjectContext deleteObject:location];
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
      NSLog(@"%@", [error description]);
      return;
    }
  }
}


// THis is now you customize the design of the table headers
// This is a UITableView delegate method. It gets called once for each section in the table view. Here you create a label for the section name, a 1-pixel high view that functions as a separator line, and a container view to hold these two subviews.
- (UIView *)tableView:(UITableView *)tableView
    viewForHeaderInSection:(NSInteger)section {
  UILabel *label = [[UILabel alloc]
      initWithFrame:CGRectMake(15.0f, tableView.sectionHeaderHeight - 14.0f,
                               300.0f, 14.0f)];
  label.font = [UIFont boldSystemFontOfSize:11.0f];
  label.text = [tableView.dataSource tableView:tableView
                       titleForHeaderInSection:section];
  label.textColor = [UIColor colorWithWhite:1.0f alpha:0.4f];
  label.backgroundColor = [UIColor clearColor];
  UIView *separator = [[UIView alloc]
      initWithFrame:CGRectMake(15.0f, tableView.sectionHeaderHeight - 0.5f,
                               tableView.bounds.size.width - 15.0f, 0.5f)];
  separator.backgroundColor = tableView.separatorColor;
  UIView *view = [[UIView alloc]
      initWithFrame:CGRectMake(0.0f, 0.0f, tableView.bounds.size.width,
                               tableView.sectionHeaderHeight)];
  view.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.85f];
  [view addSubview:label];
  [view addSubview:separator];
  
  return view;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
  if ([segue.identifier isEqualToString:@"EditLocation"]) {
    UINavigationController *navigationController = segue.destinationViewController;
    LocationDetailsViewController *controller = (LocationDetailsViewController *)navigationController.topViewController;
    controller.managedObjectContext = self.managedObjectContext;
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    Location *location = [self.fetchedResultsController objectAtIndexPath:indexPath];
    controller.locationToEdit = location;
  }
}
#pragma mark - Helper methods
// Instead of using viewWithTag to find the description and address labels, you now simply use the descriptionLabel and addressLabel properties of the cell. You first have to cast the cell variable to a LocationCell because the UITableViewCell superclass doesn’t know anything about these properties.
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
  LocationCell *locationCell = (LocationCell *)cell;
  // ask the fetchedResultsController for the object at the requested index-path. Because it is designed to work closely together with table views, NSFetchedResultsController knows how to deal with index-paths, so that’s very convenient.
  Location *location = [self.fetchedResultsController objectAtIndexPath:indexPath];
  if ([location.locationDescription length] > 0) {
    locationCell.descriptionLabel.text = location.locationDescription;
  } else {
    locationCell.descriptionLabel.text = @"(No Description)";
  }
  if (location.placemark != nil) {
    locationCell.addressLabel.text =
    [NSString stringWithFormat:@"%@ %@, %@", location.placemark.subThoroughfare, location.placemark.thoroughfare, location.placemark.locality];
  } else {
    locationCell.addressLabel.text = [NSString stringWithFormat:
                                      @"Lat: %.8f, Long: %.8f", [location.latitude doubleValue], [location.longitude doubleValue]];
  }
  UIImage *image = nil;
  if ([location hasPhoto]) {
    image = [location photoImage];
    if (image != nil) {
      image = [image resizedImageWithBounds:CGSizeMake(52, 52)];
    }
  }
  // If there is no image, we put a place holder there
  if (image == nil) {
    image = [UIImage imageNamed:@"No Photo"];
  }
  
  locationCell.photoImageView.image = image;
  
  
  // Change appearance of cell
  locationCell.backgroundColor = [UIColor blackColor];
  locationCell.descriptionLabel.textColor = [UIColor whiteColor];
  locationCell.descriptionLabel.highlightedTextColor =
      locationCell.descriptionLabel.textColor;
  locationCell.addressLabel.textColor = [UIColor colorWithWhite:1.0f alpha:0.4f];
  locationCell.addressLabel.highlightedTextColor =
      locationCell.addressLabel.textColor;
  
  // This is how you wold change the selection color (the color that appears when user clicks on cell
  // This creates a new UIView that is filled a dark gray color. This new view is placed on top of the cell’s background when the user taps on the cell. It looks like this:
  UIView *selectionView = [[UIView alloc] initWithFrame:CGRectZero];
  selectionView.backgroundColor =
  [UIColor colorWithWhite:1.0f alpha:0.2f];
  locationCell.selectedBackgroundView = selectionView;
  
  // This gives the image view rounded corners with a radius that is equal to half the width of the image, which makes it a perfect circle.
  locationCell.photoImageView.layer.cornerRadius =
      locationCell.photoImageView.bounds.size.width / 2.0f;
  // The clipsToBounds setting makes sure that the image view respects these rounded corners and does not draw outside them.
  locationCell.photoImageView.clipsToBounds = YES;
  //The separatorInset moves the separator lines between the cells a bit to the right so there are no lines between the thumbnail images.
  locationCell.separatorInset = UIEdgeInsetsMake(0, 82, 0, 0);

}

// The dealloc method is invoked when this view controller is destroyed. It may not strictly be necessary to nil out the delegate here, but it’s a bit of defensive programming that won’t hurt. (Note that in this app the LocationsViewController will never actually be deallocated because it’s one of the top-level view controllers in the tab bar.)
// explicitly set the delegate to nil when you no longer need the NSFetchedResultsController, just so you don’t get any more notifications that were still pending.
- (void)dealloc {
  self.fetchedResultsController.delegate = nil;
}

// delegate method for NSFetchedResultsController
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
  NSLog(@"*** controllerWillChangeContent");
  [self.tableView beginUpdates];
}

// delegate method for NSFetchedResultsController
- (void)controller:(NSFetchedResultsController *)controller
    didChangeObject:(id)anObject
        atIndexPath:(NSIndexPath *)indexPath
      forChangeType:(NSFetchedResultsChangeType)type
       newIndexPath:(NSIndexPath *)newIndexPath {
  switch (type) {
  case NSFetchedResultsChangeInsert:
    NSLog(@"*** NSFetchedResultsChangeInsert (object)");
    [self.tableView insertRowsAtIndexPaths:@[ newIndexPath ]
                          withRowAnimation:UITableViewRowAnimationFade];
    break;
  case NSFetchedResultsChangeDelete:
    NSLog(@"*** NSFetchedResultsChangeDelete (object)");
    [self.tableView deleteRowsAtIndexPaths:@[ indexPath ]
                          withRowAnimation:UITableViewRowAnimationFade];
    break;
  case NSFetchedResultsChangeUpdate:
    NSLog(@"*** NSFetchedResultsChangeUpdate (object)");
    [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath]
            atIndexPath:indexPath];
    break;
  case NSFetchedResultsChangeMove:
    NSLog(@"*** NSFetchedResultsChangeMove (object)");
    [self.tableView deleteRowsAtIndexPaths:@[ indexPath ]
                          withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView insertRowsAtIndexPaths:@[ newIndexPath ]
                          withRowAnimation:UITableViewRowAnimationFade];
    break;
  }
}
- (void)controller:(NSFetchedResultsController *)controller
    didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
             atIndex:(NSUInteger)sectionIndex
       forChangeType:(NSFetchedResultsChangeType)type {
  switch (type) {
  case NSFetchedResultsChangeInsert:
    NSLog(@"*** NSFetchedResultsChangeInsert (section)");
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                  withRowAnimation:UITableViewRowAnimationFade];
    break;
  case NSFetchedResultsChangeDelete:
    NSLog(@"*** NSFetchedResultsChangeDelete (section)");
    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                  withRowAnimation:UITableViewRowAnimationFade];
    break;
  }
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
  NSLog(@"*** controllerDidChangeContent");
  [self.tableView endUpdates];
}


@end
