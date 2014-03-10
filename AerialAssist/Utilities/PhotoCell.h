//
//  PhotoCell.h
//  AerialAssist
//
//  Created by FRC on 3/8/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoCell : UICollectionViewCell
@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic, strong) IBOutlet UIImageView *thumbnailView;

@end
