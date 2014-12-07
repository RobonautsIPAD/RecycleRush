//
//  ElimDataViewController.m
//  AerialAssist
//
//  Created by FRC on 3/22/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "ElimDataViewController.h"
#import "DataManager.h"
#import "DataConvenienceMethods.h"
#import "EnumerationDictionary.h"
#import "TeamData.h"
#import "TeamScore.h"
#import "MatchData.h"
#import "MatchUtilities.h"
#import "TournamentData.h"

@interface ElimDataViewController (){
    NSString *tournamentName;
    NSUserDefaults *prefs;
    NSDictionary *matchTypeDictionary;
    NSDictionary *allianceDictionary;
    MatchUtilities *matchUtilities;
}
// Quarter Final Alliance 1 Radio Button
@property (nonatomic, weak) IBOutlet UIButton *sfAlliance1Button;
// Quarter Final Alliance 2 Radio Button
@property (nonatomic, weak) IBOutlet UIButton *sfAlliance2Button;
// Quarter Final Alliance 3 Radio Button
@property (nonatomic, weak) IBOutlet UIButton *sfAlliance3Button;
// Quarter Final Alliance 4 Radio Button
@property (nonatomic, weak) IBOutlet UIButton *sfAlliance4Button;
// Quarter Final Alliance 5 Radio Button
@property (nonatomic, weak) IBOutlet UIButton *sfAlliance5Button;
// Quarter Final Alliance 6 Radio Button
@property (nonatomic, weak) IBOutlet UIButton *sfAlliance6Button;
// Quarter Final Alliance 7 Radio Button
@property (nonatomic, weak) IBOutlet UIButton *sfAlliance7Button;
// Quarter Final Alliance 8 Radio Button
@property (nonatomic, weak) IBOutlet UIButton *sfAlliance8Button;

// alliance text fields
//aliance 1
@property (nonatomic, weak) IBOutlet UITextField *alliance1Captain;
@property (nonatomic, weak) IBOutlet UITextField *alliance1Partner1;
@property (nonatomic, weak) IBOutlet UITextField *alliance1Partner2;
@property (nonatomic, weak) IBOutlet UITextField *alliance1Partner3;

//aliance 2
@property (nonatomic, weak) IBOutlet UITextField *alliance2Captain;
@property (nonatomic, weak) IBOutlet UITextField *alliance2Partner1;
@property (nonatomic, weak) IBOutlet UITextField *alliance2Partner2;
@property (nonatomic, weak) IBOutlet UITextField *alliance2Partner3;

//aliance 3
@property (nonatomic, weak) IBOutlet UITextField *alliance3Captain;
@property (nonatomic, weak) IBOutlet UITextField *alliance3Partner1;
@property (nonatomic, weak) IBOutlet UITextField *alliance3Partner2;
@property (nonatomic, weak) IBOutlet UITextField *alliance3Partner3;

//aliance 4
@property (nonatomic, weak) IBOutlet UITextField *alliance4Captain;
@property (nonatomic, weak) IBOutlet UITextField *alliance4Partner1;
@property (nonatomic, weak) IBOutlet UITextField *alliance4Partner2;
@property (nonatomic, weak) IBOutlet UITextField *alliance4Partner3;

//aliance 5
@property (nonatomic, weak) IBOutlet UITextField *alliance5Captain;
@property (nonatomic, weak) IBOutlet UITextField *alliance5Partner1;
@property (nonatomic, weak) IBOutlet UITextField *alliance5Partner2;
@property (nonatomic, weak) IBOutlet UITextField *alliance5Partner3;

//aliance 6
@property (nonatomic, weak) IBOutlet UITextField *alliance6Captain;
@property (nonatomic, weak) IBOutlet UITextField *alliance6Partner1;
@property (nonatomic, weak) IBOutlet UITextField *alliance6Partner2;
@property (nonatomic, weak) IBOutlet UITextField *alliance6Partner3;

//aliance 7
@property (nonatomic, weak) IBOutlet UITextField *alliance7Captain;
@property (nonatomic, weak) IBOutlet UITextField *alliance7Partner1;
@property (nonatomic, weak) IBOutlet UITextField *alliance7Partner2;
@property (nonatomic, weak) IBOutlet UITextField *alliance7Partner3;

//aliance 8
@property (nonatomic, weak) IBOutlet UITextField *alliance8Captain;
@property (nonatomic, weak) IBOutlet UITextField *alliance8Partner1;
@property (nonatomic, weak) IBOutlet UITextField *alliance8Partner2;
@property (nonatomic, weak) IBOutlet UITextField *alliance8Partner3;

