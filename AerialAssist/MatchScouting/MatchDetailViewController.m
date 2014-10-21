//
//  MatchDetailViewController.m
// Robonauts Scouting
//
//  Created by Kris Pettinger on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MatchDetailViewController.h"
#import "MatchData.h"
#import "MatchUtilities.h"
#import "DataConvenienceMethods.h"
#import "TeamData.h"
#import "TeamScore.h"
#import "DataManager.h"
#import "EnumerationDictionary.h"

@interface MatchDetailViewController()
    @property (nonatomic, weak) IBOutlet UIButton *matchTypeButton;
    @property (nonatomic, weak) IBOutlet UITextField *numberTextField;
    @property (nonatomic, weak) IBOutlet UITextField *red1TextField;
    @property (nonatomic, weak) IBOutlet UITextField *red2TextField;
    @property (nonatomic, weak) IBOutlet UITextField *red3TextField;
    @property (nonatomic, weak) IBOutlet UITextField *blue1TextField;
    @property (nonatomic, weak) IBOutlet UITextField *blue2TextField;
    @property (nonatomic, weak) IBOutlet UITextField *blue3TextField;
@end

@implementation MatchDetailViewController {
    NSUserDefaults *prefs;
    BOOL dataChange;
    NSArray *teamList;
    NSDictionary *matchDictionary;
    NSDictionary *allianceDictionary;
    PopUpPickerViewController *matchTypePicker;
    UIPopoverController *matchTypePickerPopover;
    NSArray *matchTypeList;
    NSNumber *newMatchNumber;
    BOOL textChangeDetected;
    OverrideMode overrideMode;
    id popUp;
    MatchUtilities *matchUtilities;
}
@synthesize delegate = _delegate;
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

    matchUtilities = [[MatchUtilities alloc] init:_dataManager];
    matchDictionary = [self getEnumDictionary:@"MatchType"];;
    matchTypeList = [matchDictionary keysSortedByValueUsingSelector:@selector(compare:)];
    allianceDictionary = [self getEnumDictionary:@"allianceListDictionary"];

    _numberTextField.font = [UIFont fontWithName:@"Helvetica" size:24.0];
    _numberTextField.text = [NSString stringWithFormat:@"%d", [_match.number intValue]];
    _matchTypeButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:24.0];
    [_matchTypeButton setTitle:[self getMatchTypeString:_match.matchType] forState:UIControlStateNormal];
    
    _red1TextField.font = [UIFont fontWithName:@"Helvetica" size:24.0];
    _red2TextField.font = [UIFont fontWithName:@"Helvetica" size:24.0];
    _red3TextField.font = [UIFont fontWithName:@"Helvetica" size:24.0];
    _blue1TextField.font = [UIFont fontWithName:@"Helvetica" size:24.0];
    _blue2TextField.font = [UIFont fontWithName:@"Helvetica" size:24.0];
    _blue3TextField.font = [UIFont fontWithName:@"Helvetica" size:24.0];

    [self setTeamList:_match];

    [self setTeamField:_red1TextField forAlliance:@"Red 1"];
    [self setTeamField:_red2TextField forAlliance:@"Red 2"];
    [self setTeamField:_red3TextField forAlliance:@"Red 3"];
    [self setTeamField:_blue1TextField forAlliance:@"Blue 1"];
    [self setTeamField:_blue2TextField forAlliance:@"Blue 2"];
    [self setTeamField:_blue3TextField forAlliance:@"Blue 3"];
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

-(void)setTeamList:(MatchData *)match {
    NSSortDescriptor *allianceSort = [NSSortDescriptor sortDescriptorWithKey:@"allianceStation" ascending:YES];
    teamList = [[match.score allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:allianceSort]];
}

-(TeamScore *)getScoreRecord:(NSString *)allianceStation {
    if (!teamList || ![teamList count]) return Nil;
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"allianceStation = %@", [EnumerationDictionary getValueFromKey:allianceStation forDictionary:allianceDictionary]];
    NSArray *scoreList = [teamList filteredArrayUsingPredicate:pred];
    if ([scoreList count]) return [scoreList objectAtIndex:0];
    else return Nil;
}

