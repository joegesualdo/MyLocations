//
//  HudView.m
//  MyLocations
//
//  Created by Joe Gesualdo on 9/8/14.
//  Copyright (c) 2014 Joe Gesualdo. All rights reserved.
//

#import "HudView.h"

@implementation HudView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

// a convenience constructor. It creates and returns a new HudView instance.
+ (instancetype)hudInView:(UIView *)view animated:(BOOL)animated;

{
  // making an instance
  HudView *hudView = [[HudView alloc] initWithFrame:view.bounds];
  hudView.opaque = NO;
  // adds the new HudView object as a subview on top of the view object. This is actually the navigation controller’s view so the HUD will cover the entire screen.
  [view addSubview:hudView];
  // While the HUD is showing you don’t want the user to interact with the screen anymore. The user has already pressed the Done button and the screen is in the process of closing. Most users will leave the screen alone at this point but there’s always some joker who wants to try and break things. By setting userInteractionEnabled to NO, the view eats up any touches and all the underlying views become unresponsive.
  view.userInteractionEnabled = NO;
  // Just for testing, the background color of the HUD view is 50% transparent red. That way you can see it covers the entire screen. By the way, whenever you see an f behind a literal number, as in 1.0f, that just means this number is a float.
//  hudView.backgroundColor =
//      [UIColor colorWithRed:1.0f green:0 blue:0 alpha:0.5f];
  
  // call the showAnimated: method just before it returns. We created teh showAnimated method below
  [hudView showAnimated:animated];
  return hudView;
}

// The drawRect method is invoked whenever UIKit wants your view to redraw itself. Recall that everything in iOS is event-driven. You don’t draw anything on the screen unless UIKit sends you the drawRect event. That means you should never call drawRect yourself.
- (void)drawRect:(CGRect)rect {
  
   // draws a filled rectangle with rounded corners in the center of the screen. The rectangle is 96 by 96 points big (so I suppose it’s really a square):
  const CGFloat boxWidth = 96.0f;
  const CGFloat boxHeight = 96.0f;
  // Use CGRect to calculate the position for the rectangle that you’ll be drawing.
  CGRect boxRect = CGRectMake(
      // roundf() function makes sure the rectangle doesn’t end up on fractional pixel boundaries because that makes the image look fuzzy.
      roundf(self.bounds.size.width - boxWidth) / 2.0f,
      roundf(self.bounds.size.height - boxHeight) / 2.0f, boxWidth, boxHeight);
  // The UIBezierPath is a very handy object for drawing rectangles with rounded corners. You just tell it how large the rectangle is and how round the corners should be.
  UIBezierPath *roundedRect =
      [UIBezierPath bezierPathWithRoundedRect:boxRect cornerRadius:10.0f];
  // Then you fill it with an 80% opaque dark gray color.
  [[UIColor colorWithWhite:0.3f alpha:0.8f] setFill];
  [roundedRect fill];
  
  // Add the checkmark ================
  
  // This loads the checkmark image into a UIImage object.
  UIImage *image = [UIImage imageNamed:@"Checkmark"];
  // calculates the position for that image based on the center coordinate of the HUD view (self.center) and the dimensions of the image (image.size).
  CGPoint imagePoint = CGPointMake(
         self.center.x - roundf(image.size.width / 2.0f),
         self.center.y - roundf(image.size.height / 2.0f)
                                      - boxHeight / 8.0f);
  // draws the checkmark image at that position.
  [image drawAtPoint:imagePoint];
  
  // Draw the text under the checkmark ===========

  // When drawing text you first need to know how big the text is, so you can figure out where to draw it.
  NSDictionary *attributes = @{
  // First, you create the UIFont object that you’ll use for the text. This is a “System” font of size 16. The system font on iOS 7 is Helvetica Neue. You also choose a color for text, plain white.
    NSFontAttributeName : [UIFont systemFontOfSize:16.0f],
    NSForegroundColorAttributeName : [UIColor whiteColor]
  };
  // You use the font and the string from the self.text property to calculate how wide and tall the text will be. The result ends up in a CGSize variable.
  CGSize textSize = [self.text sizeWithAttributes:attributes];
  
  // calculate where to draw the text
  CGPoint textPoint = CGPointMake(self.center.x - roundf(textSize.width / 2.0f),
                                  self.center.y - roundf(textSize.height / 2.0f) +
                                      boxHeight / 4.0f);
  // draw the text
  [self.text drawAtPoint:textPoint withAttributes:attributes];
}

// The animation will animate the properties that you changed from their initial state to the final state. The HUD view will quickly fade in as its opacity goes from fully transparent to fully opaque, and it will scale down from 1.3 times its original size to its regular width and height.
- (void)showAnimated:(BOOL)animated {
  if (animated) {
    // Set up the initial state of the view before the animation starts. Here you set alpha to 0, which means the view is fully transparent. You also set the transform to a scale factor of 1.3. We’re not going to go into depth on transforms here, but basically this means the view is initially stretched out.
    self.alpha = 0.0f;
    self.transform = CGAffineTransformMakeScale(1.3f, 1.3f);
    // Call [UIView animateWithDuration:. . .] to set up an animation block.
    [UIView animateWithDuration:0.3
                     animations:^{
                       // Inside the block, set up the new state of the view that it should have after the animation completes. You set alpha to 1.0, which means it is now fully opaque.
                         self.alpha = 1.0f;
                       // set the transform to the “identity” transform, which means the scale is back to normal.
                         self.transform = CGAffineTransformIdentity;
                     }];
  }
}
@end
