//
//  UIDefaults.h
//  RecycleRush
//
//  Created by FRC on 2/23/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIDefaults : NSObject
+(UIButton *)setBigButtonDefaults:(UIButton *)currentButton;
+(UIButton *)setSmallButtonDefaults:(UIButton *)currentButton;
+(UITextField *)setTextBoxDefaults:(UITextField *)currentTextField;
@end
