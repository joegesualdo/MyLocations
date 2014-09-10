//
//  CategoryPickerViewController.h
//  MyLocations
//
//  Created by Joe Gesualdo on 9/5/14.
//  Copyright (c) 2014 Joe Gesualdo. All rights reserved.
//

// What is this controller?
//   a table view controller that shows a list of category names. You can give it a category to initially select using the selectedCategoryName property. It will put a checkmark next to that name.

#import <UIKit/UIKit.h>


@interface CategoryPickerViewController : UITableViewController

@property (nonatomic, strong) NSString *selectedCategoryName;

@property (strong, nonatomic) NSArray *categories;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@end