// Semi-Finals
// Semi-Final 1 Red
@property (weak, nonatomic) IBOutlet UILabel *semiFinal1RedLabel;
@property (nonatomic, weak) IBOutlet UITextField *semiFinal1Red1;
@property (nonatomic, weak) IBOutlet UITextField *semiFinal1Red2;
@property (nonatomic, weak) IBOutlet UITextField *semiFinal1Red3;
@property (nonatomic, weak) IBOutlet UITextField *semiFinal1Red4;
// Semi-Final 1 Blue
@property (weak, nonatomic) IBOutlet UILabel *semiFinal1BlueLabel;
@property (nonatomic, weak) IBOutlet UITextField *semiFinal1Blue1;
@property (nonatomic, weak) IBOutlet UITextField *semiFinal1Blue2;
@property (nonatomic, weak) IBOutlet UITextField *semiFinal1Blue3;
@property (nonatomic, weak) IBOutlet UITextField *semiFinal1Blue4;

// Semi-Final 2 Red
@property (weak, nonatomic) IBOutlet UILabel *semiFinal2RedLabel;
@property (nonatomic, weak) IBOutlet UITextField *semiFinal2Red1;
@property (nonatomic, weak) IBOutlet UITextField *semiFinal2Red2;
@property (nonatomic, weak) IBOutlet UITextField *semiFinal2Red3;
@property (nonatomic, weak) IBOutlet UITextField *semiFinal2Red4;
/// Semi-Finalist 4
@property (weak, nonatomic) IBOutlet UILabel *semiFinal2BlueLabel;
@property (nonatomic, weak) IBOutlet UITextField *semiFinal2Blue1;
@property (nonatomic, weak) IBOutlet UITextField *semiFinal2Blue2;
@property (nonatomic, weak) IBOutlet UITextField *semiFinal2Blue3;
@property (nonatomic, weak) IBOutlet UITextField *semiFinal2Blue4;
// Finalist
@property (nonatomic, weak) IBOutlet UIButton *finalist1Button;
@property (nonatomic, weak) IBOutlet UIButton *finalist2Button;
@property (nonatomic, weak) IBOutlet UIButton *finalist3Button;
@property (nonatomic, weak) IBOutlet UIButton *finalist4Button;
@property (weak, nonatomic) IBOutlet UILabel *finalRedLabel;
@property (weak, nonatomic) IBOutlet UILabel *finalBlueLabel;
@property (nonatomic, weak) IBOutlet UITextField *finalRed1;
@property (nonatomic, weak) IBOutlet UITextField *finalRed2;
@property (nonatomic, weak) IBOutlet UITextField *finalRed3;
@property (nonatomic, weak) IBOutlet UITextField *finalRed4;
@property (nonatomic, weak) IBOutlet UITextField *finalBlue1;
@property (nonatomic, weak) IBOutlet UITextField *finalBlue2;
@property (nonatomic, weak) IBOutlet UITextField *finalBlue3;
@property (nonatomic, weak) IBOutlet UITextField *finalBlue4;

//Generate Matches Button
@property (nonatomic, weak) IBOutlet UIButton *generateButton;

@end

@implementation ElimDataViewController

@synthesize dataManager = _dataManager;
@synthesize teamIndex = _teamIndex;
@synthesize team = _team;
@synthesize teamList = _teamList;

