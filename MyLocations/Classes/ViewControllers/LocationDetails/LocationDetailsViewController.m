//
//  LocationDetailsViewController.m
//  MyLocations
//
//  Created by Joe Gesualdo on 9/5/14.
//  Copyright (c) 2014 Joe Gesualdo. All rights reserved.
//

#import "LocationDetailsViewController.h"
#import "CategoryPickerViewController.h"
#import "HudView.h"
#import "Location.h"


// The view controller must conform to both UIImagePickerControllerDelegate and UINavigationControllerDelegate for imagepicker to work, but you don’t have to implement any of the UINavigationControllerDelegate methods.
@interface LocationDetailsViewController () <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

// Why are we putting the properties in the class extension instead of the header file?
// A class extension is an addition to the @interface section of the class, but one that you keep hidden. allows you to move your outlet properties into the .m file, to hide them from the other objects in your app.
@property(nonatomic, weak) IBOutlet UITextView *descriptionTextView;
@property(nonatomic, weak) IBOutlet UILabel *categoryLabel;
@property(nonatomic, weak) IBOutlet UILabel *latitudeLabel;
@property(nonatomic, weak) IBOutlet UILabel *longitudeLabel;
@property(nonatomic, weak) IBOutlet UILabel *addressLabel;
@property(nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *photoLabel;
@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, strong)UIImagePickerController *imagePicker;

@property(strong, nonatomic)NSDate *date;

@end

@implementation LocationDetailsViewController

// ??? What does initWithCoder do here?
// give the self.descriptText property an initial value.
- (id)initWithCoder:(NSCoder *)aDecoder {
  if ((self = [super initWithCoder:aDecoder])) {
    self.descriptionText = @"";
    self.categoryName = @"No Category";
    //initialize a new date
    self.date = [NSDate date];
    
    // We  want a method to get called when app enters the background:
    // You’ve seen in the Checklists tutorial that the AppDelegate is notified by the operating system when the app is about to go into the background, through its applicationDidEnterBackground method. View controllers don’t have such a method, but fortunately iOS sends out notifications through NSNotificationCenter that you can make the view controller listen to. Earlier you used the notification center to observe the notifications from Core Data. This time you’ll listen for the UIApplicationDidEnterBackgroundNotification.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
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
  
  if (self.locationToEdit != nil) {
    self.title = @"Edit Location";
  }

  
  // put the context of the UITextView into the descriptionText variable
  
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
  
  self.descriptionTextView.text = self.descriptionText;
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
  self.dateLabel.text = [self formatDate:self.date];
  
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
  } else if (indexPath.section == 1) {
    // If there is no image, then the height for the Add Photo cell is 44 points just like a regular cell. But if there is an image, then it’s a lot higher: 280 points. That is 260 points for the image view plus 10 points margin on the top and bottom.
    if (self.imageView.hidden) {
      return 44;
    } else {
      return 280;
    }
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
  // creates a HudView object and adds it to the navigation controller’s view with an animation.
  // We created this hudInView method; check HudView.m
  HudView *hudView = [HudView hudInView:self.navigationController.view animated:YES];
  hudView.text = @"Tagged";
  
  Location *location = nil;
  // only ask Core Data for a new Location object if you don’t already have one. You also make the text in the HUD say “Updated” when the user is editing an existing Location
  if (self.locationToEdit != nil) {
    hudView.text = @"Updated";
    location = self.locationToEdit;
  } else {
    hudView.text = @"Tagged";
  // Save to CoreData
  // First, you create a new Location object. This is different from how you created objects before. If Location were a regular NSObject, you would do [[Location alloc] init] to create a new instance. However, this is a Core Data managed object, and they are created in a different manner.
  // You have to ask the NSEntityDescription class to insert a new object for your entity into the managed object context. It’s a bit of a weird way to make new objects but that’s how you do it in Core Data. The string @"Location" is the name of the entity that you added in the data model earlier.
    location = [NSEntityDescription
        insertNewObjectForEntityForName:@"Location"
                 inManagedObjectContext:self.managedObjectContext];
  }
  
  // Once you have created the Location object, you can use it like any other object. Here you set its properties. Note that you convert the latitude and longitude into NSNumber objects using the @() notation. You don’t have to do anything special for the CLPlacemark object.
  location.locationDescription = self.descriptionText;
  location.category = self.categoryName;
  location.latitude = @(self.coordinate.latitude);
  location.longitude = @(self.coordinate.longitude);
  location.date = self.date;
  location.placemark = self.placemark;
  // You now have a new Location object whose properties are set to whatever the user entered in the screen, but if you were to look in the data store at this point you’d still see no objects there. That won’t happen until you save the context. This takes any objects that were added to the context, or any managed objects that had their contents changed, and permanently saves these changes into the data store. That’s why they call the context the “scratchpad”; its changes aren’t persisted until you save them.[
  NSError *error;
  // What if something goes wrong with the save? The save method returns NO and you call the abort() function. True to its name, abort() will immediately kill the app and return the user to the iPhone’s Springboard. That’s a nasty surprise for the user, and therefore not recommended.
  if (![self.managedObjectContext save:&error]) {
    NSLog(@"Error: %@", error);
    // making the app crash hard with abort()
    abort();
  }

  // By calling performSelector:withObject:afterDelay:, you schedule the closeScreen method to be called after 0.6 seconds, which leaves time for the HUD to display. So we use this instead of using [self closeScreen]
  [self performSelector:@selector(closeScreen) withObject:nil afterDelay:0.6];
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
  } else if (indexPath.section == 1 && indexPath.row == 0) {
    // Before calling showPhotoMenu, you first deselect the Add Photo row. Try it out, it looks better this way. The cell background quickly fades from gray back to white as the action sheet slides into the screen.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // Uncomment this when live
    // [self takePhoto];
    // User this method when using the simulator
    [self showPhotoMenu];
  }
}

