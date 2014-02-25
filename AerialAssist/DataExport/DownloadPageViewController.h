//
//  DownloadPageViewController.h
// Robonauts Scouting
//
//  Created by Kris Pettinger on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@class MatchData;
@class TeamScore;
@class DataManager;

@interface DownloadPageViewController : UIViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) DataManager *dataManager;

-(IBAction)exportTapped:(id)sender;
-(void)emailTeamData;
-(void)emailMatchData;
-(NSString *)applicationDocumentsDirectory;
-(void)buildEmail:(NSArray *)filePaths attach:(NSArray *)emailFiles subject:(NSString *)emailSubject;

@end
