//
//  TeamMatchListViewController.m
//  RecycleRush
//
//  Created by FRC on 2/7/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import "TeamMatchListViewController.h"
#import "DataManager.h"
#import "TeamData.h"
#import "TeamScore.h"
#import "MatchAccessors.h"
#import "ScoreAccessors.h"
#import "MainMatchAnalysisViewController.h"
#import "LNNumberpad.h"
#import "MainMatchAnalysisViewController.h"
#import "TournamentData.h"
#import "DataManager.h"
#import "DataConvenienceMethods.h"
#import "TeamAccessors.h"
#import "MatchData.h"
#import "MatchUtilities.h"
#import "TeamData.h"
#import "TeamScore.h"
#import "MatchFlow.h"
#import "CalculateTeamStats.h"
#import "TeamDetailViewController.h"
#import "FieldDrawingViewController.h"
#import "FileIOMethods.h"
#import <QuartzCore/CALayer.h>
#import "LNNumberpad.h"

@interface TeamMatchListViewController ()
@property (nonatomic, weak) IBOutlet UITextField *teamNumberText;
@property (nonatomic, weak) IBOutlet UIButton *competitionButton;
@property (nonatomic, weak) IBOutlet UIButton *practiceButton;
@property (nonatomic, weak) IBOutlet UIButton *testButton;
@property  (nonatomic, weak) IBOutlet UITableView *matchesTable;

@end

@implementation TeamMatchListViewController {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSDictionary *matchTypeDictionary;
    NSArray *fullMatchList;
    NSMutableArray *matchList;
    TeamData *team;
    BOOL competitionState;
    BOOL testState;
    BOOL practiceState;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    prefs = [NSUserDefaults standardUserDefaults];
    tournamentName = [prefs objectForKey:@"tournament"];
    if (tournamentName) {
        self.title =  [NSString stringWithFormat:@"%@ Team Analysis", tournamentName];
        _teamNumberText.inputView  = [LNNumberpad defaultLNNumberpad];
    }
    else {
        self.title = @"Team Analysis";
    }

    matchTypeDictionary = _dataManager.matchTypeDictionary;
    
    // Default to our team. Someday create saveable preferences
    _teamNumberText.text = @"118";
    
    competitionState = TRUE;
    practiceState = FALSE;
    testState = FALSE;
    [self createMatchList:_teamNumberText.text];

    [self setRadioButtonState:_competitionButton forState:competitionState];
    [self setRadioButtonState:_practiceButton forState:practiceState];
    [self setRadioButtonState:_testButton forState:testState];
}

-(void)createMatchList:(NSString *)teamNumberString {
    NSLog(@"Analysis view - createMatchList - add check for valid team");
    int teamNumber = [teamNumberString intValue];
    fullMatchList = [ScoreAccessors getMatchListForTeam:[NSNumber numberWithInt:teamNumber] forTournament:tournamentName fromDataManager:_dataManager];
    [self filterMatchList];
}

-(void)filterMatchList {
    NSPredicate *pred;
    matchList = [fullMatchList mutableCopy];
    if (!practiceState) {
        pred = [NSPredicate predicateWithFormat:@"matchType != %@", [MatchAccessors getMatchTypeFromString:@"Practice" fromDictionary:matchTypeDictionary]];
        [matchList filterUsingPredicate:pred];
    }
    if (!competitionState) {
        pred = [NSPredicate predicateWithFormat:@"matchType != %@ AND matchType != %@", [MatchAccessors getMatchTypeFromString:@"Qualification"  fromDictionary:matchTypeDictionary], [MatchAccessors getMatchTypeFromString:@"Elimination"  fromDictionary:matchTypeDictionary]];
        [matchList filterUsingPredicate:pred];
    }
    if (!testState) {
        pred = [NSPredicate predicateWithFormat:@"matchType != %@ AND matchType != %@", [MatchAccessors getMatchTypeFromString:@"Other" fromDictionary:matchTypeDictionary], [MatchAccessors getMatchTypeFromString:@"Testing"  fromDictionary:matchTypeDictionary]];
        [matchList filterUsingPredicate:pred];
    }
    [_matchesTable reloadData];
}

