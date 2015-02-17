//
//  MatchScoutingViewController.m
//  RecycleRush
//
//  Created by FRC on 2/6/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import "MatchScoutingViewController.h"
#import <QuartzCore/CALayer.h>
#import "DataManager.h"
#import "FileIOMethods.h"
#import "MatchFlow.h"
#import "TeamData.h"
#import "TeamAccessors.h"
#import "MatchData.h"
#import "MatchAccessors.h"
#import "MatchUtilities.h"
#import "TeamScore.h"
#import "FieldPhoto.h"
#import "TeamDetailViewController.h"
#import "AddMatchViewController.h"
#import "LNNumberpad.h"

@interface MatchScoutingViewController ()
// Match Control
@property (nonatomic, weak) IBOutlet UITextField *matchNumber;
@property (nonatomic, weak) IBOutlet UIButton *matchType;
@property (nonatomic, weak) IBOutlet UIButton *prevMatch;
@property (nonatomic, weak) IBOutlet UIButton *nextMatch;
@property (nonatomic, weak) IBOutlet UIButton *teamNumber;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *matchResetButton;
// Team Info
@property (nonatomic, weak) IBOutlet UILabel *teamName;
@property (nonatomic, weak) IBOutlet UITextField *notes;
// Alliance Info
@property (nonatomic, weak) IBOutlet UIButton *alliance;
// View Control items
@property (weak, nonatomic) IBOutlet UIView *controlsView;
@property (weak, nonatomic) IBOutlet UIView *stackView;

// Score Stuff
@property (weak, nonatomic) IBOutlet UITextField *totalTotesScored;
@property (weak, nonatomic) IBOutlet UITextField *totalCansScored;
@property (weak, nonatomic) IBOutlet UITextField *landfillOppositeZone;
@property (weak, nonatomic) IBOutlet UITextField *totalLandfillLitterScored;
@property (weak, nonatomic) IBOutlet UITextField *cansDominatedText;
@property (weak, nonatomic) IBOutlet UITextField *stackKnockdownText;
@property (weak, nonatomic) IBOutlet UITextField *totalTotesIntake;
@property (weak, nonatomic) IBOutlet UITextField *totalScore;
@property (weak, nonatomic) IBOutlet UITextField *totesOn0Text;
@property (weak, nonatomic) IBOutlet UITextField *totesOn1Text;
@property (weak, nonatomic) IBOutlet UITextField *totesOn2Text;
@property (weak, nonatomic) IBOutlet UITextField *totesOn3Text;
@property (weak, nonatomic) IBOutlet UITextField *totesOn4Text;
@property (weak, nonatomic) IBOutlet UITextField *totesOn5Text;
@property (weak, nonatomic) IBOutlet UITextField *totesOn6Text;
@property (weak, nonatomic) IBOutlet UITextField *cansOn0Text;
@property (weak, nonatomic) IBOutlet UITextField *cansOn1Text;
@property (weak, nonatomic) IBOutlet UITextField *cansOn2Text;
@property (weak, nonatomic) IBOutlet UITextField *cansOn3Text;
@property (weak, nonatomic) IBOutlet UITextField *cansOn4Text;
@property (weak, nonatomic) IBOutlet UITextField *cansOn5Text;
@property (weak, nonatomic) IBOutlet UITextField *cansOn6Text;
@property (weak, nonatomic) IBOutlet UITextField *toteIntakeHPText;
@property (weak, nonatomic) IBOutlet UITextField *toteStepIntake;
@property (weak, nonatomic) IBOutlet UITextField *toteBottomFloorIntake;
@property (weak, nonatomic) IBOutlet UITextField *toteTopFloorIntake;
@property (weak, nonatomic) IBOutlet UITextField *canFloorIntake;
@property (weak, nonatomic) IBOutlet UITextField *canStepIntake;
@property (weak, nonatomic) IBOutlet UITextField *litterInCan;
@property (weak, nonatomic) IBOutlet UIButton *robotSetButton;
@property (weak, nonatomic) IBOutlet UIButton *toteSetButton;
@property (weak, nonatomic) IBOutlet UIButton *canSetButton;
@property (weak, nonatomic) IBOutlet UIButton *toteStackButton;
@property (weak, nonatomic) IBOutlet UIButton *canDomTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *coopSet;
@property (weak, nonatomic) IBOutlet UIButton *coopStack;
@property (weak, nonatomic) IBOutlet UIButton *wowlist;
@property (weak, nonatomic) IBOutlet UIButton *blacklist;

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
    NSString *defaultAlliance;
    NSString *mode;
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
    NSString *desiredAlliance;
    
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
    UIImagePickerController *imagePickerController;
    UIPopoverController *pictureController;
    
    NSTimer *canDomTimer;
    int timerCount;

    // Match Control Pop Ups
    id popUp;
    NSArray *matchTypeList;
    PopUpPickerViewController *matchTypePicker;
    UIPopoverController *matchTypePickerPopover;
    NSMutableArray *teamList;
    PopUpPickerViewController *teamPicker;
    UIPopoverController *teamPickerPopover;
    NSMutableArray *allianceList;
    PopUpPickerViewController *alliancePicker;
    UIPopoverController *alliancePickerPopover;
    NSString *newSelection;

    BOOL dataChange;
    BOOL fieldDrawingChange;
    NSString *scouter;
    AlertPromptViewController *alertPrompt;
    UIPopoverController *alertPromptPopover;
    
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
    defaultAlliance = [prefs objectForKey:@"alliance"];
    mode = [prefs objectForKey:@"mode"];
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
    [self setDefaults];
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
         [self setDataChange];*/
    }
    if (dataChange) {
        currentScore.saved = [NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()];
        currentScore.savedBy = deviceName;
        if (![_dataManager saveContext]) {
            UIAlertView *prompt  = [[UIAlertView alloc] initWithTitle:@"Horrible Problem"
                                                              message:@"Unable to save data"
                                                             delegate:nil
                                                    cancelButtonTitle:@"Ok"
                                                    otherButtonTitles:nil];
            [prompt setAlertViewStyle:UIAlertViewStyleDefault];
            [prompt show];
        }
    }
}

