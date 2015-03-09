//
//  UIDefaults.m
//  RecycleRush
//
//  Created by FRC on 2/23/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import "UIDefaults.h"
#import <QuartzCore/CALayer.h>

@implementation UIDefaults
+(UIButton *)setBigButtonDefaults:(UIButton *)currentButton withFontSize:(NSNumber *)fontSize {
    CGFloat textSize = 20.0;
    if (fontSize) textSize = [fontSize floatValue];
    currentButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:textSize];
    // Round button corners
    CALayer *btnLayer = [currentButton layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:10.0f];
    // Apply a 1 pixel, black border
    [btnLayer setBorderWidth:1.0f];
    [btnLayer setBorderColor:[[UIColor blackColor] CGColor]];
    
    // Set the button Background Color
    [currentButton setBackgroundColor:[UIColor whiteColor]];
    // Set the button Text Color
    [currentButton setTitleColor:[UIColor colorWithRed:(0.0/255) green:(0.0/255) blue:(120.0/255) alpha:1.0 ]forState: UIControlStateNormal];
    return currentButton;
}

+(UIButton *)setSmallButtonDefaults:(UIButton *)currentButton {
    currentButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    // Round button corners
    CALayer *btnLayer = [currentButton layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:10.0f];
    // Apply a 1 pixel, black border
    [btnLayer setBorderWidth:1.0f];
    [btnLayer setBorderColor:[[UIColor blackColor] CGColor]];
    // Set the button Background Color
    [currentButton setBackgroundColor:[UIColor whiteColor]];
    // Set the button Text Color
    [currentButton setTitleColor:[UIColor colorWithRed:(0.0/255) green:(0.0/255) blue:(120.0/255) alpha:1.0 ]forState: UIControlStateNormal];
    return currentButton;
}

+(UITextField *)setTextBoxDefaults:(UITextField *)currentTextField {
    currentTextField.font = [UIFont fontWithName:@"Helvetica" size:24.0];
    currentTextField.textColor = [UIColor colorWithRed:(0.0/255) green:(0.0/255) blue:(120.0/255) alpha:1.0];
    return currentTextField;
}
@end
