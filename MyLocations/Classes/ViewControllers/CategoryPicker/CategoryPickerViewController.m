//
//  CategoryPickerViewController.m
//  MyLocations
//
//  Created by Joe Gesualdo on 9/5/14.
//  Copyright (c) 2014 Joe Gesualdo. All rights reserved.
//

#import "CategoryPickerViewController.h"

@interface CategoryPickerViewController ()

@end

@implementation CategoryPickerViewController

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
  
  self.categories = @[
                      @"No Category",
                      @"Apple Store",
                      @"Bar",
                      @"Bookstore",
                      @"Club",
                      @"Grocery Store",
                      @"Historic Building",
                      @"House",
                      @"Icecream Vendor",
                      @"Landmark",
                      @"Park"
                      ];
  
  // styles the table view
  self.tableView.backgroundColor = [UIColor blackColor];
  self.tableView.separatorColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  // Return the number of rows in the section.
  return [self.categories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
  
  NSString *categoryName = self.categories[indexPath.row];
  cell.textLabel.text = categoryName;
  NSLog(@"categoryName -- %@", categoryName);
  NSLog(@"Selected Category Name -- %@", self.selectedCategoryName);
  if ([categoryName isEqualToString:self.selectedCategoryName]) {
    NSLog(@"Triggered category Name");
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    self.selectedIndexPath = indexPath;
  } else {
    cell.accessoryType = UITableViewCellAccessoryNone;
  }
  return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row != self.selectedIndexPath.row) {
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    newCell.accessoryType = UITableViewCellAccessoryCheckmark;
    UITableViewCell *oldCell =
    [tableView cellForRowAtIndexPath:self.selectedIndexPath];
    oldCell.accessoryType = UITableViewCellAccessoryNone;
    self.selectedIndexPath = indexPath;
  }
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  
  // This is our unwind segue
  if ([segue.identifier isEqualToString:@"PickedCategory"]) {
    UITableViewCell *cell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    self.selectedCategoryName = self.categories[indexPath.row];
    //
  }
}

// Customized the styles of the cells
- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
  
  cell.backgroundColor = [UIColor blackColor];
  cell.textLabel.textColor = [UIColor whiteColor];
  cell.textLabel.highlightedTextColor = cell.textLabel.textColor;
  UIView *selectionView = [[UIView alloc] initWithFrame:CGRectZero];
  selectionView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
  cell.selectedBackgroundView = selectionView;
}

@end

