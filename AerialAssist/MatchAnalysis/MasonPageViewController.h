//
//  MasonPageViewController.h
// Robonauts Scouting
//
//  Created by FRC on 3/21/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MatchTypePickerController.h"

@class MatchData;
@class TeamScore;
@class TeamData;
@class Statistics;
@class DataManager;

@interface MasonPageViewController : UIViewController <NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, MatchTypePickerDelegate>

@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, assign) MatchType currentSectionType;
@property (nonatomic, assign) NSUInteger sectionIndex;
@property (nonatomic, assign) NSUInteger rowIndex;
@property (nonatomic, assign) NSUInteger teamIndex;
@property (nonatomic, strong) MatchData *currentMatch;

// Match Control
@property (nonatomic, weak) IBOutlet UIButton *prevMatch;
@property (nonatomic, weak) IBOutlet UIButton *nextMatch;
@property (nonatomic, weak) IBOutlet UIButton *ourPrevMatch;
@property (nonatomic, weak) IBOutlet UIButton *ourNextMatch;
-(IBAction)PrevButton;
-(IBAction)OurNextButton;
-(IBAction)OurPrevButton;
-(IBAction)NextButton;
-(NSUInteger)GetNextSection:(MatchType) currentSection;
-(NSUInteger)GetPreviousSection:(NSUInteger) currentSection;
-(int)getNumberOfMatches:(NSUInteger)section;
-(MatchData *)getCurrentMatch;
-(NSMutableArray *)getMatchTypeList;
-(NSUInteger)getMatchSectionInfo:(MatchType)matchSection;

// Match Number
@property (nonatomic, weak) IBOutlet UITextField *matchNumber;
-(IBAction)MatchNumberChanged;

// Match Type
@property (nonatomic, weak) IBOutlet UIButton *matchType;
@property (nonatomic, strong) NSMutableArray *matchTypeList;
@property (nonatomic, strong) MatchTypePickerController *matchTypePicker;
@property (nonatomic, strong) UIPopoverController *matchTypePickerPopover;
-(IBAction)MatchTypeSelectionChanged:(id)sender;

// Team Statistics Table
@property (nonatomic, strong) NSMutableArray *teamData;
@property (nonatomic, strong) NSMutableArray *teamList;
@property (nonatomic, strong) NSMutableArray *teamMatches;
@property (nonatomic, strong) NSMutableArray *teamAuton;
@property (nonatomic, strong) NSMutableArray *teamTeleOp;
@property (nonatomic, strong) NSMutableArray *teamHang;
@property (nonatomic, strong) NSMutableArray *teamHangLevel;
@property (nonatomic, strong) NSMutableArray *teamDriving;
@property (nonatomic, strong) NSMutableArray *teamDefense;
@property (nonatomic, strong) NSMutableArray *teamSpeed;
@property (nonatomic, strong) NSMutableArray *teamHeight;

@property (nonatomic, weak) IBOutlet UITableView *teamInfo;
@property (nonatomic, strong) UIView *teamHeader;

// Team Match List Table
@property (nonatomic, retain) NSArray *red1Matches;
@property (nonatomic, retain) NSArray *red1;
@property (nonatomic, retain) NSArray *red2;
@property (nonatomic, retain) NSArray *red3;
@property (nonatomic, retain) Statistics *red1Stats;

// Team tables
@property (nonatomic, weak) IBOutlet UILabel *red1Team;
@property (nonatomic, weak) IBOutlet UILabel *red2Team;
@property (nonatomic, weak) IBOutlet UILabel *red3Team;
@property (nonatomic, weak) IBOutlet UILabel *blue1Team;
@property (nonatomic, weak) IBOutlet UILabel *blue2Team;
@property (nonatomic, weak) IBOutlet UILabel *blue3Team;

@property (nonatomic, weak) IBOutlet UITableView *red1Table;
@property (nonatomic, weak) IBOutlet UITableView *red2Table;
@property (nonatomic, weak) IBOutlet UITableView *red3Table;
@property (nonatomic, weak) IBOutlet UITableView *blue1Table;
@property (nonatomic, weak) IBOutlet UITableView *blue2Table;
@property (nonatomic, weak) IBOutlet UITableView *blue3Table;

// Team Scores for Segue
@property (nonatomic, retain) NSMutableArray *red1Scores;
@property (nonatomic, retain) NSMutableArray *red2Scores;
@property (nonatomic, retain) NSMutableArray *red3Scores;
@property (nonatomic, retain) NSMutableArray *blue1Scores;
@property (nonatomic, retain) NSMutableArray *blue2Scores;
@property (nonatomic, retain) NSMutableArray *blue3Scores;


// Data Handling
-(void)ShowMatch;
-(void)setTeamList;
-(NSMutableArray *)getScoreList:(TeamData *)team;

// Make It Look Good
-(void)SetTextBoxDefaults:(UITextField *)textField;
-(void)SetBigButtonDefaults:(UIButton *)currentButton;
-(void)SetSmallButtonDefaults:(UIButton *)currentButton;

- (NSString *)applicationDocumentsDirectory;

@end
