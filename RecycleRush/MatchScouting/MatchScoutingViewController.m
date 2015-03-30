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
#import "ScoreUtilities.h"
#import "TeamScore.h"
#import "FieldPhoto.h"
#import "MatchPhotoUtilities.h"
#import "TeamDetailViewController.h"
#import "AddMatchViewController.h"
#import "MainMatchAnalysisViewController.h"
#import "StackViewController.h"
#import "MatchDrawingViewController.h"
#import "LNNumberpad.h"
#import "MatchSummaryViewController.h"

@interface MatchDrawingSegue : UIStoryboardSegue
@end

@implementation MatchDrawingSegue

-(void)perform {
    // our custom segue is being fired, push the tablet error view controller
    UINavigationController *sourceViewController = self.sourceViewController;
    MatchDrawingViewController *destinationViewController = self.destinationViewController;
    destinationViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [sourceViewController presentViewController:destinationViewController animated:YES completion:nil];
 //   [sourceViewController pushViewController:destinationViewController animated:YES];
}

@end

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
@property (weak, nonatomic) IBOutlet UITextField *toteLandfillIntake;
@property (weak, nonatomic) IBOutlet UITextField *toteStepIntake;
@property (weak, nonatomic) IBOutlet UITextField *canFloorIntake;
@property (weak, nonatomic) IBOutlet UITextField *canStepIntake;
@property (weak, nonatomic) IBOutlet UITextField *litterInCan;
@property (weak, nonatomic) IBOutlet UIButton *robotSetButton;
@property (weak, nonatomic) IBOutlet UIButton *toteSetButton;
@property (weak, nonatomic) IBOutlet UIButton *canSetButton;
@property (weak, nonatomic) IBOutlet UIButton *toteStackButton;
@property (weak, nonatomic) IBOutlet UIButton *canDomTimeButton;
@property (weak, nonatomic) IBOutlet UITextField *coopSetNumer;
@property (weak, nonatomic) IBOutlet UITextField *coopSetDenom;
@property (weak, nonatomic) IBOutlet UITextField *coopStackNumer;
@property (weak, nonatomic) IBOutlet UITextField *coopStackDenom;
@property (nonatomic, weak) IBOutlet UIButton *noShowButton;
@property (nonatomic, weak) IBOutlet UIButton *doaButton;
@property (weak, nonatomic) IBOutlet UIButton *autonToteIntake;
@property (nonatomic, weak) IBOutlet UIButton *driverRating;
@property (weak, nonatomic) IBOutlet UIButton *robotType;
@property (weak, nonatomic) IBOutlet UITextField *allianceScore;

// Drawing Stuff
@property (weak, nonatomic) IBOutlet UIButton *drawingChoiceButton;
@property (weak, nonatomic) IBOutlet UIView *fieldDrawingContainer;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIImageView *autonTrace;
@property (weak, nonatomic) IBOutlet UIImageView *teleOpTrace;
@property (weak, nonatomic) IBOutlet UIImageView *paperPhoto;
@property (weak, nonatomic) IBOutlet UIButton *drawModeButton;
@property (weak, nonatomic) IBOutlet UIButton *createStacksButton;

@end

