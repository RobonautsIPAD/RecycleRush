//
//  MainScoutingPageViewController.m
// Robonauts Scouting
//
//  Created by Kris Pettinger on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/CALayer.h>
#import "MainScoutingPageViewController.h"
#import "DataManager.h"
#import "FileIOMethods.h"
#import "DataConvenienceMethods.h"
#import "TeamAccessors.h"
#import "EnumerationDictionary.h"
#import "MatchData.h"
#import "MatchAccessors.h"
#import "MatchUtilities.h"
#import "MatchFlow.h"
#import "TeamScore.h"
#import "FieldDrawing.h"
#import "TeamData.h"
#import "SyncMethods.h"
#import "PadSyncViewController.h"
#import "TeamDetailViewController.h"
#import "PopUpPickerViewController.h"
#import <ImageIO/CGImageSource.h>

@interface MainScoutingPageViewController ()
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

// Auton Scoring
@property (weak, nonatomic) IBOutlet UIButton *toteSetButton;
@property (weak, nonatomic) IBOutlet UIButton *toteStackButton;
@property (weak, nonatomic) IBOutlet UIButton *autonToteIntakeButton;
@property (nonatomic, weak) IBOutlet UIButton *autonMobilityButton;
@property (nonatomic, weak) IBOutlet UIButton *noShowButton;
@property (nonatomic, weak) IBOutlet UIButton *doaButton;

// TeleOp Scoring
@property (weak, nonatomic) IBOutlet UIButton *toteFloorTopButton;
@property (weak, nonatomic) IBOutlet UIButton *toteFloorBottomButton;
@property (weak, nonatomic) IBOutlet UIButton *toteFloorButton;
@property (weak, nonatomic) IBOutlet UIButton *toteStepTopButton;
@property (weak, nonatomic) IBOutlet UIButton *toteStepBottomButton;
@property (weak, nonatomic) IBOutlet UIButton *toteStepButton;

// Human Player
@property (weak, nonatomic) IBOutlet UIButton *toteHPButton;
@property (weak, nonatomic) IBOutlet UIButton *toteHPTopButton;
@property (weak, nonatomic) IBOutlet UIButton *toteHPBottomButton;
@property (weak, nonatomic) IBOutlet UIButton *litterHPTopButton;
@property (weak, nonatomic) IBOutlet UIButton *litterHPBottomButton;

// Floor Action
// Defensive Action
    @property (nonatomic, weak) IBOutlet UIButton *knockoutButton;
// Ratings
    @property (nonatomic, weak) IBOutlet UIButton *driverRating;
    @property (nonatomic, weak) IBOutlet UIButton *robotSpeed;
     @property (nonatomic, weak) IBOutlet UIButton *intakeRatingButton;
// Other Stuff
    @property (nonatomic, weak) IBOutlet UIButton *toggleGridButton;
    @property (nonatomic, weak) IBOutlet UIButton *drawModeButton;
    @property (nonatomic, weak) IBOutlet UIButton *eraserButton;
    @property (nonatomic, weak) IBOutlet UITextField *foulTextField;
    @property (weak, nonatomic) IBOutlet UIButton *scouterButton;
    @property (nonatomic, weak) IBOutlet UITextField *scouterTextField;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;


// Drawing Layers
// The trace of the robot in auton
@property (weak, nonatomic) IBOutlet UIImageView *autonTrace;
// The trace of the robot in tele op
@property (weak, nonatomic) IBOutlet UIImageView *teleOpTrace;
// The field backgroud image layer
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImage;

// This is the "main view" that holds all the drawing pieces
@property (nonatomic, weak) IBOutlet UIView *imageContainer;

// Segues
    @property (nonatomic, weak) IBOutlet UIButton *matchListButton;
    @property (nonatomic, weak) IBOutlet UIButton *teamEdit;
    @property (nonatomic, weak) IBOutlet UIButton *syncButton;

@end

@implementation MainScoutingPageViewController {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSString *previousTournament;
    NSString *deviceName;
    NSString *scouter;
    NSMutableDictionary *settingsDictionary;
    NSDictionary *matchDictionary;
    NSDictionary *allianceDictionary;
    NSFetchedResultsController *fetchedResultsController;
    NSUInteger sectionIndex;
    NSUInteger rowIndex;
    NSUInteger teamIndex;
    MatchData *currentMatch;
    TeamScore *currentScore;
    TeamData *currentTeam;
    MatchUtilities *matchUtilities;
    NSUInteger numberMatchTypes;
    id popUp;
    NSArray *scoreList;
    BOOL setStartPoint;
 
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

    // Drawing Pop Ups
    NSArray *scoreButtonChoices;
    PopUpPickerViewController *scoreButtonReset;
    UIPopoverController *scoreButtonPickerPopover;
    NSArray *defenseList;
    PopUpPickerViewController *defensePicker;
    UIPopoverController *defensePickerPopover;

    UIButton *currentStack;
    // Auton Scoring Items
    NSMutableArray *autonScoreList;
    UIPopoverController *autonPickerPopover;
    PopUpPickerViewController *autonPicker;
    NSMutableArray *autonToteStacks;

    // TeleOp Scoring pop up
    NSMutableArray *teleOpScoreList;
    UIPopoverController *teleOpPickerPopover;
    PopUpPickerViewController *teleOpPicker;
    // TeleOp Pick Up pop up
    NSMutableArray *teleOpPickUpList;
    UIPopoverController *teleOpPickUpPickerPopover;
    PopUpPickerViewController *teleOpPickUpPicker;
    // Partner Action pop up
    NSMutableArray *partnerActionsList;
    UIPopoverController *partnerActionsPickerPopover;
    PopUpPickerViewController *partnerActionsPicker;
    // Rating Pop Up
    NSArray *rateList;
    UIPopoverController *ratingPickerPopover;
    PopUpPickerViewController *ratePicker;
    // Scouter Pop Up
    NSArray *scouterNameList;
    PopUpPickerViewController *scouterNamePicker;
    UIPopoverController *scouterNamePickerPopover;
    
    // Tote stack slider
    UISlider *toteStackSlider;
    
    UITapGestureRecognizer *tapPressGesture;
    UITapGestureRecognizer *doubleTapGestureRecognizer;
    UITapGestureRecognizer *tripleTapGesture;
    UIPanGestureRecognizer *drawGesture;

    BOOL eraseMode;
    BOOL dataChange;
    BOOL fieldDrawingChange;
    
    int popCounter;
    CGPoint currentPoint;
    DrawingMode drawMode;

    // Drawing Symbols
    UIImage *autonSPImage;
    UIImage *robotMissImage;
    UIImage *humanIntakeImage;
    UIImage *humanMissImage;
    UIImage *trussCatchImage;
    UIImage *trussCatchMissImage;
    UIImage *trussThrowImage;
    UIImage *trussThrowMissImage;
    UIImage *floorPickUpImage;
    UIImage *floorPickUpMissImage;
    UIImage *passImage;
    UIImage *passMissImage;
    UIImage *disruptedShotImage;
    
    BOOL startPoint;
    CGRect orgFrame;
}

// User Access Control
@synthesize overrideMode;
@synthesize alertPrompt;
@synthesize alertPromptPopover;

// Match Score
@synthesize valuePrompt = _valuePrompt;
@synthesize valuePromptPopover = _valuePromptPopover;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
#ifdef NOTUSED
    NSLog(@"Main Scouting viewDidLoad");
    NSError *error = nil;
    if (!_dataManager) {
        _dataManager = [[DataManager alloc] init];
    }

    prefs = [NSUserDefaults standardUserDefaults];
    deviceName = [prefs objectForKey:@"deviceName"];
    scouter = [prefs objectForKey:@"scouter"];
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

    [self setDefaults];
    allianceDictionary = _dataManager.allianceDictionary;
    matchDictionary = _dataManager.matchTypeDictionary;
    matchUtilities = [[MatchUtilities alloc] init:_dataManager];

/*    toteStackSlider = [[UISlider alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    [toteStackSlider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    [toteStackSlider setBackgroundColor:[UIColor clearColor]];
    toteStackSlider.minimumValue = 0.0;
    toteStackSlider.maximumValue = 6.0;
    toteStackSlider.continuous = YES;
    toteStackSlider.value = 25.0;
 //   CGAffineTransform trans = CGAffineTransformMakeRotation(M_PI * 0.5);
 //   toteStackSlider.transform = trans;
    UIImage *sliderTrackImage = [[UIImage imageNamed: @"ios-7-camera-icon.png"] stretchableImageWithLeftCapWidth: 7 topCapHeight: 0];
    
    [toteStackSlider setMinimumTrackImage: sliderTrackImage forState: UIControlStateNormal];
    [toteStackSlider setMaximumTrackImage: sliderTrackImage forState: UIControlStateNormal];
    */
    teamList = [[NSMutableArray alloc] init];
    allianceList = [[NSMutableArray alloc] init];
    NSLog(@"add check for valid match");
    
    [self disableButtons];
    [self drawingSettings];
    [self createGestures];
    [self.view bringSubviewToFront:_imageContainer];
    [_imageContainer sendSubviewToBack:_backgroundImage];
    orgFrame = _imageContainer.frame;
#endif
}

- (void) viewWillAppear:(BOOL)animated
{
#ifdef NOTUSED
    NSLog(@"viewWillAppear");
    // Set the list of match types
    matchTypeList = [self getMatchTypeList];
    numberMatchTypes = [matchTypeList count];
    NSLog(@"%@", matchTypeList);
    setStartPoint = TRUE;
    // NSLog(@"Match Type List Count = %@", matchTypeList);
    
    // If there are no matches in any section then don't set this stuff. ShowMatch will set currentMatch to
    // nil, printing out blank info in all the display items.

    if (numberMatchTypes) {
        // Temporary method to save the data markers
        storePath = [[self applicationLibraryDirectory] stringByAppendingPathComponent: @"Preferences/dataMarker.csv"];
        fileManager = [NSFileManager defaultManager];
        //        [fileManager removeItemAtPath:storePath error:&error];
        if (![fileManager fileExistsAtPath:storePath]) {
            // Loading Default Data Markers
    //        currentSectionType = [[matchDictionary getMatchTypeEnum:[matchTypeList objectAtIndex:0]] intValue];
            rowIndex = 0;
            sectionIndex = [self getMatchSectionInfo:currentSectionType];
            teamIndex = 0;
        }
        else {
            CSVParser *parser = [CSVParser new];
            [parser openFile: storePath];
            NSMutableArray *csvContent = [parser parseFile];
            // NSLog(@"data marker = %@", csvContent);
            rowIndex = [[[csvContent objectAtIndex:0] objectAtIndex:0] intValue];
            teamIndex = [[[csvContent objectAtIndex:0] objectAtIndex:2] intValue];
            currentSectionType = [[[csvContent objectAtIndex:0] objectAtIndex:1] intValue];
            sectionIndex = [self getMatchSectionInfo:currentSectionType];
            if (sectionIndex == -1) { // The selected match type does not exist
                // Go back to the first section in the table
    //            currentSectionType = [[matchDictionary getMatchTypeEnum:[matchTypeList objectAtIndex:0]] intValue];
                sectionIndex = [self getMatchSectionInfo:currentSectionType];
            }
        }
    }
    
    currentMatch = [self getCurrentMatch];
    // NSLog(@"Match = %@, Type = %@, Tournament = %@", currentMatch.number, currentMatch.matchType, currentMatch.tournament);
    // NSLog(@"Settings = %@", settings.tournament.name);
    // NSLog(@"Field Drawing Path = %@", baseDrawingPath);
    dataChange = NO;
    fieldDrawingChange = NO;
    [self setTeamList];
    [self showTeam:teamIndex];
#endif
}

