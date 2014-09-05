//
//  LocationDetailsViewController.m
//  MyLocations
//
//  Created by Joe Gesualdo on 9/5/14.
//  Copyright (c) 2014 Joe Gesualdo. All rights reserved.
//

#import "LocationDetailsViewController.h"

@interface LocationDetailsViewController ()

// Why are we putting the properties in the class extension instead of the header file?
// A class extension is an addition to the @interface section of the class, but one that you keep hidden. allows you to move your outlet properties into the .m file, to hide them from the other objects in your app.
@property(nonatomic, weak) IBOutlet UITextView *descriptionTextView;
@property(nonatomic, weak) IBOutlet UILabel *categoryLabel;
@property(nonatomic, weak) IBOutlet UILabel *latitudeLabel;
@property(nonatomic, weak) IBOutlet UILabel *longitudeLabel;
@property(nonatomic, weak) IBOutlet UILabel *addressLabel;
@property(nonatomic, weak) IBOutlet UILabel *dateLabel;

@end

@implementation LocationDetailsViewController

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
  
  self.descriptionTextView.text = @"";
  self.categoryLabel.text = @"";
  self.latitudeLabel.text =
      [NSString stringWithFormat:@"%.8f", self.coordinate.latitude];
  self.longitudeLabel.text =
      [NSString stringWithFormat:@"%.8f", self.coordinate.longitude];
  if (self.placemark != nil) {
    self.addressLabel.text = [self stringFromPlacemark:self.placemark];
  } else {
    self.addressLabel.text = @"No Address Found";
  }
  self.dateLabel.text = [self formatDate:[NSDate date]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

// Commenting out these two methods because they aren't needed when we have static cells

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}
//
/*
 
 
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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

#pragma mark - IBActions

// Why didn't we declare these done and cancel methods in the header file?
//  If you don’t declare them inside the .h file, they will become private. In this case, there is no reason for any object outside this view controller to ever call these methods, so you might as well keep them hidden.
- (IBAction)done:(id)sender {
  [self closeScreen];
}
- (IBAction)cancel:(id)sender {
  [self closeScreen];
}

#pragma mark - Helpers

// Helper to format Placemark
- (NSString *)stringFromPlacemark:(CLPlacemark *)placemark {
  return [NSString stringWithFormat:@"%@ %@, %@, %@ %@, %@", placemark.subThoroughfare, placemark.thoroughfare, placemark.locality, placemark.administrativeArea, placemark.postalCode, placemark.country];
}

// HElper to format Date
- (NSString *)formatDate:(NSDate *)theDate {
  // You use NSDateFormatter class to convert the date and time that are encapsulated by the NSDate object into a human- readable string (in the user’s language and locale settings).
  // create NSDateFormatter just once, becasause initializing it is VERY expensive, and then re-use that same object over and over. The trick is that you won’t create the NSDateFormatter object until the app actually needs it. This principle is called lazy loading and it’s a very important pattern for iOS apps.
  // Putting the keyword static in front of a local variable declaration creates a special type of variable, a so-called static local variable. This variable keeps its value even after the method ends. The next time you call this method, the variable isn’t created anew but the existing one is used. You still can’t use the variable outside of the method (it remains local) but it will stay alive once it has been created.
  static NSDateFormatter *formatter = nil;
  if (formatter == nil) {
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
  }
  return [formatter stringFromDate:theDate];
}
-(void)closeScreen
{
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
