//
//  MainLogo.m
//  RecycleRush
//
//  Created by FRC on 12/5/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "MainLogo.h"

@implementation MainLogo
+(UIImageView *)rotate:(UIView *)parent forImageView:(UIImageView *)image forOrientation:(UIInterfaceOrientation)orientation {
    UIImage *LandscapeImage = [UIImage imageNamed:@"robonauts app banner original.jpg"];
    UIImage *PortraitImage = [[UIImage alloc] initWithCGImage: LandscapeImage.CGImage
                                                scale: 1.0
                                          orientation: UIImageOrientationLeft];
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        CGRect rect = image.frame;
        CGFloat mainViewWidth = parent.bounds.size.width;
        rect.size.width = mainViewWidth;
        rect.size.height = mainViewWidth/5.2;
        image.frame = rect;
        [image setImage:LandscapeImage];
        // NSLog(@"Landscape height width %lf, %lf", parent.bounds.size.height, parent.bounds.size.width);
    }
    else {
        CGRect rect = image.frame;
        // rect.origin.x = 0;
        CGFloat mainViewHeight = parent.bounds.size.height;
        rect.size.width = mainViewHeight/4;
        rect.size.height = mainViewHeight;
        image.frame = rect;
        [image setImage:PortraitImage];
        // NSLog(@"Portrait height width %lf, %lf", parent.bounds.size.height, parent.bounds.size.width);
    }
    return image;
}

@end
