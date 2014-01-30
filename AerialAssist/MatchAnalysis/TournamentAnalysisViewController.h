//
//  TournamentAnalysisViewController.h
//  AerialAssist
//
//  Created by FRC on 1/13/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataManager;

@interface TournamentAnalysisViewController : UIViewController
@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, weak) IBOutlet UIImageView *splashPicture;
@property (nonatomic, weak) IBOutlet UIImageView *mainLogo;
@property (nonatomic, weak) IBOutlet UILabel *pictureCaption;
@property (nonatomic, weak) IBOutlet UIButton *masonPageButton;
@property (nonatomic, weak) IBOutlet UIButton *lucianPageButton;
@property (nonatomic, weak) IBOutlet UIButton *ridleyPageButton;
@end