- (void) viewWillDisappear:(BOOL)animated
{
    NSLog(@"viewWillDisappear");
#ifdef NOTUSED
    [self checkDataStatus];
    [self saveSettings];
#endif
}
#ifdef NOTUSED

-(void)getDrawingSymbols {
    NSString *imageFilePath = [[NSBundle mainBundle] pathForResource:@"AutonSP" ofType:@"png"];
    autonSPImage = [UIImage imageWithContentsOfFile:imageFilePath];
    imageFilePath = [[NSBundle mainBundle] pathForResource:@"Intake from Robot Miss" ofType:@"png"];
    robotMissImage = [UIImage imageWithContentsOfFile:imageFilePath];

    imageFilePath = [[NSBundle mainBundle] pathForResource:@"Intake from Human" ofType:@"png"];
    humanIntakeImage = [UIImage imageWithContentsOfFile:imageFilePath];
    imageFilePath = [[NSBundle mainBundle] pathForResource:@"Intake from Human Miss" ofType:@"png"];
    humanMissImage = [UIImage imageWithContentsOfFile:imageFilePath];

    imageFilePath = [[NSBundle mainBundle] pathForResource:@"Truss Catch" ofType:@"png"];
    trussCatchImage = [UIImage imageWithContentsOfFile:imageFilePath];
    imageFilePath = [[NSBundle mainBundle] pathForResource:@"Truss Catch Miss" ofType:@"png"];
    trussCatchMissImage = [UIImage imageWithContentsOfFile:imageFilePath];
    
    imageFilePath = [[NSBundle mainBundle] pathForResource:@"Truss Throw" ofType:@"png"];
    trussThrowImage = [UIImage imageWithContentsOfFile:imageFilePath];
    imageFilePath = [[NSBundle mainBundle] pathForResource:@"Truss Throw Miss" ofType:@"png"];
    trussThrowMissImage = [UIImage imageWithContentsOfFile:imageFilePath];

    imageFilePath = [[NSBundle mainBundle] pathForResource:@"Pick Up" ofType:@"png"];
    floorPickUpImage = [UIImage imageWithContentsOfFile:imageFilePath];
    imageFilePath = [[NSBundle mainBundle] pathForResource:@"Pick Up Miss" ofType:@"png"];
    floorPickUpMissImage = [UIImage imageWithContentsOfFile:imageFilePath];

    imageFilePath = [[NSBundle mainBundle] pathForResource:@"Pass to Robot" ofType:@"png"];
    passImage = [UIImage imageWithContentsOfFile:imageFilePath];
    imageFilePath = [[NSBundle mainBundle] pathForResource:@"Pass to Robot Miss" ofType:@"png"];
    passMissImage = [UIImage imageWithContentsOfFile:imageFilePath];

    imageFilePath = [[NSBundle mainBundle] pathForResource:@"Blocked Shot" ofType:@"png"];
    disruptedShotImage = [UIImage imageWithContentsOfFile:imageFilePath];

}

-(NSMutableArray *)getMatchTypeList {
    NSMutableArray *matchTypes = [[NSMutableArray alloc] init];
    NSString *sectionName;
    for (int i=0; i < [[fetchedResultsController sections] count]; i++) {
        sectionName = [[[fetchedResultsController sections] objectAtIndex:i] name];
        // NSLog(@"Section = %@", sectionName);
        [matchTypes addObject:[EnumerationDictionary getKeyFromValue:[NSNumber numberWithInt:[sectionName intValue]] forDictionary:matchDictionary]];
    }
    // NSLog(@"match types = %@", matchTypes);
    return matchTypes;
}

-(NSUInteger)getNumberOfMatches:(NSUInteger)section {
    if ([[fetchedResultsController sections] count]) {
        return [[[[fetchedResultsController sections] objectAtIndex:sectionIndex] objects] count];
    }
    else return 0;
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

-(void)loadSettings {
    NSString *plistPath = [[FileIOMethods applicationLibraryDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"Preferences/MainScoutingPageSettings.plist"]];
    settingsDictionary = [[FileIOMethods getDictionaryFromPListFile:plistPath] mutableCopy];
    if (settingsDictionary) previousTournament = [settingsDictionary valueForKey:@"Tournament"];
    sectionIndex = 0;
    rowIndex = 0;
    if ([tournamentName isEqualToString:previousTournament]) {
        sectionIndex = [[settingsDictionary valueForKey:@"Section Index"] intValue];
        rowIndex = [[settingsDictionary valueForKey:@"Row Index"] intValue];
        teamIndex = [[settingsDictionary valueForKey:@"Team Index"] intValue];
    }
}

-(void)saveSettings {
    if (!settingsDictionary) {
        settingsDictionary = [[NSMutableDictionary alloc] init];
    }
    [settingsDictionary setObject:tournamentName forKey:@"Tournament"];
    [settingsDictionary setObject:[NSNumber numberWithLong:sectionIndex] forKey:@"Section Index"];
    [settingsDictionary setObject:[NSNumber numberWithLong:rowIndex] forKey:@"Row Index"];
    [settingsDictionary setObject:[NSNumber numberWithLong:teamIndex] forKey:@"Team Index"];
    
    NSString *plistPath = [[FileIOMethods applicationLibraryDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"Preferences/MainScoutingPageSettings.plist"]];
    NSError *error;
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:settingsDictionary format:NSPropertyListXMLFormat_v1_0 options:nil error:&error];
    if(data) {
        [data writeToFile:plistPath atomically:YES];
    }
    else {
        NSLog(@"An error has occured %@", error);
    }
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
    NSString *typeString = [EnumerationDictionary getKeyFromValue:currentType forDictionary:matchDictionary];
    
    newSection = [MatchFlow getNextMatchType:matchTypeList forCurrent:typeString];
    if (newSection == NSNotFound) return sectionIndex;
    else return newSection;
}