- (id)initWithDataManager:(DataManager *)initManager {
	if ((self = [super init]))
	{
        _dataManager = initManager;
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if (!_dataManager) {
        _dataManager = [[DataManager alloc] init];
    }
    
    prefs = [NSUserDefaults standardUserDefaults];
    tournamentName = [prefs objectForKey:@"tournament"];
    if (tournamentName) {
        self.title = tournamentName;
    }
    else {
        self.title = @"Elim Data";
    }

    matchTypeDictionary = [EnumerationDictionary initializeBundledDictionary:@"MatchType"];
    allianceDictionary = [EnumerationDictionary initializeBundledDictionary:@"AllianceList"];
    matchUtilities = [[MatchUtilities alloc] init:_dataManager];
  
    //Set SF & FI RadioButtons to Default to Off
    
    //SF Butttons
    [self setRadioButtonDefaults:_sfAlliance1Button];
    [self setRadioButtonDefaults:_sfAlliance2Button];
    [self setRadioButtonDefaults:_sfAlliance3Button];
    [self setRadioButtonDefaults:_sfAlliance4Button];
    [self setRadioButtonDefaults:_sfAlliance5Button];
    [self setRadioButtonDefaults:_sfAlliance6Button];
    [self setRadioButtonDefaults:_sfAlliance7Button];
    [self setRadioButtonDefaults:_sfAlliance8Button];
    
    //FI Buttons
    [self setRadioButtonDefaults:_finalist1Button];
    [self setRadioButtonDefaults:_finalist2Button];
    [self setRadioButtonDefaults:_finalist3Button];
    [self setRadioButtonDefaults:_finalist4Button];
    
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"MatchData" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"tournamentName = %@ AND matchType = %@", tournamentName, [EnumerationDictionary getValueFromKey:@"Elimination" forDictionary:matchTypeDictionary]];
    [fetchRequest setPredicate:pred];
    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:numberDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSArray *matchList = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    // Q1
    pred = [NSPredicate predicateWithFormat:@"number = %@", [NSNumber numberWithInt:1]];
    NSArray *match = [matchList filteredArrayUsingPredicate:pred];
    if ([match count]) {
        [self showMatch:@"Red" forMatch:[match objectAtIndex:0] forSlot1:_alliance1Captain forSlot2:_alliance1Partner1 forSlot3:_alliance1Partner2 forSlot4:_alliance1Partner3];
        [self showMatch:@"Blue" forMatch:[match objectAtIndex:0] forSlot1:_alliance8Captain forSlot2:_alliance8Partner1 forSlot3:_alliance8Partner2 forSlot4:_alliance8Partner3];
    }
    // Q2
    pred = [NSPredicate predicateWithFormat:@"number = %@", [NSNumber numberWithInt:2]];
    match = [matchList filteredArrayUsingPredicate:pred];
    if ([match count]) {
        [self showMatch:@"Red" forMatch:[match objectAtIndex:0] forSlot1:_alliance4Captain forSlot2:_alliance4Partner1 forSlot3:_alliance4Partner2 forSlot4:_alliance4Partner3];
        [self showMatch:@"Blue" forMatch:[match objectAtIndex:0] forSlot1:_alliance5Captain forSlot2:_alliance5Partner1 forSlot3:_alliance5Partner2 forSlot4:_alliance5Partner3];
    }
    // Q3
    pred = [NSPredicate predicateWithFormat:@"number = %@", [NSNumber numberWithInt:3]];
    match = [matchList filteredArrayUsingPredicate:pred];
    if ([match count]) {
        [self showMatch:@"Red" forMatch:[match objectAtIndex:0] forSlot1:_alliance2Captain forSlot2:_alliance2Partner1 forSlot3:_alliance2Partner2 forSlot4:_alliance2Partner3];
        [self showMatch:@"Blue" forMatch:[match objectAtIndex:0] forSlot1:_alliance7Captain forSlot2:_alliance7Partner1 forSlot3:_alliance7Partner2 forSlot4:_alliance7Partner3];
    }
    // Q4
    pred = [NSPredicate predicateWithFormat:@"number = %@", [NSNumber numberWithInt:4]];
    match = [matchList filteredArrayUsingPredicate:pred];
    if ([match count]) {
        [self showMatch:@"Red" forMatch:[match objectAtIndex:0] forSlot1:_alliance3Captain forSlot2:_alliance3Partner1 forSlot3:_alliance3Partner2 forSlot4:_alliance3Partner3];
        [self showMatch:@"Blue" forMatch:[match objectAtIndex:0] forSlot1:_alliance6Captain forSlot2:_alliance6Partner1 forSlot3:_alliance6Partner2 forSlot4:_alliance6Partner3];
    }

    // Semi 1
    pred = [NSPredicate predicateWithFormat:@"number = %@", [NSNumber numberWithInt:13]];
    match = [matchList filteredArrayUsingPredicate:pred];
    if ([match count]) {
        [self showMatch:@"Red" forMatch:[match objectAtIndex:0] forSlot1:_semiFinal1Red1 forSlot2:_semiFinal1Red2 forSlot3:_semiFinal1Red3 forSlot4:_semiFinal1Red4];
        [self showMatch:@"Blue" forMatch:[match objectAtIndex:0] forSlot1:_semiFinal1Blue1 forSlot2:_semiFinal1Blue2 forSlot3:_semiFinal1Blue3 forSlot4:_semiFinal1Blue4];
        [_finalist1Button setHidden:NO];
        [_finalist2Button setHidden:NO];
    }
    else {
        _semiFinal1Red1.text = @"";
        _semiFinal1Red2.text = @"";
        _semiFinal1Red3.text = @"";
        _semiFinal1Blue1.text = @"";
        _semiFinal1Blue2.text = @"";
        _semiFinal1Blue3.text = @"";
        [_finalist1Button setHidden:YES];
        [_finalist2Button setHidden:YES];
    }
    // Semi 2
    pred = [NSPredicate predicateWithFormat:@"number = %@", [NSNumber numberWithInt:14]];
    match = [matchList filteredArrayUsingPredicate:pred];
    if ([match count]) {
        [self showMatch:@"Red" forMatch:[match objectAtIndex:0] forSlot1:_semiFinal2Red1 forSlot2:_semiFinal2Red2 forSlot3:_semiFinal2Red3 forSlot4:_semiFinal2Red4];
        [self showMatch:@"Blue" forMatch:[match objectAtIndex:0] forSlot1:_semiFinal2Blue1 forSlot2:_semiFinal2Blue2 forSlot3:_semiFinal2Blue3 forSlot4:_semiFinal2Blue4];
        [_finalist3Button setHidden:NO];
        [_finalist4Button setHidden:NO];
    }
    else {
        _semiFinal2Red1.text = @"";
        _semiFinal2Red2.text = @"";
        _semiFinal2Red3.text = @"";
        _semiFinal2Blue1.text = @"";
        _semiFinal2Blue2.text = @"";
        _semiFinal2Blue3.text = @"";
        [_finalist3Button setHidden:YES];
        [_finalist4Button setHidden:YES];
    }
    // Final
    pred = [NSPredicate predicateWithFormat:@"number = %@", [NSNumber numberWithInt:19]];
    match = [matchList filteredArrayUsingPredicate:pred];
    if ([match count]) {
        [self showMatch:@"Red" forMatch:[match objectAtIndex:0] forSlot1:_finalRed1 forSlot2:_finalRed2 forSlot3:_finalRed3 forSlot4:_finalRed4];
        [self showMatch:@"Blue" forMatch:[match objectAtIndex:0] forSlot1:_finalBlue1 forSlot2:_finalBlue2 forSlot3:_finalBlue3 forSlot4:_finalBlue4
         ];
    }
    else {
        _finalRed1.text = @"";
        _finalRed2.text = @"";
        _finalRed3.text = @"";
        _finalBlue1.text = @"";
        _finalBlue2.text = @"";
        _finalBlue3.text = @"";
    }
}

