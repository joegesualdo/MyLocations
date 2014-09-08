//
//  LocationDetailsViewController.m
//  MyLocations
//
//  Created by Joe Gesualdo on 9/5/14.
//  Copyright (c) 2014 Joe Gesualdo. All rights reserved.
//

#import "LocationDetailsViewController.h"
#import "CategoryPickerViewController.h"


@interface LocationDetailsViewController () <UITextViewDelegate>

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

// ??? What does initWithCoder do here?
// give the self.descriptText property an initial value.
- (id)initWithCoder:(NSCoder *)aDecoder {
  if ((self = [super initWithCoder:aDecoder])) {
    self.descriptionText = @"";
    self.categoryName = @"No Category";
  }
  return self;
}

// ??? What's the difference betweeen initWithStyle and initWithCoder?
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
  
  // put the context of the UITextView into the descriptionText variable
  self.descriptionTextView.text = self.descriptionText;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
  
  self.descriptionTextView.text = @"";
  self.categoryLabel.text = self.categoryName;
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
  
  // This will make hideKeyboard get called EVERYTIME you click on the location details screen
  // You simply create the gesture recognizer object, give it a method to call when that particular gesture has been observed to take place, and add the recognizer object to the view.
  // Here you’ve chosen the message hideKeyboard: to be sent when a tap is recognized anywhere in the table view, so you also have to implement that method.
  UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc]
                                               initWithTarget:self action:@selector(hideKeyboard:)];
  gestureRecognizer.cancelsTouchesInView = NO;
  [self.tableView addGestureRecognizer:gestureRecognizer];
}

// Whenever the user taps somewhere in the table view, the gesture recognizer calls this method. It also passes a reference to itself as the parameter, which is handy because now you can ask gestureRecognizer where the tap happened.
- (void)hideKeyboard:(UIGestureRecognizer *)gestureRecognizer {
  // CGPoint is another common struct that you see all the time in UIKit. It contains two fields, x and y, that describe a position on the screen. Using this CGPoint, you ask the table view which index-path is currently displayed at that position. This is important because you obviously don’t want to hide the keyboard if the user tapped in the row with the description text view! If the user tapped anywhere else, you do hide the keyboard.
  CGPoint point = [gestureRecognizer locationInView:self.tableView];
  NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
  if (indexPath != nil && indexPath.section == 0 && indexPath.row == 0) {
    return;
  }
  [self.descriptionTextView resignFirstResponder];
  NSLog(@"hideKeyboard was called");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

// Commenting out these methods because they aren't needed when we have static cells
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
//    
//    // Configure the cell...
//    
//    return cell;
//}
// Override to support conditional editing of the table view.
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Return NO if you do not want the specified item to be editable.
//    return YES;
//}
//// Override to support editing the table view.
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        // Delete the row from the data source
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//    }   
//}
//// Override to support rearranging the table view.
//- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
//{
//}
//// Override to support conditional rearranging of the table view.
//- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Return NO if you do not want the item to be re-orderable.
//    return YES;
//}

// Since we want our cells to be different sizes, we implement the delegate method heightForrowAtIndex
- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.section == 0 && indexPath.row == 0) {
    return 88;
  } else if (indexPath.section == 2 && indexPath.row == 2) {
    // 1. CGRect is a struct that describes a rectangle. A rectangle has an origin made up of an X, Y coordinate, and a size (width and height). The CGRectMake() function takes four values – x, y, width and height – and puts them into a new CGRect struct. The width value is 205 points, but the height is a whopping 10,000 points. That is done to make the rectangle tall enough to fit a lot of text.
    CGRect rect = CGRectMake(100, 10, 205, 10000);
    //  Once you have that initial rectangle that is way too high, you resize the label. The frame property is a CGRect that describes the position and size of a view. All UIView objects (and subclasses such as UILabel) have a frame rectangle. Changing the frame is how you can position views on the screen programmatically. Setting the frame on a multi-line UILabel has another effect: it will now word-wrap the text to fit the requested width (205 points). This works because you already set the text on the label in viewDidLoad.
    self.addressLabel.frame = rect;
    // Now that the label has word-wrapped its contents, you’ll have to size the label back to the proper height because you don’t want a cell that is 10,000 points tall. Remember the Size to Fit Content menu option from Interface Builder that you can use to resize a label to fit its contents? You can also do that from code with sizeToFit.
    [self.addressLabel sizeToFit];
    // The call to sizeToFit removed any spare space to the right and bottom of the label. You want that to happen for the height of the label but not for the width, so you put the newly calculated height back into the rect from earlier. This gives you a rectangle with an origin at X: 100, Y: 10, a width of 205, and a height that exactly fits the text.
    rect.size.height = self.addressLabel.frame.size.height;
    self.addressLabel.frame = rect;
    // Now that you know how high the label is, you can add a margin (10 points at the top, 10 points at the bottom) to calculate the full height for the cell.
    return self.addressLabel.frame.size.height + 20;
  } else {
    return 44;
  }
}

#pragma mark - IBActions

// Why didn't we declare these done and cancel methods in the header file?
//  If you don’t declare them inside the .h file, they will become private. In this case, there is no reason for any object outside this view controller to ever call these methods, so you might as well keep them hidden.
- (IBAction)done:(id)sender {
  NSLog(@"Description '%@'", self.descriptionText);
  [self closeScreen];
}
- (IBAction)cancel:(id)sender {
  [self closeScreen];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  // Will set the category on the CategoryPicket view
  if ([segue.identifier isEqualToString:@"PickCategory"]){
    CategoryPickerViewController *controller = segue.destinationViewController;
    controller.selectedCategoryName = self.categoryName;
  }
}
// This is an 'unwind segue'
// But in order to make an unwind segue you need to define an action method that takes a UIStoryboardSegue parameter.
- (IBAction)categoryPickerDidPickCategory:(UIStoryboardSegue *)segue {
  CategoryPickerViewController *controller = segue.sourceViewController;
  self.categoryName = controller.selectedCategoryName;
  self.categoryLabel.text = self.categoryName;
}

#pragma mark - UITextViewDelegate

// These methods simply update the contents of the self.descriptionText variable whenever the user types into the text view. Of course, those delegate methods won’t do any good if you don’t also tell the text view that it has a delegate.

// shouldChangeTExtInRange delegate is called after every action in a text view (i.e add character, edit character, etc)
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
  self.descriptionText = [textView.text
                      stringByReplacingCharactersInRange:range withString:text];
  return YES;
}
- (void)textViewDidEndEditing:(UITextView *)textView {
  self.descriptionText = textView.text;
}

// The willSelectRowAtIndexPath method limits taps on rows to just the cells from the first two sections. The third section only has read-only labels anyway, so it doesn’t need to allow taps. So now When the user taps anywhere inside that first cell, the app should activate the text view, even the tap wasn’t on the text view itself. Before we had to tap in the text view, no on the cell. Anywhere you click inside that first cell should now bring up the keyboard.
- (NSIndexPath *)tableView:(UITableView *)tableView
    willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0 || indexPath.section == 1) {
    return indexPath;
  } else {
    return nil;
  }
}
// The didSelectRowAtIndexPath handles the actual taps on the rows. You don’t need to respond to taps on the Category or Add Photo rows as these cells are connected to segues. But if the user tapped in the first row of the first section – the row with the description text view – then this will give the input focus to that text view.
- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0 && indexPath.row == 0) {
    [self.descriptionTextView becomeFirstResponder];
  }
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