-(void)setRadioButtonState:(UIButton *)button forState:(BOOL)selection {
    if (selection) {
        [button setImage:[UIImage imageNamed:@"RadioButton-Selected.png"] forState:UIControlStateNormal];
    }
    else {
        [button setImage:[UIImage imageNamed:@"RadioButton-Unselected.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)matchTypeSelected:(id)sender {
    if (sender == _competitionButton) {
        competitionState = !competitionState;
        [self setRadioButtonState:_competitionButton forState:competitionState];
    }
    else if (sender == _practiceButton) {
        practiceState = !practiceState;
        [self setRadioButtonState:_practiceButton forState:practiceState];
    }
    else if (sender == _testButton) {
        testState = !testState;
        [self setRadioButtonState:_testButton forState:testState];
    }
    [self filterMatchList];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Segue occurs when the user selects a match out of the match list table. Receiving
    //  VC is the Main Match Anaylsis Page VC.
    NSIndexPath *indexPath = [self.matchesTable indexPathForCell:sender];
    [segue.destinationViewController setDataManager:_dataManager];
    // NSLog(@"Match list = %@", matchList);
    [segue.destinationViewController setTeamNumber:[NSNumber numberWithInt:[_teamNumberText.text intValue]]];
    TeamScore  *current = [matchList objectAtIndex:indexPath.row];
    [segue.destinationViewController setInitialMatchNumber:current.matchNumber];
    [segue.destinationViewController setInitialMatchType:current.matchType];
    [_matchesTable deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Limit the text field to numbers only.
    NSString *resultingString = [textField.text stringByReplacingCharactersInRange: range withString: string];
    
    // This allows backspace
    if ([resultingString length] == 0) {
        return true;
    }
    NSInteger holder;
    NSScanner *scan = [NSScanner scannerWithString: resultingString];
    
    return [scan scanInteger: &holder] && [scan isAtEnd];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [self createMatchList:textField.text];
    [_matchesTable reloadData];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [matchList count];
}

- (void)configureMatchCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    TeamScore  *score = [matchList objectAtIndex:indexPath.row];
    //  NSLog(@"score = %@", score);
	UILabel *label1 = (UILabel *)[cell viewWithTag:10];
	label1.text = [NSString stringWithFormat:@"%d", [score.matchNumber intValue]];
    
    UILabel *label2 = (UILabel *)[cell viewWithTag:20];
    label2.text = [MatchAccessors getMatchTypeString:score.matchType  fromDictionary:matchTypeDictionary];
    
    UILabel *label3 = (UILabel *)[cell viewWithTag:30];
    label3.text = [NSString stringWithFormat:@"%d", [score.totalScore intValue]];
    
    UILabel *label4 = (UILabel *)[cell viewWithTag:40];
    label4.text = [NSString stringWithFormat:@"%@", [score.results boolValue] ? @"Y": @"N"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:@"MatchSchedule"];
    // Set up the cell...
    [self configureMatchCell:cell atIndexPath:indexPath];
    
    return cell;
}

/*- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIColor *goldColor = [UIColor colorWithRed:(255.0/255.0) green:(190.0/255.0) blue:(0.0/255.0) alpha:(100.0/100.0)];
    cell.backgroundColor = goldColor;
    
    // Xcode 4.6.3 compatibility issue
    //self.matchesTable.layer.borderWidth = 2;
    //self.matchesTable.layer.borderColor = [[UIColor blackColor] CGColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // Draw top border only on first cell
    if (indexPath.row == 0) {
        UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
        topLineView.backgroundColor = [UIColor blackColor];
        [cell.contentView addSubview:topLineView];
    }
    
    UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, cell.bounds.size.height, self.view.bounds.size.width, 1)];
    bottomLineView.backgroundColor = [UIColor blackColor];
    [cell.contentView addSubview:bottomLineView];
    
}*/
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