-(void)showMatch:(NSString *)alliance forMatch:(MatchData *)match forSlot1:(UITextField *)team1 forSlot2:(UITextField *)team2 forSlot3:(UITextField *)team3 forSlot4:(UITextField *)team4 {
    NSArray *scoresList = [match.score allObjects];
    NSString *allianceStation = [alliance stringByAppendingString:@" 1"];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"allianceStation = %@", [EnumerationDictionary getValueFromKey:allianceStation forDictionary:allianceDictionary]];
    // NSLog(@"Alliance = %@", allianceStation);
    // Search for Alliance Station 1
    NSArray *score = [scoresList filteredArrayUsingPredicate:pred];
    NSNumber *teamNumber;
    if ([score count]) {
        TeamScore *teamScore = [score objectAtIndex:0];
        teamNumber = teamScore.teamNumber;
        team1.text = [NSString stringWithFormat:@"%d", [teamNumber intValue]];
    }
    // Search for Alliance Station 2
    allianceStation = [alliance stringByAppendingString:@" 2"];
    pred = [NSPredicate predicateWithFormat:@"allianceStation = %@", [EnumerationDictionary getValueFromKey:allianceStation forDictionary:allianceDictionary]];
    // NSLog(@"Alliance = %@", allianceStation);
    score = [scoresList filteredArrayUsingPredicate:pred];
    if ([score count]) {
        TeamScore *teamScore = [score objectAtIndex:0];
        teamNumber = teamScore.teamNumber;
        team2.text = [NSString stringWithFormat:@"%d", [teamNumber intValue]];
    }
    // Search for Alliance Station 3
    allianceStation = [alliance stringByAppendingString:@" 3"];
    pred = [NSPredicate predicateWithFormat:@"allianceStation = %@", [EnumerationDictionary getValueFromKey:allianceStation forDictionary:allianceDictionary]];
    // NSLog(@"Alliance = %@", allianceStation);
    score = [scoresList filteredArrayUsingPredicate:pred];
    if ([score count]) {
        TeamScore *teamScore = [score objectAtIndex:0];
        teamNumber = teamScore.teamNumber;
        team3.text = [NSString stringWithFormat:@"%d", [teamNumber intValue]];
    }
    // Search for Alliance Station 4
    allianceStation = [alliance stringByAppendingString:@" 4"];
    pred = [NSPredicate predicateWithFormat:@"allianceStation = %@", [EnumerationDictionary getValueFromKey:allianceStation forDictionary:allianceDictionary]];
    // NSLog(@"Alliance = %@", allianceStation);
    score = [scoresList filteredArrayUsingPredicate:pred];
    if ([score count]) {
        TeamScore *teamScore = [score objectAtIndex:0];
        teamNumber = teamScore.teamNumber;
        team4.text = [NSString stringWithFormat:@"%d", [teamNumber intValue]];
    }
}

