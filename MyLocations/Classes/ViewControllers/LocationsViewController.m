//
//  LocationsViewController.m
//  MyLocations
//
//  Created by Joe Gesualdo on 9/8/14.
//  Copyright (c) 2014 Joe Gesualdo. All rights reserved.
//

#import "LocationsViewController.h"
#import "Location.h"

@interface LocationsViewController ()

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
  
  // NSFetchRequest =================================
  // ask the managed object context for a list of all Location objects in the data store, sorted by date.
  
  // The NSFetchRequest is the object that describes which objects you’re going to fetch from the data store. To retrieve an object that you previously saved to the data store, you create a fetch request that describes the search parameters of the object – or multiple objects – that you’re looking for.
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
 
  //The NSEntityDescription tells the fetch request you’re looking for Location entities.
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location"
                                            inManagedObjectContext:self.managedObjectContext];
  [fetchRequest setEntity:entity];
  
  // The NSSortDescriptor tells the fetch request to sort on the date attribute, in ascending order. In order words, the Location objects that the user added first will be at the top of the list. You can sort on any attribute here (later in this tutorial you’ll sort on the Location’s category as well).
  NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
  [fetchRequest setSortDescriptors:@[sortDescriptor]];
  
  // Now that you have the fetch request, you can tell the context to execute it. The executeFetchRequest method returns an NSArray with the sorted objects, or nil in case of an error. Since those errors shouldn’t really happen, you use the special macro to handle that situation.
  NSError *error;
  NSArray *foundObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
  if (foundObjects == nil) {
    NSLog(@"%@", [error description]);
    return;
  }
  
  // If everything went well, you assign the contents of the foundObjects array to the _locations instance variable.
  self.locations = foundObjects;
  // END Fetch request =====================
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
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  return [self.locations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Location"];
  Location *location = self.locations[indexPath.row];
  UILabel *descriptionLabel = (UILabel *)[cell viewWithTag:100];
  descriptionLabel.text = location.locationDescription;
  UILabel *addressLabel = (UILabel *)[cell viewWithTag:101];
  addressLabel.text = [NSString stringWithFormat:@"%@ %@, %@",
                       location.placemark.subThoroughfare,
                       location.placemark.thoroughfare,
                       location.placemark.locality];
  return cell;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