@implementation MatchScoutingViewController {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSString *previousTournament;
    NSString *deviceName;
    NSString *defaultAlliance;
    NSString *scoutMode;
    NSMutableDictionary *settingsDictionary;
    NSFetchedResultsController *fetchedResultsController;
    
    // Markers saved so that the user comes back to the same match if they leave this
    // display and then return
    NSNumber *storedMatchNumber;
    NSString *storedMatchType;
    NSString *storedAlliance;
    
    MatchUtilities *matchUtilities;
    ScoreUtilities *scoreUtilities;
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
    int currentMatchNumber;
    
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

    PopUpPickerViewController *robotTypePicker;
    UIPopoverController *robotTypePickerPopover;
    NSArray *robotTypeList;
    
    NSArray *autonTotePopUpList;
    PopUpPickerViewController *autonTotePicker;
    UIPopoverController *autonTotePickerPopover;

    NSArray *autonCanPopUpList;
    PopUpPickerViewController *autonCanPicker;
    UIPopoverController *autonCanPickerPopover;

    // Rating Pop Up
    NSArray *rateList;
    UIPopoverController *ratingPickerPopover;
    PopUpPickerViewController *ratePicker;
 
    BOOL dataChange;
    BOOL fieldDrawingChange;
    NSString *scouter;
    AlertPromptViewController *alertPrompt;
    UIPopoverController *alertPromptPopover;
    DrawingMode drawMode;
    BOOL returnFromScore;
    NSData *savedData;
    MatchPhotoUtilities *matchPhotoUtilities;
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
    scoutMode = [prefs objectForKey:@"mode"];
    if (tournamentName) {
        self.title =  [NSString stringWithFormat:@"%@ Match Scouting", tournamentName];
    }
    else {
        self.title = @"Match Scouting";
    }
    [self loadSettings];
    returnFromScore = FALSE;
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
    autonTotePopUpList = [[NSArray alloc] initWithObjects:@"0", @"1", @"2", @"3", nil];
    autonCanPopUpList = [[NSArray alloc] initWithObjects:@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", nil];
    rateList = [[NSMutableArray alloc] initWithObjects:@"0", @"1",@"2",@"3",@"4",@"5", nil];
    allianceDictionary = _dataManager.allianceDictionary;
    matchDictionary = _dataManager.matchTypeDictionary;
    matchUtilities = [[MatchUtilities alloc] init:_dataManager];
    scoreUtilities = [[ScoreUtilities alloc] init:_dataManager];
    matchPhotoUtilities = [[MatchPhotoUtilities alloc] init:_dataManager];
    _fieldDrawingContainer.layer.borderColor = [UIColor blackColor].CGColor;
    _fieldDrawingContainer.layer.borderWidth = 2.0f;
    teamList = [[NSMutableArray alloc] init];
    allianceList = [[NSMutableArray alloc] init];
    [self setDefaults];
    
    
}

-(void) viewWillAppear:(BOOL)animated
{
    NSLog(@"viewWillAppear");
    // Set the list of match types
    [self loadSettings];
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
        [self hideViews];
        [_teamNumber setTitle:@"" forState:UIControlStateNormal];
        _teamName.text = @"";
        [_alliance setTitle:@"" forState:UIControlStateNormal];
        return;
    }
    if (teamIndex == NSNotFound) {
        NSString *msg = @"No team in this alliance slot";
        [self alertPrompt:@"Show Team" withMessage:msg];
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
    _cansDominatedText.text = [NSString stringWithFormat:@"%@", currentScore.autonCansFromStep];
    _stackKnockdownText.text = [NSString stringWithFormat:@"%@", currentScore.stackKnockdowns];
     _totalTotesIntake.text = [NSString stringWithFormat:@"%@", currentScore.totalTotesIntake];
    _canFloorIntake.text = [NSString stringWithFormat:@"%@", currentScore.canIntakeFloor];
   _canStepIntake.text = [NSString stringWithFormat:@"%@", currentScore.cansFromStep];
    _totalScore.text = [NSString stringWithFormat:@"%@", currentScore.totalScore];
    _toteIntakeHPText.text = [NSString stringWithFormat:@"%@", currentScore.toteIntakeHP];
    _toteStepIntake.text = [NSString stringWithFormat:@"%@", currentScore.toteIntakeStep];
    _toteLandfillIntake.text = [NSString stringWithFormat:@"%@", currentScore.toteIntakeLandfill];
    _coopSetNumer.text = [NSString stringWithFormat:@"%@", currentScore.coopSetNumerator];
    _coopSetDenom.text = [NSString stringWithFormat:@"%@", currentScore.coopSetDenominator];
    _coopStackNumer.text = [NSString stringWithFormat:@"%@", currentScore.coopStackNumerator];
    _coopStackDenom.text = [NSString stringWithFormat:@"%@", currentScore.coopStackDenominator];
    _litterInCan.text = [NSString stringWithFormat:@"%@", currentScore.litterInCan];
    _totesOn0Text.text = [NSString stringWithFormat:@"%@", currentScore.totesOn0];
    _totesOn1Text.text = [NSString stringWithFormat:@"%@", currentScore.totesOn1];
    _totesOn2Text.text = [NSString stringWithFormat:@"%@", currentScore.totesOn2];
    _totesOn3Text.text = [NSString stringWithFormat:@"%@", currentScore.totesOn3];
    _allianceScore.text = [NSString stringWithFormat:@"%@", currentScore.allianceScore];
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
    [_robotType setTitle:currentScore.robotType forState:UIControlStateNormal];
    [_driverRating setTitle:[NSString stringWithFormat:@"%d", [currentScore.driverRating intValue]] forState:UIControlStateNormal];
    [self setAutonButton:_robotSetButton forValue:currentScore.autonRobotSet];
    [self setAutonButton:_toteStackButton forValue:currentScore.autonToteStack];
    [_canSetButton setTitle:[NSString stringWithFormat:@"%@", currentScore.autonCansScored] forState:UIControlStateNormal];
    [_toteSetButton setTitle:[NSString stringWithFormat:@"%@", currentScore.autonToteSet] forState:UIControlStateNormal];
    [_canDomTimeButton setTitle:[NSString stringWithFormat:@"%2.2f", [currentScore.canDominationTime floatValue]] forState:UIControlStateNormal];
    [self setRadioButtonState:_noShowButton forState:[currentScore.noShow intValue]];
    [self setRadioButtonState:_doaButton forState:[currentScore.deadOnArrival intValue]];
    [self showViews];
    if (returnFromScore) {
        drawMode = DrawInput;
        returnFromScore = FALSE;
    }
    else if ([currentScore.results boolValue]) {
        drawMode = DrawLock;
    }
    else {
        drawMode = DrawOff;
    }
    [self loadDrawing:allianceString];
    [self drawModeSettings:drawMode];
}

-(void)loadDrawing:(NSString *)allianceString {
    // Decide what to load
    // NSLog(@"field = %@, paper = %@", currentScore.field, currentScore.field.paper);
    if (currentScore.fieldPhotoName) {
    //    _fieldDrawingContainer.backgroundColor = [UIColor whiteColor];
        [_paperPhoto setImage:[UIImage imageWithContentsOfFile:[matchPhotoUtilities getFullPath:currentScore.fieldPhotoName]]];
        [_paperPhoto setHidden:FALSE];
    }
    else {
        [_paperPhoto setImage:nil];
        [_paperPhoto setHidden:TRUE];
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
    else desiredAlliance = newAlliance;
    [self showTeam:teamIndex];
}

-(IBAction)matchTypeSelectionChanged:(id)sender {
    // NSLog(@"matchTypeSelectionChanged");
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
    else desiredAlliance = [allianceList objectAtIndex:teamIndex];
    [self showTeam:teamIndex];
}

-(IBAction)matchNumberChanged {
    // NSLog(@"matchNumberChanged");
    [self checkDataStatus];
    
    if ([_matchNumber.text isEqualToString:@""]) {
        _matchNumber.text = [NSString stringWithFormat:@"%d", currentMatchNumber];
        return;
    }
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
        if ([scoutMode isEqualToString:@"Tournament"]) {
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
        if ([scoutMode isEqualToString:@"Tournament"]) {
            newSelection = newPick;
            [self checkAdminCode:_alliance];
        }
        else {
            [self allianceSelected:newPick];
        }
        [alliancePickerPopover dismissPopoverAnimated:YES];
        return;
    }
    if (popUp == robotTypePicker) {
        [robotTypePickerPopover dismissPopoverAnimated:YES];
        currentScore.robotType = newPick;
        [_robotType setTitle:newPick forState:UIControlStateNormal];
        return;
    }
    if (popUp == autonCanPicker) {
        currentScore.autonCansScored = [NSNumber numberWithInt:[newPick intValue]];
        [_canSetButton setTitle:[NSString stringWithFormat:@"%@", currentScore.autonCansScored] forState:UIControlStateNormal];
        [autonCanPickerPopover dismissPopoverAnimated:YES];
        return;
    }
    if (popUp == autonTotePicker) {
        currentScore.autonToteSet = [NSNumber numberWithInt:[newPick intValue]];
        [_toteSetButton setTitle:[NSString stringWithFormat:@"%@", currentScore.autonToteSet] forState:UIControlStateNormal];
        [autonTotePickerPopover dismissPopoverAnimated:YES];
        return;
    }
    if (popUp == _driverRating) {
        [ratingPickerPopover dismissPopoverAnimated:YES];
        [self setDriverRate:newPick];
        return;
    }
}

-(void)setDriverRate:(NSString *)newPick {
    currentScore.driverRating = [NSNumber numberWithInt:[newPick intValue]];
    [_driverRating setTitle:[NSString stringWithFormat:@"%d", [currentScore.driverRating intValue]] forState:UIControlStateNormal];
    [self setDataChange];
}

- (IBAction)autonSelection:(id)sender {
    [self setDataChange];
    if (sender == _robotSetButton) {
        if ([currentScore.autonRobotSet boolValue]) currentScore.autonRobotSet = [NSNumber numberWithBool:FALSE];
        else currentScore.autonRobotSet = [NSNumber numberWithBool:TRUE];
        [self setAutonButton:_robotSetButton forValue:currentScore.autonRobotSet];
    }
    else if (sender == _canSetButton) {
        popUp = _canSetButton;
        if (autonCanPicker == nil) {
            autonCanPicker = [[PopUpPickerViewController alloc]
                          initWithStyle:UITableViewStylePlain];
            autonCanPicker.delegate = self;
        }
        autonCanPicker.pickerChoices = autonCanPopUpList;
        if (!autonCanPickerPopover) {
            autonCanPickerPopover = [[UIPopoverController alloc]
                                 initWithContentViewController:autonCanPicker];
        }
        popUp = autonCanPicker;
        [autonCanPickerPopover presentPopoverFromRect:_canSetButton.bounds inView:_canSetButton
                         permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else if (sender == _toteSetButton) {
        if (autonTotePicker == nil) {
            autonTotePicker = [[PopUpPickerViewController alloc]
                              initWithStyle:UITableViewStylePlain];
            autonTotePicker.delegate = self;
        }
        autonTotePicker.pickerChoices = autonTotePopUpList;
        if (!autonTotePickerPopover) {
            autonTotePickerPopover = [[UIPopoverController alloc]
                                     initWithContentViewController:autonTotePicker];
        }
        popUp = autonTotePicker;
        [autonTotePickerPopover presentPopoverFromRect:_toteSetButton.bounds inView:_toteSetButton
                             permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else if (sender == _toteStackButton) {
        if ([currentScore.autonToteStack boolValue]) currentScore.autonToteStack = [NSNumber numberWithBool:FALSE];
        else currentScore.autonToteStack = [NSNumber numberWithBool:TRUE];
        [self setAutonButton:_toteStackButton forValue:currentScore.autonToteStack];
    }
    else if (sender == _robotType) {
        if (!robotTypeList) robotTypeList = [FileIOMethods initializePopUpList:@"RobotType"];
        if (robotTypePicker == nil) {
            robotTypePicker = [[PopUpPickerViewController alloc]
                              initWithStyle:UITableViewStylePlain];
            robotTypePicker.delegate = self;
        }
        robotTypePicker.pickerChoices = robotTypeList;
        if (!robotTypePickerPopover) {
            robotTypePickerPopover = [[UIPopoverController alloc]
                                     initWithContentViewController:robotTypePicker];
        }
        popUp = robotTypePicker;
        [robotTypePickerPopover presentPopoverFromRect:_robotType.bounds inView:_robotType
                             permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
   // [self updateTotal:@"TotalScore"];
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
    [self setDataChange];

//    if (drawMode == DrawAuton || drawMode == DrawDefense || drawMode == DrawTeleop) {
        dataChange = YES;
        NSLog(@"Start Timer");
        if (canDomTimer == nil) {
            canDomTimer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                                          target:self
                                                        selector:@selector(timerFired)
                                                        userInfo:nil
                                                         repeats:YES];
        }
        timerCount = 0;
  //  }
}

-(IBAction)canDomStop:(id)sender {
    [self setDataChange];
 //   if (drawMode == DrawAuton || drawMode == DrawDefense || drawMode == DrawTeleop) {
        float timeInSeconds = (float) timerCount/100;
        float newTimer = [currentScore.canDominationTime floatValue] + timeInSeconds;
        currentScore.canDominationTime = [NSNumber numberWithFloat:newTimer];
        [_canDomTimeButton setTitle:[NSString stringWithFormat:@"%2.2f", newTimer] forState:UIControlStateNormal];
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
        NSString *title = @"Empire Says: Are you sure you want to rest?";
        NSString *button = @"Yes, Reset";
        popUp = sender;
        
        [self confirmationActionSheet:title withButton:button];
    
}
    
-(void)confirmationActionSheet:title withButton:(NSString *)button {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:button otherButtonTitles:@"Nevermind",  nil];
        
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
    return matchTypes;
}

-(NSUInteger)getNumberOfMatches:(NSUInteger)section {
    if ([[fetchedResultsController sections] count]) {
        return [[[[fetchedResultsController sections] objectAtIndex:sectionIndex] objects] count];
    }
    else return 0;
}

- (IBAction)radioButtonTapped:(id)sender {
    if (sender == _noShowButton) { // It is on, turn it off
        if ([currentScore.noShow intValue]) {
            currentScore.noShow = [NSNumber numberWithBool:NO];
        }
        else { // It is off, turn it on
            currentScore.noShow = [NSNumber numberWithBool:YES];
            // If notes are blank, then go ahead and put no show in the notes
            if (!currentScore.notes || [currentScore.notes isEqualToString:@""]) {
                currentScore.notes = @"No Show";
                _notes.text = currentScore.notes;
            }
        }
        [self setRadioButtonState:_noShowButton forState:[currentScore.noShow intValue]];
    }
    if (sender == _doaButton) { // It is on, turn it off
        if ([currentScore.deadOnArrival intValue]) {
            currentScore.deadOnArrival = [NSNumber numberWithBool:NO];
        }
        else { // It is off, turn it on
            currentScore.deadOnArrival = [NSNumber numberWithBool:YES];
            // If notes are blank, then go ahead and put DOA in the notes
            if (!currentScore.notes || [currentScore.notes isEqualToString:@""]) {
                currentScore.notes = @"Dead";
                _notes.text = currentScore.notes;
            }
        }
        [self setRadioButtonState:_doaButton forState:[currentScore.deadOnArrival intValue]];
    }
    
    [self setDataChange];
}

-(void)setRadioButtonState:(UIButton *)button forState:(NSUInteger)selection {
    if (selection == -1 || selection == 0) {
        [button setImage:[UIImage imageNamed:@"RadioButton-Unselected.png"] forState:UIControlStateNormal];
    }
    else {
        [button setImage:[UIImage imageNamed:@"RadioButton-Selected.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)ratingPopUp:(id)sender {
    UIButton *PressedButton = (UIButton*)sender;
    popUp = PressedButton;
    
    if (ratePicker == nil) {
        ratePicker = [[PopUpPickerViewController alloc]
                      initWithStyle:UITableViewStylePlain];
        ratePicker.delegate = self;
        ratePicker.pickerChoices = rateList;
        ratingPickerPopover = [[UIPopoverController alloc]initWithContentViewController:ratePicker];
    }
    [ratingPickerPopover presentPopoverFromRect:PressedButton.bounds inView:PressedButton
                       permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}


- (IBAction)drawingChoice:(id)sender {
    popUp = _drawingChoiceButton;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Photo", @"Draw Mode",  nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showFromRect:_drawingChoiceButton.frame inView:_stackView animated:YES];
    popUp = _drawingChoiceButton;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            if (popUp == _drawingChoiceButton) [self fieldPhoto:@"Take"];
            else if (popUp == _matchResetButton) [self matchReset];
            else if (popUp == _drawModeButton) {
                drawMode = DrawOff;
                [self drawModeSettings:drawMode];
            }
            break;
        case 1:
            if (popUp == _drawingChoiceButton) [self fieldPhoto:@"Choose"];
            break;
        case 2:
            if (popUp == _drawingChoiceButton) [self pushDrawingView];
            break;

        default:
            break;
    }    
}

-(void)matchReset {
    dataChange = FALSE;
    currentScore = [scoreUtilities scoreReset:currentScore];
    [self showTeam:teamIndex];
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
    //NSLog(@"photo popover");
    _paperPhoto.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [_paperPhoto setHidden:FALSE];
    currentScore.fieldPhotoName = [matchPhotoUtilities savePhoto:_paperPhoto.image forMatch:currentScore.matchNumber forType:matchTypeString forTeam:currentScore.teamNumber];
    [self setDataChange];
    // NSLog(@"image picker finish");*/
    [picker dismissViewControllerAnimated:YES completion:Nil];
    [pictureController dismissPopoverAnimated:true];
}

-(void) drawModeSettings:(DrawingMode) mode {
    switch (mode) {
        case DrawOff:
            [_drawModeButton setBackgroundImage:[UIImage imageNamed:@"Small White Button.jpg"] forState:UIControlStateNormal];
            [_drawModeButton setTitle:@"Off" forState:UIControlStateNormal];
            [_drawModeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self disableInputs];
            break;
        case DrawInput:
            [_drawModeButton setBackgroundImage:[UIImage imageNamed:@"Small Green Button.jpg"] forState:UIControlStateNormal];
            [_drawModeButton setTitle:@"Input" forState:UIControlStateNormal];
            [_drawModeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self enableInputs];
            break;
/*        case DrawAuton:
            red = 255.0/255.0;
            green = 190.0/255.0;
            blue = 0.0/255.0;
            [_drawModeButton setBackgroundImage:[UIImage imageNamed:@"Small Green Button.jpg"] forState:UIControlStateNormal];
            [_drawModeButton setTitle:@"Auton" forState:UIControlStateNormal];
            [_drawModeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self enableButtons];
            [self activateAuton];
            [self deactivateTeleOp];
            break;
        case DrawTeleop:
            red = 0.0/255.0;
            green = 0.0/255.0;
            blue = 0.0/255.0;
            [_drawModeButton setBackgroundImage:[UIImage imageNamed:@"Small Blue Button.jpg"] forState:UIControlStateNormal];
            [_drawModeButton setTitle:@"TeleOp" forState:UIControlStateNormal];
            [_drawModeButton setTitleColor:[UIColor colorWithRed:255.0 green:190.0 blue:0 alpha:1.0] forState:UIControlStateNormal];
            [self activateTeleOp];
            [self deactivateAuton];
            break;
        case DrawDefense:
            // Not in use for Recycle Rush
            red = 255.0/255.0;
            green = 0.0/255.0;
            blue = 0.0/255.0;
            [_drawModeButton setBackgroundImage:[UIImage imageNamed:@"Small Grey Button.jpg"] forState:UIControlStateNormal];
            [_drawModeButton setTitle:@"Defense" forState:UIControlStateNormal];
            [_drawModeButton setTitleColor:[UIColor colorWithRed:255.0 green:190.0 blue:0 alpha:1.0] forState:UIControlStateNormal];
            break;*/
        case DrawLock:
            [_drawModeButton setBackgroundImage:[UIImage imageNamed:@"Small Red Button.jpg"] forState:UIControlStateNormal];
            [_drawModeButton setTitle:@"Locked" forState:UIControlStateNormal];
            [_drawModeButton setTitleColor:[UIColor colorWithRed:255.0 green:190.0 blue:0 alpha:1.0] forState:UIControlStateNormal];
            [self disableInputs];
            break;
        default:
            break;
    }
}

-(void)setDisplayInactive {
    //NSLog(@"Deactivate display");
    [_drawModeButton setUserInteractionEnabled:NO];
    [_matchNumber setUserInteractionEnabled:FALSE];
    [_matchType setUserInteractionEnabled:FALSE];
    [_alliance setUserInteractionEnabled:FALSE];
    [self hideViews];
}

-(void)setDisplayActive {
    //NSLog(@"Reactivate display");
    [_drawModeButton setUserInteractionEnabled:TRUE];
    [_matchNumber setUserInteractionEnabled:TRUE];
    [_matchType setUserInteractionEnabled:TRUE];
    [_robotType setUserInteractionEnabled:TRUE];
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
        if ([scoutMode isEqualToString:@"Tournament"]) {
            NSString *msg;
            if (defaultAlliance == nil || [defaultAlliance isEqualToString:@""]) {
                desiredAlliance = @"";
                msg = @"No Default Alliance Set";
                [self alertPrompt:@"Tournament Mode" withMessage:msg];
            }
            else if ([defaultAlliance isEqualToString:storedAlliance] == NO) {
                desiredAlliance = defaultAlliance;
                msg = [NSString stringWithFormat:@"Switching from stored %@ to default %@", storedAlliance, defaultAlliance];
                [self alertPrompt:@"Tournament Mode" withMessage:msg];
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
        NSIndexPath *indexPath = [fetchedResultsController indexPathForObject:match];
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
    if (textField == _matchNumber) currentMatchNumber = [_matchNumber.text intValue];
    else [self setDataChange];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    //    NSLog(@"should end editing");
    if (textField == _notes) {
		currentScore.notes = _notes.text;
	}
    else if (textField == _coopSetNumer) {
        currentScore.coopSetNumerator = [NSNumber numberWithInt:[_coopSetNumer.text intValue]];
    }
    else if (textField == _coopSetDenom) {
        currentScore.coopSetDenominator = [NSNumber numberWithInt:[_coopSetDenom.text intValue]];
    }
    else if (textField == _coopStackNumer) {
        currentScore.coopStackNumerator = [NSNumber numberWithInt:[_coopStackNumer.text intValue]];
    }
    else if (textField == _coopStackDenom) {
        currentScore.coopStackDenominator = [NSNumber numberWithInt:[_coopStackDenom.text intValue]];
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
        currentScore.autonCansFromStep = [NSNumber numberWithInt:[_cansDominatedText.text intValue]];
    }
    else if (textField == _stackKnockdownText) {
        currentScore.stackKnockdowns = [NSNumber numberWithInt:[_stackKnockdownText.text intValue]];
    }
    else if (textField == _allianceScore) {
        currentScore.allianceScore = [NSNumber numberWithInt:[_allianceScore.text intValue]];
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
    else if (textField == _toteLandfillIntake) {
        currentScore.toteIntakeLandfill = [NSNumber numberWithInt:[_toteLandfillIntake.text intValue]];
        [self updateTotal:@"TotesIntake"];
    }
    else if (textField == _canFloorIntake) {
        currentScore.canIntakeFloor = [NSNumber numberWithInt:[_canFloorIntake.text intValue]];
    }
    else if (textField == _canStepIntake) {
        currentScore.cansFromStep = [NSNumber numberWithInt:[_canStepIntake.text intValue]];
    }
    else if (textField == _litterInCan) {
        currentScore.litterInCan = [NSNumber numberWithInt:[_litterInCan.text intValue]];
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
        int score = [currentScore.toteIntakeHP intValue] + [currentScore.toteIntakeStep intValue] + [currentScore.toteIntakeLandfill intValue];
         currentScore.totalTotesIntake = [NSNumber numberWithInt:score];
        _totalTotesIntake.text = [NSString stringWithFormat:@"%d", score];
    }
    else if ([scoreObject isEqualToString:@"TotalScore"]) {
        int score = [currentScore.totesOn0 intValue]*0 + [currentScore.totesOn1 intValue]*2 + [currentScore.totesOn2 intValue]*2 + [currentScore.totesOn3 intValue]*2 + [currentScore.totesOn4 intValue]*2 + [currentScore.totesOn5 intValue]*2 + [currentScore.totesOn6 intValue]*2 + [currentScore.cansOn0 intValue]*0 + [currentScore.cansOn1 intValue]*4 + [currentScore.cansOn2 intValue]*8 + [currentScore.cansOn3 intValue]*12 + [currentScore.cansOn4 intValue]*16 + [currentScore.cansOn5 intValue]*20 + [currentScore.cansOn6 intValue]*24 + [currentScore.litterInCan intValue]*6 + [currentScore.totalLandfillLitterScored intValue] + [currentScore.oppositeZoneLitter intValue]*4 + [currentScore.autonRobotSet intValue]*4 + [currentScore.autonToteSet intValue]*6 + [currentScore.autonCansScored intValue]*8 + [currentScore.autonToteStack intValue]*20;
        currentScore.totalScore = [NSNumber numberWithInt:score];
        _totalScore.text = [NSString stringWithFormat:@"%d", score];
    }
}

-(IBAction)drawModeChange: (id)sender {
    switch (drawMode) {
        case DrawOff:
            if (!currentScore.teamNumber || [currentScore.teamNumber intValue] == 0) {
                UIAlertView *prompt  = [[UIAlertView alloc] initWithTitle:@"Team Check Alert"
                                                                  message:@"FYI There's No Team in This Slot"
                                                                 delegate:nil
                                                        cancelButtonTitle:@"Ok"
                                                        otherButtonTitles:nil];
                [prompt setAlertViewStyle:UIAlertViewStyleDefault];
                [prompt show];
            }
            else {
                drawMode = DrawInput;
               // [self enlargeDrawing];
            }
            break;
        case DrawInput:
            drawMode = DrawOff;
            break;
/*        case DrawAuton:
            drawMode = DrawTeleop;
            break;
        case DrawTeleop:
            drawMode = DrawAuton;
            break;
        case DrawDefense:
            drawMode = DrawTeleop;
            break;*/
        case DrawLock:
            popUp = sender;
            [self confirmationActionSheet:@"Empire Wants To Know if You Want To Confirm Match Unlock" withButton:@"Yes (Unlock)"];
            break;
        default:
            NSLog(@"Bad things have happened in drawModeChange");
    }
    [self drawModeSettings:drawMode];
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
    [self setBigButtonDefaults:_robotType];
    [self setBigButtonDefaults:_drawModeButton];
    [self setBigButtonDefaults:_createStacksButton];
    [self setSmallButtonDefaults:_driverRating];

    _robotSetButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    _toteSetButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    _toteStackButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    _canSetButton.titleLabel.textAlignment = NSTextAlignmentCenter;
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
    _totalTotesScored.inputView = [LNNumberpad defaultLNNumberpad];
    _totalCansScored.inputView = [LNNumberpad defaultLNNumberpad];
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
    _toteLandfillIntake.inputView  = [LNNumberpad defaultLNNumberpad];
    _canStepIntake.inputView  = [LNNumberpad defaultLNNumberpad];
    _litterInCan.inputView  = [LNNumberpad defaultLNNumberpad];
    _coopSetNumer.inputView = [LNNumberpad defaultLNNumberpad];
    _coopSetDenom.inputView = [LNNumberpad defaultLNNumberpad];
    _coopStackNumer.inputView = [LNNumberpad defaultLNNumberpad];
    _coopStackDenom.inputView = [LNNumberpad defaultLNNumberpad];
    _allianceScore.inputView = [LNNumberpad defaultLNNumberpad];

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

#pragma mark - Navigation
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self checkDataStatus];
    if ([segue.identifier isEqualToString:@"TeamDetail"]) {
        TeamDetailViewController *detailViewController = [segue destinationViewController];
        [segue.destinationViewController setDataManager:_dataManager];
        detailViewController.team = currentTeam;
    }
    else if ([segue.identifier isEqualToString:@"StackView"]) {
        [segue.destinationViewController setDataManager:_dataManager];
        [segue.destinationViewController setAllianceString:allianceString];
        [segue.destinationViewController setCurrentScore:currentScore];
        [segue.destinationViewController setDeviceName:deviceName];
       [segue.destinationViewController setDelegate:self];
    }
    else if ([segue.identifier isEqualToString:@"FlagView"]) {
        [segue.destinationViewController setDataManager:_dataManager];
        [segue.destinationViewController setCurrentScore:currentScore];
    }
    else if ([segue.identifier isEqualToString:@"MainAnalysis"]) {
        [segue.destinationViewController setDataManager:_dataManager];
        // NSLog(@"Match list = %@", matchList);
        [segue.destinationViewController setTeamNumber:[NSNumber numberWithInt:[_teamNumber.titleLabel.text intValue]]];
        [segue.destinationViewController setInitialMatchNumber:currentScore.matchNumber];
        [segue.destinationViewController setInitialMatchType:currentScore.matchType];
    }
    else if ([segue.identifier isEqualToString:@"Add"]) {
        UINavigationController *nv = (UINavigationController *)[segue destinationViewController];
        AddMatchViewController *addvc = (AddMatchViewController *)nv.topViewController;
        [addvc setDataManager:_dataManager];
        [addvc setTournamentName:tournamentName];
    }
    else if ([segue.identifier isEqualToString:@"Edit"]) {
        UINavigationController *nv = (UINavigationController *)[segue destinationViewController];
        AddMatchViewController *addvc = (AddMatchViewController *)nv.topViewController;
        [addvc setDataManager:_dataManager];
        [addvc setTournamentName:tournamentName];
        [addvc setMatch:currentMatch];
    }
    else if ([segue.identifier isEqualToString:@"Sync"])  {
        [segue.destinationViewController setDataManager:_dataManager];
        [segue.destinationViewController setConnectionUtility:_connectionUtility];
    }
    else if ([segue.identifier isEqualToString:@"MatchSummary"])  {
        [segue.destinationViewController setDataManager:_dataManager];
        [segue.destinationViewController setCurrentScore:currentScore];
       // [segue.destinationViewController setTeam:currentTeam];
    }
}

- (void)scoringViewFinished {
    returnFromScore = TRUE;
}

-(void)pushDrawingView {
    MatchDrawingViewController *drawingViewController = [[self.navigationController storyboard]instantiateViewControllerWithIdentifier:@"MatchDrawingViewController"];
    [drawingViewController setDataManager:_dataManager];
    [drawingViewController setScore:currentScore];
    MatchDrawingSegue *matchDrawingSegue = [[MatchDrawingSegue alloc] initWithIdentifier:@"MatchDrawingViewController"
                                                                                  source:self.navigationController
                                                                             destination:drawingViewController];
    [matchDrawingSegue perform];    
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

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    // [self.tableView beginUpdates];
    NSLog(@"controllerWillChangeContent");
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    //   UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            //NSLog(@"didChangeObject 1");
            // [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            //NSLog(@"didChangeObject 2");
            //[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            //NSLog(@"didChangeObject 3");
            //  [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
           // NSLog(@"didChangeObject 4");
            // [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            //[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            //NSLog(@"didChangeSection 1");
            //[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            //NSLog(@"didChangeSection 2");
            //[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    //[self.tableView endUpdates];
    //NSLog(@"controllerDidChangeContent");
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