-(void)setRadioButtonDefaults:(UIButton *)button {
    [button setImage:[UIImage imageNamed:@"RadioButton-Unselected.png"] forState:UIControlStateNormal];
}

-(IBAction)toggleRadioButtonState:(id)sender {
    if (sender == _sfAlliance1Button) {
        [self coupledRadioButtons:(UIButton *)_sfAlliance1Button forPair:(UIButton *)_sfAlliance8Button];
        [self createSemiMatch1Red];
    }
    else if (sender == _sfAlliance8Button) {
        [self coupledRadioButtons:(UIButton *)_sfAlliance8Button forPair:(UIButton *)_sfAlliance1Button];
        [self createSemiMatch1Red];
    }
    else if (sender == _sfAlliance4Button) {
        [self coupledRadioButtons:(UIButton *)_sfAlliance4Button forPair:(UIButton *)_sfAlliance5Button];
        [self createSemiMatch1Blue];
    }
    else if (sender == _sfAlliance5Button) {
        [self coupledRadioButtons:(UIButton *)_sfAlliance5Button forPair:(UIButton *)_sfAlliance4Button];
        [self createSemiMatch1Blue];
    }
    else if (sender == _sfAlliance2Button) {
        [self coupledRadioButtons:(UIButton *)_sfAlliance2Button forPair:(UIButton *)_sfAlliance7Button];
        [self createSemiMatch2Red];
    }
    else if (sender == _sfAlliance7Button) {
        [self coupledRadioButtons:(UIButton *)_sfAlliance7Button forPair:(UIButton *)_sfAlliance2Button];
        [self createSemiMatch2Red];
    }
    else if (sender == _sfAlliance3Button) {
        [self coupledRadioButtons:(UIButton *)_sfAlliance3Button forPair:(UIButton *)_sfAlliance6Button];
        [self createSemiMatch2Blue];
    }
    else if (sender == _sfAlliance6Button) {
        [self coupledRadioButtons:(UIButton *)_sfAlliance6Button forPair:(UIButton *)_sfAlliance3Button];
        [self createSemiMatch2Blue];
    }
    else if (sender == _finalist1Button) {
        [self coupledRadioButtons:(UIButton *)_finalist1Button forPair:(UIButton *)_finalist2Button];
        [self createFinalMatchRed];
    }
    else if (sender == _finalist2Button) {
        [self coupledRadioButtons:(UIButton *)_finalist2Button forPair:(UIButton *)_finalist1Button];
        [self createFinalMatchRed];
    }
    else if (sender == _finalist3Button) {
        [self coupledRadioButtons:(UIButton *)_finalist3Button forPair:(UIButton *)_finalist4Button];
        [self createFinalMatchBlue];
    }
    else if (sender == _finalist4Button) {
        [self coupledRadioButtons:(UIButton *)_finalist4Button forPair:(UIButton *)_finalist3Button];
        [self createFinalMatchBlue];
    }
}

-(void) coupledRadioButtons:(UIButton *)button1 forPair:(UIButton *)button2 {
    if ([button1 isSelected]) {
        [button1 setImage:[UIImage imageNamed:@"RadioButton-Unselected.png"] forState:UIControlStateNormal];
        [button1 setSelected:NO];
    } else {
        [button1 setImage:[UIImage imageNamed:@"RadioButton-Selected.png"] forState:UIControlStateSelected];
        [button1 setSelected:YES];
        [button2 setImage:[UIImage imageNamed:@"RadioButton-Unselected.png"] forState:UIControlStateNormal];
        [button2 setSelected:NO];
    }
}