-(IBAction)popupSelected:(id)sender {
    UIButton * PressedButton = (UIButton*)sender;
    popUp = PressedButton;
    if (PressedButton == _matchTypeButton) {
        if (matchTypePicker == nil) {
            matchTypePicker = [[PopUpPickerViewController alloc]
                            initWithStyle:UITableViewStylePlain];
            matchTypePicker.delegate = self;
            matchTypePicker.pickerChoices = matchTypeList;
        }
        if (!matchTypePickerPopover) {
            matchTypePickerPopover = [[UIPopoverController alloc]
                                   initWithContentViewController:matchTypePicker];
        }
        [matchTypePickerPopover presentPopoverFromRect:PressedButton.bounds inView:PressedButton
                           permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (void)pickerSelected:(NSString *)newPick {
    // The user has made a selection on one of the pop-ups. Dismiss the pop-up
    //  and call the correct method to change the right field.
    // NSLog(@"new pick = %@", newPick);
    if (popUp == _matchTypeButton) {
        [matchTypePickerPopover dismissPopoverAnimated:YES];
        _match.matchType  = [EnumerationDictionary getValueFromKey:newPick forDictionary:matchDictionary ];
    }
    [popUp setTitle:newPick forState:UIControlStateNormal];
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
//            _match.matchTypeSection = [matchDictionary getMatchTypeEnum:matchType];
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
//                [self MatchTypeSelectionPopUp];
            }
            break;
                        
        default:
            break;
    }
    overrideMode = NoOverride;
}

-(void)setTeamField:(UITextField *)textBox forAlliance:(NSString *)alliance {
    TeamScore *score = [self getScoreRecord:alliance];
    if (score) {
        textBox.text = [NSString stringWithFormat:@"%d", [score.teamNumber intValue]];
    /*    if (textField == _numberTextField) {
     int number = [textField.text intValue];
     newMatchNumber = [NSNumber numberWithInt:number];
*/
    
    /*    if ([score.saved intValue]) {
        textBox.textColor = [UIColor redColor];
        [textBox setEnabled:NO];
    }
    else {
        textBox.textColor = [UIColor blackColor];
        [textBox setEnabled:YES];
    }*/
    }
    else {
        textBox.text = @"";
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    // NSLog(@"viewWillDisappear");
    if (!_delegate) NSLog(@"Match Detail Delegate Problem");
    NSLog(@"Move from match detail to create match");
    _match.saved = [NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()];
    _match.savedBy = [prefs objectForKey:@"deviceName"];
    [_delegate matchDetailReturned:dataChange];
}

-(NSString *)getMatchTypeString:(NSNumber *)matchType {
    return [EnumerationDictionary getKeyFromValue:matchType forDictionary:matchDictionary];
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
/*        if (![self editTeam:number forScore:[scoreData objectAtIndex:3]]) {
            success = FALSE;
            // The change failed. Reset the field to what it used to be
            [self setTeamField:_red1TextField forAlliance:@"Red 1"];
        }*/
	}
    else if (textField == _red2TextField) {
      /*  if (![self editTeam:number forScore:[scoreData objectAtIndex:4]]) {
            success = FALSE;
            // The change failed. Reset the field to what it used to be
            [self setTeamField:_red2TextField forAlliance:@"Red 2"];
        }*/
	}
	else if (textField == _red3TextField) {
     /*   if (![self editTeam:number forScore:[scoreData objectAtIndex:5]]) {
            success = FALSE;
            // The change failed. Reset the field to what it used to be
            [self setTeamField:_red3TextField forAlliance:@"Red 3"];
        }*/
	}
	else if (textField == _blue1TextField) {
   /*     if (![self editTeam:number forScore:[scoreData objectAtIndex:0]]) {
            success = FALSE;
            // The change failed. Reset the field to what it used to be
            [self setTeamField:_blue1TextField forAlliance:@"Blue 1"];
        }*/
	}
	else if (textField == _blue2TextField) {
   /*     if (![self editTeam:number forScore:[scoreData objectAtIndex:1]]) {
            success = FALSE;
            // The change failed. Reset the field to what it used to be
            [self setTeamField:_blue2TextField forAlliance:@"Blue 1"];
        }*/
	}
	else if (textField == _blue3TextField) {
      /*  if (![self editTeam:number forScore:[scoreData objectAtIndex:2]]) {
            success = FALSE;
            // The change failed. Reset the field to what it used to be
            [self setTeamField:_blue3TextField forAlliance:@"Blue 1"];
        }*/
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
    TeamData *team = [DataConvenienceMethods getTeamInTournament:[NSNumber numberWithInt:teamNumber] forTournament:_match.tournamentName fromContext:_dataManager.managedObjectContext];
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
    score.airCatch = [NSNumber numberWithInt:0];
    score.airPasses = [NSNumber numberWithInt:0];
    score.autonBlocks = [NSNumber numberWithInt:0];
    score.autonHighCold = [NSNumber numberWithInt:0];
    score.autonHighHot = [NSNumber numberWithInt:0];
    score.autonLowCold = [NSNumber numberWithInt:0];
    score.autonLowHot = [NSNumber numberWithInt:0];
    score.autonMissed = [NSNumber numberWithInt:0];
    score.autonLowMiss = [NSNumber numberWithInt:0];
    score.autonHighMiss = [NSNumber numberWithInt:0];
    score.autonShotsMade = [NSNumber numberWithInt:0];
    score.autonMobility = [NSNumber numberWithInt:0];
    score.fieldDrawing = nil;
}

-(id)getEnumDictionary:(NSString *) dictionaryName {
    if (!dictionaryName) {
        return nil;
    }
    if ([dictionaryName isEqualToString:@"MatchType"]) {
        if (!matchDictionary) matchDictionary = [EnumerationDictionary initializeBundledDictionary:@"MatchType"];
        return matchDictionary;
    }
    else if ([dictionaryName isEqualToString:@"allianceListDictionary"]) {
        if (!allianceDictionary) allianceDictionary = [EnumerationDictionary initializeBundledDictionary:@"AllianceList"];
        return allianceDictionary;
    }
    else return nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
