//
//  ElimDataViewController.m
//  AerialAssist
//
//  Created by FRC on 3/22/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "ElimDataViewController.h"
#import "DataManager.h"
#import "TeamData.h"
#import "TeamScore.h"
#import "MatchData.h"
#import "TeamDataInterfaces.h"
#import "MatchDataInterfaces.h"
#import "TournamentData.h"

@interface ElimDataViewController (){
    NSString *tournamentName;
    NSUserDefaults *prefs;
    NSMutableDictionary *matchDictionary;
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

//aliance 2
@property (nonatomic, weak) IBOutlet UITextField *alliance2Captain;
@property (nonatomic, weak) IBOutlet UITextField *alliance2Partner1;
@property (nonatomic, weak) IBOutlet UITextField *alliance2Partner2;

//aliance 3
@property (nonatomic, weak) IBOutlet UITextField *alliance3Captain;
@property (nonatomic, weak) IBOutlet UITextField *alliance3Partner1;
@property (nonatomic, weak) IBOutlet UITextField *alliance3Partner2;

//aliance 4
@property (nonatomic, weak) IBOutlet UITextField *alliance4Captain;
@property (nonatomic, weak) IBOutlet UITextField *alliance4Partner1;
@property (nonatomic, weak) IBOutlet UITextField *alliance4Partner2;

//aliance 5
@property (nonatomic, weak) IBOutlet UITextField *alliance5Captain;
@property (nonatomic, weak) IBOutlet UITextField *alliance5Partner1;
@property (nonatomic, weak) IBOutlet UITextField *alliance5Partner2;

//aliance 6
@property (nonatomic, weak) IBOutlet UITextField *alliance6Captain;
@property (nonatomic, weak) IBOutlet UITextField *alliance6Partner1;
@property (nonatomic, weak) IBOutlet UITextField *alliance6Partner2;

//aliance 7
@property (nonatomic, weak) IBOutlet UITextField *alliance7Captain;
@property (nonatomic, weak) IBOutlet UITextField *alliance7Partner1;
@property (nonatomic, weak) IBOutlet UITextField *alliance7Partner2;

//aliance 8
@property (nonatomic, weak) IBOutlet UITextField *alliance8Captain;
@property (nonatomic, weak) IBOutlet UITextField *alliance8Partner1;
@property (nonatomic, weak) IBOutlet UITextField *alliance8Partner2;

// Semi-Finals
// Semi-Final 1 Red
@property (weak, nonatomic) IBOutlet UILabel *semiFinal1RedLabel;
@property (nonatomic, weak) IBOutlet UITextField *semiFinal1Red1;
@property (nonatomic, weak) IBOutlet UITextField *semiFinal1Red2;
@property (nonatomic, weak) IBOutlet UITextField *semiFinal1Red3;
// Semi-Final 1 Blue
@property (weak, nonatomic) IBOutlet UILabel *semiFinal1BlueLabel;
@property (nonatomic, weak) IBOutlet UITextField *semiFinal1Blue1;
@property (nonatomic, weak) IBOutlet UITextField *semiFinal1Blue2;
@property (nonatomic, weak) IBOutlet UITextField *semiFinal1Blue3;

// Semi-Final 2 Red
@property (weak, nonatomic) IBOutlet UILabel *semiFinal2RedLabel;
@property (nonatomic, weak) IBOutlet UITextField *semiFinal2Red1;
@property (nonatomic, weak) IBOutlet UITextField *semiFinal2Red2;
@property (nonatomic, weak) IBOutlet UITextField *semiFinal2Red3;
/// Semi-Finalist 4
@property (weak, nonatomic) IBOutlet UILabel *semiFinal2BlueLabel;
@property (nonatomic, weak) IBOutlet UITextField *semiFinal2Blue1;
@property (nonatomic, weak) IBOutlet UITextField *semiFinal2Blue2;
@property (nonatomic, weak) IBOutlet UITextField *semiFinal2Blue3;
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
@property (nonatomic, weak) IBOutlet UITextField *finalBlue1;
@property (nonatomic, weak) IBOutlet UITextField *finalBlue2;
@property (nonatomic, weak) IBOutlet UITextField *finalBlue3;

//Generate Matches Button
@property (nonatomic, weak) IBOutlet UIButton *generateButton;

@end

@implementation ElimDataViewController

@synthesize dataManager = _dataManager;
@synthesize teamIndex = _teamIndex;
@synthesize team = _team;
@synthesize fetchedResultsController = _fetchedResultsController;
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