-(void)createSemiMatch1Red {
    if ([_sfAlliance1Button isSelected]) {
        // move the #1 alliance over
        _semiFinal1RedLabel.text = @"Alliance 1";
        _semiFinal1Red1.text = _alliance1Captain.text;
        _semiFinal1Red2.text = _alliance1Partner1.text;
        _semiFinal1Red3.text = _alliance1Partner2.text;
        [_finalist1Button setHidden:NO];
    }
    else if ([_sfAlliance8Button isSelected]) {
        // move the #8 alliance over
        _semiFinal1RedLabel.text = @"Alliance 8";
        _semiFinal1Red1.text = _alliance8Captain.text;
        _semiFinal1Red2.text = _alliance8Partner1.text;
        _semiFinal1Red3.text = _alliance8Partner2.text;
        [_finalist1Button setHidden:NO];
    }
    else {
        // clear the semi
        _semiFinal1RedLabel.text = @"Alliance X";
        _semiFinal1Red1.text = @"";
        _semiFinal1Red2.text = @"";
        _semiFinal1Red3.text = @"";
        [_finalist1Button setSelected:NO];
        [_finalist1Button setHidden:YES];
    }
}

-(void)createSemiMatch1Blue {
    if ([_sfAlliance4Button isSelected]) {
        // move the #4 alliance over
        _semiFinal1BlueLabel.text = @"Alliance 4";
        _semiFinal1Blue1.text = _alliance4Captain.text;
        _semiFinal1Blue2.text = _alliance4Partner1.text;
        _semiFinal1Blue3.text = _alliance4Partner2.text;
        [_finalist2Button setHidden:NO];
    }
    else if ([_sfAlliance5Button isSelected]) {
        // move the #5 alliance over
        _semiFinal1BlueLabel.text = @"Alliance 5";
        _semiFinal1Blue1.text = _alliance5Captain.text;
        _semiFinal1Blue2.text = _alliance5Partner1.text;
        _semiFinal1Blue3.text = _alliance5Partner2.text;
        [_finalist2Button setHidden:NO];
    }
    else {
        // clear the semi
        _semiFinal1BlueLabel.text = @"Alliance Y";
        _semiFinal1Blue1.text = @"";
        _semiFinal1Blue2.text = @"";
        _semiFinal1Blue3.text = @"";
        [_finalist2Button setSelected:NO];
        [_finalist2Button setHidden:YES];
    }
}

-(void)createSemiMatch2Red {
    if ([_sfAlliance2Button isSelected]) {
        // move the #2 alliance over
        _semiFinal2RedLabel.text = @"Alliance 2";
        _semiFinal2Red1.text = _alliance2Captain.text;
        _semiFinal2Red2.text = _alliance2Partner1.text;
        _semiFinal2Red3.text = _alliance2Partner2.text;
        [_finalist3Button setHidden:NO];
    }
    else if ([_sfAlliance7Button isSelected]) {
        // move the #7 alliance over
        _semiFinal2RedLabel.text = @"Alliance 7";
        _semiFinal2Red1.text = _alliance7Captain.text;
        _semiFinal2Red2.text = _alliance7Partner1.text;
        _semiFinal2Red3.text = _alliance7Partner2.text;
        [_finalist3Button setHidden:NO];
    }
    else {
        // clear the semi
        _semiFinal2RedLabel.text = @"Alliance Z";
        _semiFinal2Red1.text = @"";
        _semiFinal2Red2.text = @"";
        _semiFinal2Red3.text = @"";
        [_finalist3Button setSelected:NO];
        [_finalist3Button setHidden:YES];
    }
}

-(void)createSemiMatch2Blue {
    if ([_sfAlliance3Button isSelected]) {
        // move the #3 alliance over
        _semiFinal2BlueLabel.text = @"Alliance 3";
        _semiFinal2Blue1.text = _alliance3Captain.text;
        _semiFinal2Blue2.text = _alliance3Partner1.text;
        _semiFinal2Blue3.text = _alliance3Partner2.text;
        [_finalist4Button setHidden:NO];
    }
    else if ([_sfAlliance6Button isSelected]) {
        // move the #6 alliance over
        _semiFinal2BlueLabel.text = @"Alliance 6";
        _semiFinal2Blue1.text = _alliance6Captain.text;
        _semiFinal2Blue2.text = _alliance6Partner1.text;
        _semiFinal2Blue3.text = _alliance6Partner2.text;
        [_finalist4Button setHidden:NO];
    }
    else {
        // clear the semi
        _semiFinal2BlueLabel.text = @"Alliance Q";
        _semiFinal2Blue1.text = @"";
        _semiFinal2Blue2.text = @"";
        _semiFinal2Blue3.text = @"";
        [_finalist4Button setSelected:NO];
        [_finalist4Button setHidden:YES];
    }
}