-(void)showTeam:(NSUInteger)currentScoreIndex {
    if (!currentMatch) return;
    matchTypeString = [MatchAccessors getMatchTypeString:currentMatch.matchType fromDictionary:_dataManager.matchTypeDictionary];
    [_matchType setTitle:matchTypeString forState:UIControlStateNormal];
    _matchNumber.text = [NSString stringWithFormat:@"%d", [currentMatch.number intValue]];
    if (teamIndex == -1) {
        NSString *msg = @"No default alliance set";
        [self alertPrompt:@"Show Team" withMessage:msg];
        NSLog(@"do something else");
        [self hideViews];
        [_teamNumber setTitle:@"" forState:UIControlStateNormal];
        _teamName.text = @"";
        [_alliance setTitle:@"" forState:UIControlStateNormal];
        return;
    }
    if (teamIndex == NSNotFound) {
        NSString *msg = @"No team in this alliance slot";
        [self alertPrompt:@"Show Team" withMessage:msg];
        NSLog(@"do something else");
        [self hideViews];
        [_teamNumber setTitle:@"" forState:UIControlStateNormal];
        _teamName.text = @"";
        [_alliance setTitle:desiredAlliance forState:UIControlStateNormal];
        return;
    }
    currentScore = [scoreList objectAtIndex:teamIndex];
    currentTeam = [TeamAccessors getTeam:currentScore.teamNumber fromDataManager:_dataManager];
    [_teamNumber setTitle:[NSString stringWithFormat:@"%d", [currentScore.teamNumber intValue]] forState:UIControlStateNormal];
    _teamName.text = currentTeam.name;
    
    _notes.text = currentScore.notes;
    allianceString = [MatchAccessors getAllianceString:currentScore.allianceStation fromDictionary:allianceDictionary];
    [_alliance setTitle:allianceString forState:UIControlStateNormal];
    _totalTotesScored.text = [NSString stringWithFormat:@"%@", currentScore.totalTotesScored];
    _totalCansScored.text = [NSString stringWithFormat:@"%@", currentScore.totalCansScored];
    _totalLandfillLitterScored.text = [NSString stringWithFormat:@"%@", currentScore.totalLandfillLitterScored];
    _landfillOppositeZone.text = [NSString stringWithFormat:@"%@", currentScore.oppositeZoneLitter];    
    _cansDominatedText.text = [NSString stringWithFormat:@"%@", currentScore.canDomination];
    _stackKnockdownText.text = [NSString stringWithFormat:@"%@", currentScore.stackKnockdowns];
     _totalTotesIntake.text = [NSString stringWithFormat:@"%@", currentScore.totalTotesIntake];
    _canFloorIntake.text = [NSString stringWithFormat:@"%@", currentScore.canIntakeFloor];
   _canStepIntake.text = [NSString stringWithFormat:@"%@", currentScore.cansFromStep];
    _totalScore.text = [NSString stringWithFormat:@"%@", currentScore.totalScore];
    _toteIntakeHPText.text = [NSString stringWithFormat:@"%@", currentScore.toteIntakeHP];
    _toteStepIntake.text = [NSString stringWithFormat:@"%@", currentScore.toteIntakeStep];
    _toteTopFloorIntake.text = [NSString stringWithFormat:@"%@", currentScore.toteIntakeTopFloor];
    _toteBottomFloorIntake.text = [NSString stringWithFormat:@"%@", currentScore.toteIntakeBottomFloor];
     _litterInCan.text = [NSString stringWithFormat:@"%@", currentScore.litterinCan];
    _totesOn0Text.text = [NSString stringWithFormat:@"%@", currentScore.totesOn0];
    _totesOn1Text.text = [NSString stringWithFormat:@"%@", currentScore.totesOn1];
    _totesOn2Text.text = [NSString stringWithFormat:@"%@", currentScore.totesOn2];
    _totesOn3Text.text = [NSString stringWithFormat:@"%@", currentScore.totesOn3];
    _totesOn4Text.text = [NSString stringWithFormat:@"%@", currentScore.totesOn4];
    _totesOn5Text.text = [NSString stringWithFormat:@"%@", currentScore.totesOn5];
    _totesOn6Text.text = [NSString stringWithFormat:@"%@", currentScore.totesOn6];
    _cansOn0Text.text = [NSString stringWithFormat:@"%@", currentScore.cansOn0];
    _cansOn1Text.text = [NSString stringWithFormat:@"%@", currentScore.cansOn1];
    _cansOn2Text.text = [NSString stringWithFormat:@"%@", currentScore.cansOn2];
    _cansOn3Text.text = [NSString stringWithFormat:@"%@", currentScore.cansOn3];
    _cansOn4Text.text = [NSString stringWithFormat:@"%@", currentScore.cansOn4];
    _cansOn5Text.text = [NSString stringWithFormat:@"%@", currentScore.cansOn5];
    _cansOn6Text.text = [NSString stringWithFormat:@"%@", currentScore.cansOn6];
    [self setAutonButton:_robotSetButton forValue:currentScore.autonRobotSet];
    [self setAutonButton:_toteSetButton forValue:currentScore.autonToteSet];
    [self setAutonButton:_toteStackButton forValue:currentScore.autonToteStack];
    [self setAutonButton:_canSetButton forValue:currentScore.autonCanSet];
    [self setAutonButton:_coopSet forValue:currentScore.coopSet];
    [self setAutonButton:_coopStack forValue:currentScore.coopStack];
    [self setAutonButton:_blacklist forValue:currentScore.blacklist];
    [self setAutonButton:_wowlist forValue:currentScore.wowList];
    double seconds = fmod([currentScore.canDominationTime floatValue], 60.0);
    double minutes = fmod(trunc([currentScore.canDominationTime floatValue] / 60.0), 60.0);
    [_canDomTimeButton setTitle:[NSString stringWithFormat:@"%02.0f:%02.0f", minutes, seconds] forState:UIControlStateNormal];
    [self showViews];
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
    NSLog(@"add check for mode");
    [self checkDataStatus];
    [alliancePickerPopover dismissPopoverAnimated:YES];
    NSUInteger currentTeamIndex = teamIndex;
    teamIndex = [allianceList indexOfObject:newAlliance];
    if (teamIndex == NSNotFound) teamIndex = currentTeamIndex;
    else desiredAlliance = newAlliance;
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
    NSLog(@"check for mode");
    [self checkDataStatus];
    [teamPickerPopover dismissPopoverAnimated:YES];
    NSUInteger currentTeamIndex = teamIndex;
    teamIndex = [teamList indexOfObject:newTeam];
    if (teamIndex == NSNotFound) teamIndex = currentTeamIndex;
    else desiredAlliance = [allianceList objectAtIndex:teamIndex];
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
        if ([mode isEqualToString:@"Tournament"]) {
            newSelection = newPick;
            [self checkAdminCode:_teamNumber];
        }
        else {
            [self teamSelected:newPick];
        }
        [teamPickerPopover dismissPopoverAnimated:YES];
        return;
    }
    if (popUp == alliancePicker) {
        if ([mode isEqualToString:@"Tournament"]) {
            newSelection = newPick;
            [self checkAdminCode:_alliance];
        }
        else {
            [self allianceSelected:newPick];
        }
        [alliancePickerPopover dismissPopoverAnimated:YES];
        return;
    }
}


