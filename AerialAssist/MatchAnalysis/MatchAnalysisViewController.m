//
//  MatchAnalysisViewController.m
// Robonauts Scouting
//
//  Created by FRC on 2/15/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "MatchAnalysisViewController.h"
#import "MasonPageViewController.h"
#import "DataManager.h"
#import "DataConvenienceMethods.h"
#import "MatchData.h"
#import "TeamScore.h"
#import "EnumerationDictionary.h"

@interface MatchAnalysisViewController ()
    @property  (nonatomic, weak) IBOutlet UITableView *matchesTable;
    @property (nonatomic, weak) IBOutlet UITextField *teamNumberText;
    @property (nonatomic, weak) IBOutlet UIButton *competitionButton;
    @property (nonatomic, weak) IBOutlet UIButton *practiceButton;
    @property (nonatomic, weak) IBOutlet UIButton *testButton;
    @property (nonatomic, weak) IBOutlet UIImageView *mainLogo;
    @property (nonatomic, weak) IBOutlet UILabel *pictureCaption;
    @property (nonatomic, weak) IBOutlet UIImageView *matchPicture;
    @property (nonatomic, weak) IBOutlet UIImageView *splashPicture;

@end


@implementation MatchAnalysisViewController{
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
    NSLog(@"Match Analysis Page");
    // Display the Robonauts Banner
    [_mainLogo setImage:[UIImage imageNamed:@"robonauts app banner.jpg"]];
    // Display the Label for the Picture
    _pictureCaption.font = [UIFont fontWithName:@"Nasalization" size:24.0];
    _pictureCaption.text = @"Just Hangin' Out";
    
    prefs = [NSUserDefaults standardUserDefaults];
    tournamentName = [prefs objectForKey:@"tournament"];
    if (tournamentName) {
        self.title = tournamentName;
    }
    matchTypeDictionary = [EnumerationDictionary initializeBundledDictionary:@"MatchType"];

    // Default to our team. Someday create saveable preferences
    _teamNumberText.text = @"118";
    competitionState = TRUE;
    practiceState = FALSE;
    testState = FALSE;
    
    [self setRadioButtonState:_competitionButton forState:competitionState];
    [self setRadioButtonState:_practiceButton forState:practiceState];
    [self setRadioButtonState:_testButton forState:testState];

    [self createMatchList:_teamNumberText.text];
 
    self.title = @"Match Analysis";
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)createMatchList:(NSString *)teamNumberString {
    NSLog(@"Analysis view - createMatchList - add check for valid team");
    int teamNumber = [teamNumberString intValue];
    fullMatchList = [DataConvenienceMethods getMatchListForTeam:[NSNumber numberWithInt:teamNumber] forTournament:tournamentName fromContext:_dataManager.managedObjectContext];
     NSLog(@"score count = %d", [fullMatchList count]);
    [self filterMatchList];
}

-(void)filterMatchList {
    NSPredicate *pred;
    matchList = [fullMatchList mutableCopy];
    if (!practiceState) {
        pred = [NSPredicate predicateWithFormat:@"matchType != %@", [EnumerationDictionary getValueFromKey:@"Practice" forDictionary:matchTypeDictionary]];
        [matchList filterUsingPredicate:pred];
    }
    if (!competitionState) {
        pred = [NSPredicate predicateWithFormat:@"matchType != %@ AND matchType != %@", [EnumerationDictionary getValueFromKey:@"Qualification" forDictionary:matchTypeDictionary],  [EnumerationDictionary getValueFromKey:@"Elimination" forDictionary:matchTypeDictionary]];
        [matchList filterUsingPredicate:pred];
    }
    if (!testState) {
        pred = [NSPredicate predicateWithFormat:@"matchType != %@ AND matchType != %@", [EnumerationDictionary getValueFromKey:@"Other" forDictionary:matchTypeDictionary],  [EnumerationDictionary getValueFromKey:@"Testing" forDictionary:matchTypeDictionary]];
        [matchList filterUsingPredicate:pred];
    }
    for (TeamScore *score in matchList) {
            NSLog(@"%@", score.matchNumber);
    }
    [_matchesTable reloadData];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Segue occurs when the user selects a match out of the match list table. Receiving
    //  VC is the Mason Page VC.
    NSIndexPath *indexPath = [self.matchesTable indexPathForCell:sender];
    [segue.destinationViewController setDataManager:_dataManager];
    // NSLog(@"Match list = %@", matchList);
    [segue.destinationViewController setTeamNumber:[NSNumber numberWithInt:[_teamNumberText.text intValue]]];
    TeamScore  *current = [matchList objectAtIndex:indexPath.row];
    [segue.destinationViewController setInitialMatchNumber:current.matchNumber];
    [segue.destinationViewController setInitialMatchType:current.matchType];
    [_matchesTable deselectRowAtIndexPath:indexPath animated:YES];
    
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSLog(@"Change char");
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
    NSLog(@"End edit");
    [self createMatchList:textField.text];
    [_matchesTable reloadData];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"Resign");
	[textField resignFirstResponder];
	return YES;
}

-(NSInteger)numberOfRowsInTableView:(UITableView *)tableView{
    return 1;
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
    label2.text = [EnumerationDictionary getKeyFromValue:score.matchType forDictionary:matchTypeDictionary];
    
    UILabel *label3 = (UILabel *)[cell viewWithTag:30];
    label3.text = @"";
    
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

/*
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            _mainLogo.frame = CGRectMake(-20, 0, 285, 960);
            [_mainLogo setImage:[UIImage imageNamed:@"robonauts app banner.jpg"]];
            _masonPageButton.frame = CGRectMake(325, 125, 400, 68);
            _lucienPageButton.frame = CGRectMake(325, 225, 400, 68);
            _splashPicture.frame = CGRectMake(293, 563, 468, 330);
            _pictureCaption.frame = CGRectMake(293, 901, 468, 39);
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            _mainLogo.frame = CGRectMake(0, -60, 1024, 255);
            [_mainLogo setImage:[UIImage imageNamed:@"robonauts app banner original.jpg"]];
            _masonPageButton.frame = CGRectMake(550, 225, 400, 68);
            _lucienPageButton.frame = CGRectMake(550, 325, 400, 68);
            _splashPicture.frame = CGRectMake(50, 243, 468, 330);
            _pictureCaption.frame = CGRectMake(50, 581, 468, 39);
            break;
        default:
            break;
    }
    // Return YES for supported orientations
	return YES;
} */


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
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
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
