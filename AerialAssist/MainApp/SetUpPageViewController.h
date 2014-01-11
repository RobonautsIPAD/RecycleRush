//
//  SetUpPageViewController.h
// Robonauts Scouting
//
//  Created by Kris Pettinger on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DataManager;

@interface SetUpPageViewController : UIViewController
@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, weak) IBOutlet UIImageView *mainLogo;
@property (nonatomic, weak) IBOutlet UILabel *pictureCaption;
@property (nonatomic, weak) IBOutlet UIButton *matchSetUpButton;
@property (nonatomic, weak) IBOutlet UIButton *settingsButton;
@property (nonatomic, weak) IBOutlet UIButton *importDataButton;
@property (nonatomic, weak) IBOutlet UIButton *exportDataButton;
@property (nonatomic, weak) IBOutlet UIImageView *splashPicture;

@end
