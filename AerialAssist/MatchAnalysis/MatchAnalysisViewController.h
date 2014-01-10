//
//  MatchAnalysisViewController.h
// Robonauts Scouting
//
//  Created by FRC on 2/15/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataManager;

@interface MatchAnalysisViewController : UIViewController
@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, weak) IBOutlet UIImageView *mainLogo;
@property (nonatomic, weak) IBOutlet UILabel *pictureCaption;
@property (nonatomic, weak) IBOutlet UIImageView *matchPicture;
@property (nonatomic, weak) IBOutlet UIButton *masonPageButton;
@property (nonatomic, weak) IBOutlet UIButton *rossPageButton;
@property (nonatomic, weak) IBOutlet UIButton *lucienPageButton;
@property (nonatomic, weak) IBOutlet UIImageView *splashPicture;

@end