- (IBAction)autonSelection:(id)sender {
    [self setDataChange];
    if (sender == _robotSetButton) {
        if ([currentScore.autonRobotSet boolValue]) currentScore.autonRobotSet = [NSNumber numberWithBool:FALSE];
        else currentScore.autonRobotSet = [NSNumber numberWithBool:TRUE];
        [self setAutonButton:_robotSetButton forValue:currentScore.autonRobotSet];
    }
    else if (sender == _canSetButton) {
        if ([currentScore.autonCanSet boolValue]) currentScore.autonCanSet = [NSNumber numberWithBool:FALSE];
        else currentScore.autonCanSet = [NSNumber numberWithBool:TRUE];
        [self setAutonButton:_canSetButton forValue:currentScore.autonCanSet];
    }
    else if (sender == _toteSetButton) {
        if ([currentScore.autonToteSet boolValue]) currentScore.autonToteSet = [NSNumber numberWithBool:FALSE];
        else currentScore.autonToteSet = [NSNumber numberWithBool:TRUE];
        [self setAutonButton:_toteSetButton forValue:currentScore.autonToteSet];
    }
    else if (sender == _toteStackButton) {
        if ([currentScore.autonToteStack boolValue]) currentScore.autonToteStack = [NSNumber numberWithBool:FALSE];
        else currentScore.autonToteStack = [NSNumber numberWithBool:TRUE];
        [self setAutonButton:_toteStackButton forValue:currentScore.autonToteStack];
    }
    else if (sender == _coopSet) {
        if ([currentScore.coopSet boolValue]) currentScore.coopSet = [NSNumber numberWithBool:FALSE];
        else currentScore.coopSet = [NSNumber numberWithBool:TRUE];
        [self setAutonButton:_coopSet forValue:currentScore.coopSet];
    }
    else if (sender == _coopStack) {
        if ([currentScore.coopStack boolValue]) currentScore.coopStack = [NSNumber numberWithBool:FALSE];
        else currentScore.coopStack = [NSNumber numberWithBool:TRUE];
        [self setAutonButton:_coopStack forValue:currentScore.coopStack];
    }
    else if (sender == _blacklist) {
        if ([currentScore.blacklist boolValue]) currentScore.blacklist = [NSNumber numberWithBool:FALSE];
        else currentScore.blacklist = [NSNumber numberWithBool:TRUE];
        [self setAutonButton:_blacklist forValue:currentScore.coopSet];
    }
    else if (sender == _wowlist) {
        if ([currentScore.wowList boolValue]) currentScore.wowList = [NSNumber numberWithBool:FALSE];
        else currentScore.wowList = [NSNumber numberWithBool:TRUE];
        [self setAutonButton:_wowlist forValue:currentScore.coopSet];
    }
    [self updateTotal:@"TotalScore"];
}

