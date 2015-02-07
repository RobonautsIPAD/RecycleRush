//
//  MatchScoutingViewController.m
//  RecycleRush
//
//  Created by FRC on 2/6/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import "MatchScoutingViewController.h"
#import "DataManager.h"
#import "FileIOMethods.h"
#import "MatchFlow.h"
#import "MatchData.h"
#import "MatchAccessors.h"
#import "MatchUtilities.h"
#import "TeamScore.h"
#import "TeamData.h"
#import "TeamAccessors.h"
#import "FieldPhoto.h"

@interface MatchScoutingViewController ()
// Match Control
@property (nonatomic, weak) IBOutlet UITextField *matchNumber;
@property (nonatomic, weak) IBOutlet UIButton *matchType;
@property (nonatomic, weak) IBOutlet UIButton *prevMatch;
@property (nonatomic, weak) IBOutlet UIButton *nextMatch;
@property (nonatomic, weak) IBOutlet UIButton *teamNumber;
@property (nonatomic, weak) IBOutlet UIButton *matchResetButton;
// Team Info
@property (nonatomic, weak) IBOutlet UILabel *teamName;
@property (nonatomic, weak) IBOutlet UITextField *notes;
// Alliance Info
@property (nonatomic, weak) IBOutlet UIButton *alliance;

// Drawing Stuff
@property (weak, nonatomic) IBOutlet UIButton *drawingChoiceButton;
@property (weak, nonatomic) IBOutlet UIView *fieldDrawingContainer;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIImageView *autonTrace;
@property (weak, nonatomic) IBOutlet UIImageView *teleOpTrace;
@property (weak, nonatomic) IBOutlet UIImageView *paperPhoto;

@end

