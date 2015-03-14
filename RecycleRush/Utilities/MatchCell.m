//
//  MatchCell.m
//  RecycleRush
//
//  Created by FRC on 3/13/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import "MatchCell.h"

@implementation MatchCell

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
-(void) setMatchImage:(UIImage *)photo {
    self.matchPhoto.image = photo;
}

@end