-(void)setAutonButton:(UIButton *)button forValue:(NSNumber *)value {
    // check value, set button to right color
    if ([value boolValue]) {
        [button setBackgroundImage:[UIImage imageNamed:@"Small Green Button.jpg"] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    else {
        [button setBackgroundImage:[UIImage imageNamed:@"Small Red Button.jpg"] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:255.0 green:190.0 blue:0 alpha:1.0] forState:UIControlStateNormal];
    }
}
- (IBAction)canDomStart:(id)sender {

//    if (drawMode == DrawAuton || drawMode == DrawDefense || drawMode == DrawTeleop) {
        dataChange = YES;
        NSLog(@"Start Timer");
        if (canDomTimer == nil) {
            canDomTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                          target:self
                                                        selector:@selector(timerFired)
                                                        userInfo:nil
                                                         repeats:YES];
        }
        timerCount = 0;
  //  }
}

-(IBAction)canDomStop:(id)sender {
 //   if (drawMode == DrawAuton || drawMode == DrawDefense || drawMode == DrawTeleop) {
        NSLog(@"Stop Timer %d", timerCount);
        int newTimer = [currentScore.canDominationTime intValue] + timerCount;
        currentScore.canDominationTime = [NSNumber numberWithInt:newTimer];
    NSLog(@"fix timer string");
        [_canDomTimeButton setTitle:[NSString stringWithFormat:@"%02d:%02d:%02d:%02d", newTimer/60, newTimer%60] forState:UIControlStateNormal];
 //   }
}

- (void)timerFired {
    timerCount++;
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
    if ([desiredAlliance isEqualToString:@""]) teamIndex = -1;
    else teamIndex = [allianceList indexOfObject:desiredAlliance];

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
- (IBAction)matchResetTapped:(id)sender {
        NSString *title = @"Confirm Match Reset";
        NSString *button = @"Reset";
        popUp = sender;
        
        [self confirmationActionSheet:title withButton:button];
    }
    
    - (void)confirmationActionSheet:title withButton:(NSString *)button {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:button otherButtonTitles:@"Cancel",  nil];
        
        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
        [actionSheet showInView:self.view];
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
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Photo", @"Draw Mode 1",  nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showFromRect:_drawingChoiceButton.frame inView:_stackView animated:YES];
    popUp = _drawingChoiceButton;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            if (popUp == _drawingChoiceButton) [self fieldPhoto:@"Take"];
            break;
        case 1:
            if (popUp == _drawingChoiceButton) [self fieldPhoto:@"Choose"];
            break;
            
        default:
            break;
    }

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

-(void)fieldPhoto:(NSString *)choice {
    if (!imagePickerController) {
        imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;
    }
    if ([choice isEqualToString:@"Take"] && [UIImagePickerController isSourceTypeAvailable:
                                             UIImagePickerControllerSourceTypeCamera]) {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePickerController animated:YES completion:Nil];
    }
    else {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        if (!pictureController) {
            pictureController = [[UIPopoverController alloc]
                                 initWithContentViewController:imagePickerController];
            pictureController.delegate = self;
        }
        [pictureController presentPopoverFromRect:_drawingChoiceButton.bounds inView:_drawingChoiceButton
                         permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"photo popover");
    _paperPhoto.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [_paperPhoto setHidden:FALSE];
    currentScore.field.paper = [NSData dataWithData:UIImageJPEGRepresentation(_paperPhoto.image, 1.0)];
    [self setDataChange];
    // NSLog(@"image picker finish");*/
    [picker dismissViewControllerAnimated:YES completion:Nil];
    [pictureController dismissPopoverAnimated:true];
}

