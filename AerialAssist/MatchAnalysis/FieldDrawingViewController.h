//
//  FieldDrawingViewController.h
// Robonauts Scouting
//
//  Created by FRC on 2/15/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MatchData;
@class TeamScore;

@interface FieldDrawingViewController : UIViewController <UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSArray *teamScores;
@property (nonatomic, assign) int *startingIndex;
@property (nonatomic, weak) IBOutlet UIButton *prevMatchButton;
@property (nonatomic, weak) IBOutlet UIButton *nextMatchButton;
- (IBAction)nextMatch:(id)sender;
- (IBAction)prevMatch:(id)sender;
@property (nonatomic, weak) IBOutlet UITextField *matchNumber;
@property (nonatomic, weak) IBOutlet UIButton *matchType;
@property (nonatomic, weak) IBOutlet UITextField *teamName;
@property (nonatomic, weak) IBOutlet UITextField *teamNumber;
@property (nonatomic, weak) IBOutlet UITextField *autonScoreMade;
@property (nonatomic, weak) IBOutlet UITextField *autonScoreShot;
@property (nonatomic, weak) IBOutlet UITextField *autonHotHigh;
@property (nonatomic, weak) IBOutlet UITextField *autonColdHigh;
@property (nonatomic, weak) IBOutlet UITextField *autonHotLow;
@property (nonatomic, weak) IBOutlet UITextField *autonColdLow;
@property (nonatomic, weak) IBOutlet UITextField *autonMissed;
@property (nonatomic, weak) IBOutlet UITextField *autonBlocked;

@property (nonatomic, weak) IBOutlet UITextField *teleOpScoreMade;
@property (nonatomic, weak) IBOutlet UITextField *teleOpScoreShot;
@property (nonatomic, weak) IBOutlet UITextField *teleOpHigh;
@property (nonatomic, weak) IBOutlet UITextField *teleOpLow;
@property (nonatomic, weak) IBOutlet UITextField *wallPickUp;
@property (nonatomic, weak) IBOutlet UITextField *wall1;
@property (nonatomic, weak) IBOutlet UITextField *wall2;
@property (nonatomic, weak) IBOutlet UITextField *wall3;
@property (nonatomic, weak) IBOutlet UITextField *wall4;
@property (nonatomic, weak) IBOutlet UITextField *floorPickUp;
@property (nonatomic, weak) IBOutlet UITextField *teleOpBlocked;
@property (nonatomic, weak) IBOutlet UITextField *teleOpMissed;

@property (nonatomic, weak) IBOutlet UITextField *trussThrow;
@property (nonatomic, weak) IBOutlet UITextField *trussCatch;

@property (nonatomic, weak) IBOutlet UITextField *pickUpHuman;
@property (nonatomic, weak) IBOutlet UITextField *pickUpFLoor;

@property (nonatomic, weak) IBOutlet UITextField *passFloor;
@property (nonatomic, weak) IBOutlet UITextField *passAir;

@property (nonatomic, weak) IBOutlet UITextView  *notes;
@property (nonatomic, weak) IBOutlet UIImageView *fieldImage;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImage;

-(void)setDisplayData;
-(void)loadFieldDrawing;
-(void)gotoNextMatch:(UISwipeGestureRecognizer *)gestureRecognizer;
-(void)gotoPrevMatch:(UISwipeGestureRecognizer *)gestureRecognizer;

// Make It Look Good
-(void)SetTextBoxDefaults:(UITextField *)textField;
-(void)SetSmallTextBoxDefaults:(UITextField *)textField;
-(void)SetBigButtonDefaults:(UIButton *)currentButton;
-(void)SetSmallButtonDefaults:(UIButton *)currentButton;

@end
