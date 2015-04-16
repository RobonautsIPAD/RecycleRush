//
//  SplashPageViewController.h
// Robonauts Scouting
//
//  Created by Kris Pettinger on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DataManager;
@class ConnectionUtility;

@interface SplashPageViewController : UIViewController
{
IBOutlet UIImageView *image;
NSTimer *moveObjectTimer;
}
@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) ConnectionUtility *connectionUtility;
@property (nonatomic, weak) IBOutlet UIImageView *mainLogo;
@property (nonatomic, weak) IBOutlet UILabel *pictureCaption;
@property (nonatomic, weak) IBOutlet UIButton *teamScoutingButton;
@property (nonatomic, weak) IBOutlet UIButton *matchSetUpButton;
@property (nonatomic, weak) IBOutlet UIButton *matchScoutingButton;
@property (nonatomic, weak) IBOutlet UIButton *matchAnalysisButton;
@property (nonatomic, weak) IBOutlet UIButton *tournamentAnalysisButton;
@property (nonatomic, weak) IBOutlet UIImageView *splashPicture;
@end