- (void)setLocationToEdit:(Location *)newLocationToEdit {
  if (_locationToEdit != newLocationToEdit) {
    _locationToEdit = newLocationToEdit;
    self.descriptionText = _locationToEdit.locationDescription;
    self.categoryName = _locationToEdit.category;
    self.date = _locationToEdit.date;
    self.coordinate =
        CLLocationCoordinate2DMake([_locationToEdit.latitude doubleValue],
                                   [_locationToEdit.longitude doubleValue]);
    
    self.placemark = _locationToEdit.placemark;
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

- (void)takePhoto {
  // All you need to do is create a UIImagePickerController instance,
  self.imagePicker = [[UIImagePickerController alloc] init];
  // set its properties to configure the picker, set its delegate, and then present it. When the user closes the image picker screen, the delegate methods will let you know what happened.
  self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
  self.imagePicker.delegate = self;
  // With this setting enabled, the user can do some quick editing on the photo before making his final choice.
  self.imagePicker.allowsEditing = YES;
  [self presentViewController:self.imagePicker animated:YES completion:nil];
}

// We create a choosePhotoLibrary method also because our simulator doesn have a camera, thus can use the takePhoto method
- (void)choosePhotoFromLibrary {
  self.imagePicker = [[UIImagePickerController alloc] init];
  self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  self.imagePicker.delegate = self;
  // With this setting enabled, the user can do some quick editing on the photo before making his final choice.
  self.imagePicker.allowsEditing = YES;
  [self presentViewController:self.imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

// gets called when the user has selected a photo in the image picker
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
  // The info dictionary contains a variety of data describing the image that the user picked.
  // You use the UIImagePickerControllerEditedImage key to retrieve a UIImage object that contains the image from after the Move and Scale operation. (You can also get the original image if you wish.)
  self.image = info[UIImagePickerControllerEditedImage];
  // Once you have the image, the call to showImage puts it in the Add Photo cell. Note that you also store the image in the self.image instance variable so you can use it later.
  [self showImage:self.image];
  // The call to [self.tableView reloadData] refreshes the table view and sets the photo row to the proper height.
  [self.tableView reloadData];
  [self dismissViewControllerAnimated:YES completion:nil];
  self.imagePicker = nil;
}
- (void)imagePickerControllerDidCancel: (UIImagePickerController *)picker
{
  // simply remove the image picker from the screen.
  [self dismissViewControllerAnimated:YES completion:nil];
  
  self.imagePicker = nil;
}

#pragma mark - UIActionSheetDelegate methods
// First you check whether the camera is available. When it is, you show an action sheet to let the user choose between the camera and the Photo Library.
- (void)showPhotoMenu {
  // use UIImagePickerController’s isSourceTypeAvailable method to check whether there’s a camera present. If not, you call choosePhotoFromLibrary as that is the only option then. But when the device does have a camera you show a UIActionSheet on the screen. An action sheet works very much like an alert view, except that it slides in from the bottom of the screen.
  if ([UIImagePickerController
          isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    self.actionSheet = [[UIActionSheet alloc]
                 initWithTitle:nil
                      delegate:self
             cancelButtonTitle:@"Cancel"
        destructiveButtonTitle:nil
             otherButtonTitles:@"Take Photo", @"Choose From Library", nil];
    [self.actionSheet showInView:self.view];
  } else {
    [self choosePhotoFromLibrary];
  }
}

#pragma mark - UIActionSheetDelegate

// The button at index 0 is the Take Photo button and the button at index 1 is the Choose from Library button. There may be a small delay between pressing any of these buttons before the image picker appears but that’s because it’s a big component and iOS needs a few seconds to load it up.
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  if (buttonIndex == 0) {
    [self takePhoto];
  } else if (buttonIndex == 1) {
    [self choosePhotoFromLibrary];
  }
  self.actionSheet = nil;
}

// This puts the image into the image view, makes the image view visible and gives it the proper dimensions. hides the Add Photo label because you don’t want it to overlap the image view.
- (void)showImage:(UIImage *)image {
  self.imageView.image = image;
  self.imageView.hidden = NO;
  self.imageView.frame = CGRectMake(10, 10, 260, 260);
  self.photoLabel.hidden = YES;
}

- (void)applicationDidEnterBackground {
  // If there is an active image picker or action sheet, you dismiss it. This assumes you store references to those objects in instance variables.
  if (self.imagePicker != nil) {
    [self dismissViewControllerAnimated:NO completion:nil]; self.imagePicker = nil;
  }
  if (self.actionSheet != nil) {
    [self.actionSheet dismissWithClickedButtonIndex:
     self.actionSheet.cancelButtonIndex animated:NO]; self.actionSheet = nil;
  }
  [self.descriptionTextView resignFirstResponder];
}
@end