-(void)createFinalMatchRed {
    if ([_finalist1Button isSelected]) {
        // move the winning alliance over
        _finalRedLabel.text = _semiFinal1RedLabel.text;
        _finalRed1.text = _semiFinal1Red1.text;
        _finalRed2.text = _semiFinal1Red2.text;
        _finalRed3.text = _semiFinal1Red3.text;
    }
    else if ([_finalist2Button isSelected]) {
        // move the winning alliance over
        _finalRedLabel.text = _semiFinal1BlueLabel.text;
        _finalRed1.text = _semiFinal1Blue1.text;
        _finalRed2.text = _semiFinal1Blue2.text;
        _finalRed3.text = _semiFinal1Blue3.text;
    }
    else {
        // clear the semi
        _finalRedLabel.text = @"Alliance R";
        _finalRed1.text = @"";
        _finalRed2.text = @"";
        _finalRed3.text = @"";
    }
}

-(void)createFinalMatchBlue{
    if ([_finalist3Button isSelected]) {
        // move the winning alliance over
        _finalBlueLabel.text = _semiFinal2RedLabel.text;
        _finalBlue1.text = _semiFinal2Red1.text;
        _finalBlue2.text = _semiFinal2Red2.text;
        _finalBlue3.text = _semiFinal2Red3.text;
    }
    else if ([_finalist4Button isSelected]) {
        // move the winning alliance over
        _finalBlueLabel.text = _semiFinal1BlueLabel.text;
        _finalBlue1.text = _semiFinal2Blue1.text;
        _finalBlue2.text = _semiFinal2Blue2.text;
        _finalBlue3.text = _semiFinal2Blue3.text;
    }
    else {
        // clear the semi
        _finalBlueLabel.text = @"Alliance R";
        _finalBlue1.text = @"";
        _finalBlue2.text = @"";
        _finalBlue3.text = @"";
    }
}

-(IBAction)generateMatch:(id)sender {
    // Semi Final 1
    if ([_sfAlliance1Button isSelected] || [_sfAlliance8Button isSelected] || [_sfAlliance4Button isSelected] || [_sfAlliance5Button isSelected]) {
        [self makeMatches:([_sfAlliance1Button isSelected] || [_sfAlliance8Button isSelected])
                     blueStatus:([_sfAlliance4Button isSelected] || [_sfAlliance5Button isSelected])
         forStartingMatch:13 forIncrement:2
                    forRed1:_semiFinal1Red1.text forRed2:_semiFinal1Red2.text forRed3:_semiFinal1Red3.text forRed4:_semiFinal1Red4.text forBlue1:_semiFinal1Blue1.text forforBlue2:_semiFinal1Blue2.text forBlue3:_semiFinal1Blue3.text forBlue4:_semiFinal1Blue4.text];
    }
    // Semi Final 2
    if ([_sfAlliance2Button isSelected] || [_sfAlliance7Button isSelected] || [_sfAlliance3Button isSelected] || [_sfAlliance6Button isSelected]) {
        [self makeMatches:([_sfAlliance2Button isSelected] || [_sfAlliance7Button isSelected])
               blueStatus:([_sfAlliance3Button isSelected] || [_sfAlliance6Button isSelected])
         forStartingMatch:14 forIncrement:2
                  forRed1:_semiFinal2Red1.text forRed2:_semiFinal2Red2.text forRed3:_semiFinal2Red3.text forRed4:_semiFinal2Red4.text
                 forBlue1:_semiFinal2Blue1.text forforBlue2:_semiFinal2Blue2.text forBlue3:_semiFinal2Blue3.text forBlue4:_semiFinal2Blue4.text];
    }
    // Finals
    if ([_finalist1Button isSelected] || [_finalist2Button isSelected] || [_finalist3Button isSelected] || [_finalist4Button isSelected]) {
        [self makeMatches:([_finalist1Button isSelected] || [_finalist2Button isSelected])
               blueStatus:([_finalist3Button isSelected] || [_finalist4Button isSelected])
         forStartingMatch:19 forIncrement:1
                  forRed1:_finalRed1.text forRed2:_finalRed2.text forRed3:_finalRed3.text forRed4:_finalRed4.text                  forBlue1:_finalBlue1.text forforBlue2:_finalBlue2.text forBlue3:_finalBlue3.text forBlue4:_finalBlue4.text];
    }
}