    NSArray *matchKeys = [NSArray arrayWithObjects:@"tournamentName", @"matchType", nil];
    NSArray *matchObjects = [NSArray arrayWithObjects:tournamentName, @"Elimination", nil];
    matchDictionary = [NSMutableDictionary dictionaryWithObjects:matchObjects forKeys:matchKeys];
   
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
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"tournamentName = %@ AND matchType = %@", tournamentName, @"Elimination"];
    [fetchRequest setPredicate:pred];
    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:numberDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSArray *matchList = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    // Q1
    pred = [NSPredicate predicateWithFormat:@"number = %@", [NSNumber numberWithInt:1]];
    NSArray *match = [matchList filteredArrayUsingPredicate:pred];
    if ([match count]) {
        [self showMatch:@"Red" forMatch:[match objectAtIndex:0] forSlot1:_alliance1Captain forSlot2:_alliance1Partner1 forSlot:_alliance1Partner2];
        [self showMatch:@"Blue" forMatch:[match objectAtIndex:0] forSlot1:_alliance8Captain forSlot2:_alliance8Partner1 forSlot:_alliance8Partner2];
    }
    // Q2
    pred = [NSPredicate predicateWithFormat:@"number = %@", [NSNumber numberWithInt:2]];
    match = [matchList filteredArrayUsingPredicate:pred];
    if ([match count]) {
        [self showMatch:@"Red" forMatch:[match objectAtIndex:0] forSlot1:_alliance4Captain forSlot2:_alliance4Partner1 forSlot:_alliance4Partner2];
        [self showMatch:@"Blue" forMatch:[match objectAtIndex:0] forSlot1:_alliance5Captain forSlot2:_alliance5Partner1 forSlot:_alliance5Partner2];
    }
    // Q3
    pred = [NSPredicate predicateWithFormat:@"number = %@", [NSNumber numberWithInt:3]];
    match = [matchList filteredArrayUsingPredicate:pred];
    if ([match count]) {
        [self showMatch:@"Red" forMatch:[match objectAtIndex:0] forSlot1:_alliance2Captain forSlot2:_alliance2Partner1 forSlot:_alliance2Partner2];
        [self showMatch:@"Blue" forMatch:[match objectAtIndex:0] forSlot1:_alliance7Captain forSlot2:_alliance7Partner1 forSlot:_alliance7Partner2];
    }
    // Q4
    pred = [NSPredicate predicateWithFormat:@"number = %@", [NSNumber numberWithInt:4]];
    match = [matchList filteredArrayUsingPredicate:pred];
    if ([match count]) {
        [self showMatch:@"Red" forMatch:[match objectAtIndex:0] forSlot1:_alliance3Captain forSlot2:_alliance3Partner1 forSlot:_alliance3Partner2];
        [self showMatch:@"Blue" forMatch:[match objectAtIndex:0] forSlot1:_alliance6Captain forSlot2:_alliance6Partner1 forSlot:_alliance6Partner2];
    }

    // Semi 1
    pred = [NSPredicate predicateWithFormat:@"number = %@", [NSNumber numberWithInt:13]];
    match = [matchList filteredArrayUsingPredicate:pred];
    if ([match count]) {
        [self showMatch:@"Red" forMatch:[match objectAtIndex:0] forSlot1:_semiFinal1Red1 forSlot2:_semiFinal1Red2 forSlot:_semiFinal1Red3];
        [self showMatch:@"Blue" forMatch:[match objectAtIndex:0] forSlot1:_semiFinal1Blue1 forSlot2:_semiFinal1Blue2 forSlot:_semiFinal1Blue3];
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
        [self showMatch:@"Red" forMatch:[match objectAtIndex:0] forSlot1:_semiFinal2Red1 forSlot2:_semiFinal2Red2 forSlot:_semiFinal2Red3];
        [self showMatch:@"Blue" forMatch:[match objectAtIndex:0] forSlot1:_semiFinal2Blue1 forSlot2:_semiFinal2Blue2 forSlot:_semiFinal2Blue3];
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
        [self showMatch:@"Red" forMatch:[match objectAtIndex:0] forSlot1:_finalRed1 forSlot2:_finalRed2 forSlot:_finalRed3];
        [self showMatch:@"Blue" forMatch:[match objectAtIndex:0] forSlot1:_finalBlue1 forSlot2:_finalBlue2 forSlot:_finalBlue3];
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

-(void)showMatch:(NSString *)alliance forMatch:(MatchData *)match forSlot1:(UITextField *)team1 forSlot2:(UITextField *)team2 forSlot:(UITextField *)team3 {
    NSArray *scores = [match.score allObjects];
    NSString *allianceStation = [alliance stringByAppendingString:@" 1"];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"alliance = %@", allianceStation];
    // NSLog(@"Alliance = %@", allianceStation);
    // Search for Alliance Station 1
    NSArray *score = [scores filteredArrayUsingPredicate:pred];
    NSNumber *teamNumber;
    if ([score count]) {
        teamNumber = [[[score objectAtIndex:0] valueForKey:@"team"] valueForKey:@"number"];
        team1.text = [NSString stringWithFormat:@"%d", [teamNumber intValue]];
    }
    // Search for Alliance Station 2
    allianceStation = [alliance stringByAppendingString:@" 2"];
    pred = [NSPredicate predicateWithFormat:@"alliance = %@", allianceStation];
    // NSLog(@"Alliance = %@", allianceStation);
    score = [scores filteredArrayUsingPredicate:pred];
    if ([score count]) {
        teamNumber = [[[score objectAtIndex:0] valueForKey:@"team"] valueForKey:@"number"];
        team2.text = [NSString stringWithFormat:@"%d", [teamNumber intValue]];
    }
    // Search for Alliance Station 3
    allianceStation = [alliance stringByAppendingString:@" 3"];
    pred = [NSPredicate predicateWithFormat:@"alliance = %@", allianceStation];
    // NSLog(@"Alliance = %@", allianceStation);
    score = [scores filteredArrayUsingPredicate:pred];
    if ([score count]) {
        teamNumber = [[[score objectAtIndex:0] valueForKey:@"team"] valueForKey:@"number"];
        team3.text = [NSString stringWithFormat:@"%d", [teamNumber intValue]];
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
                    forRed1:_semiFinal1Red1.text forRed2:_semiFinal1Red2.text forRed3:_semiFinal1Red3.text
                    forBlue1:_semiFinal1Blue1.text forforBlue2:_semiFinal1Blue2.text forBlue3:_semiFinal1Blue3.text];
    }
    // Semi Final 2
    if ([_sfAlliance2Button isSelected] || [_sfAlliance7Button isSelected] || [_sfAlliance3Button isSelected] || [_sfAlliance6Button isSelected]) {
        [self makeMatches:([_sfAlliance2Button isSelected] || [_sfAlliance7Button isSelected])
               blueStatus:([_sfAlliance3Button isSelected] || [_sfAlliance6Button isSelected])
         forStartingMatch:14 forIncrement:2
                  forRed1:_semiFinal2Red1.text forRed2:_semiFinal2Red2.text forRed3:_semiFinal2Red3.text
                 forBlue1:_semiFinal2Blue1.text forforBlue2:_semiFinal2Blue2.text forBlue3:_semiFinal2Blue3.text];
    }
    // Finals
    if ([_finalist1Button isSelected] || [_finalist2Button isSelected] || [_finalist3Button isSelected] || [_finalist4Button isSelected]) {
        [self makeMatches:([_finalist1Button isSelected] || [_finalist2Button isSelected])
               blueStatus:([_finalist3Button isSelected] || [_finalist4Button isSelected])
         forStartingMatch:19 forIncrement:1
                  forRed1:_finalRed1.text forRed2:_finalRed2.text forRed3:_finalRed3.text
                 forBlue1:_finalBlue1.text forforBlue2:_finalBlue2.text forBlue3:_finalBlue3.text];
    }
}

