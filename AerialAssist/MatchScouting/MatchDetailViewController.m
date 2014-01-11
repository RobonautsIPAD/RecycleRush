//
//  MatchDetailViewController.m
// Robonauts Scouting
//
//  Created by Kris Pettinger on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MatchDetailViewController.h"
#import "MatchTypeDictionary.h"
#import "MatchTypePickerController.h"
#import "MatchData.h"
#import "TeamData.h"
#import "TeamScore.h"
#import "DataManager.h"

@implementation MatchDetailViewController {
    NSUserDefaults *prefs;
    NSArray *scoreData;
    BOOL dataChange;
    MatchTypeDictionary *matchDictionary;
    NSArray *matchTypeList;
    NSNumber *newMatchNumber;
    BOOL textChangeDetected;
    OverrideMode overrideMode;
}
@synthesize dataManager = _dataManager;
@synthesize match = _match;
@synthesize delegate = _delegate;
@synthesize numberTextField = _numberTextField;
@synthesize matchTypeButton = _matchTypeButton;
@synthesize matchTypePicker = _matchTypePicker;
@synthesize matchTypePickerPopover = _matchTypePickerPopover;
@synthesize red1TextField = _red1TextField;
@synthesize red2TextField = _red2TextField;
@synthesize red3TextField = _red3TextField;
@synthesize blue1TextField = _blue1TextField;
@synthesize blue2TextField = _blue2TextField;
@synthesize blue3TextField = _blue3TextField;
// User Access Control
@synthesize alertPrompt = _alertPrompt;
@synthesize alertPromptPopover = _alertPromptPopover;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    [super viewDidUnload];
    _dataManager = nil;
    _match = nil;
    prefs = nil;
    scoreData = nil;
    matchDictionary = nil;
    matchTypeList = nil;
    newMatchNumber = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!_dataManager) {
        _dataManager = [[DataManager alloc] init];
    }
    
    prefs = [NSUserDefaults standardUserDefaults];
    if (_match.tournamentName) {
        self.title =  [NSString stringWithFormat:@"%@ Match Detail", _match.tournamentName];
    }
    else {
        self.title = @"Match Detail";
    }
    dataChange = NO;

    matchDictionary = [[MatchTypeDictionary alloc] init];
    matchTypeList = [matchDictionary getMatchTypes];

    _numberTextField.font = [UIFont fontWithName:@"Helvetica" size:24.0];
    _numberTextField.text = [NSString stringWithFormat:@"%d", [_match.number intValue]];
    _matchTypeButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:24.0];
    [_matchTypeButton setTitle:_match.matchType forState:UIControlStateNormal];
    NSSortDescriptor *allianceSort = [NSSortDescriptor sortDescriptorWithKey:@"alliance" ascending:YES];
    scoreData = [[_match.score allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:allianceSort]];

    
    _red1TextField.font = [UIFont fontWithName:@"Helvetica" size:24.0];
    _red2TextField.font = [UIFont fontWithName:@"Helvetica" size:24.0];
    _red3TextField.font = [UIFont fontWithName:@"Helvetica" size:24.0];
    _blue1TextField.font = [UIFont fontWithName:@"Helvetica" size:24.0];
    _blue2TextField.font = [UIFont fontWithName:@"Helvetica" size:24.0];
    _blue3TextField.font = [UIFont fontWithName:@"Helvetica" size:24.0];

    [self setTeamField:_red1TextField forTeam:[scoreData objectAtIndex:3]];
    [self setTeamField:_red2TextField forTeam:[scoreData objectAtIndex:4]];
    [self setTeamField:_red3TextField forTeam:[scoreData objectAtIndex:5]];
    [self setTeamField:_blue1TextField forTeam:[scoreData objectAtIndex:0]];
    [self setTeamField:_blue2TextField forTeam:[scoreData objectAtIndex:1]];
    [self setTeamField:_blue3TextField forTeam:[scoreData objectAtIndex:2]];
    textChangeDetected = NO;

    [_numberTextField addTarget:self action:@selector(textFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];
    [_red1TextField addTarget:self action:@selector(textFieldDidChange:)
            forControlEvents:UIControlEventEditingChanged];
    [_red2TextField addTarget:self action:@selector(textFieldDidChange:)
            forControlEvents:UIControlEventEditingChanged];
    [_red3TextField addTarget:self action:@selector(textFieldDidChange:)
            forControlEvents:UIControlEventEditingChanged];
    [_blue1TextField addTarget:self action:@selector(textFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];
    [_blue2TextField addTarget:self action:@selector(textFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];
    [_blue3TextField addTarget:self action:@selector(textFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];

}

-(IBAction)MatchTypeSelectionChanged:(id)sender {
    //    NSLog(@"matchTypeSelectionChanged");
    overrideMode = OverrideMatchTypeSelection;
    [self checkOverrideCode];
}

-(void)MatchTypeSelectionPopUp {
    if (_matchTypePicker == nil) {
        self.matchTypePicker = [[MatchTypePickerController alloc]
                                initWithStyle:UITableViewStylePlain];
        _matchTypePicker.delegate = self;
        _matchTypePicker.matchTypeChoices = [matchTypeList copy];
        self.matchTypePickerPopover = [[UIPopoverController alloc]
                                       initWithContentViewController:_matchTypePicker];
    }
    [self.matchTypePickerPopover presentPopoverFromRect:_matchTypeButton.bounds inView:_matchTypeButton
                               permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)matchTypeSelected:(NSString *)newMatchType {
    [self.matchTypePickerPopover dismissPopoverAnimated:YES];
    
    for (int i = 0 ; i < [matchTypeList count] ; i++) {
        if ([newMatchType isEqualToString:[matchTypeList objectAtIndex:i]]) {
            [self editMatch:_match.number forMatchType:newMatchType];
            [_matchTypeButton setTitle:_match.matchType forState:UIControlStateNormal];
            break;
        }
    }
}

-(void)matchNumberChanged:(NSNumber *)number forMatchType:(NSString *)matchType {
    if (![self editMatch:newMatchNumber forMatchType:_match.matchType]) {
        // The change failed. Reset field.
        _numberTextField.text = [NSString stringWithFormat:@"%d", [_match.number intValue]];
    }
}

-(BOOL)editMatch:(NSNumber *)number forMatchType:(NSString *)matchType {
    BOOL success = TRUE;
    //    NSLog(@"Searching for match = %@", matchNumber);
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"MatchData" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"number == %@ AND matchType == %@ and tournamentName = %@", number, matchType, _match.tournamentName];
    [fetchRequest setPredicate:predicate];
    
    NSArray *matchData = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!matchData) {
        NSLog(@"Karma disruption error");
        success = FALSE;
    }
    else {
        if([matchData count] > 0) {  // Match Exists
            success = FALSE;
        }
        else {
            success = TRUE;
            _match.number = number;
            _match.matchType = matchType;
            _match.matchTypeSection = [matchDictionary getMatchTypeEnum:matchType];
        }
    }
    if (success) {
        dataChange = TRUE;
        return TRUE;
    }
    else {
    //    NSString *msg = [NSString stringWithFormat:@"Error changing match"];
        UIAlertView *prompt  = [[UIAlertView alloc] initWithTitle:@"Team Change Alert"
                                                          message:@"Error changing match"
                                                         delegate:nil
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
        [prompt setAlertViewStyle:UIAlertViewStyleDefault];
        [prompt show];
        return FALSE;
    }
}


-(void)checkOverrideCode {
    // NSLog(@"Check override");
    if (_alertPrompt == nil) {
        self.alertPrompt = [[AlertPromptViewController alloc] initWithNibName:nil bundle:nil];
        _alertPrompt.delegate = self;
        _alertPrompt.titleText = @"Enter Over Ride Code";
        _alertPrompt.msgText = @"Be Very Sure";
        self.alertPromptPopover = [[UIPopoverController alloc]
                                   initWithContentViewController:_alertPrompt];
    }
    if (overrideMode == OverrideMatchNumberSelection) {
        [self.alertPromptPopover presentPopoverFromRect:_numberTextField.bounds inView:_numberTextField permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
        
    }
    else {
        [self.alertPromptPopover presentPopoverFromRect:_matchTypeButton.bounds inView:_matchTypeButton permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    }
    
    return;
}

- (void)passCodeResult:(NSString *)passCodeAttempt {
    [self.alertPromptPopover dismissPopoverAnimated:YES];
    NSString *overrideCode = [prefs objectForKey:@"overrideCode"];
    switch (overrideMode) {
        case OverrideMatchNumberSelection:
            if ([passCodeAttempt isEqualToString:overrideCode]) {
                [self matchNumberChanged:newMatchNumber forMatchType:_match.matchType];
            }
            break;
            
        case OverrideMatchTypeSelection:
            if ([passCodeAttempt isEqualToString:overrideCode]) {
                [self MatchTypeSelectionPopUp];
            }
            break;
                        
        default:
            break;
    }
    overrideMode = NoOverride;
}

-(void)setTeamField:(UITextField *)textBox forTeam:(TeamScore *)score {
    textBox.text = [NSString stringWithFormat:@"%d", [score.team.number intValue]];
    if ([score.saved intValue]) {
        textBox.textColor = [UIColor redColor];
        [textBox setEnabled:NO];
    }
    else {
        textBox.textColor = [UIColor blackColor];
        [textBox setEnabled:YES];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    // NSLog(@"viewWillDisappear");
    if (!_delegate) NSLog(@"Match Detail Delegate Problem");
    [_delegate matchDetailReturned:dataChange];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Text Fields

-(void)textFieldDidChange:(UITextField *)textField {
    // whatever you wanted to do
    // NSLog(@"DidChange");
    textChangeDetected = YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    BOOL success = TRUE;
    if (!textChangeDetected) return YES;
    // NSLog(@"EndEditing");
    int number = [textField.text intValue];
    
    if (textField == _numberTextField) {
        int number = [textField.text intValue];
        newMatchNumber = [NSNumber numberWithInt:number];
        overrideMode = OverrideMatchNumberSelection;
        [self checkOverrideCode];
    }
	else if (textField == _red1TextField) {
        if (![self editTeam:number forScore:[scoreData objectAtIndex:3]]) {
            success = FALSE;
            // The change failed. Reset the field to what it used to be
            [self setTeamField:_red1TextField forTeam:[scoreData objectAtIndex:3]];
        }
	}
    else if (textField == _red2TextField) {
        if (![self editTeam:number forScore:[scoreData objectAtIndex:4]]) {
            success = FALSE;
            // The change failed. Reset the field to what it used to be
            [self setTeamField:_red2TextField forTeam:[scoreData objectAtIndex:4]];
        }
	}
	else if (textField == _red3TextField) {
        if (![self editTeam:number forScore:[scoreData objectAtIndex:5]]) {
            success = FALSE;
            // The change failed. Reset the field to what it used to be
            [self setTeamField:_red3TextField forTeam:[scoreData objectAtIndex:5]];
        }
	}
	else if (textField == _blue1TextField) {
        if (![self editTeam:number forScore:[scoreData objectAtIndex:0]]) {
            success = FALSE;
            // The change failed. Reset the field to what it used to be
            [self setTeamField:_blue1TextField forTeam:[scoreData objectAtIndex:0]];
        }
	}
	else if (textField == _blue2TextField) {
        if (![self editTeam:number forScore:[scoreData objectAtIndex:1]]) {
            success = FALSE;
            // The change failed. Reset the field to what it used to be
            [self setTeamField:_blue2TextField forTeam:[scoreData objectAtIndex:1]];
        }
	}
	else if (textField == _blue3TextField) {
        if (![self editTeam:number forScore:[scoreData objectAtIndex:2]]) {
            success = FALSE;
            // The change failed. Reset the field to what it used to be
            [self setTeamField:_blue3TextField forTeam:[scoreData objectAtIndex:2]];
        }
	}
    
    textChangeDetected = NO;
    if (success) {
        dataChange = TRUE;
    }
    else {
        NSString *msg = [NSString stringWithFormat:@"Error changing to team %d", number];
        UIAlertView *prompt  = [[UIAlertView alloc] initWithTitle:@"Team Change Alert"
                                                          message:msg
                                                         delegate:nil
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
        [prompt setAlertViewStyle:UIAlertViewStyleDefault];
        [prompt show];
    }
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // NSLog(@"ShouldReturn");
	[textField resignFirstResponder];
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // NSLog(@"shouldChange");
    NSString *resultingString = [textField.text stringByReplacingCharactersInRange: range withString: string];
    
    // This allows backspace
    if ([resultingString length] == 0) {
        return true;
    }
    
    NSInteger holder;
    NSScanner *scan = [NSScanner scannerWithString: resultingString];
    
    return [scan scanInteger: &holder] && [scan isAtEnd];
}

-(BOOL)editTeam:(int)teamNumber forScore:(TeamScore *)score{
    // NSLog(@"EditTeam");
    // Get team data object for team number
    TeamData *team = [self getTeam:teamNumber forTournament:_match.tournamentName];
    // NSLog(@"Team data = %@", team);
    if (!team) return 0;
    // check score to see if it is allocated
    if (score) {
        [self setScoreData:score];
        [score setTeam:team]; // Set Relationship!!! */
        return 1;
    }
    else return 0;
}

-(void)setScoreData:(TeamScore *)score {
    score.autonHigh = [NSNumber numberWithInt:0];
    score.autonMid = [NSNumber numberWithInt:0];
    score.autonLow = [NSNumber numberWithInt:0];
    score.autonMissed = [NSNumber numberWithInt:0];
    score.autonShotsMade = [NSNumber numberWithInt:0];
    score.totalAutonShots = [NSNumber numberWithInt:0];
    score.teleOpHigh = [NSNumber numberWithInt:0];
    score.teleOpMid = [NSNumber numberWithInt:0];
    score.teleOpLow = [NSNumber numberWithInt:0];
    score.teleOpMissed = [NSNumber numberWithInt:0];
    score.teleOpShots = [NSNumber numberWithInt:0];
    score.totalTeleOpShots = [NSNumber numberWithInt:0];
    score.pyramid = [NSNumber numberWithInt:0];
    score.passes = [NSNumber numberWithInt:0];
    score.blocks = [NSNumber numberWithInt:0];
    score.wallPickUp = [NSNumber numberWithInt:0];
    score.wallPickUp1 = [NSNumber numberWithInt:0];
    score.wallPickUp2 = [NSNumber numberWithInt:0];
    score.wallPickUp3 = [NSNumber numberWithInt:0];
    score.wallPickUp4 = [NSNumber numberWithInt:0];
    score.floorPickUp = [NSNumber numberWithInt:0];
    score.driverRating = [NSNumber numberWithInt:0];
    score.notes = @"";
    score.saved = [NSNumber numberWithInt:0];
//    score.fieldDrawing = nil;
    score.defenseRating = [NSNumber numberWithInt:0];
    score.climbLevel = [NSNumber numberWithInt:0];
    score.climbAttempt = [NSNumber numberWithInt:0];
    score.climbTimer = [NSNumber numberWithFloat:0.0];
}

-(TeamData *)getTeam:(int)teamNumber forTournament:(NSString *)tournament {
    TeamData *team;
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription 
                                   entityForName:@"TeamData" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(number == %@) AND (ANY tournament.name = %@)", [NSNumber numberWithInt:teamNumber], tournament];
    [fetchRequest setPredicate:pred];    
    NSArray *teamData = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    //   NSLog(@"Matchin team? = %@", teamData);
    if(!teamData) {
        NSLog(@"Karma disruption error");
        return nil;
    } 
    else {
        if([teamData count] > 0) {  // Team Exists
            team = [teamData objectAtIndex:0];
            // NSLog(@"Team %@ exists", team.number);
            return team;
        }
        else return nil;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