-(void)setDisplayInactive {
    NSLog(@"Deactivate display");
  //  [_drawModeButton setUserInteractionEnabled:NO];
    [_matchNumber setUserInteractionEnabled:FALSE];
    [_matchType setUserInteractionEnabled:FALSE];
    [_alliance setUserInteractionEnabled:FALSE];
    [self hideViews];
}

-(void)setDisplayActive {
    NSLog(@"Reactivate display");
  //  [_drawModeButton setUserInteractionEnabled:TRUE];
    [_matchNumber setUserInteractionEnabled:TRUE];
    [_matchType setUserInteractionEnabled:TRUE];
    [_alliance setUserInteractionEnabled:TRUE];
    [self showViews];
}

-(void)hideViews {
    [_fieldDrawingContainer setHidden:TRUE];
    [_controlsView setHidden:TRUE];
    [_stackView setHidden:TRUE];
}

-(void)showViews {
    [_fieldDrawingContainer setHidden:FALSE];
    [_controlsView setHidden:FALSE];
    [_stackView setHidden:FALSE];
}

-(void)disableInputs {
    [_fieldDrawingContainer setUserInteractionEnabled:FALSE];
    [_controlsView setUserInteractionEnabled:FALSE];
    [_stackView setUserInteractionEnabled:FALSE];
}

-(void)enableInputs {
    [_fieldDrawingContainer setUserInteractionEnabled:TRUE];
    [_controlsView setUserInteractionEnabled:TRUE];
    [_stackView setUserInteractionEnabled:TRUE];
}