@implementation MatchScoutingViewController {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSString *previousTournament;
    NSString *deviceName;
    NSMutableDictionary *settingsDictionary;
    NSFetchedResultsController *fetchedResultsController;
    // Markers saved so that the user comes back to the same match if they leave this
    // display and then return
    NSNumber *storedMatchNumber;
    NSString *storedMatchType;
    NSString *storedAlliance;
    MatchUtilities *matchUtilities;
    NSDictionary *matchDictionary;
    NSDictionary *allianceDictionary;
    // The currently displayed match, and team
    MatchData *currentMatch;
    TeamScore *currentScore;
    TeamData *currentTeam;
    NSString *allianceString;
    NSString *matchTypeString;
    NSArray *scoreList;
    // The fetchedResultsController indices of the current match and team
    NSUInteger sectionIndex;
    NSUInteger rowIndex;
    NSUInteger teamIndex;
    
    NSUInteger numberMatchTypes;
   
    id popUp;
    // Match Control Pop Ups
    NSArray *matchTypeList;
    PopUpPickerViewController *matchTypePicker;
    UIPopoverController *matchTypePickerPopover;
    NSMutableArray *teamList;
    PopUpPickerViewController *teamPicker;
    UIPopoverController *teamPickerPopover;
    NSMutableArray *allianceList;
    PopUpPickerViewController *alliancePicker;
    UIPopoverController *alliancePickerPopover;

    BOOL dataChange;
    BOOL fieldDrawingChange;
    NSString *scouter;
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
    NSLog(@"Main Scouting viewDidLoad");
    NSError *error = nil;
    prefs = [NSUserDefaults standardUserDefaults];
    deviceName = [prefs objectForKey:@"deviceName"];
    tournamentName = [prefs objectForKey:@"tournament"];
    if (tournamentName) {
        self.title =  [NSString stringWithFormat:@"%@ Match Scouting", tournamentName];
    }
    else {
        self.title = @"Match Scouting";
    }
    [self loadSettings];
    if (![[self fetchedResultsController] performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         abort() causes the application to generate a crash log and terminate.
         You should not use this function in a shipping application,
         although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    allianceDictionary = _dataManager.allianceDictionary;
    matchDictionary = _dataManager.matchTypeDictionary;
    matchUtilities = [[MatchUtilities alloc] init:_dataManager];

    teamList = [[NSMutableArray alloc] init];
    allianceList = [[NSMutableArray alloc] init];
    NSLog(@"Disable stuff");
}

-(void) viewWillAppear:(BOOL)animated
{
    NSLog(@"viewWillAppear");
    // Set the list of match types
    matchTypeList = [self getMatchTypeList];
    numberMatchTypes = [matchTypeList count];
    [self setInitialMatch];
    currentMatch = [self getCurrentMatch];
    if (currentMatch) [self setDisplayActive];
    else [self setDisplayInactive];
/*    NSString *allianceString = [MatchAccessors getAllianceString:currentScore.allianceStation fromDictionary:allianceDictionary];
    // NSLog(@"Match = %@, Type = %@, Tournament = %@", currentMatch.number, currentMatch.matchType, currentMatch.tournament);
    // NSLog(@"Settings = %@", settings.tournament.name);
    // NSLog(@"Field Drawing Path = %@", baseDrawingPath);*/
    dataChange = NO;
    fieldDrawingChange = NO;
    [self setTeamList];
    [self showTeam:teamIndex];
}

- (void) viewWillDisappear:(BOOL)animated
{
    NSLog(@"viewWillDisappear");
    [self checkDataStatus];
    [self saveSettings];
}

-(void)setDataChange {
    //  A change to one of the database fields has been detected. Set the time tag for the
    //  saved field and set the device name into the field to indicated who made the change.
    // Also indicate that the match has results.
    currentScore.results = [NSNumber numberWithBool:YES];
    currentScore.saved = [NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()];
    currentScore.savedBy = deviceName;
    currentScore.scouter = scouter;
    NSLog(@"Team = %@, Match = %@ Saved by:%@\tTime = %@", currentScore.teamNumber, currentScore.matchNumber, currentScore.savedBy, currentScore.saved);
    dataChange = TRUE;
}

-(void)checkDataStatus {
    //    NSLog(@"Check to Save");
    NSLog (@"Data changed: %@", dataChange ? @"YES" : @"NO");
    if (fieldDrawingChange) {
        /*        // Save the picture
         if (!currentScore.fieldDrawing) {
         FieldDrawing *drawing = [NSEntityDescription insertNewObjectForEntityForName:@"FieldDrawing"
         inManagedObjectContext:_dataManager.managedObjectContext];
         currentScore.fieldDrawing = drawing;
         }
         //    currentScore.fieldDrawing.trace = [NSData dataWithData:UIImagePNGRepresentation(_fieldImage.image)];
         fieldDrawingChange = NO;
         [self setDataChange];
         }
         if (dataChange) {
         currentScore.saved = [NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()];
         currentScore.savedBy = deviceName;
         NSError *error;
         if (![_dataManager.managedObjectContext save:&error]) {
         NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
         }*/
        dataChange = NO;
    }
}

-(void)showTeam:(NSUInteger)currentScoreIndex {
    if (!currentMatch) return;
    matchTypeString = [MatchAccessors getMatchTypeString:currentMatch.matchType fromDictionary:_dataManager.matchTypeDictionary];
    [_matchType setTitle:matchTypeString forState:UIControlStateNormal];
    _matchNumber.text = [NSString stringWithFormat:@"%d", [currentMatch.number intValue]];
    if (teamIndex == NSNotFound) {
        UIAlertView *prompt  = [[UIAlertView alloc] initWithTitle:@"Team Check Alert"
                                                          message:@"No team in this alliance slot"
                                                         delegate:nil
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
        [prompt setAlertViewStyle:UIAlertViewStyleDefault];
        [prompt show];
        NSLog(@"do something else");
        return;
    }
    currentScore = [scoreList objectAtIndex:teamIndex];
    currentTeam = [TeamAccessors getTeam:currentScore.teamNumber fromDataManager:_dataManager];
    [_teamNumber setTitle:[NSString stringWithFormat:@"%d", [currentScore.teamNumber intValue]] forState:UIControlStateNormal];
    _teamName.text = currentTeam.name;
    
    _notes.text = currentScore.notes;
    allianceString = [MatchAccessors getAllianceString:currentScore.allianceStation fromDictionary:allianceDictionary];
    [_alliance setTitle:allianceString forState:UIControlStateNormal];
    [self loadDrawing:allianceString];
}

-(void)loadDrawing:(NSString *)allianceString {
    // Decide what to load
    if (currentScore.field.paper) {
        _fieldDrawingContainer.backgroundColor = [UIColor whiteColor];
        [_paperPhoto setImage:[UIImage imageWithData:currentScore.field.paper]];
        [_paperPhoto setHidden:FALSE];
    }
    // Set the correct background image for the alliance
/*    if ([[allianceString substringToIndex:1] isEqualToString:@"R"]) {
        [_backgroundImage setImage:[UIImage imageNamed:@"Red 2015 New.png"]];
    }
    else {
        [_backgroundImage setImage:[UIImage imageNamed:@"Blue 2015 New.png"]];
    }
    if ([currentScore.results boolValue]) {
        drawMode = DrawLock;
        if (currentScore.autonDrawing.trace) {
            [_autonTrace setImage:[UIImage imageWithData:currentScore.autonDrawing.trace]];
        }
        else {
            [_autonTrace setImage:[[UIImage alloc] init]];
        }
        if (currentScore.teleOpDrawing.trace) {
            [_teleOpTrace setImage:[UIImage imageWithData:currentScore.teleOpDrawing.trace]];
        }
        else {
            [_teleOpTrace setImage:[[UIImage alloc] init]];
        }
        [_autonTrace setHidden:FALSE];
        [_teleOpTrace setHidden:FALSE];
        NSLog(@"Load composite image");
        startPoint = TRUE;
    }
    else {
        drawMode = DrawOff;
        [_autonTrace setImage:[[UIImage alloc] init]];
        [_autonTrace setHidden:FALSE];
        [_teleOpTrace setImage:[[UIImage alloc] init]];
        [_teleOpTrace setHidden:TRUE];
        startPoint = FALSE;
    }
 
     // Check the database to see if this team and match have an auton drawing already
     if (currentScore.autonDrawing.trace) {
     [_autonTrace setImage:[UIImage imageWithData:currentScore.autonDrawing.trace]];
     }
     else {
     [_autonTrace setImage:[[UIImage alloc] init]];
     }
     NSLog(@"Add stuff to import teleop drawing");
    [self drawModeSettings:drawMode];
    */
}

-(IBAction)allianceSelectionChanged:(id)sender {
    [self checkDataStatus];
    if (alliancePicker == nil) {
        alliancePicker = [[PopUpPickerViewController alloc]
                          initWithStyle:UITableViewStylePlain];
        alliancePicker.delegate = self;
    }
    alliancePicker.pickerChoices = allianceList;
    if (!alliancePickerPopover) {
        alliancePickerPopover = [[UIPopoverController alloc]
                                 initWithContentViewController:alliancePicker];
    }
    popUp = alliancePicker;
    [alliancePickerPopover presentPopoverFromRect:_alliance.bounds inView:_alliance
                         permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    /*    //    NSLog(@"AllianceSelectionChanged");
     if ([[prefs objectForKey:@"mode"] isEqualToString:@"Test"]) {
     [self AllianceSelectionPopUp];
     }
     else {
     overrideMode = OverrideAllianceSelection;
     [self checkAdminCode:alliance];
     }*/
}

- (void)allianceSelected:(NSString *)newAlliance {
    [self checkDataStatus];
    [alliancePickerPopover dismissPopoverAnimated:YES];
    NSUInteger currentTeamIndex = teamIndex;
    teamIndex = [allianceList indexOfObject:newAlliance];
    if (teamIndex == NSNotFound) teamIndex = currentTeamIndex;
    [self showTeam:teamIndex];
}

-(IBAction)matchTypeSelectionChanged:(id)sender {
    // NSLog(@"matchTypeSelectionChanged");
    [self checkDataStatus];
    if (matchTypePicker == nil) {
        matchTypePicker = [[PopUpPickerViewController alloc]
                           initWithStyle:UITableViewStylePlain];
        matchTypePicker.delegate = self;
        matchTypePicker.pickerChoices = matchTypeList;
    }
    popUp = matchTypePicker;
    if (!matchTypePickerPopover) {
        matchTypePickerPopover = [[UIPopoverController alloc]
                                  initWithContentViewController:matchTypePicker];
    }
    [matchTypePickerPopover presentPopoverFromRect:_matchType.bounds inView:_matchType
                          permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)matchTypeSelected:(NSString *)newMatchType {
    [self checkDataStatus];
    NSUInteger currectSection = sectionIndex;
    sectionIndex = [matchTypeList indexOfObject:newMatchType];
    if (sectionIndex == NSNotFound) sectionIndex = currectSection;
    //   [self setValidMatchNumber:Nil forType:Nil];
    rowIndex = 0;
    currentMatch = [self getCurrentMatch];
    [self setTeamList];
    [self showTeam:teamIndex];
}

-(IBAction)teamSelectionChanged:(id)sender {
    [self checkDataStatus];
    if (teamPicker == nil) {
        teamPicker = [[PopUpPickerViewController alloc]
                      initWithStyle:UITableViewStylePlain];
        teamPicker.delegate = self;
    }
    teamPicker.pickerChoices = teamList;
    if (!teamPickerPopover) {
        teamPickerPopover = [[UIPopoverController alloc]
                             initWithContentViewController:teamPicker];
    }
    popUp = teamPicker;
    [teamPickerPopover presentPopoverFromRect:_teamNumber.bounds inView:_teamNumber
                     permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    //    NSLog(@"TeamSelectionChanged");
    //    if ([[prefs objectForKey:@"mode"] isEqualToString:@"Test"]) {
    //        [self teamSelectionPopUp];
    //    }
    //    else {
    //       overrideMode = OverrideTeamSelection;
    //        [self checkAdminCode:teamNumber];
    
}

- (void)teamSelected:(NSString *)newTeam {
    [self checkDataStatus];
    [teamPickerPopover dismissPopoverAnimated:YES];
    NSUInteger currentTeamIndex = teamIndex;
    teamIndex = [teamList indexOfObject:newTeam];
    if (teamIndex == NSNotFound) teamIndex = currentTeamIndex;
    [self showTeam:teamIndex];
}

-(IBAction)matchNumberChanged {
    // NSLog(@"matchNumberChanged");
    [self checkDataStatus];
    
    NSUInteger matchField = [_matchNumber.text intValue];
    
    id <NSFetchedResultsSectionInfo> sectionInfo =
    [[fetchedResultsController sections] objectAtIndex:sectionIndex];
    NSUInteger nmatches = [sectionInfo numberOfObjects];
    if (matchField > nmatches) {
        /* Ooops, not that many matches */
        // For now, just change the match field to the last match in the section
        matchField = nmatches;
    }
    rowIndex = matchField-1;
    currentMatch = [self getCurrentMatch];
    [self setTeamList];
    [self showTeam:teamIndex];
}

- (void)pickerSelected:(NSString *)newPick {
    if (popUp == matchTypePicker) {
        [matchTypePickerPopover dismissPopoverAnimated:YES];
        [self matchTypeSelected:newPick];
        return;
    }
    if (popUp == teamPicker) {
        [teamPickerPopover dismissPopoverAnimated:YES];
        [self teamSelected:newPick];
        return;
    }
    if (popUp == alliancePicker) {
        [alliancePickerPopover dismissPopoverAnimated:YES];
        [self allianceSelected:newPick];
        return;
    }
}

-(MatchData *)getCurrentMatch {
    if (numberMatchTypes == 0) {
        [_matchType setTitle:@"No Matches" forState:UIControlStateNormal];
        [_alliance setTitle:@"" forState:UIControlStateNormal];
        matchTypeString = @"";
        allianceString = @"";
        [self setDisplayInactive];
        return nil;
    }
    else {
        NSIndexPath *matchIndex = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
        return [fetchedResultsController objectAtIndexPath:matchIndex];
    }
}

-(void)setTeamList {
    NSSortDescriptor *allianceSort = [NSSortDescriptor sortDescriptorWithKey:@"allianceStation" ascending:YES];
    scoreList = [[currentMatch.score allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:allianceSort]];
    [teamList removeAllObjects];
    [allianceList removeAllObjects];
    for (TeamScore *score in scoreList) {
        [teamList addObject:[NSString stringWithFormat:@"%d", [score.teamNumber intValue]]];
        NSString *alliance = [MatchAccessors getAllianceString:score.allianceStation fromDictionary:allianceDictionary];
        [allianceList addObject:alliance];
    }
    teamPicker = Nil;
    teamPickerPopover = Nil;
    alliancePicker = Nil;
    alliancePickerPopover = Nil;
}

-(IBAction)prevButton {
    [self checkDataStatus];
    if (rowIndex > 0) rowIndex--;
    else {
        sectionIndex = [self getPreviousSection:currentMatch.matchType];
        rowIndex =  [self getNumberOfMatches:sectionIndex]-1;
    }
    
    currentMatch = [self getCurrentMatch];
    [self setTeamList];
    [self showTeam:teamIndex];
}

-(IBAction)nextButton {
    [self checkDataStatus];
    NSUInteger nrows;
    nrows =  [self getNumberOfMatches:sectionIndex];
    if (rowIndex < (nrows-1)) rowIndex++;
    else {
        rowIndex = 0;
        sectionIndex = [self getNextSection:currentMatch.matchType];
    }
    currentMatch = [self getCurrentMatch];
    [self setTeamList];
    [self showTeam:teamIndex];
}

-(NSUInteger)getNextSection:(NSNumber *) currentType {
    NSUInteger newSection;
    // NSLog(@"getNextSection");
    NSString *typeString = [MatchAccessors getMatchTypeString:currentType fromDictionary:matchDictionary];
    
    newSection = [MatchFlow getNextMatchType:matchTypeList forCurrent:typeString];
    if (newSection == NSNotFound) return sectionIndex;
    else return newSection;
}

-(NSUInteger)getPreviousSection:(NSNumber *) currentType {
    NSUInteger newSection;
    //    NSLog(@"getPreviousSection");
    NSString *typeString = [MatchAccessors getMatchTypeString:currentType fromDictionary:matchDictionary];
    
    newSection = [MatchFlow getPreviousMatchType:matchTypeList forCurrent:typeString];
    if (newSection == NSNotFound) return sectionIndex;
    else return newSection;
}

-(NSMutableArray *)getMatchTypeList {
    NSMutableArray *matchTypes = [[NSMutableArray alloc] init];
    NSString *sectionName;
    for (int i=0; i < [[fetchedResultsController sections] count]; i++) {
        sectionName = [[[fetchedResultsController sections] objectAtIndex:i] name];
        // NSLog(@"Section = %@", sectionName);
        [matchTypes addObject:[MatchAccessors getMatchTypeString:[NSNumber numberWithInt:[sectionName intValue]] fromDictionary:matchDictionary]];
    }
    NSLog(@"match types = %@", matchTypes);
    return matchTypes;
}

-(NSUInteger)getNumberOfMatches:(NSUInteger)section {
    if ([[fetchedResultsController sections] count]) {
        return [[[[fetchedResultsController sections] objectAtIndex:sectionIndex] objects] count];
    }
    else return 0;
}

- (IBAction)drawingChoice:(id)sender {
    popUp = _drawingChoiceButton;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Draw Mode 1",  nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showFromRect:_drawingChoiceButton.frame inView:self.view animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
/*        if (popUp == _matchResetButton) {
            [self matchReset];
        }
        else if (popUp == _drawModeButton) {
            drawMode = DrawOff;
            [self drawModeSettings:drawMode];
            NSLog(@"Load real saved drawing");
            [self activateAuton];
        }
    }*/
    }
}


-(void)setDisplayInactive {
    NSLog(@"Deactivate display");
  //  [_drawModeButton setUserInteractionEnabled:NO];
    [_matchNumber setUserInteractionEnabled:FALSE];
    [_matchType setUserInteractionEnabled:FALSE];
    [_alliance setUserInteractionEnabled:FALSE];
}

-(void)setDisplayActive {
    NSLog(@"Reactivate display");
  //  [_drawModeButton setUserInteractionEnabled:TRUE];
    [_matchNumber setUserInteractionEnabled:TRUE];
    [_matchType setUserInteractionEnabled:TRUE];
    [_alliance setUserInteractionEnabled:TRUE];
}

-(void)loadSettings {
    NSString *plistPath = [[FileIOMethods applicationLibraryDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"Preferences/MatchScoutingPageSettings.plist"]];
    settingsDictionary = [[FileIOMethods getDictionaryFromPListFile:plistPath] mutableCopy];
    if (settingsDictionary) previousTournament = [settingsDictionary valueForKey:@"Tournament"];
    storedMatchNumber = [NSNumber numberWithInt:-1];
    storedMatchType = @"";
    storedAlliance = @"";
    if ([tournamentName isEqualToString:previousTournament]) {
        storedMatchNumber = [settingsDictionary valueForKey:@"Match"];
        storedMatchType = [settingsDictionary valueForKey:@"Match Type"];
        storedAlliance = [settingsDictionary valueForKey:@"Alliance"];
    }
}

-(void)setInitialMatch {
    // Check if stored match exists
        // If not, go to first match, first section, and correct alliance if in tourney mode
    // Add checks for mode and if correct alliance exists
//    sectionIndex = [matchTypeList indexOfObject:newMatchType];
    MatchData *match = [MatchAccessors getMatch:storedMatchNumber forType:[MatchAccessors getMatchTypeFromString:storedMatchType fromDictionary:_dataManager.matchTypeDictionary] forTournament:tournamentName fromDataManager:_dataManager];
    if (match) {
        //            sectionIndex = [self getMatchSectionInfo:currentSectionType];
        //    teamIndex = [allianceList indexOfObject:newAlliance];
        NSIndexPath *indexPath = [fetchedResultsController indexPathForObject:match];
        NSLog(@"Add stuff for tournament mode");
        sectionIndex = indexPath.section;
        rowIndex = indexPath.row;
        currentMatch = [self getCurrentMatch];
        [self setTeamList];
        NSLog(@"%@", teamList);
        teamIndex = [allianceList indexOfObject:storedAlliance];
    }
    else {
        sectionIndex = 0;
        rowIndex = 0;
        teamIndex = NSNotFound;
    }
}

-(void)saveSettings {
    if (!settingsDictionary) {
        settingsDictionary = [[NSMutableDictionary alloc] init];
    }
    if (tournamentName) [settingsDictionary setObject:tournamentName forKey:@"Tournament"];
    if (currentMatch.number) [settingsDictionary setObject:currentMatch.number forKey:@"Match"];
    if (allianceString) [settingsDictionary setObject:allianceString forKey:@"Alliance"];
    if (matchTypeString) [settingsDictionary setObject:matchTypeString forKey:@"Match Type"];
    
    NSString *plistPath = [[FileIOMethods applicationLibraryDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"Preferences/MatchScoutingPageSettings.plist"]];
    NSError *error;
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:settingsDictionary format:NSPropertyListXMLFormat_v1_0 options:nil error:&error];
    if(data) {
        [data writeToFile:plistPath atomically:YES];
    }
    else {
        [_dataManager writeErrorMessage:error forType:kErrorMessage];
    }
}

#pragma mark -
#pragma mark Text

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == _notes) {
        [self setDataChange];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    //    NSLog(@"should end editing");
    if (textField == _notes) {
		currentScore.notes = _notes.text;
	}
/*    else if (textField == _foulTextField) {
        currentScore.fouls = [NSNumber numberWithInt:[_foulTextField.text intValue]];
    }
    else if (textField == _scouterTextField) {
        scouter = _scouterTextField.text;
		currentScore.scouter = scouter;
        [prefs setObject:scouter forKey:@"scouter"];
	}*/
	return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    if (textField != _foulTextField)  return YES;
    NSString *resultingString = [textField.text stringByReplacingCharactersInRange: range withString: string];
    // This allows backspace
    if ([resultingString length] == 0) {
        return true;
    }
    
    NSInteger holder;
    NSScanner *scan = [NSScanner scannerWithString: resultingString];
    
    return [scan scanInteger: &holder] && [scan isAtEnd];
}

-(void)setDefaults {
//    eraseMode = FALSE;
//    overrideMode = NoOverride;
    _teamName.font = [UIFont fontWithName:@"Helvetica" size:24.0];
    
    // Match Control
    [self setTextBoxDefaults:_matchNumber forSize:24.0];
    [self setBigButtonDefaults:_prevMatch];
    [self setBigButtonDefaults:_nextMatch];
    [self setTextBoxDefaults:_matchNumber forSize:24.0];
    [self setBigButtonDefaults:_matchType];
    [self setBigButtonDefaults:_alliance];
    [self setBigButtonDefaults:_teamNumber];
    
    // Buttons on the drawing
/*    [self setSmallButtonDefaults:_toteHPTopButton];
    [self setSmallButtonDefaults:_toteHPBottomButton];
    
    [self setSmallButtonDefaults:_litterHPTopButton];
    [self setSmallButtonDefaults:_litterHPBottomButton];
    
    [self setSmallButtonDefaults:_toteFloorTopButton];
    [self setSmallButtonDefaults:_toteFloorBottomButton];
    
    [self setSmallButtonDefaults:_toteStepTopButton];
    [self setSmallButtonDefaults:_toteStepBottomButton];
    */
    //    [self setBigButtonDefaults:_knockoutButton];
/*    [self setSmallButtonDefaults:_eraserButton];
    [self setTextBoxDefaults:_foulTextField forSize:18.0];
    [self setTextBoxDefaults:_scouterTextField forSize:18.0];
    _matchResetButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    [self setBigButtonDefaults:_teamEdit];
    [_teamEdit setTitle:@"Team Info" forState:UIControlStateNormal];
    [self setBigButtonDefaults:_syncButton];
    [_syncButton setTitle:@"Sync" forState:UIControlStateNormal];*/
/*    [self setBigButtonDefaults:_matchListButton];
    [_matchListButton setTitle:@"Match List" forState:UIControlStateNormal];
    [self setSmallButtonDefaults:_toggleGridButton];
    [_toggleGridButton setTitle:@"Off" forState:UIControlStateNormal];
    [self setSmallButtonDefaults:_matchResetButton];
    [self setSmallButtonDefaults:_robotSpeed];
    [self setSmallButtonDefaults:_driverRating];
    [self setSmallButtonDefaults:_intakeRatingButton];
    [self setTextBoxDefaults:_notes forSize:24.0];*/
    
}

-(void)setTextBoxDefaults:(UITextField *)currentTextField forSize:(float)fontSize {
    currentTextField.font = [UIFont fontWithName:@"Helvetica" size:fontSize];
}

-(void)setBigButtonDefaults:(UIButton *)currentButton {
    currentButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:20.0];
    // Round button corners
    CALayer *btnLayer = [currentButton layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:10.0f];
    // Apply a 1 pixel, black border
    [btnLayer setBorderWidth:1.0f];
    [btnLayer setBorderColor:[[UIColor blackColor] CGColor]];
    // Set the button Background Color
    [currentButton setBackgroundColor:[UIColor whiteColor]];
    // Set the button Text Color
    [currentButton setTitleColor:[UIColor colorWithRed:(0.0/255) green:(0.0/255) blue:(120.0/255) alpha:1.0 ]forState: UIControlStateNormal];
}

-(void)setSmallButtonDefaults:(UIButton *)currentButton {
    currentButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    // Round button corners
    CALayer *btnLayer = [currentButton layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:10.0f];
    // Apply a 1 pixel, black border
    [btnLayer setBorderWidth:1.0f];
    [btnLayer setBorderColor:[[UIColor blackColor] CGColor]];
    // Set the button Background Color
    [currentButton setBackgroundColor:[UIColor whiteColor]];
    // Set the button Text Color
    [currentButton setTitleColor:[UIColor colorWithRed:(0.0/255) green:(0.0/255) blue:(120.0/255) alpha:1.0 ]forState: UIControlStateNormal];
}

-(NSFetchedResultsController *)fetchedResultsController {
    // Set up the fetched results controller if needed.
    if (fetchedResultsController == nil) {
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"MatchData" inManagedObjectContext:_dataManager.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Edit the sort key as appropriate.
        NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"matchType" ascending:YES];
        NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:typeDescriptor, numberDescriptor, nil];
        // Add the search for tournament name
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"tournamentName = %@", tournamentName];
        [fetchRequest setPredicate:pred];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        // Edit the section name key path and cache name if appropriate.
        if (previousTournament && ![previousTournament isEqualToString:tournamentName]) {
            // NSLog(@"Clear Cache");
            [NSFetchedResultsController deleteCacheWithName:@"MatchScoutingPage"];
        }
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController =
        [[NSFetchedResultsController alloc]
         initWithFetchRequest:fetchRequest
         managedObjectContext:_dataManager.managedObjectContext
         sectionNameKeyPath:@"matchType"
         cacheName:@"MatchScoutingPage"];
        aFetchedResultsController.delegate = self;
        fetchedResultsController = aFetchedResultsController;
    }
	return fetchedResultsController;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