-(void)makeMatches:(BOOL)redSelected blueStatus:(BOOL)blueSelected forStartingMatch:(int)startMatch
            forIncrement:(int)intcrementMatch
           forRed1:(NSString *)red1 forRed2:(NSString *)red2 forRed3:(NSString *)red3
           forBlue1:(NSString *)blue1 forforBlue2:(NSString *)blue2 forBlue3:(NSString *)blue3
{
    [matchDictionary setObject:[NSNumber numberWithInt:startMatch] forKey:@"number"];
    NSMutableDictionary *teamsA = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *teamsB = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *teamsC = [[NSMutableDictionary alloc] init];

    if (redSelected) {
        if (red1 && ![red1 isEqualToString:@""]) {
            [teamsA setObject:[NSNumber numberWithInt:[red1 intValue]] forKey:@"Red 1"];
            [teamsB setObject:[NSNumber numberWithInt:[red1 intValue]] forKey:@"Red 2"];
            [teamsC setObject:[NSNumber numberWithInt:[red1 intValue]] forKey:@"Red 3"];
        }
        if (red2 && ![red2 isEqualToString:@""]) {
            [teamsA setObject:[NSNumber numberWithInt:[red2 intValue]] forKey:@"Red 2"];
            [teamsB setObject:[NSNumber numberWithInt:[red2 intValue]] forKey:@"Red 3"];
            [teamsC setObject:[NSNumber numberWithInt:[red2 intValue]] forKey:@"Red 1"];
        }
        if (red3 && ![red3 isEqualToString:@""]) {
            [teamsA setObject:[NSNumber numberWithInt:[red3 intValue]] forKey:@"Red 3"];
            [teamsB setObject:[NSNumber numberWithInt:[red3 intValue]] forKey:@"Red 1"];
            [teamsC setObject:[NSNumber numberWithInt:[red3 intValue]] forKey:@"Red 2"];
        }
    }
    if (blueSelected) {
        if (blue1 && ![blue1 isEqualToString:@""]) {
            [teamsA setObject:[NSNumber numberWithInt:[blue1 intValue]] forKey:@"Blue 1"];
            [teamsB setObject:[NSNumber numberWithInt:[blue1 intValue]] forKey:@"Blue 2"];
            [teamsC setObject:[NSNumber numberWithInt:[blue1 intValue]] forKey:@"Blue 3"];
        }
        if (blue2 && ![blue2 isEqualToString:@""]) {
            [teamsA setObject:[NSNumber numberWithInt:[blue2 intValue]] forKey:@"Blue 2"];
            [teamsB setObject:[NSNumber numberWithInt:[blue2 intValue]] forKey:@"Blue 3"];
            [teamsC setObject:[NSNumber numberWithInt:[blue2 intValue]] forKey:@"Blue 1"];
        }
        if (blue3 && ![blue3 isEqualToString:@""]) {
            [teamsA setObject:[NSNumber numberWithInt:[blue3 intValue]] forKey:@"Blue 3"];
            [teamsB setObject:[NSNumber numberWithInt:[blue3 intValue]] forKey:@"Blue 1"];
            [teamsC setObject:[NSNumber numberWithInt:[blue3 intValue]] forKey:@"Blue 2"];
        }
    }
    // First Match
    [matchDictionary setObject:teamsA forKey:@"teams"];
    // NSLog(@"matchDictionary = %@", matchDictionary);
    MatchDataInterfaces *matchDataPackage = [[MatchDataInterfaces alloc] initWithDataManager:_dataManager];
    MatchData *match = [matchDataPackage updateMatch:matchDictionary];
    // Second Match
    [matchDictionary setObject:[NSNumber numberWithInt:(startMatch+intcrementMatch)] forKey:@"number"];
    [matchDictionary setObject:teamsB forKey:@"teams"];
    // NSLog(@"matchDictionary = %@", matchDictionary);
    match = [matchDataPackage updateMatch:matchDictionary];
    // Third Match
    [matchDictionary setObject:[NSNumber numberWithInt:(startMatch+intcrementMatch*2)] forKey:@"number"];
    [matchDictionary setObject:teamsC forKey:@"teams"];
    // NSLog(@"matchDictionary = %@", matchDictionary);
    match = [matchDataPackage updateMatch:matchDictionary];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