-(NSUInteger)getPreviousSection:(NSNumber *) currentType {
    NSUInteger newSection;
    //    NSLog(@"getPreviousSection");
    NSString *typeString = [EnumerationDictionary getKeyFromValue:currentType forDictionary:matchDictionary];
    
    newSection = [MatchFlow getPreviousMatchType:matchTypeList forCurrent:typeString];
    if (newSection == NSNotFound) return sectionIndex;
    else return newSection;
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

-(IBAction)MatchNumberChanged {
    // NSLog(@"MatchNumberChanged");
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

-(void)setRadioButtonState:(UIButton *)button forState:(NSUInteger)selection {
    if (selection == -1 || selection == 0) {
        [button setImage:[UIImage imageNamed:@"RadioButton-Unselected.png"] forState:UIControlStateNormal];
    }
    else {
        [button setImage:[UIImage imageNamed:@"RadioButton-Selected.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)radioButtonTapped:(id)sender {
    if (sender == _autonMobilityButton) { // It is on, turn it off
        if ([currentScore.autonRobotSet intValue]) {
            currentScore.autonRobotSet = [NSNumber numberWithBool:NO];
        }
        else { // It is off, turn it on
            currentScore.autonRobotSet = [NSNumber numberWithBool:YES];
        }
        [self setRadioButtonState:_autonMobilityButton forState:[currentScore.autonRobotSet intValue]];
    }
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField != _foulTextField)  return YES;
    
    NSString *resultingString = [textField.text stringByReplacingCharactersInRange: range withString: string];
    
    // This allows backspace
    if ([resultingString length] == 0) {
        return true;
    }
    
    NSInteger holder;
    NSScanner *scan = [NSScanner scannerWithString: resultingString];
    
    return [scan scanInteger: &holder] && [scan isAtEnd];
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
    else if (textField == _foulTextField) {
        currentScore.fouls = [NSNumber numberWithInt:[_foulTextField.text intValue]];
    }
    else if (textField == _scouterTextField) {
        scouter = _scouterTextField.text;
		currentScore.scouter = scouter;
        [prefs setObject:scouter forKey:@"scouter"];
	}
	return YES;
}



// Keeping the score

- (IBAction)scoreButtons:(id)sender {    
    UIButton *button = (UIButton *)sender;
    if (scoreButtonReset == nil) {
        scoreButtonReset = [[PopUpPickerViewController alloc]
                              initWithStyle:UITableViewStylePlain];
        scoreButtonReset.delegate = self;
        scoreButtonReset.pickerChoices = scoreButtonChoices;
        scoreButtonPickerPopover = [[UIPopoverController alloc]
                                     initWithContentViewController:scoreButtonReset];
    }
    scoreButtonReset.pickerChoices = scoreButtonChoices;
    popUp = sender;
    [scoreButtonPickerPopover presentPopoverFromRect:button.bounds inView:button
                             permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
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
    if (popUp == autonPicker) {
        [autonPickerPopover dismissPopoverAnimated:YES];
        [self autonScoreSelected:newPick];
        return;
    }
    if (popUp == teleOpPicker) {
        [teleOpPickerPopover dismissPopoverAnimated:YES];
        [self teleOpScoreSelected:newPick];
        return;
    }
    if (popUp == teleOpPickUpPicker) {
        [teleOpPickUpPickerPopover dismissPopoverAnimated:YES];
        [self teleOpPickUpSelected:newPick];
        return;
    }
    if (popUp == defensePicker) {
        [defensePickerPopover dismissPopoverAnimated:YES];
        [self defenseSelected:newPick];
        return;
    }
    if (popUp == partnerActionsPicker) {
        [partnerActionsPickerPopover dismissPopoverAnimated:YES];
        [self allianceCatchSelected:newPick];
        return;
    }
    if (popUp == _driverRating) {
        [ratingPickerPopover dismissPopoverAnimated:YES];
        [self setDriverRate:newPick];
        return;
    }
    if(popUp == _robotSpeed){
        [ratingPickerPopover dismissPopoverAnimated:YES];
        [self setSpeedRate:newPick];
        return;
    }
    [scoreButtonPickerPopover dismissPopoverAnimated:YES];
    /*
    if (popUp == _autonHighHotButton) [self autonHighHot:newPick];
    else if (popUp == _autonHighColdButton) [self autonHighCold:newPick];
    else if (popUp == _autonLowColdButton) [self autonLowCold:newPick];
    else if (popUp == _autonLowHotButton) [self autonLowHot:newPick];
    else if (popUp == _autonMissButton) [self autonMiss:newPick];
    else if (popUp == _autonBlockButton) [self autonBlock:newPick];
    else if (popUp == _teleOpHighButton) [self teleOpHigh:newPick];
    else if (popUp == _teleOpLowButton) [self teleOpLow:newPick];
    else if (popUp == _teleOpMissButton) [self teleOpMiss:newPick];
    else if (popUp == _teleOpBlockButton) [self teleOpBlock:newPick];
    else if (popUp == _trussThrowButton) [self trussThrow:newPick];
    else if (popUp == _trussThrowMissButton) [self updateButton:_trussThrowMissButton forKey:@"trussThrowMiss" forAction:newPick];
    else if (popUp == _humanTrussButton) [self updateButton:_humanTrussButton forKey:@"trussCatchHuman" forAction:newPick];
    else if (popUp == _humanTrussMissButton) [self updateButton:_humanTrussMissButton forKey:@"trussCatchHumanMiss" forAction:newPick];
    else if (popUp == _trussCatchButton) [self trussCatch:newPick];
    else if (popUp == _humanPickUpsButton) [self humanPickUp:newPick];
    else if (popUp == _humanMissButton) [self updateButton:_humanMissButton forKey:@"humanMiss" forAction:newPick];

    else if (popUp == _floorPickUpsButton) [self floorPickUpSelected:newPick];
    else if (popUp == _floorPickUpMissButton) [self updateButton:_floorPickUpMissButton forKey:@"floorPickUpMiss" forAction:newPick];
    else if (popUp == _passesFloorButton) [self floorPass:newPick];
    else if (popUp == _passesFloorMissButton) [self updateButton:_passesFloorMissButton forKey:@"floorPassMiss" forAction:newPick];
    else if (popUp == _passesAirButton) [self airPass:newPick];
    else if (popUp == _knockoutButton) [self updateButton:_knockoutButton forKey:@"knockout" forAction:newPick];
    else if (popUp == _floorCatchButton) [self floorCatch:newPick];
    else if (popUp == _robotIntakeButton) [self updateButton:_robotIntakeButton forKey:@"RobotIntake" forAction:newPick];
    else if (popUp == _robotMissButton) [self updateButton:_robotMissButton forKey:@"robotIntakeMiss" forAction:newPick];
    else if (popUp == _disruptShotButton) [self updateButton:_disruptShotButton forKey:@"disruptedShot" forAction:newPick];
    else if (popUp == _defensiveDisruptionButton) [self updateButton:_defensiveDisruptionButton forKey:@"defensiveDisruption" forAction:newPick];*/
}

- (void)valueEnteredAtPrompt:(NSString *)valueEntered {
    [self.valuePromptPopover dismissPopoverAnimated:YES];
}

-(void)floorCatch:(NSString *)choice {
/*    // Update the number of missed shots
    int score = [_floorCatchButton.titleLabel.text intValue];
    if ([choice isEqualToString:@"Reset to 0"]) {
        score = 0;
    }
    else if ([choice isEqualToString:@"Decrement"] && score !=0) {
        score--;
    }
    else if ([choice isEqualToString:@"Increment"]) {
        score++;
    }
    else if ([choice isEqualToString:@"Pick a Value"]) {
        [self promptForValue:_floorCatchButton];
        return;
    }
    currentScore.floorCatch = [NSNumber numberWithInt:score];
    [_floorCatchButton setTitle:[NSString stringWithFormat:@"%d", [currentScore.floorCatch intValue]] forState:UIControlStateNormal];
    [self setDataChange];*/
}

-(void)airCatch:(NSString *)choice {
/*    // Update the number of missed shots
    int score = [_airCatchButton.titleLabel.text intValue];
    if ([choice isEqualToString:@"Reset to 0"]) {
        score = 0;
    }
    else if ([choice isEqualToString:@"Decrement"] && score !=0) {
        score--;
    }
    else if ([choice isEqualToString:@"Increment"]) {
        score++;
    }
    else if ([choice isEqualToString:@"Pick a Value"]) {
        [self promptForValue:_airCatchButton];
        return;
    }
    currentScore.airCatch = [NSNumber numberWithInt:score];
    [_airCatchButton setTitle:[NSString stringWithFormat:@"%d", [currentScore.airCatch intValue]] forState:UIControlStateNormal];
    [self setDataChange];*/
}

-(void)airPass:(NSString *)choice {
    // Update the number of missed shots
/*    int score = [_passesAirButton.titleLabel.text intValue];
    if ([choice isEqualToString:@"Reset to 0"]) {
        score = 0;
    }
    else if ([choice isEqualToString:@"Decrement"] && score !=0) {
        score--;
    }
    else if ([choice isEqualToString:@"Increment"]) {
        score++;
    }
    else if ([choice isEqualToString:@"Pick a Value"]) {
        [self promptForValue:_passesAirButton];
        return;
    }
    currentScore.airPasses = [NSNumber numberWithInt:score];
    [_passesAirButton setTitle:[NSString stringWithFormat:@"%d", [currentScore.airPasses intValue]] forState:UIControlStateNormal];
    [self setDataChange];*/
}

-(void)floorPass:(NSString *)choice {
/*    // Update the number of floor passes
    int score = [_passesFloorButton.titleLabel.text intValue];
    if ([choice isEqualToString:@"Reset to 0"]) {
        score = 0;
    }
    else if ([choice isEqualToString:@"Decrement"] && score !=0) {
        score--;
    }
    else if ([choice isEqualToString:@"Increment"]) {
        score++;
    }
    else if ([choice isEqualToString:@"Pick a Value"]) {
        [self promptForValue:_passesFloorButton];
        return;
    }
    currentScore.floorPasses = [NSNumber numberWithInt:score];
    [_passesFloorButton setTitle:[NSString stringWithFormat:@"%d", [currentScore.floorPasses intValue]] forState:UIControlStateNormal];
    // Update total passes
    score = [currentScore.totalPasses intValue];
    score++;
    currentScore.totalPasses = [NSNumber numberWithInt:score];
    // Update total passes
    score = [currentScore.totalPasses intValue];
    score++;
    currentScore.totalPasses = [NSNumber numberWithInt:score];
    [self setDataChange];*/
}


-(void)floorPickUpSelected:(NSString *)choice {
/*    // Update the number of floor pick ups
    int score = [_floorPickUpsButton.titleLabel.text intValue];
    if ([choice isEqualToString:@"Reset to 0"]) {
        score = 0;
    }
    else if ([choice isEqualToString:@"Decrement"] && score !=0) {
        score--;
    }
    else if ([choice isEqualToString:@"Increment"]) {
        score++;
    }
    else if ([choice isEqualToString:@"Pick a Value"]) {
        [self promptForValue:_floorPickUpsButton];
        return;
    }
    currentScore.floorPickUp = [NSNumber numberWithInt:score];
    [_floorPickUpsButton setTitle:[NSString stringWithFormat:@"%d", [currentScore.floorPickUp intValue]] forState:UIControlStateNormal];
    [self setDataChange];*/
}

-(void)floorPickUp {
    // NSLog(@"PickUps");
/*    int score = [_floorPickUpsButton.titleLabel.text intValue];
    score++;
    currentScore.floorPickUp = [NSNumber numberWithInt:score];
    [_floorPickUpsButton setTitle:[NSString stringWithFormat:@"%d", [currentScore.floorPickUp intValue]] forState:UIControlStateNormal];
    [self setDataChange];*/
}

-(void)humanPickUp:(NSString *)choice {
    // Update the number of missed shots
/*    int score = [_humanPickUpsButton.titleLabel.text intValue];
    if ([choice isEqualToString:@"Reset to 0"]) {
        score = 0;
    }
    else if ([choice isEqualToString:@"Decrement"] && score !=0) {
        score--;
    }
    else if ([choice isEqualToString:@"Increment"]) {
        score++;
    }
    else if ([choice isEqualToString:@"Pick a Value"]) {
        [self promptForValue:_humanPickUpsButton];
        return;
    }
    currentScore.humanPickUp = [NSNumber numberWithInt:score];
    [_humanPickUpsButton setTitle:[NSString stringWithFormat:@"%d", [currentScore.humanPickUp intValue]] forState:UIControlStateNormal];
    
    [self setDataChange];*/
}

- (IBAction)scouterName:(id)sender {
//    else if (popUp == _scouterNameType) {
        [scouterNamePickerPopover dismissPopoverAnimated:YES];
  //      _team.scouterName = newPick;
}

-(void)autonBlock:(NSString *)choice {
/*    // Update the number of missed shots
    int score = [_autonBlockButton.titleLabel.text intValue];
    if ([choice isEqualToString:@"Reset to 0"]) {
        score = 0;
    }
    else if ([choice isEqualToString:@"Decrement"] && score !=0) {
        score--;
    }
    else if ([choice isEqualToString:@"Increment"]) {
        score++;
    }
    else if ([choice isEqualToString:@"Pick a Value"]) {
        [self promptForValue:_autonBlockButton];
        return;
    }
    currentScore.autonBlocks = [NSNumber numberWithInt:score];
    [_autonBlockButton setTitle:[NSString stringWithFormat:@"%d", [currentScore.autonBlocks intValue]] forState:UIControlStateNormal];
    
    [self setDataChange];*/
}

-(void)trussCatch:(NSString *)choice {
    // Update the number of missed shots
/*    int score = [_trussCatchButton.titleLabel.text intValue];
    if ([choice isEqualToString:@"Reset to 0"]) {
        score = 0;
    }
    else if ([choice isEqualToString:@"Decrement"] && score !=0) {
        score--;
    }
    else if ([choice isEqualToString:@"Increment"]) {
        score++;
    }
    else if ([choice isEqualToString:@"Pick a Value"]) {
        [self promptForValue:_trussCatchButton];
        return;
    }
    currentScore.trussCatch = [NSNumber numberWithInt:score];
    [_trussCatchButton setTitle:[NSString stringWithFormat:@"%d", [currentScore.trussCatch intValue]] forState:UIControlStateNormal];
    
    [self setDataChange];*/
}

-(void)trussThrow:(NSString *)choice {
    // Update the number of missed shots
/*    int score = [_trussThrowButton.titleLabel.text intValue];
    if ([choice isEqualToString:@"Reset to 0"]) {
        score = 0;
    }
    else if ([choice isEqualToString:@"Decrement"] && score !=0) {
        score--;
    }
    else if ([choice isEqualToString:@"Increment"]) {
        score++;
    }
    else if ([choice isEqualToString:@"Pick a Value"]) {
        [self promptForValue:_trussThrowButton];
        return;
    }
    currentScore.trussThrow = [NSNumber numberWithInt:score];
    [_trussThrowButton setTitle:[NSString stringWithFormat:@"%d", [currentScore.trussThrow intValue]] forState:UIControlStateNormal];
    
    [self setDataChange];*/
}


-(void)teleOpBlock:(NSString *)choice {
    // Update the number of missed shots
/*    int score = [_teleOpBlockButton.titleLabel.text intValue];
    if ([choice isEqualToString:@"Reset to 0"]) {
        score = 0;
    }
    else if ([choice isEqualToString:@"Decrement"] && score !=0) {
        score--;
    }
    else if ([choice isEqualToString:@"Increment"]) {
        score++;
    }
    else if ([choice isEqualToString:@"Pick a Value"]) {
        [self promptForValue:_teleOpBlockButton];
        return;
    }
    currentScore.teleOpBlocks = [NSNumber numberWithInt:score];
    [_teleOpBlockButton setTitle:[NSString stringWithFormat:@"%d", [currentScore.teleOpBlocks intValue]] forState:UIControlStateNormal];
    
    [self setDataChange];*/
}

-(void)teleOpMiss:(NSString *)choice {
    // Update the number of missed shots
/*    int score = [_teleOpMissButton.titleLabel.text intValue];
    if ([choice isEqualToString:@"Reset to 0"]) {
        score = 0;
    }
    else if ([choice isEqualToString:@"Decrement"] && score !=0) {
        score--;
    }
    else if ([choice isEqualToString:@"Increment"]) {
        score++;
    }
    else if ([choice isEqualToString:@"Pick a Value"]) {
        [self promptForValue:_teleOpMissButton];
        return;
    }
    currentScore.teleOpMissed = [NSNumber numberWithInt:score];
    [_teleOpMissButton setTitle:[NSString stringWithFormat:@"%d", [currentScore.teleOpMissed intValue]] forState:UIControlStateNormal];

    // Update the number of shots taken
    int total = [currentScore.teleOpHigh intValue] + [currentScore.teleOpLow intValue] + [currentScore.teleOpMissed intValue];
    currentScore.totalTeleOpShots = [NSNumber numberWithInt:total];
   
    [self setDataChange];*/
}

-(void)teleOpHigh:(NSString *)choice {
    // Update the number of high shots
/*    int score = [_teleOpHighButton.titleLabel.text intValue];
    if ([choice isEqualToString:@"Reset to 0"]) {
        score = 0;
    }
    else if ([choice isEqualToString:@"Decrement"] && score !=0) {
        score--;
    }
    else if ([choice isEqualToString:@"Increment"]) {
        score++;
    }
    else if ([choice isEqualToString:@"Pick a Value"]) {
        [self promptForValue:_teleOpHighButton];
        return;
    }
    currentScore.teleOpHigh = [NSNumber numberWithInt:score];
    [_teleOpHighButton setTitle:[NSString stringWithFormat:@"%d", [currentScore.teleOpHigh intValue]] forState:UIControlStateNormal];

    // Update the number of shots taken
    int total = [currentScore.teleOpHigh intValue] + [currentScore.teleOpLow intValue] + [currentScore.teleOpMissed intValue];
    currentScore.totalTeleOpShots = [NSNumber numberWithInt:total];
    
    // Update the number of shots made
    total = [currentScore.teleOpHigh intValue] + [currentScore.teleOpLow intValue];
    currentScore.teleOpShotsMade = [NSNumber numberWithInt:total];
    [self setDataChange];*/
}

-(void)teleOpLow:(NSString *)choice {
    // Update the number of high shots
/*    int score = [_teleOpLowButton.titleLabel.text intValue];
    if ([choice isEqualToString:@"Reset to 0"]) {
        score = 0;
    }
    else if ([choice isEqualToString:@"Decrement"] && score !=0) {
        score--;
    }
    else if ([choice isEqualToString:@"Increment"]) {
        score++;
    }
    else if ([choice isEqualToString:@"Pick a Value"]) {
        [self promptForValue:_teleOpLowButton];
        return;
    }
    currentScore.teleOpLow = [NSNumber numberWithInt:score];
    [_teleOpLowButton setTitle:[NSString stringWithFormat:@"%d", [currentScore.teleOpLow intValue]] forState:UIControlStateNormal];

    // Update the number of shots taken
    int total = [currentScore.teleOpHigh intValue] + [currentScore.teleOpLow intValue] + [currentScore.teleOpMissed intValue];
    currentScore.totalTeleOpShots = [NSNumber numberWithInt:total];
    
    // Update the number of shots made
    total = [currentScore.teleOpHigh intValue] + [currentScore.teleOpLow intValue];
    currentScore.teleOpShotsMade = [NSNumber numberWithInt:total];
    [self setDataChange];*/
}

-(void)autonMiss:(NSString *)choice {
    // Update the number of missed shots
/*    int score = [_autonMissButton.titleLabel.text intValue];
    if ([choice isEqualToString:@"Reset to 0"]) {
        score = 0;
    }
    else if ([choice isEqualToString:@"Decrement"] && score !=0) {
        score--;
    }
    else if ([choice isEqualToString:@"Increment"]) {
        score++;
    }
    else if ([choice isEqualToString:@"Pick a Value"]) {
        [self promptForValue:_autonMissButton];
        return;
    }
    currentScore.autonMissed = [NSNumber numberWithInt:score];
    [_autonMissButton setTitle:[NSString stringWithFormat:@"%d", [currentScore.autonMissed intValue]] forState:UIControlStateNormal];

    // Update the number of shots taken
    int total = [currentScore.autonHighCold intValue] + [currentScore.autonHighHot intValue] +[currentScore.autonLowHot intValue] + [currentScore.autonLowCold intValue] + [currentScore.autonMissed intValue];
    currentScore.totalAutonShots = [NSNumber numberWithInt:total];

    [self setDataChange];*/
}

-(void)promptForValue:(UIButton *)button {
    if (_valuePrompt == nil) {
        self.valuePrompt = [[ValuePromptViewController alloc] initWithNibName:nil bundle:nil];
        _valuePrompt.delegate = self;
        _valuePrompt.titleText = @"Enter a new value";
        _valuePrompt.msgText = nil;
        self.valuePromptPopover = [[UIPopoverController alloc]
                                   initWithContentViewController:_valuePrompt];
    }
    [self.valuePromptPopover presentPopoverFromRect:button.bounds inView:button permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
}

-(void)autonHighHot:(NSString *)choice {
/*    int score = [_autonHighHotButton.titleLabel.text intValue];
    // Update the number of high shots
    if ([choice isEqualToString:@"Reset to 0"]) {
        score = 0;
    }
    else if ([choice isEqualToString:@"Decrement"] && score !=0) {
        score--;
    }
    else if ([choice isEqualToString:@"Increment"]) {
        score++;
    }
    else if ([choice isEqualToString:@"Pick a Value"]) {
        [self promptForValue:_autonHighHotButton];
        return;
    }
    currentScore.autonHighHot = [NSNumber numberWithInt:score];
    [_autonHighHotButton setTitle:[NSString stringWithFormat:@"%d", [currentScore.autonHighHot intValue]] forState:UIControlStateNormal];
    // Update the number of shots taken
    int total = [currentScore.autonHighHot intValue] + [currentScore.autonHighCold intValue] + [currentScore.autonLowCold intValue] +[currentScore.autonLowHot intValue] + [currentScore.autonMissed intValue];
    currentScore.totalAutonShots = [NSNumber numberWithInt:total];
    
    // Update the number of shots made
    total = [currentScore.autonHighHot intValue] + [currentScore.autonHighCold intValue] + [currentScore.autonLowCold intValue] +[currentScore.autonLowHot intValue];
    currentScore.autonShotsMade = [NSNumber numberWithInt:total];
    [self setDataChange];*/
}

-(void)autonHighCold:(NSString *)choice {
/*    int score = [_autonHighColdButton.titleLabel.text intValue];
    // Update the number of high shots
    if ([choice isEqualToString:@"Reset to 0"]) {
        score = 0;
    }
    else if ([choice isEqualToString:@"Decrement"] && score !=0) {
        score--;
    }
    else if ([choice isEqualToString:@"Increment"]) {
        score++;
    }
    else if ([choice isEqualToString:@"Pick a Value"]) {
        [self promptForValue:_autonHighColdButton];
        return;
    }
    currentScore.autonHighCold = [NSNumber numberWithInt:score];
    [_autonHighColdButton setTitle:[NSString stringWithFormat:@"%d", [currentScore.autonHighCold intValue]] forState:UIControlStateNormal];
    // Update the number of shots taken
    int total = [currentScore.autonHighHot intValue] + [currentScore.autonHighCold intValue] + [currentScore.autonLowCold intValue] +[currentScore.autonLowHot intValue] + [currentScore.autonMissed intValue];
    currentScore.totalAutonShots = [NSNumber numberWithInt:total];
    
    // Update the number of shots made
    total = [currentScore.autonHighHot intValue] + [currentScore.autonHighCold intValue] + [currentScore.autonLowCold intValue] +[currentScore.autonLowHot intValue];
    currentScore.autonShotsMade = [NSNumber numberWithInt:total];
    [self setDataChange];*/
}

-(void)autonLowCold:(NSString *)choice {
/*    int score = [_autonLowColdButton.titleLabel.text intValue];
    // Update the number of Low shots
    if ([choice isEqualToString:@"Reset to 0"]) {
        score = 0;
    }
    else if ([choice isEqualToString:@"Decrement"] && score !=0) {
        score--;
    }
    else if ([choice isEqualToString:@"Increment"]) {
        score++;
    }
    else if ([choice isEqualToString:@"Pick a Value"]) {
        [self promptForValue:_autonLowColdButton];
        return;
    }
    currentScore.autonLowCold = [NSNumber numberWithInt:score];
    [_autonLowColdButton setTitle:[NSString stringWithFormat:@"%d", [currentScore.autonLowCold intValue]] forState:UIControlStateNormal];

    int total = [currentScore.autonHighCold intValue] + [currentScore.autonHighHot intValue] + [currentScore.autonLowCold intValue] + [currentScore.autonLowHot intValue] + [currentScore.autonMissed intValue];
    currentScore.totalAutonShots = [NSNumber numberWithInt:total];
    
    // Update the number of shots made
    total = [currentScore.autonHighHot intValue] + [currentScore.autonHighCold intValue] + [currentScore.autonLowCold intValue] +[currentScore.autonLowHot intValue];
    currentScore.autonShotsMade = [NSNumber numberWithInt:total];
    [self setDataChange];*/
}

-(void)autonLowHot:(NSString *)choice {
/*    int score = [_autonLowHotButton.titleLabel.text intValue];
    // Update the number of Low shots
    if ([choice isEqualToString:@"Reset to 0"]) {
        score = 0;
    }
    else if ([choice isEqualToString:@"Decrement"] && score !=0) {
        score--;
    }
    else if ([choice isEqualToString:@"Increment"]) {
        score++;
    }
    else if ([choice isEqualToString:@"Pick a Value"]) {
        [self promptForValue:_autonLowHotButton];
        return;
    }
    currentScore.autonLowHot = [NSNumber numberWithInt:score];
    [_autonLowHotButton setTitle:[NSString stringWithFormat:@"%d", [currentScore.autonLowHot intValue]] forState:UIControlStateNormal];
    
    int total = [currentScore.autonHighCold intValue] + [currentScore.autonHighHot intValue] + [currentScore.autonLowCold intValue] + [currentScore.autonLowHot intValue] + [currentScore.autonMissed intValue];
    currentScore.totalAutonShots = [NSNumber numberWithInt:total];
    
    // Update the number of shots made
    total = [currentScore.autonHighHot intValue] + [currentScore.autonHighCold intValue] + [currentScore.autonLowCold intValue] +[currentScore.autonLowHot intValue];
    currentScore.autonShotsMade = [NSNumber numberWithInt:total];
    [self setDataChange];*/
}

-(void)autonBlockedShots: (NSString *)choice {
    // NSLog(@"Blocked Shots");
    
/*    int score = [_autonBlockButton.titleLabel.text intValue];
    // Update the number of Low shots
    if ([choice isEqualToString:@"Reset to 0"]) {
        score = 0;
    }
    else if ([choice isEqualToString:@"Decrement"] && score !=0) {
        score--;
    }
    else if ([choice isEqualToString:@"Increment"]) {
        score++;
    }
    else if ([choice isEqualToString:@"Pick a Value"]) {
        [self promptForValue:_autonBlockButton];
        return;
    }
    currentScore.autonBlocks = [NSNumber numberWithInt:score];
    [_autonBlockButton setTitle:[NSString stringWithFormat:@"%d", [currentScore.autonBlocks intValue]] forState:UIControlStateNormal];
    [self setDataChange];*/
}

-(void)updateButton:(UIButton *)button forKey:(NSString *)key forAction:(NSString *)buttonAction {
    NSLog(@"updateButton");
    int score = [button.titleLabel.text intValue];
    if ([buttonAction isEqualToString:@"Reset to 0"]) {
        score = 0;
    }
    else if ([buttonAction isEqualToString:@"Decrement"] && score !=0) {
        score--;
    }
    else if ([buttonAction isEqualToString:@"Increment"]) {
        score++;
    }
    else if ([buttonAction isEqualToString:@"Pick a Value"]) {
       // [self promptForValue:teleOpBlockButton];
        return;
    }
    [currentScore setValue:[NSNumber numberWithInt:score] forKey:key];
    [button setTitle:[NSString stringWithFormat:@"%d", score] forState:UIControlStateNormal];
    [self setDataChange];
}

-(void)teleOpBlockedShots: (NSString *)choice {
/*    // NSLog(@"Blocked Shots");
    int score = [_teleOpBlockButton.titleLabel.text intValue];
    if ([choice isEqualToString:@"Reset to 0"]) {
        score = 0;
    }
    else if ([choice isEqualToString:@"Decrement"] && score !=0) {
        score--;
    }
    else if ([choice isEqualToString:@"Increment"]) {
        score++;
    }
    else if ([choice isEqualToString:@"Pick a Value"]) {
        [self promptForValue:_teleOpBlockButton];
        return;
    }
    currentScore.teleOpBlocks= [NSNumber numberWithInt:score];
    [_teleOpBlockButton setTitle:[NSString stringWithFormat:@"%d", [currentScore.teleOpBlocks intValue]] forState:UIControlStateNormal];
    [self setDataChange];*/
}

-(IBAction)humanPickUpsMade:(id) sender {
 /*   UIButton * PressedButton = (UIButton*)sender;
   // NSLog(@"PickUps");
    if (drawMode == DrawDefense || drawMode == DrawTeleop) {
        [self setDataChange];
        int score = [_humanPickUpsButton.titleLabel.text intValue];
        score++;
        currentScore.humanPickUp = [NSNumber numberWithInt:score];
        [_humanPickUpsButton setTitle:[NSString stringWithFormat:@"%d", [currentScore.humanPickUp intValue]] forState:UIControlStateNormal];
        [self setDataChange];
        if (PressedButton == _human1Button) {
            score = [_human1Button.titleLabel.text intValue];
            CGPoint textPoint;
            CGPoint basePoint;
            CGFloat interval = 20;
            basePoint.x = 184;
            basePoint.y = 45;
            textPoint.x = basePoint.x - (score%4)*interval;
            textPoint.y = basePoint.y + (score/4)*interval;
            [self drawSymbol:humanIntakeImage location:textPoint];
            score++;
            currentScore.humanPickUp1 = [NSNumber numberWithInt:score];
            [_human1Button setTitle:[NSString stringWithFormat:@"%d", [currentScore.humanPickUp1 intValue]] forState:UIControlStateNormal];
        } else if (PressedButton == _human2Button) {
            score = [_human2Button.titleLabel.text intValue];
            CGPoint textPoint;
            CGPoint basePoint;
            CGFloat interval = 20;
            basePoint.x = 654;
            basePoint.y = 45;
            textPoint.x = basePoint.x + (score%4)*interval;
            textPoint.y = basePoint.y + (score/4)*interval;
            [self drawSymbol:humanIntakeImage location:textPoint];
            score++;
            currentScore.humanPickUp2 = [NSNumber numberWithInt:score];
            [_human2Button setTitle:[NSString stringWithFormat:@"%d", [currentScore.humanPickUp2 intValue]] forState:UIControlStateNormal];
        } else if (PressedButton == _human3Button) {
            score = [_human3Button.titleLabel.text intValue];
            CGPoint textPoint;
            CGPoint basePoint;
            CGFloat interval = 20;
            basePoint.x = 664;
            basePoint.y = 365;
            textPoint.x = basePoint.x + (score%4)*interval;
            textPoint.y = basePoint.y - (score/4)*interval;
            [self drawSymbol:humanIntakeImage location:textPoint];
            score++;
            currentScore.humanPickUp3 = [NSNumber numberWithInt:score];
            [_human3Button setTitle:[NSString stringWithFormat:@"%d", [currentScore.humanPickUp3 intValue]] forState:UIControlStateNormal];
        } else if (PressedButton == _human4Button) {
            score = [_human4Button.titleLabel.text intValue];
            CGPoint textPoint;
            CGPoint basePoint;
            CGFloat interval = 20;
            basePoint.x = 174;
            basePoint.y = 365;
            textPoint.x = basePoint.x - (score%4)*interval;
            textPoint.y = basePoint.y - (score/4)*interval;
            [self drawSymbol:humanIntakeImage location:textPoint];
            score++;
            currentScore.humanPickUp4 = [NSNumber numberWithInt:score];
            [_human4Button setTitle:[NSString stringWithFormat:@"%d", [currentScore.humanPickUp4 intValue]] forState:UIControlStateNormal];
        }
    }*/
}

- (IBAction)humanPickUpsMiss:(id)sender {
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self checkDataStatus];
    
    if ([segue.identifier isEqualToString:@"TeamInfo"]) {
        TeamDetailViewController *detailViewController = [segue destinationViewController];
        [segue.destinationViewController setDataManager:_dataManager];
        detailViewController.team = currentTeam;
    }

    else if ([segue.identifier isEqualToString:@"Sync"]) {
        [segue.destinationViewController setDataManager:_dataManager];
        [segue.destinationViewController setSyncOption:SyncAllSavedSince];
        [segue.destinationViewController setSyncType:SyncMatchResults];
    }
    else {
        [segue.destinationViewController setDataManager:_dataManager];    
    }
    
}

-(void)setTeamList {
    NSSortDescriptor *allianceSort = [NSSortDescriptor sortDescriptorWithKey:@"allianceStation" ascending:YES];
    scoreList = [[currentMatch.score allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:allianceSort]];
    [teamList removeAllObjects];
    [allianceList removeAllObjects];
    for (TeamScore *score in scoreList) {
        [teamList addObject:[NSString stringWithFormat:@"%d", [score.teamNumber intValue]]];
        NSString *allianceString = [EnumerationDictionary getKeyFromValue:score.allianceStation forDictionary:allianceDictionary];
        [allianceList addObject:allianceString];
    }
    teamPicker = Nil;
    teamPickerPopover = Nil;
    alliancePicker = Nil;
    alliancePickerPopover = Nil;
}

-(MatchData *)getCurrentMatch {
    if (numberMatchTypes == 0) {
        [_matchType setTitle:@"No Matches" forState:UIControlStateNormal];
        [_matchType setUserInteractionEnabled:FALSE];
        [_alliance setTitle:@"" forState:UIControlStateNormal];
        [_alliance setUserInteractionEnabled:FALSE];
        [self setDisplayInactive];
        return nil;
    }
    else {
        [self setDisplayActive];
        NSIndexPath *matchIndex = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
        return [fetchedResultsController objectAtIndexPath:matchIndex];
    }
}

-(void)setDisplayInactive {
    [_drawModeButton setUserInteractionEnabled:NO];
}

-(void)setDisplayActive {
    [_drawModeButton setUserInteractionEnabled:TRUE];
}

-(void)disableButtons{
    // NSLog(@"disabling buttons");
    [_autonMobilityButton setUserInteractionEnabled:NO];
    [_noShowButton setUserInteractionEnabled:NO];
    [_doaButton setUserInteractionEnabled:NO];
  //  [_knockoutButton setUserInteractionEnabled:NO];
    [_robotSpeed setUserInteractionEnabled:NO];
    [_driverRating setUserInteractionEnabled:NO];
    [_intakeRatingButton setUserInteractionEnabled:NO];
    [_notes setUserInteractionEnabled:NO];
    [_foulTextField setUserInteractionEnabled:NO];
    [_eraserButton setUserInteractionEnabled:NO];
}

-(void)enableButtons{
    NSLog(@"enabling Buttons");
    [_autonMobilityButton setUserInteractionEnabled:YES];
    [_noShowButton setUserInteractionEnabled:YES];
    [_doaButton setUserInteractionEnabled:YES];
  //  [_knockoutButton setUserInteractionEnabled:YES];
    [_robotSpeed setUserInteractionEnabled:YES];
    [_driverRating setUserInteractionEnabled:YES];
    [_intakeRatingButton setUserInteractionEnabled:YES];
    [_notes setUserInteractionEnabled:YES];
    [_foulTextField setUserInteractionEnabled:YES];
    [_eraserButton setUserInteractionEnabled:YES];
}

-(void)showTeam:(NSUInteger)currentScoreIndex {
    if (!currentMatch) return;
    [_matchType setTitle:[EnumerationDictionary getKeyFromValue:currentMatch.matchType forDictionary:matchDictionary] forState:UIControlStateNormal];
    _matchNumber.text = [NSString stringWithFormat:@"%d", [currentMatch.number intValue]];
 
    currentScore = [scoreList objectAtIndex:teamIndex];
    currentTeam = [TeamAccessors getTeam:currentScore.teamNumber fromDataManager:_dataManager];
   [_teamNumber setTitle:[NSString stringWithFormat:@"%d", [currentScore.teamNumber intValue]] forState:UIControlStateNormal];
    _teamName.text = currentTeam.name;

    _notes.text = currentScore.notes;
    NSString *allianceString = [MatchAccessors getAllianceString:currentScore.allianceStation fromDictionary:allianceDictionary];
    [_alliance setTitle:allianceString forState:UIControlStateNormal];
    
//    [_teleOpHighButton setTitle:[NSString stringWithFormat:@"%d", [currentScore.teleOpHigh intValue]] forState:UIControlStateNormal];
    
 //    [_knockoutButton setTitle:[NSString stringWithFormat:@"%d", [currentScore.knockout intValue]] forState:UIControlStateNormal];
   _foulTextField.text = [NSString stringWithFormat:@"%d", [currentScore.fouls intValue]];

    [_driverRating setTitle:[NSString stringWithFormat:@"%d", [currentScore.driverRating intValue]] forState:UIControlStateNormal];
    [_robotSpeed setTitle:[NSString stringWithFormat:@"%d", [currentScore.robotSpeed intValue]] forState:UIControlStateNormal];
    [self setRadioButtonState:_noShowButton forState:[currentScore.noShow intValue]];
    [self setRadioButtonState:_doaButton forState:[currentScore.deadOnArrival intValue]];
    [self setRadioButtonState:_autonMobilityButton forState:[currentScore.autonRobotSet intValue]];

    if ([currentScore.results boolValue]) _scouterTextField.text = currentScore.scouter;
    else _scouterTextField.text = scouter;
    
    [self loadDrawing:allianceString];
    eraseMode = FALSE;
    [_eraserButton setBackgroundImage:nil forState:UIControlStateNormal];
    
    NSLog(@"Saved by = %@", currentScore.savedBy);
}

-(void)loadDrawing:(NSString *)allianceString {
    // Set the correct background image for the alliance
    if ([[allianceString substringToIndex:1] isEqualToString:@"R"]) {
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
/*
    // Check the database to see if this team and match have an auton drawing already
    if (currentScore.autonDrawing.trace) {
        [_autonTrace setImage:[UIImage imageWithData:currentScore.autonDrawing.trace]];
    }
    else {
        [_autonTrace setImage:[[UIImage alloc] init]];
    }
    NSLog(@"Add stuff to import teleop drawing");*/
    [self drawModeSettings:drawMode];

}

- (IBAction)buttonIntakeAction:(id)sender {
    UIButton * PressedButton = (UIButton*)sender;
    NSLog(@"Tote Intake");
    [self setDataChange];
    if (PressedButton == _toteHPTopButton) {
        [self updateButton:_toteHPTopButton forKey:@"toteHPTop" forAction:@"Increment"];
        [self updateButton:_toteHPButton forKey:@"toteIntakeHP" forAction:@"Increment"];
     } else if (PressedButton == _toteHPBottomButton) {
         [self updateButton:_toteHPBottomButton forKey:@"toteHPBottom" forAction:@"Increment"];
         [self updateButton:_toteHPButton forKey:@"toteIntakeHP" forAction:@"Increment"];
     } else if (PressedButton == _toteStepTopButton) {
         [self updateButton:_toteStepTopButton forKey:@"toteStepTop" forAction:@"Increment"];
         [self updateButton:_toteStepButton forKey:@"toteIntakeStep" forAction:@"Increment"];
     } else if (PressedButton == _toteStepBottomButton) {
         [self updateButton:_toteStepBottomButton forKey:@"toteStepBottom" forAction:@"Increment"];
         [self updateButton:_toteStepButton forKey:@"toteIntakeStep" forAction:@"Increment"];
     } else if (PressedButton == _toteFloorTopButton) {
         [self updateButton:_toteFloorTopButton forKey:@"toteFloorTop" forAction:@"Increment"];
         [self updateButton:_toteFloorButton forKey:@"toteIntakeFloor" forAction:@"Increment"];
     } else if (PressedButton == _toteFloorBottomButton) {
         [self updateButton:_toteFloorBottomButton forKey:@"toteFloorBottom" forAction:@"Increment"];
         [self updateButton:_toteFloorButton forKey:@"toteIntakeFloor" forAction:@"Increment"];
     }


    /*     CGPoint textPoint;
     CGPoint basePoint;
     CGFloat interval = 20;
     basePoint.x = 210;
     basePoint.y = 45;
     textPoint.x = basePoint.x + (score%4)*interval;
     textPoint.y = basePoint.y + (score/4)*interval;
     [self drawSymbol:humanMissImage location:textPoint];*/

}


-(void)totePickUp:(UITapGestureRecognizer *)gestureRecognizer {
  //  if ([gestureRecognizer view] == _fieldImage) NSLog(@"Yeah!");
    fieldDrawingChange = YES;
    if(drawMode == DrawAuton){
        // NSLog(@"floorPickUp");
        NSString *marker = @"T";
        currentPoint = [gestureRecognizer locationInView:_autonTrace];
        [self drawText:marker location:currentPoint inView:_autonTrace];
        [self updateButton:_autonToteIntakeButton forKey:@"autonTotePickUp" forAction:@"Increment"];
    }
    else {
        NSString *marker = @"T";
        currentPoint = [gestureRecognizer locationInView:_teleOpTrace];
        [self drawText:marker location:currentPoint inView:_teleOpTrace];
    }
}

-(void)scoreStack:(UITapGestureRecognizer *)gestureRecognizer {
    fieldDrawingChange = YES;
    if(drawMode == DrawAuton){
        // NSLog(@"floorPickUp");
        currentPoint = [gestureRecognizer locationInView:_autonTrace];
        if (setStartPoint) {
            setStartPoint = FALSE;
            [self drawSymbol:autonSPImage location:currentPoint inView:_autonTrace];
        }
        else {
            if (autonPicker == nil) {
                autonPicker = [[PopUpPickerViewController alloc] initWithStyle:UITableViewStylePlain];
                autonPicker.delegate = self;
                autonPicker.pickerChoices = autonScoreList;
                autonPickerPopover = [[UIPopoverController alloc] initWithContentViewController:autonPicker];
            }
            popUp = autonPicker;
            // We are creating a brand new stack, so we do not already have a button for it
            currentStack = nil;
            CGPoint popPoint = [self scorePopOverLocation:currentPoint];
            [autonPickerPopover presentPopoverFromRect:CGRectMake(popPoint.x, popPoint.y, 1.0, 1.0) inView:_autonTrace permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
//            NSString *marker = @"S";
//            [self drawText:marker location:currentPoint];
        }
    }
    else {
/*        [self.teleOpLayer addSubview:toteStackSlider];
        NSString *marker = @"Not yet";
        currentPoint = [gestureRecognizer locationInView:_teleOpTrace];
        [self drawText:marker location:currentPoint inView:_teleOpTrace];*/
    }
}

-(void)canPickUp:(UITapGestureRecognizer *)gestureRecognizer {
    fieldDrawingChange = YES;
    if(drawMode == DrawAuton){
        // NSLog(@"canPickUp");
        NSString *marker = @"O";
        currentPoint = [gestureRecognizer locationInView:_autonTrace];
        [self drawText:marker location:currentPoint inView:_autonTrace];
    }
    else {
        NSString *marker = @"O";
        currentPoint = [gestureRecognizer locationInView:_teleOpTrace];
        [self drawText:marker location:currentPoint inView:_teleOpTrace];
    }
}

- (IBAction)eraserPressed:(id)sender {
    if (eraseMode) {
        [_eraserButton setBackgroundImage:nil forState:UIControlStateNormal];
        eraseMode = FALSE;
    }
    else {
        [_eraserButton setBackgroundImage:[UIImage imageNamed:@"Small Red Button.jpg"] forState:UIControlStateNormal];
        eraseMode = TRUE;
    }
}

-(CGPoint)scorePopOverLocation:(CGPoint)location; {
    CGPoint popPoint;
    popPoint = location;
    if (location.x <= 98) {
        // NSLog(@"On the left edge");
        popPoint.x = -22;
    }
    else if (location.x < 740) {
        // NSLog(@"In the middle");
        popPoint.x = location.x-55;
    } else {
        // NSLog(@"On the right edge");
        popPoint.x = 705;
    }
    
    popPoint.y = location.y+10;
    
    return popPoint;
}

-(CGPoint)defensePopOverLocation:(CGPoint)location {
    CGPoint popPoint;
    popPoint = location;
    if (location.x <= 98) {
        // NSLog(@"On the left edge");
        popPoint.x = -22;
    }
    else if (location.x < 750) {
        // NSLog(@"In the middle");
        popPoint.x = location.x-55;
    } else {
        // NSLog(@"On the right edge");
        popPoint.x = 714;
    }
    
    popPoint.y = location.y+20;
    
    return popPoint;
}

-(IBAction)drawModeChange: (id)sender {
    switch (drawMode) {
        case DrawOff:
            if (!currentScore.teamNumber || [currentScore.teamNumber intValue] == 0) {
                UIAlertView *prompt  = [[UIAlertView alloc] initWithTitle:@"Team Check Alert"
                                                                  message:@"No team in this slot"
                                                                 delegate:nil
                                                        cancelButtonTitle:@"Ok"
                                                        otherButtonTitles:nil];
                [prompt setAlertViewStyle:UIAlertViewStyleDefault];
                [prompt show];
            }
            else {
                drawMode = DrawAuton;
                [self enlargeDrawing];
            }
            break;
        case DrawAuton:
            drawMode = DrawTeleop;
            break;
        case DrawTeleop:
            drawMode = DrawAuton;
            break;
        case DrawDefense:
            drawMode = DrawTeleop;
            break;
        case DrawLock:
            popUp = sender;
            [self confirmationActionSheet:@"Confirm Match Unlock" withButton:@"Unlock"];
            break;
        default:
            NSLog(@"Bad things have happened in drawModeChange");
    }
    [self drawModeSettings:drawMode];
}

-(void) drawModeSettings:(DrawingMode) mode {
    switch (mode) {
        case DrawOff:
            [_drawModeButton setBackgroundImage:[UIImage imageNamed:@"Small White Button.jpg"] forState:UIControlStateNormal];
            [_drawModeButton setTitle:@"Off" forState:UIControlStateNormal];
            [_drawModeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self disableButtons];
            break;
        case DrawAuton:
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
            break;
        case DrawLock:
            [_drawModeButton setBackgroundImage:[UIImage imageNamed:@"Small Red Button.jpg"] forState:UIControlStateNormal];
            [_drawModeButton setTitle:@"Locked" forState:UIControlStateNormal];
            [_drawModeButton setTitleColor:[UIColor colorWithRed:255.0 green:190.0 blue:0 alpha:1.0] forState:UIControlStateNormal];
            [self disableButtons];
            break;
        default:
            break;
    }
}

-(void)enlargeDrawing {
    float x, y;
    x = _imageContainer.frame.origin.x;
    y = _imageContainer.frame.origin.y;
    float maxHeight = 665;
    float ratio = _imageContainer.frame.size.height/_imageContainer.frame.size.width;
    NSLog(@"frame = %f, %f, %f, %f", x, y, _imageContainer.frame.size.height, _imageContainer.frame.size.width);
    NSLog(@"frame = %f, %f, %f, %f", _backgroundImage.frame.origin.x, _backgroundImage.frame.origin.y, _backgroundImage.frame.size.height, _backgroundImage.frame.size.width);
    NSLog(@"frame = %f, %f, %f, %f", _autonTrace.frame.origin.x, _autonTrace.frame.origin.y, _autonTrace.frame.size.height, _autonTrace.frame.size.width);
    NSLog(@"frame = %f, %f, %f, %f",  _teleOpTrace.frame.origin.x,  _teleOpTrace.frame.origin.y,  _teleOpTrace.frame.size.height,  _teleOpTrace.frame.size.width);
    _imageContainer.frame = CGRectMake(0, 0, ratio*maxHeight, maxHeight);
    _autonTrace.frame = CGRectMake(0, 0, maxHeight, maxHeight);
    _teleOpTrace.frame = CGRectMake(0, 0, maxHeight, maxHeight);
    _backgroundImage.frame = CGRectMake(0, 0, maxHeight, maxHeight);
 //   [_backgroundImage setHidden:TRUE];

}

-(void)activateAuton {
    _autonTrace.userInteractionEnabled = TRUE;
    [_autonTrace setHidden:FALSE];
    [_autonTrace addGestureRecognizer:tripleTapGesture];
    [_autonTrace addGestureRecognizer:doubleTapGestureRecognizer];
    [_autonTrace addGestureRecognizer:drawGesture];
    [_autonTrace addGestureRecognizer:tapPressGesture];
}

-(void)deactivateAuton {
    _autonTrace.userInteractionEnabled = FALSE;
    [_autonTrace setHidden:TRUE];
    [_autonTrace removeGestureRecognizer:tripleTapGesture];
    [_autonTrace removeGestureRecognizer:doubleTapGestureRecognizer];
    [_autonTrace removeGestureRecognizer:drawGesture];
    [_autonTrace removeGestureRecognizer:tapPressGesture];
}

-(void)activateTeleOp {
    _teleOpTrace.userInteractionEnabled = TRUE;
    [_teleOpTrace setHidden:FALSE];
    [_teleOpTrace addGestureRecognizer:tripleTapGesture];
    [_teleOpTrace addGestureRecognizer:doubleTapGestureRecognizer];
    [_teleOpTrace addGestureRecognizer:drawGesture];
    [_teleOpTrace addGestureRecognizer:tapPressGesture];
}

-(void)deactivateTeleOp {
    _teleOpTrace.userInteractionEnabled = FALSE;
    [_teleOpTrace setHidden:TRUE];
    [_teleOpTrace removeGestureRecognizer:tripleTapGesture];
    [_teleOpTrace removeGestureRecognizer:doubleTapGestureRecognizer];
    [_teleOpTrace removeGestureRecognizer:drawGesture];
    [_teleOpTrace removeGestureRecognizer:tapPressGesture];
}

- (void)autonScoreSelected:(NSString *)newScore {
    [autonPickerPopover dismissPopoverAnimated:YES];
    if (currentStack) {
        NSLog(@"Old stack");
        if ([newScore isEqualToString:@"0"]) {
            [currentStack removeTarget:self action:@selector(autonToteAction:) forControlEvents:UIControlEventTouchUpInside];
            [self removeStackButton:currentStack inView:_autonTrace fromList:autonToteStacks];
        }
        else {
            NSLog(@"Record stuff somehow");
            [currentStack setTitle:newScore forState:UIControlStateNormal];
        }
    }
    else {
        if ([newScore isEqualToString:@"0"]) {
            return;
        }
        NSLog(@"Record stuff somehow");
        UIButton *newstack = [self createAutonToteStack:currentPoint withTitle:newScore];
        if (!autonToteStacks) {
            autonToteStacks = [[NSMutableArray alloc] init];
        }
        [autonToteStacks addObject:newstack];
    }

}

-(UIButton *)createAutonToteStack:(CGPoint)location withTitle:(NSString *)value {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(location.x,location.y,30,30)];
    [self setToteStackButtonDefaults:button];
    [button setTitle:value forState:UIControlStateNormal];
    [button addTarget:self action:@selector(autonToteAction:) forControlEvents:UIControlEventTouchUpInside];
    [_autonTrace addSubview:button];
    return button;
}

-(void)removeStackButton:(UIButton *)button inView:(UIView *)view fromList:(NSMutableArray *)stackList {
    [stackList removeObject:button];
    [button removeFromSuperview];
}

- (IBAction)autonToteAction:(id)sender {
    currentStack = (UIButton*)sender;
    if (autonPicker == nil) {
        autonPicker = [[PopUpPickerViewController alloc] initWithStyle:UITableViewStylePlain];
        autonPicker.delegate = self;
        autonPicker.pickerChoices = autonScoreList;
        autonPickerPopover = [[UIPopoverController alloc] initWithContentViewController:autonPicker];
    }
    popUp = autonPicker;
    CGPoint popPoint = [self scorePopOverLocation:currentPoint];
    [autonPickerPopover presentPopoverFromRect:CGRectMake(popPoint.x, popPoint.y, 1.0, 1.0) inView:_autonTrace permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
}

- (IBAction)autonButtonScore:(id)sender {
}

- (void)teleOpScoreSelected:(NSString *)newScore {
    [teleOpPickerPopover dismissPopoverAnimated:YES];
    NSString *marker;
    CGPoint textPoint;
    textPoint.x = currentPoint.x;
    textPoint.y = currentPoint.y + popCounter*16;
    // NSLog(@"Text Point = %f %f", textPoint.x, textPoint.y);
    popCounter++;
    
    NSLog(@"selection = %@", newScore);
 /*
    if ([newScore isEqualToString:@"Pass"]) {
        [self updateButton:_passesFloorButton forKey:@"floorPasses" forAction:@"Increment"];
        [self drawSymbol:passImage location:textPoint];
    }
    else if ([newScore isEqualToString:@"Truss Miss"]) {
        [self updateButton:_trussThrowMissButton forKey:@"trussThrowMiss" forAction:@"Increment"];
        [self drawSymbol:trussThrowMissImage location:textPoint];
    }*/
}

-(void)teleOpPickUpSelected:(NSString *)newPickUp {
    [teleOpPickUpPickerPopover dismissPopoverAnimated:YES];
    NSString *marker;
    CGPoint textPoint;
    textPoint.x = currentPoint.x;
    textPoint.y = currentPoint.y + popCounter*16;
    // NSLog(@"Text Point = %f %f", textPoint.x, textPoint.y);
    red = 0.0/255.0;
    green = 0.0/255.0;
    blue = 0.0/255.0;
    NSLog(@"selection = %@", newPickUp);
/*
    if ([newPickUp isEqualToString:@"Floor Pick Up"]) {
        [self drawSymbol:floorPickUpImage location:textPoint];
        [self floorPickUpSelected:@"Increment"];
    }
    else if ([newPickUp isEqualToString:@"Truss Catch Miss"]) {
        [self updateButton:_trussCatchMissButton forKey:@"trussCatchMiss" forAction:@"Increment"];
        [self drawSymbol:trussCatchMissImage location:textPoint];
    }
  
    if (drawMode == DrawDefense) {
        red = 255.0/255.0;
        green = 0.0/255.0;
        blue = 0.0/255.0;
     }*/
}

-(void)allianceCatchSelected:(NSString *)newPickUp {
 /*   [partnerActionsPickerPopover dismissPopoverAnimated:YES];
    NSString *marker;
    CGPoint textPoint;
    textPoint.x = currentPoint.x;
    textPoint.y = currentPoint.y + popCounter*16;
    // NSLog(@"Text Point = %f %f", textPoint.x, textPoint.y);
    red = 0.0/255.0;
    green = 0.0/255.0;
    blue = 0.0/255.0;
    for (int i = 0 ; i < [partnerActionsList count] ; i++) {
        if ([newPickUp isEqualToString:[partnerActionsList objectAtIndex:i]]) {
            switch (i) {
                case 0:
                    marker = [partnerActionsList objectAtIndex:i];
                    break;
                case 1:
                    marker = [partnerActionsList objectAtIndex:i];
                    break;
                case 2:
                    marker = @"HC";
                    [self updateButton:_humanTrussButton forKey:@"trussCatchHuman" forAction:@"Increment"];
                   break;
                case 3:
                    marker = @"HM";
                    [self updateButton:_humanTrussMissButton forKey:@"trussCatchHumanMiss" forAction:@"Increment"];
                    break;
            }
            break;
        }
    }
    [self drawText:marker location:textPoint];
    
    if (drawMode == DrawDefense) {
        red = 255.0/255.0;
        green = 0.0/255.0;
        blue = 0.0/255.0;
    }*/
}

- (void)defenseSelected:(NSString *)newDefense {
/*    [defensePickerPopover dismissPopoverAnimated:YES];
    NSString *marker;
    CGPoint textPoint;
    textPoint.x = currentPoint.x;
    textPoint.y = currentPoint.y + popCounter*16;
    popCounter++;

    if ([newDefense isEqualToString:@"Blocked"]) {
        marker = @"B";
        [self teleOpBlockedShots:@"Increment"];
    }
    else if ([newDefense isEqualToString:@"Disrupter"]) {
        marker = @"D";
        [self updateButton:_defensiveDisruptionButton forKey:@"defensiveDisruption" forAction:@"Increment"];
    }
    [self drawText:marker location:textPoint];*/
 }

-(void)drawPath:(UIPanGestureRecognizer *)gestureRecognizer {
    fieldDrawingChange = YES;
    UIImageView *currentView = (UIImageView *)[gestureRecognizer view];
    //  if ([gestureRecognizer view] == _fieldImage) NSLog(@"Yeah!");
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        // NSLog(@"drawPath Began");
        lastPoint = [gestureRecognizer locationInView:currentView];
    }
    else {
        currentPoint = [gestureRecognizer locationInView: currentView];
        // NSLog(@"current point = %lf, %lf", currentPoint.x, currentPoint.y);
        //        CGContextRef context = UIGraphicsGetCurrentContext();
        UIGraphicsBeginImageContext(currentView.frame.size);
        [currentView.image drawInRect:CGRectMake(0, 0, currentView.frame.size.width, currentView.frame.size.height)];
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1.0);
        if (eraseMode) {
            CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeClear);
            brush = 10.0;
        }
        else {
            CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
            brush = 3.0;
        }
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush );
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        currentView.image = UIGraphicsGetImageFromCurrentImageContext();
        [currentView setAlpha:opacity];
        UIGraphicsEndImageContext();
        lastPoint = currentPoint;
    }
}

-(void)drawText:(NSString *)marker location:(CGPoint)point inView:(UIImageView *)activeView {
    fieldDrawingChange = YES;
    UIGraphicsBeginImageContext(activeView.frame.size);
    [activeView.image drawInRect:CGRectMake(0, 0, activeView.frame.size.width, activeView.frame.size.height)];
    CGContextRef myContext = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(myContext, kCGLineCapRound);
    CGContextSetLineWidth(myContext, 1);
    CGContextSetRGBStrokeColor(myContext, red, green, blue, opacity);
    CGContextSelectFont (myContext,
                         "Helvetica",
                         16,
                         kCGEncodingMacRoman);
    CGContextSetCharacterSpacing (myContext, 1);
    CGContextSetTextDrawingMode (myContext, kCGTextFillStroke);
    CGContextSetTextMatrix(myContext, CGAffineTransformMake(1.0,0.0, 0.0, -1.0, 0.0, 0.0));
    
    CGContextShowTextAtPoint (myContext, point.x, point.y, [marker UTF8String], marker.length);
    CGContextFlush(UIGraphicsGetCurrentContext());
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    activeView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

-(void)drawSymbol:(UIImage *)marker location:(CGPoint)point inView:(UIImageView *)activeView {
    fieldDrawingChange = YES;
    NSLog(@"Pass in imageview");
    UIGraphicsBeginImageContext(activeView.frame.size);
    [activeView.image drawInRect:CGRectMake(0, 0, activeView.frame.size.width, activeView.frame.size.height)];
//    CGContextRef myContext = UIGraphicsGetCurrentContext();
    CGRect imageRect = CGRectMake(point.x, point.y, 18, 18);
//    CGContextScaleCTM(myContext, 1.0, -1.0);
    [marker drawInRect:imageRect];
//    CGContextDrawImage(myContext, imageRect, snarf.CGImage);
    CGContextFlush(UIGraphicsGetCurrentContext());
    activeView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}


-(void)checkOverrideCode:(UIButton *)button {
    // NSLog(@"Check override");
    if (alertPrompt == nil) {
        self.alertPrompt = [[AlertPromptViewController alloc] initWithNibName:nil bundle:nil];
        alertPrompt.delegate = self;
        alertPrompt.titleText = @"Enter Override Code";
        alertPrompt.msgText = @"Please be sure you really want to do this.";
        self.alertPromptPopover = [[UIPopoverController alloc]
                                   initWithContentViewController:alertPrompt];
    }
    [self.alertPromptPopover presentPopoverFromRect:button.bounds inView:button permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    
    return;
}

-(void)checkAdminCode:(UIButton *)button {
    // NSLog(@"Check override");
    if (alertPrompt == nil) {
        self.alertPrompt = [[AlertPromptViewController alloc] initWithNibName:nil bundle:nil];
        alertPrompt.delegate = self;
        alertPrompt.titleText = @"Enter Admin Code";
        alertPrompt.msgText = @"Danielle will kill you.";
        self.alertPromptPopover = [[UIPopoverController alloc]
                                   initWithContentViewController:alertPrompt];
    }
    [self.alertPromptPopover presentPopoverFromRect:button.bounds inView:button permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    
    return;
}

- (void)passCodeResult:(NSString *)passCodeAttempt {
    [self.alertPromptPopover dismissPopoverAnimated:YES];
    switch (overrideMode) {
        case OverrideDrawLock:
            if ([passCodeAttempt isEqualToString:[prefs objectForKey:@"overrideCode"]]) {
                drawMode = DrawOff;
                [self drawModeSettings:drawMode];
            }
            break;
            
        case OverrideMatchReset:
            if ([passCodeAttempt isEqualToString:[prefs objectForKey:@"overrideCode"]]) {
                [self matchReset];
            }
            break;

        case OverrideAllianceSelection:
            if ([passCodeAttempt isEqualToString:[prefs objectForKey:@"adminCode"]]) {
           //     [self AllianceSelectionPopUp];
            }
            break;

        case OverrideTeamSelection:
            if ([passCodeAttempt isEqualToString:[prefs objectForKey:@"adminCode"]]) {
              //  [self TeamSelectionPopUp];
            }
            break;

        default:
            break;
    }
    overrideMode = NoOverride;
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

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        if (popUp == _matchResetButton) {
            [self matchReset];
        }
        else if (popUp == _drawModeButton) {
            drawMode = DrawOff;
            [self drawModeSettings:drawMode];
            NSLog(@"Load real saved drawing");
            [self activateAuton];
        }
    }
}

-(void)matchReset {
    dataChange = FALSE;
    fieldDrawingChange = NO;
    currentMatch.redScore = [NSNumber numberWithInt:-1];
    currentMatch.blueScore = [NSNumber numberWithInt:-1];

    currentScore.saved = [NSNumber numberWithFloat:0.0];
    currentScore.savedBy = @"";
    currentScore.received = [NSNumber numberWithFloat:0.0];
    currentScore.results = [NSNumber numberWithBool:NO];

    currentScore.autonRobotSet = [NSNumber numberWithBool:NO];
    currentScore.deadOnArrival = [NSNumber numberWithBool:NO];
    currentScore.driverRating = [NSNumber numberWithInt:0];
    currentScore.fouls = [NSNumber numberWithInt:0];
    
    currentScore.toteIntakeHP = [NSNumber numberWithInt:0];
    currentScore.toteHPTop = [NSNumber numberWithInt:0];
    currentScore.toteHPBottom = [NSNumber numberWithInt:0];

    currentScore.litterHP = [NSNumber numberWithInt:0];
    currentScore.litterHPTop = [NSNumber numberWithInt:0];

    currentScore.toteIntakeTopFloor = [NSNumber numberWithInt:0];
      currentScore.toteIntakeBottomFloor = [NSNumber numberWithInt:0];
    currentScore.toteFloorTop = [NSNumber numberWithInt:0];
    currentScore.toteFloorBottom = [NSNumber numberWithInt:0];

    currentScore.toteIntakeStep = [NSNumber numberWithInt:0];
    currentScore.toteStepTop = [NSNumber numberWithInt:0];
    currentScore.toteStepBottom = [NSNumber numberWithInt:0];

    currentScore.noShow = [NSNumber numberWithBool:NO];
    currentScore.notes = @"";
    currentScore.otherRating = [NSNumber numberWithInt:0];
    currentScore.robotSpeed = [NSNumber numberWithInt:0];
    currentScore.sc1 = [NSNumber numberWithInt:0];
    currentScore.sc2 = [NSNumber numberWithInt:0];
    currentScore.sc3 = [NSNumber numberWithInt:0];
    currentScore.sc4 = [NSNumber numberWithInt:0];
    currentScore.sc5 = [NSNumber numberWithInt:0];
    currentScore.sc6 = [NSNumber numberWithInt:0];
    currentScore.sc7 = @"";
    currentScore.sc8 = @"";
    currentScore.sc9 = @"";
    currentScore.scouter = @"";
    currentScore.autonDrawing.trace = nil;
    currentScore.teleOpDrawing.trace = nil;

    NSError *error;
    if (![_dataManager.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    [self showTeam:teamIndex];
}

-(IBAction)toggleGrid:(id)sender{
    if(_backgroundImage.image == [UIImage imageNamed:@"Blue.png"]){
        _backgroundImage.image = [UIImage imageNamed:@"Red.png"];
        [_toggleGridButton setTitle:@"On" forState:UIControlStateNormal];
    }
    else{
        _backgroundImage.image = [UIImage imageNamed:@"Blue.png"];
        [_toggleGridButton setTitle:@"Off" forState:UIControlStateNormal];
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

-(void)setSpeedRate:(NSString *)newPick {
    currentScore.robotSpeed = [NSNumber numberWithInt:[newPick intValue]];
    [_robotSpeed setTitle:[NSString stringWithFormat:@"%d", [currentScore.robotSpeed intValue]] forState:UIControlStateNormal];
    [self setDataChange];
}

-(void)setBlockRate:(NSString *)newPick {
  //  currentScore.defenseBlockRating = [NSNumber numberWithInt:[newPick intValue]];
 //   [_defenseBlockRating setTitle:[NSString stringWithFormat:@"%d", [currentScore.defenseBlockRating intValue]] forState:UIControlStateNormal];
    [self setDataChange];
}

-(void)setBullyRate:(NSString *)newPick {
  //  currentScore.defenseBullyRating = [NSNumber numberWithInt:[newPick intValue]];
 //   [_defenseBullyRating setTitle:[NSString stringWithFormat:@"%d", [currentScore.defenseBullyRating intValue]] forState:UIControlStateNormal];
    [self setDataChange];
}

-(void)setDriverRate:(NSString *)newPick {
    currentScore.driverRating = [NSNumber numberWithInt:[newPick intValue]];
    [_driverRating setTitle:[NSString stringWithFormat:@"%d", [currentScore.driverRating intValue]] forState:UIControlStateNormal];
    [self setDataChange];
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

-(BOOL)shouldAutorotate {
    return YES;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(void)setDefaults {
    eraseMode = FALSE;
    overrideMode = NoOverride;
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
    [self setSmallButtonDefaults:_toteHPTopButton];
    [self setSmallButtonDefaults:_toteHPBottomButton];

    [self setSmallButtonDefaults:_litterHPTopButton];
    [self setSmallButtonDefaults:_litterHPBottomButton];

    [self setSmallButtonDefaults:_toteFloorTopButton];
    [self setSmallButtonDefaults:_toteFloorBottomButton];

    [self setSmallButtonDefaults:_toteStepTopButton];
    [self setSmallButtonDefaults:_toteStepBottomButton];

    //    [self setBigButtonDefaults:_knockoutButton];
    [self setSmallButtonDefaults:_eraserButton];
    [self setTextBoxDefaults:_foulTextField forSize:18.0];
    [self setTextBoxDefaults:_scouterTextField forSize:18.0];
    _matchResetButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    [self setBigButtonDefaults:_teamEdit];
    [_teamEdit setTitle:@"Team Info" forState:UIControlStateNormal];
    [self setBigButtonDefaults:_syncButton];
    [_syncButton setTitle:@"Sync" forState:UIControlStateNormal];
    [self setBigButtonDefaults:_matchListButton];
    [_matchListButton setTitle:@"Match List" forState:UIControlStateNormal];
    [self setSmallButtonDefaults:_toggleGridButton];
    [_toggleGridButton setTitle:@"Off" forState:UIControlStateNormal];
    [self setSmallButtonDefaults:_matchResetButton];
    [self setSmallButtonDefaults:_robotSpeed];
    [self setSmallButtonDefaults:_driverRating];
    [self setSmallButtonDefaults:_intakeRatingButton];
    [self setTextBoxDefaults:_notes forSize:24.0];

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

-(void)setToteStackButtonDefaults:(UIButton *)currentButton {
    currentButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:10.0];
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

-(void)createGestures {
    // Triple tap for tote pick up
    tripleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(totePickUp:)];
    tripleTapGesture.numberOfTapsRequired=3;
    
    // Double tap for can pick up
    doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(canPickUp:)];
    doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    [doubleTapGestureRecognizer requireGestureRecognizerToFail: tripleTapGesture];
  
    drawGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drawPath:)];
    
    // Single tap to score totes, cans and noodles
    tapPressGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scoreStack:)];
    tapPressGesture.numberOfTapsRequired = 1;
    [tapPressGesture requireGestureRecognizerToFail: doubleTapGestureRecognizer];
    [tapPressGesture requireGestureRecognizerToFail: tripleTapGesture];
}

-(void)drawingSettings {
    scoreButtonChoices = [[NSArray alloc] initWithObjects:@"Reset to 0", @"Decrement", @"Increment", nil];
    
    // Drawing Stuff
    autonScoreList = [[NSMutableArray alloc] initWithObjects: @"0", @"1", @"2", @"3", nil];
    teleOpScoreList = [[NSMutableArray alloc] initWithObjects: @"Pass", @"Miss Pass", @"Disrupt", @"Miss Shot", @"Low", @"High", @"Truss Throw", @"Truss Miss", nil];
    teleOpPickUpList = [[NSMutableArray alloc] initWithObjects: @"Robot Intake", @"Robot Miss", @"Floor Pick Up", @"Miss Pick Up", @"Knockout", @"Truss Catch", @"Truss Catch Miss", nil];
    defenseList = [[NSMutableArray alloc] initWithObjects:@"Blocked", @"Disrupter", nil];
    rateList = [[NSMutableArray alloc] initWithObjects:@"1",@"2",@"3",@"4",@"5", nil];
    brush = 3.0;
    opacity = 1.0;
    [self getDrawingSymbols];
}

- (NSFetchedResultsController *)fetchedResultsController {
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
            NSLog(@"didChangeObject 1");
           // [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            NSLog(@"didChangeObject 2");
            //[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            NSLog(@"didChangeObject 3");
          //  [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            NSLog(@"didChangeObject 4");
           // [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            //[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            NSLog(@"didChangeSection 1");
           //[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            NSLog(@"didChangeSection 2");
           //[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    //[self.tableView endUpdates];
    NSLog(@"controllerDidChangeContent");

}
#endif

@end