-(void)loadSettings {
    NSString *plistPath = [[FileIOMethods applicationLibraryDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"Preferences/MatchScoutingPageSettings.plist"]];
    settingsDictionary = [[FileIOMethods getDictionaryFromPListFile:plistPath] mutableCopy];
    if (settingsDictionary) previousTournament = [settingsDictionary valueForKey:@"Tournament"];
    storedMatchNumber = [NSNumber numberWithInt:-1];
    storedMatchType = @"";
    storedAlliance = @"";
    if ([tournamentName isEqualToString:previousTournament]) {
        // It is the same tournament since the last time we were here. The match placement
        // data should still be good.
        desiredAlliance = @"";
        storedMatchNumber = [settingsDictionary valueForKey:@"Match"];
        storedMatchType = [settingsDictionary valueForKey:@"Match Type"];
        storedAlliance = [settingsDictionary valueForKey:@"Alliance"];
        if ([mode isEqualToString:@"Tournament"]) {
            NSString *msg;
            if (defaultAlliance == nil || [defaultAlliance isEqualToString:@""]) {
                desiredAlliance = @"";
                msg = @"No Default Alliance Set";
                [self alertPrompt:@"Tournament Mode" withMessage:msg];
            }
            else if ([defaultAlliance isEqualToString:storedAlliance] == NO) {
                desiredAlliance = defaultAlliance;
                msg = [NSString stringWithFormat:@"Switching from stored %@ to default %@", storedAlliance, defaultAlliance];
                [self alertPrompt:@"Tournament Mode" withMessage:@""];
            }
            else desiredAlliance = defaultAlliance;
        }
        else {
            if (storedAlliance && [storedAlliance isEqualToString:@""] == NO) desiredAlliance = storedAlliance;
            else if (defaultAlliance && [defaultAlliance isEqualToString:@""] == NO) desiredAlliance = defaultAlliance;
            else desiredAlliance = @"Red 1";
        }
    }
    else {
        // We are on a different tournament. Use the default alliance set in the prefs for this device
        // unless it is blank. If it is blank move onto the stored alliance. If that is blank, use Red 1.
        if (![defaultAlliance isEqualToString:@""]) desiredAlliance = defaultAlliance;
        else if (![storedAlliance isEqualToString:@""]) desiredAlliance = storedAlliance;
        else desiredAlliance = @"Red 1";
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
    }
    else {
        sectionIndex = 0;
        rowIndex = 0;
        currentMatch = [self getCurrentMatch];
    }
    [self setTeamList];
    NSLog(@"%@", teamList);
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
    if (textField != _matchNumber) {
        [self setDataChange];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    //    NSLog(@"should end editing");
    if (textField == _notes) {
		currentScore.notes = _notes.text;
	}
    else if (textField == _totalTotesScored) {
        currentScore.totalTotesScored = [NSNumber numberWithInt:[_totalTotesScored.text intValue]];
    }
    else if (textField == _totalCansScored) {
        currentScore.totalCansScored = [NSNumber numberWithInt:[_totalCansScored.text intValue]];
    }
    else if (textField == _totalLandfillLitterScored) {
        currentScore.totalLandfillLitterScored = [NSNumber numberWithInt:[_totalLandfillLitterScored.text intValue]];
         [self updateTotal:@"TotalScore"];
    }
    else if (textField == _landfillOppositeZone) {
        currentScore.oppositeZoneLitter = [NSNumber numberWithInt:[_landfillOppositeZone.text intValue]];
        [self updateTotal:@"TotalScore"];
    }
    else if (textField == _cansDominatedText) {
        currentScore.canDomination = [NSNumber numberWithInt:[_cansDominatedText.text intValue]];
    }
    else if (textField == _stackKnockdownText) {
        currentScore.stackKnockdowns = [NSNumber numberWithInt:[_stackKnockdownText.text intValue]];
    }
    else if (textField == _totesOn0Text) {
        currentScore.totesOn0 = [NSNumber numberWithInt:[_totesOn0Text.text intValue]];
        [self updateTotal:@"Totes"];
        [self updateTotal:@"TotalScore"];
    }
    else if (textField == _totesOn1Text) {
        currentScore.totesOn1 = [NSNumber numberWithInt:[_totesOn1Text.text intValue]];
        [self updateTotal:@"Totes"];
        [self updateTotal:@"TotalScore"];
    }
    else if (textField == _totesOn2Text) {
        currentScore.totesOn2 = [NSNumber numberWithInt:[_totesOn2Text.text intValue]];
        [self updateTotal:@"Totes"];
        [self updateTotal:@"TotalScore"];
    }
    else if (textField == _totesOn3Text) {
        currentScore.totesOn3 = [NSNumber numberWithInt:[_totesOn3Text.text intValue]];
        [self updateTotal:@"Totes"];
        [self updateTotal:@"TotalScore"];
    }
    else if (textField == _totesOn4Text) {
        currentScore.totesOn4 = [NSNumber numberWithInt:[_totesOn4Text.text intValue]];
        [self updateTotal:@"Totes"];
        [self updateTotal:@"TotalScore"];
    }
    else if (textField == _totesOn5Text) {
        currentScore.totesOn5 = [NSNumber numberWithInt:[_totesOn5Text.text intValue]];
        [self updateTotal:@"Totes"];
        [self updateTotal:@"TotalScore"];
    }
    else if (textField == _totesOn6Text) {
        currentScore.totesOn6 = [NSNumber numberWithInt:[_totesOn6Text.text intValue]];
        [self updateTotal:@"Totes"];
        [self updateTotal:@"TotalScore"];
    }
    else if (textField == _cansOn0Text) {
        currentScore.cansOn0 = [NSNumber numberWithInt:[_cansOn0Text.text intValue]];
        [self updateTotal:@"Cans"];
        [self updateTotal:@"TotalScore"];
    }
    else if (textField == _cansOn1Text) {
        currentScore.cansOn1 = [NSNumber numberWithInt:[_cansOn1Text.text intValue]];
        [self updateTotal:@"Cans"];
        [self updateTotal:@"TotalScore"];
    }
    else if (textField == _cansOn2Text) {
        currentScore.cansOn2 = [NSNumber numberWithInt:[_cansOn2Text.text intValue]];
        [self updateTotal:@"Cans"];
        [self updateTotal:@"TotalScore"];
    }
    else if (textField == _cansOn3Text) {
        currentScore.cansOn3 = [NSNumber numberWithInt:[_cansOn3Text.text intValue]];
        [self updateTotal:@"Cans"];
        [self updateTotal:@"TotalScore"];
    }
    else if (textField == _cansOn4Text) {
        currentScore.cansOn4 = [NSNumber numberWithInt:[_cansOn4Text.text intValue]];
        [self updateTotal:@"Cans"];
        [self updateTotal:@"TotalScore"];
    }
    else if (textField == _cansOn5Text) {
        currentScore.cansOn5 = [NSNumber numberWithInt:[_cansOn5Text.text intValue]];
        [self updateTotal:@"Cans"];
        [self updateTotal:@"TotalScore"];
    }
    else if (textField == _cansOn6Text) {
        currentScore.cansOn6 = [NSNumber numberWithInt:[_cansOn6Text.text intValue]];
        [self updateTotal:@"Cans"];
        [self updateTotal:@"TotalScore"];
    }
    else if (textField == _toteIntakeHPText) {
        currentScore.toteIntakeHP = [NSNumber numberWithInt:[_toteIntakeHPText.text intValue]];
        [self updateTotal:@"TotesIntake"];
    }
    else if (textField == _toteStepIntake) {
        currentScore.toteIntakeStep = [NSNumber numberWithInt:[_toteStepIntake.text intValue]];
        [self updateTotal:@"TotesIntake"];
    }
    else if (textField == _toteTopFloorIntake) {
        currentScore.toteIntakeTopFloor = [NSNumber numberWithInt:[_toteTopFloorIntake.text intValue]];
        [self updateTotal:@"TotesIntake"];
    }
    else if (textField == _toteBottomFloorIntake) {
        currentScore.toteIntakeBottomFloor = [NSNumber numberWithInt:[_toteBottomFloorIntake.text intValue]];
        [self updateTotal:@"TotesIntake"];
    }
    else if (textField == _canFloorIntake) {
        currentScore.canIntakeFloor = [NSNumber numberWithInt:[_canFloorIntake.text intValue]];
    }
    else if (textField == _canStepIntake) {
        currentScore.cansFromStep = [NSNumber numberWithInt:[_canStepIntake.text intValue]];
    }
    else if (textField == _litterInCan) {
        currentScore.litterinCan = [NSNumber numberWithInt:[_litterInCan.text intValue]];
        [self updateTotal:@"TotalScore"];
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

-(void)updateTotal:(NSString *)scoreObject {
    if ([scoreObject isEqualToString:@"Totes"]) {
        int score = [currentScore.totesOn0 intValue] + [currentScore.totesOn1 intValue] + [currentScore.totesOn2 intValue] + [currentScore.totesOn3 intValue] + [currentScore.totesOn4 intValue] + [currentScore.totesOn5 intValue] + [currentScore.totesOn6 intValue];
        currentScore.totalTotesScored = [NSNumber numberWithInt:score];
        _totalTotesScored.text = [NSString stringWithFormat:@"%d", score];
    }
    else if ([scoreObject isEqualToString:@"Cans"]) {
        int score = [currentScore.cansOn0 intValue] + [currentScore.cansOn1 intValue] + [currentScore.cansOn2 intValue] + [currentScore.cansOn3 intValue] + [currentScore.cansOn4 intValue] + [currentScore.cansOn5 intValue] + [currentScore.cansOn6 intValue];
        currentScore.totalCansScored = [NSNumber numberWithInt:score];
        _totalCansScored.text = [NSString stringWithFormat:@"%d", score];
    }
    else if ([scoreObject isEqualToString:@"TotesIntake"]) {
        int score = [currentScore.toteIntakeHP intValue] + [currentScore.toteIntakeStep intValue] + [currentScore.toteIntakeTopFloor intValue] + [currentScore.toteIntakeBottomFloor intValue];
         currentScore.totalTotesIntake = [NSNumber numberWithInt:score];
        _totalTotesIntake.text = [NSString stringWithFormat:@"%d", score];
    }
    else if ([scoreObject isEqualToString:@"TotalScore"]) {
        int score = [currentScore.totesOn0 intValue]*0 + [currentScore.totesOn1 intValue]*2 + [currentScore.totesOn2 intValue]*2 + [currentScore.totesOn3 intValue]*2 + [currentScore.totesOn4 intValue]*2 + [currentScore.totesOn5 intValue]*2 + [currentScore.totesOn6 intValue]*2 + [currentScore.cansOn0 intValue]*0 + [currentScore.cansOn1 intValue]*4 + [currentScore.cansOn2 intValue]*8 + [currentScore.cansOn3 intValue]*12 + [currentScore.cansOn4 intValue]*16 + [currentScore.cansOn5 intValue]*20 + [currentScore.cansOn6 intValue]*24 + [currentScore.litterinCan intValue]*6 + [currentScore.totalLandfillLitterScored intValue] + [currentScore.oppositeZoneLitter intValue]*4 + [currentScore.autonRobotSet intValue]*4 + [currentScore.autonToteSet intValue]*6 + [currentScore.autonCanSet intValue]*8 + [currentScore.autonToteStack intValue]*20 + [currentScore.coopSet intValue]*20 + [currentScore.coopStack intValue]*40;
        currentScore.totalScore = [NSNumber numberWithInt:score];
        _totalScore.text = [NSString stringWithFormat:@"%d", score];
    }
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
    _teamName.font = [UIFont fontWithName:@"Nasalization" size:24.0];
    
    // Match Control
    [self setTextBoxDefaults:_matchNumber forSize:24.0];
    [self setBigButtonDefaults:_prevMatch];
    [self setBigButtonDefaults:_nextMatch];
    [self setTextBoxDefaults:_matchNumber forSize:24.0];
    [self setBigButtonDefaults:_matchType];
    [self setBigButtonDefaults:_alliance];
    [self setBigButtonDefaults:_teamNumber];
    [self setBigButtonDefaults:_canDomTimeButton];
    [self setBigButtonDefaults:_drawingChoiceButton];
    [self setBigButtonDefaults:_blacklist];
    [self setBigButtonDefaults:_wowlist];
    
    _robotSetButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    _toteSetButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    _toteStackButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    _canSetButton.titleLabel.textAlignment = NSTextAlignmentCenter;
      _coopSet.titleLabel.textAlignment = NSTextAlignmentCenter;
      _coopStack.titleLabel.textAlignment = NSTextAlignmentCenter;
    _blacklist.titleLabel.textAlignment = NSTextAlignmentCenter;
    _wowlist.titleLabel.textAlignment = NSTextAlignmentCenter;
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
    _canFloorIntake.inputView  = [LNNumberpad defaultLNNumberpad];
    _matchNumber.inputView  = [LNNumberpad defaultLNNumberpad];
    _landfillOppositeZone.inputView  = [LNNumberpad defaultLNNumberpad];
    _totalLandfillLitterScored.inputView  = [LNNumberpad defaultLNNumberpad];
    _cansDominatedText.inputView  = [LNNumberpad defaultLNNumberpad];
    _stackKnockdownText.inputView  = [LNNumberpad defaultLNNumberpad];
    _totesOn0Text.inputView  = [LNNumberpad defaultLNNumberpad];
    _totesOn1Text.inputView  = [LNNumberpad defaultLNNumberpad];
    _totesOn2Text.inputView  = [LNNumberpad defaultLNNumberpad];
    _totesOn3Text.inputView  = [LNNumberpad defaultLNNumberpad];
    _totesOn4Text.inputView  = [LNNumberpad defaultLNNumberpad];
    _totesOn5Text.inputView  = [LNNumberpad defaultLNNumberpad];
    _totesOn6Text.inputView  = [LNNumberpad defaultLNNumberpad];
    _cansOn0Text.inputView  = [LNNumberpad defaultLNNumberpad];
    _cansOn1Text.inputView  = [LNNumberpad defaultLNNumberpad];
    _cansOn2Text.inputView  = [LNNumberpad defaultLNNumberpad];
    _cansOn3Text.inputView  = [LNNumberpad defaultLNNumberpad];
    _cansOn4Text.inputView  = [LNNumberpad defaultLNNumberpad];
    _cansOn5Text.inputView  = [LNNumberpad defaultLNNumberpad];
    _cansOn6Text.inputView  = [LNNumberpad defaultLNNumberpad];
    _toteIntakeHPText.inputView  = [LNNumberpad defaultLNNumberpad];
    _toteStepIntake.inputView  = [LNNumberpad defaultLNNumberpad];
    _toteBottomFloorIntake.inputView  = [LNNumberpad defaultLNNumberpad];
    _toteTopFloorIntake.inputView  = [LNNumberpad defaultLNNumberpad];
    _canStepIntake.inputView  = [LNNumberpad defaultLNNumberpad];
    _litterInCan.inputView  = [LNNumberpad defaultLNNumberpad];
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

#pragma mark - Navigation
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self checkDataStatus];
    
    if ([segue.identifier isEqualToString:@"TeamDetail"]) {
        TeamDetailViewController *detailViewController = [segue destinationViewController];
        [segue.destinationViewController setDataManager:_dataManager];
        detailViewController.team = currentTeam;
    }
    
/*    else if ([segue.identifier isEqualToString:@"Sync"]) {
        [segue.destinationViewController setDataManager:_dataManager];
        [segue.destinationViewController setSyncOption:SyncAllSavedSince];
        [segue.destinationViewController setSyncType:SyncMatchResults];
    }*/
/*    if ([segue.identifier isEqualToString:@"Edit"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        pushedIndexPath = [self.tableView indexPathForCell:sender];
        UINavigationController *nv = (UINavigationController *)[segue destinationViewController];
        AddMatchViewController *addvc = (AddMatchViewController *)nv.topViewController;
        [addvc setDataManager:_dataManager];
        [addvc setTournamentName:tournamentName];
        [addvc setMatch:[fetchedResultsController objectAtIndexPath:indexPath]];
    }
    if ([segue.identifier isEqualToString:@"Add"]) {
        NSLog(@"add");
        UINavigationController *nv = (UINavigationController *)[segue destinationViewController];
        AddMatchViewController *addvc = (AddMatchViewController *)nv.topViewController;
        [addvc setDataManager:_dataManager];
        [addvc setTournamentName:tournamentName];
    }  */
    else {
        [segue.destinationViewController setDataManager:_dataManager];
    }
    
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

-(void)checkAdminCode:(UIButton *)button {
    // NSLog(@"Check override");
    if (alertPrompt == nil) {
        alertPrompt = [[AlertPromptViewController alloc] initWithNibName:nil bundle:nil];
        alertPrompt.delegate = self;
        alertPrompt.titleText = @"Enter Admin Code";
        alertPrompt.msgText = @"Do NOT change unless you are sure";
        alertPromptPopover = [[UIPopoverController alloc]
                                   initWithContentViewController:alertPrompt];
    }
    [alertPromptPopover presentPopoverFromRect:button.bounds inView:button permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    
    return;
}

-(void)passCodeResult:(NSString *)passCodeAttempt {
    [alertPromptPopover dismissPopoverAnimated:YES];
    if ([passCodeAttempt isEqualToString:[prefs objectForKey:@"adminCode"]]) {
        if (popUp == alliancePicker) [self allianceSelected:newSelection];
        else if (popUp == teamPicker) [self teamSelected:newSelection];
    }
}

-(void)alertPrompt:(NSString *)title withMessage:(NSString *)message {
    UIAlertView *prompt  = [[UIAlertView alloc] initWithTitle:title
                                                      message:message
                                                     delegate:nil
                                            cancelButtonTitle:@"Ok"
                                            otherButtonTitles:nil];
    [prompt setAlertViewStyle:UIAlertViewStyleDefault];
    [prompt show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
