//
//  PhotoCell.m
//  RecycleRush
//
//  Created by FRC on 3/8/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "PhotoCell.h"

@implementation PhotoCell

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

-(void) setThumbnail:(UIImage *)photo {
    self.thumbnailView.image = photo;
}

@end