-(void)makeMatches:(BOOL)redSelected blueStatus:(BOOL)blueSelected forStartingMatch:(int)startMatch
            forIncrement:(int)intcrementMatch
           forRed1:(NSString *)red1 forRed2:(NSString *)red2 forRed3:(NSString *)red3 forRed4:(NSString *)red4
           forBlue1:(NSString *)blue1 forforBlue2:(NSString *)blue2 forBlue3:(NSString *)blue3 forBlue4:(NSString *)blue4
{
    NSMutableArray *teamList1 = [[NSMutableArray alloc] init];
    NSMutableArray *teamList2 = [[NSMutableArray alloc] init];
    NSMutableArray *teamList3 = [[NSMutableArray alloc] init];

    if (redSelected) {
        if (red1 && ![red1 isEqualToString:@""]) {
            NSDictionary *teamInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:[red1 intValue]] forKey:@"Red 1"];
            [teamList1 addObject:teamInfo];
            teamInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:[red1 intValue]] forKey:@"Red 2"];
            [teamList2 addObject:teamInfo];
            teamInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:[red1 intValue]] forKey:@"Red 3"];
            [teamList3 addObject:teamInfo];
        }
        if (red2 && ![red2 isEqualToString:@""]) {
            NSDictionary *teamInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:[red2 intValue]] forKey:@"Red 2"];
            [teamList1 addObject:teamInfo];
            teamInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:[red2 intValue]] forKey:@"Red 3"];
            [teamList2 addObject:teamInfo];
            teamInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:[red2 intValue]] forKey:@"Red 1"];
            [teamList3 addObject:teamInfo];
        }
        if (red3 && ![red3 isEqualToString:@""]) {
            NSDictionary *teamInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:[red3 intValue]] forKey:@"Red 3"];
            [teamList1 addObject:teamInfo];
            teamInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:[red3 intValue]] forKey:@"Red 1"];
            [teamList2 addObject:teamInfo];
            teamInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:[red3 intValue]] forKey:@"Red 2"];
            [teamList3 addObject:teamInfo];
        }
        if (red4 && ![red4 isEqualToString:@""]) {
            NSDictionary *teamInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:[red4 intValue]] forKey:@"Red 4"];
            [teamList1 addObject:teamInfo];
            [teamList2 addObject:teamInfo];
            [teamList3 addObject:teamInfo];
        }
    }
    if (blueSelected) {
        if (blue1 && ![blue1 isEqualToString:@""]) {
            NSDictionary *teamInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:[blue1 intValue]] forKey:@"Blue 1"];
            [teamList1 addObject:teamInfo];
            teamInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:[blue1 intValue]] forKey:@"Blue 2"];
            [teamList2 addObject:teamInfo];
            teamInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:[blue1 intValue]] forKey:@"Blue 3"];
            [teamList3 addObject:teamInfo];
        }
        if (blue2 && ![blue2 isEqualToString:@""]) {
            NSDictionary *teamInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:[blue2 intValue]] forKey:@"Blue 2"];
            [teamList1 addObject:teamInfo];
            teamInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:[blue2 intValue]] forKey:@"Blue 3"];
            [teamList2 addObject:teamInfo];
            teamInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:[blue2 intValue]] forKey:@"Blue 1"];
            [teamList3 addObject:teamInfo];
        }
        if (blue3 && ![blue3 isEqualToString:@""]) {
            NSDictionary *teamInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:[blue3 intValue]] forKey:@"Blue 3"];
            [teamList1 addObject:teamInfo];
            teamInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:[blue3 intValue]] forKey:@"Blue 1"];
            [teamList2 addObject:teamInfo];
            teamInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:[blue3 intValue]] forKey:@"Blue 2"];
            [teamList3 addObject:teamInfo];
        }
    }
    // First Match
    NSError *err;
    MatchData *match = [matchUtilities addMatch:[NSNumber numberWithInt:startMatch] forMatchType:@"Elimination" forTeams:teamList1 forTournament:tournamentName error:&err];
    match = [matchUtilities addMatch:[NSNumber numberWithInt:startMatch+intcrementMatch] forMatchType:@"Elimination" forTeams:teamList2 forTournament:tournamentName  error:&err];
    match = [matchUtilities addMatch:[NSNumber numberWithInt:startMatch+intcrementMatch*2] forMatchType:@"Elimination" forTeams:teamList3 forTournament:tournamentName  error:&err];
    if (match) {
        if (![_dataManager.managedObjectContext save:&err]) {
            NSLog(@"Whoops, couldn't save: %@", [err localizedDescription]);
        }
    }
 }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
