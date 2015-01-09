//
//  MainLogo.h
//  RecycleRush
//
//  Created by FRC on 12/5/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MainLogo : NSObject
+(UIImageView *)rotate:(UIView *)parent forImageView:(UIImageView *)image forOrientation:(UIInterfaceOrientation)orientation;
@end
