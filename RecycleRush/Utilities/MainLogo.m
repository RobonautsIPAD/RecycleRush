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
        CGFloat mainViewHeight = parent.bounds.size.height;
        rect.size.width = mainViewHeight/4;
        rect.size.height = mainViewHeight;
        image.frame = rect;
        [image setImage:LandscapeImage];
        NSLog(@"Landscape %lf, %lf", rect.size.width, rect.size.height);
    }
    else {
        CGRect rect = image.frame;
        // rect.origin.x = 0;
        CGFloat mainViewWidth = parent.bounds.size.width;
        rect.size.width = mainViewWidth;
        rect.size.height = mainViewWidth/4.6;
        image.frame = rect;
        [image setImage:PortraitImage];
        NSLog(@"Portrait");
    }
    return image;
}

@end
