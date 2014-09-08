//
//  HudView.h
//  MyLocations
//
//  Created by Joe Gesualdo on 9/8/14.
//  Copyright (c) 2014 Joe Gesualdo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HudView : UIView

@property (nonatomic, strong) NSString *text;

+ (instancetype)hudInView:(UIView *)view animated:(BOOL)animated;

@end