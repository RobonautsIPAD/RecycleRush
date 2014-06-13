//
//  MainScoutingPageViewController.m
// Robonauts Scouting
//
//  Created by Kris Pettinger on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/CALayer.h>
#import "MainScoutingPageViewController.h"
#import "TeamDetailViewController.h"
#import "MatchData.h"
#import "TeamScore.h"
#import "FieldDrawing.h"
#import "TeamData.h"
#import "TournamentData.h"
#import "DataManager.h"
#import "MatchTypeDictionary.h"
#import "parseCSV.h"
#import "PopUpPickerViewController.h"
#import <ImageIO/CGImageSource.h>

@interface MainScoutingPageViewController ()
    @property (nonatomic, weak) IBOutlet UIButton *driverRating;
    @property (nonatomic, weak) IBOutlet UIButton *robotSpeed;
    @property (nonatomic, weak) IBOutlet UIButton *defenseBullyRating;
    @property (nonatomic, weak) IBOutlet UIButton *defenseBlockRating;
    @property (weak, nonatomic) IBOutlet UIButton *intakeRatingButton;
    @property (weak, nonatomic) IBOutlet UIButton *assistRatingButton;
    @property (nonatomic, weak) IBOutlet UIButton *noShowButton;
    @property (nonatomic, weak) IBOutlet UIButton *doaButton;
    @property (nonatomic, weak) IBOutlet UIButton *autonMobilityButton;
    @property (weak, nonatomic) IBOutlet UIButton *trussThrowMissButton;
    @property (weak, nonatomic) IBOutlet UIButton *robotIntakeButton;
    @property (weak, nonatomic) IBOutlet UIButton *robotMissButton;
    @property (weak, nonatomic) IBOutlet UIButton *humanMissButton;
    @property (nonatomic, weak) IBOutlet UIButton *floorPickUpsButton;
    @property (weak, nonatomic) IBOutlet UIButton *floorPickUpMissButton;
    @property (weak, nonatomic) IBOutlet UIButton *knockoutButton;
    @property (weak, nonatomic) IBOutlet UIButton *humanMiss1Button;
    @property (weak, nonatomic) IBOutlet UIButton *humanMiss2Button;
    @property (weak, nonatomic) IBOutlet UIButton *humanMiss3Button;
    @property (weak, nonatomic) IBOutlet UIButton *humanMiss4Button;
    @property (weak, nonatomic) IBOutlet UIButton *humanTrussButton;
    @property (weak, nonatomic) IBOutlet UIButton *humanTrussMissButton;
    @property (weak, nonatomic) IBOutlet UIButton *trussCatchMissButton;
    @property (weak, nonatomic) IBOutlet UIButton *defensiveDisruptionButton;
    @property (weak, nonatomic) IBOutlet UITextField *foulTextField;
    @property (weak, nonatomic) IBOutlet UIButton *disruptShotButton;
    @property (weak, nonatomic) IBOutlet UITextField *scouterTextField;
@end

@implementation MainScoutingPageViewController {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSString *deviceName;
    NSString *scouter;
    MatchTypeDictionary *matchDictionary;
    int numberMatchTypes;
    id popUp;
    
    BOOL eraseMode;
    
    // Rating Pop Up
    UIPopoverController *ratingPickerPopover;
    PopUpPickerViewController *ratePicker;
    NSMutableArray *rateList;
    // Auton Scoring pop up
    NSMutableArray *autonScoreList;
    UIPopoverController *autonPickerPopover;
    PopUpPickerViewController *autonPicker;
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

    // Drawing Symbols
    UIImage *robotIntakeImage;
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
}

@synthesize settings;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize dataManager = _dataManager;
// Data Markers
@synthesize currentSectionType;
@synthesize rowIndex;
@synthesize sectionIndex;
@synthesize teamIndex;
@synthesize currentMatch;
@synthesize currentTeam;
@synthesize teamData;
@synthesize dataChange;
@synthesize delegate;
@synthesize storePath;
@synthesize fileManager;

// Match Control Buttons
@synthesize prevMatch;
@synthesize nextMatch;

// User Access Control
@synthesize overrideMode;
@synthesize alertPrompt;
@synthesize alertPromptPopover;

// Alliance Picker
@synthesize alliance;
@synthesize allianceList;
@synthesize alliancePicker;
@synthesize alliancePickerPopover;

// Team Picker
@synthesize teamNumber;
@synthesize teamList;
@synthesize teamPicker;
@synthesize teamPickerPopover;

// Match Data
@synthesize matchNumber;
@synthesize matchType;
@synthesize matchTypeList;
@synthesize matchTypePicker;
@synthesize matchTypePickerPopover;

// Match Score
@synthesize teamName;
@synthesize climbLevel;
@synthesize notes;
@synthesize teleOpBlockButton;
@synthesize teleOpMissButton;
@synthesize teleOpHighButton;
@synthesize teleOpLowButton;
@synthesize autonBlockButton;
@synthesize autonMissButton;
@synthesize passesFloorButton;
@synthesize passesAirButton;
@synthesize humanPickUpsButton = _humanPickUpsButton;
@synthesize human1Button = _human1Button;
@synthesize human2Button = _human2Button;
@synthesize human3Button = _human3Button;
@synthesize human4Button = _human4Button;
@synthesize floorPickUpsButton = _floorPickUpsButton;
@synthesize floorCatchButton = _floorCatchButton;
@synthesize airCatchButton = _airCatchButton;
@synthesize matchResetButton;
@synthesize trussCatchButton;
@synthesize trussThrowButton;
@synthesize scoreButtonReset = _scoreButtonReset;
@synthesize scoreButtonChoices = _scoreButtonChoices;
@synthesize scoreButtonPickerPopover = _scoreButtonPickerPopover;
@synthesize valuePrompt = _valuePrompt;
@synthesize valuePromptPopover = _valuePromptPopover;

// Other Stuff
@synthesize redScore;
@synthesize blueScore;
@synthesize teamEdit;
@synthesize matchListButton;
@synthesize syncButton;
@synthesize toggleGridButton;

// Field Drawing
@synthesize imageContainer;
@synthesize fieldImage;
@synthesize fieldDrawingChange;
@synthesize defenseList;
@synthesize defensePicker;
@synthesize defensePickerPopover;
@synthesize popCounter;
@synthesize currentPoint;
@synthesize drawMode;
@synthesize drawModeButton;
@synthesize eraserButton = _eraserButton;

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
    // NSLog(@"Main Scouting viewDidLoad");
    NSError *error = nil;
    if (!_dataManager) {
        _dataManager = [[DataManager alloc] init];
    }

    prefs = [NSUserDefaults standardUserDefaults];
    deviceName = [prefs objectForKey:@"deviceName"];
    scouter = [prefs objectForKey:@"scouter"];
    tournamentName = [prefs objectForKey:@"tournament"];
    if (tournamentName) {
        self.title = tournamentName;
    }
    else {
        self.title = @"Match Scouting";
    }
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

    // Set the list of match types
    matchDictionary = [[MatchTypeDictionary alloc] init];    
    
    eraseMode = FALSE;
    overrideMode = NoOverride;
    teamName.font = [UIFont fontWithName:@"Helvetica" size:24.0];
    [self SetBigButtonDefaults:prevMatch];
    [self SetBigButtonDefaults:nextMatch];
    [self SetTextBoxDefaults:matchNumber];
    [self SetBigButtonDefaults:matchType];
    [self SetBigButtonDefaults:teamNumber];

    [self SetBigButtonDefaults:_autonHighHotButton];
    [_autonHighHotButton setTitleColor:[UIColor redColor]forState: UIControlStateNormal];
    [self SetBigButtonDefaults:_autonHighColdButton];
    [_autonHighColdButton setTitleColor:[UIColor blueColor]forState: UIControlStateNormal];
    [self SetBigButtonDefaults:_autonLowColdButton];
    [_autonLowColdButton setTitleColor:[UIColor blueColor]forState: UIControlStateNormal];
    [self SetBigButtonDefaults:_autonLowHotButton];
    [_autonLowHotButton setTitleColor:[UIColor redColor]forState: UIControlStateNormal];
    [self SetBigButtonDefaults:autonMissButton];
    [self SetBigButtonDefaults:autonBlockButton];
 
    [self SetBigButtonDefaults:teleOpHighButton];
    [self SetBigButtonDefaults:teleOpLowButton];
    [self SetBigButtonDefaults:teleOpMissButton];
    [self SetBigButtonDefaults:teleOpBlockButton];

    [self SetBigButtonDefaults:trussThrowButton];
    [self SetBigButtonDefaults:_trussThrowMissButton];

    [self SetBigButtonDefaults:_humanTrussButton];
    [self SetBigButtonDefaults:_humanTrussMissButton];

    [self SetBigButtonDefaults:passesFloorButton];
    [self SetBigButtonDefaults:_passesFloorMissButton];

    [self SetBigButtonDefaults:_robotIntakeButton];
    [self SetBigButtonDefaults:_robotMissButton];

    [self SetBigButtonDefaults:_humanPickUpsButton];
    [self SetBigButtonDefaults:_humanMissButton];

    [self SetBigButtonDefaults:_floorPickUpsButton];
    [self SetBigButtonDefaults:_floorPickUpMissButton];

    [self SetBigButtonDefaults:_knockoutButton];
    [self SetBigButtonDefaults:_disruptShotButton];
    [self SetBigButtonDefaults:_defensiveDisruptionButton];

    [self SetBigButtonDefaults:passesFloorButton];
    [self SetBigButtonDefaults:passesAirButton];
    [self SetSmallButtonDefaults:_human1Button];
    [self SetSmallButtonDefaults:_human2Button];
    [self SetSmallButtonDefaults:_human3Button];
    [self SetSmallButtonDefaults:_human4Button];
    [self SetSmallButtonDefaults:_humanMiss1Button];
    [self SetSmallButtonDefaults:_humanMiss2Button];
    [self SetSmallButtonDefaults:_humanMiss3Button];
    [self SetSmallButtonDefaults:_humanMiss4Button];
    [_humanMiss1Button setTitleColor:[UIColor redColor]forState: UIControlStateNormal];
    [_humanMiss2Button setTitleColor:[UIColor redColor]forState: UIControlStateNormal];
    [_humanMiss3Button setTitleColor:[UIColor redColor]forState: UIControlStateNormal];
    [_humanMiss4Button setTitleColor:[UIColor redColor]forState: UIControlStateNormal];
    [self SetSmallButtonDefaults:_eraserButton];
    [self SetTextBoxDefaults:redScore];
    [self SetTextBoxDefaults:blueScore];
    _foulTextField.font = [UIFont fontWithName:@"Helvetica" size:18.0];
    _scouterTextField.font = [UIFont fontWithName:@"Helvetica" size:18.0];
    matchResetButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    [self SetBigButtonDefaults:teamEdit];
    [teamEdit setTitle:@"Team Info" forState:UIControlStateNormal];
    [self SetBigButtonDefaults:syncButton];
    [syncButton setTitle:@"Sync" forState:UIControlStateNormal];
    [self SetBigButtonDefaults:matchListButton];
    [matchListButton setTitle:@"Match List" forState:UIControlStateNormal];
    [self SetSmallButtonDefaults:toggleGridButton];
    [toggleGridButton setTitle:@"Off" forState:UIControlStateNormal];
    [self SetSmallButtonDefaults:matchResetButton];
    [self SetBigButtonDefaults:trussCatchButton];
    [self SetBigButtonDefaults:passesAirButton];
    [self SetBigButtonDefaults:_airCatchButton];
    [self SetBigButtonDefaults:_floorCatchButton];
    [self SetSmallButtonDefaults:_robotSpeed];
    [self SetSmallButtonDefaults:_defenseBullyRating];
    [self SetSmallButtonDefaults:_defenseBlockRating];
    [self SetSmallButtonDefaults:_driverRating];
    [self SetSmallButtonDefaults:_intakeRatingButton];
    [self SetSmallButtonDefaults:_assistRatingButton];

    
    [self SetTextBoxDefaults:notes];

    [self SetBigButtonDefaults:alliance];
    allianceList = [[NSMutableArray alloc] initWithObjects:@"Red 1", @"Red 2", @"Red 3", @"Blue 1", @"Blue 2", @"Blue 3", nil];

    _scoreButtonChoices = [[NSMutableArray alloc] initWithObjects:@"Reset to 0", @"Decrement", @"Increment", nil];

    // Drawing Stuff
    autonScoreList = [[NSMutableArray alloc] initWithObjects: @"High (Hot)", @"High (Cold)", @"Missed", @"Low (Hot)",@"Low (Cold)", @"Blocked", nil];
    teleOpScoreList = [[NSMutableArray alloc] initWithObjects: @"Pass", @"Miss Pass", @"Disrupt", @"Miss Shot", @"Low", @"High", @"Truss Throw", @"Truss Miss", nil];
    teleOpPickUpList = [[NSMutableArray alloc] initWithObjects: @"Robot Intake", @"Robot Miss", @"Floor Pick Up", @"Miss Pick Up", @"Knockout", @"Truss Catch", @"Truss Catch Miss", nil];
    defenseList = [[NSMutableArray alloc] initWithObjects:@"Blocked", @"Disrupter", nil];
    rateList = [[NSMutableArray alloc] initWithObjects:@"1",@"2",@"3",@"4",@"5", nil];

    UITapGestureRecognizer *tripleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(partnerCatch:)];
    tripleTapGesture.numberOfTapsRequired=3;
    [fieldImage addGestureRecognizer:tripleTapGesture];

    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(floorPickUpGesture:)];
    doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    [doubleTapGestureRecognizer requireGestureRecognizerToFail: tripleTapGesture];
    [fieldImage addGestureRecognizer:doubleTapGestureRecognizer];
    
    UIPanGestureRecognizer *drawGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drawPath:)];
    [fieldImage addGestureRecognizer:drawGesture];
    
    UITapGestureRecognizer *tapPressGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scoreDisk:)];
    tapPressGesture.numberOfTapsRequired = 1;
    [tapPressGesture requireGestureRecognizerToFail: doubleTapGestureRecognizer];
    [tapPressGesture requireGestureRecognizerToFail: tripleTapGesture];
    [fieldImage addGestureRecognizer:tapPressGesture];
    
    [imageContainer sendSubviewToBack:_backgroundImage];

    brush = 3.0;
    opacity = 1.0;
    
    [self getDrawingSymbols];
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated
{
    // NSLog(@"viewWillAppear");
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}		
    matchTypeList = [self getMatchTypeList];
    numberMatchTypes = [matchTypeList count];
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
            currentSectionType = [[matchDictionary getMatchTypeEnum:[matchTypeList objectAtIndex:0]] intValue];
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
                currentSectionType = [[matchDictionary getMatchTypeEnum:[matchTypeList objectAtIndex:0]] intValue];
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
    [self ShowTeam:teamIndex];
}    

- (void) viewWillDisappear:(BOOL)animated
{
    NSLog(@"viewWillDisappear");
    NSString *dataMarkerString;
    storePath = [[self applicationLibraryDirectory] stringByAppendingPathComponent: @"Preferences/dataMarker.csv"];
    dataMarkerString = [NSString stringWithFormat:@"%d, %d, %d\n", rowIndex, currentSectionType, teamIndex];
    [dataMarkerString writeToFile:storePath 
                       atomically:YES 
                         encoding:NSUTF8StringEncoding 
                            error:nil];
   [self CheckDataStatus];
    //    [delegate scoutingPageStatus:sectionIndex forRow:rowIndex forTeam:teamIndex];
}

-(void)getDrawingSymbols {
    NSString *imageFilePath = [[NSBundle mainBundle] pathForResource:@"Intake from Robot" ofType:@"png"];
    robotIntakeImage = [UIImage imageWithContentsOfFile:imageFilePath];
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
    NSMutableArray *matchTypes = [NSMutableArray array];
    NSString *sectionName;
    for (int i=0; i < [[_fetchedResultsController sections] count]; i++) {
        sectionName = [[[_fetchedResultsController sections] objectAtIndex:i] name];
        [matchTypes addObject:[matchDictionary getMatchTypeString:[NSNumber numberWithInt:[sectionName intValue]]]];
    }
    return matchTypes;
}

-(NSUInteger)getMatchSectionInfo:(MatchType)matchSection {
    NSString *sectionName;
    sectionIndex = -1;
    // Loop for number of sections in table
    for (int i=0; i < [[_fetchedResultsController sections] count]; i++) {
        sectionName = [[[_fetchedResultsController sections] objectAtIndex:i] name];
        if ([sectionName intValue] == matchSection) {
            sectionIndex = i;
            break;
        }
    }
    return sectionIndex;
}
-(int)getNumberOfMatches:(NSUInteger)section {
    if ([[_fetchedResultsController sections] count]) {
        return [[[[_fetchedResultsController sections] objectAtIndex:sectionIndex] objects] count];
    }
    else return 0;
}

-(void)setDataChange {
    //  A change to one of the database fields has been detected. Set the time tag for the
    //  saved filed and set the device name into the field to indicated who made the change.
    // Also indicate that the match has results.
    currentTeam.results = [NSNumber numberWithBool:YES];
    currentTeam.saved = [NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()];
    currentTeam.savedBy = deviceName;
    currentTeam.scouter = scouter;
    //NSLog(@"Team = %@, Match = %@ Saved by:%@\tTime = %@", currentTeam.team.number, currentTeam.match.number, currentTeam.savedBy, currentTeam.saved);
    dataChange = TRUE;
}

-(void)CheckDataStatus {
    //    NSLog(@"Check to Save");
    //    NSLog (@"Data changed: %@", dataChange ? @"YES" : @"NO");
    if (fieldDrawingChange) {
        // Save the picture
        if (!currentTeam.fieldDrawing) {
            FieldDrawing *drawing = [NSEntityDescription insertNewObjectForEntityForName:@"FieldDrawing"
                                                        inManagedObjectContext:_dataManager.managedObjectContext];
            currentTeam.fieldDrawing = drawing;
        }
        currentTeam.fieldDrawing.trace = [NSData dataWithData:UIImagePNGRepresentation(fieldImage.image)];
        fieldDrawingChange = NO;
        [self setDataChange];
    }
    if (dataChange) {
        currentTeam.saved = [NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()];
        currentTeam.savedBy = deviceName;
        NSError *error;
        if (![_dataManager.managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        dataChange = NO;
    }
}

-(IBAction)PrevButton {
    [self CheckDataStatus];
    if (rowIndex > 0) rowIndex--;
    else {
        sectionIndex = [self GetPreviousSection:currentSectionType];
        rowIndex =  [self getNumberOfMatches:sectionIndex]-1;
    }
    
    currentMatch = [self getCurrentMatch];
    [self setTeamList];
    [self ShowTeam:teamIndex];
}

-(IBAction)NextButton {
    [self CheckDataStatus];
    int nrows;
    nrows =  [self getNumberOfMatches:sectionIndex];
    if (rowIndex < (nrows-1)) rowIndex++;
    else { 
        rowIndex = 0; 
        sectionIndex = [self GetNextSection:currentSectionType];
    }
    currentMatch = [self getCurrentMatch];
    
    [self setTeamList];
    [self ShowTeam:teamIndex];
}

// Move through the rounds
-(NSUInteger)GetNextSection:(MatchType) currentSection {
    //    NSLog(@"GetNextSection");
    NSUInteger nextSection;
    switch (currentSection) {
        case Practice:
            currentSectionType = Seeding;
            nextSection = [self getMatchSectionInfo:currentSectionType];
            if (nextSection == -1) { // There are no seeding matches
                nextSection = [self getMatchSectionInfo:currentSection];
                currentSectionType = currentSection;
            }
            break;
        case Seeding:
            currentSectionType = Elimination;
            nextSection = [self getMatchSectionInfo:currentSectionType];
            if (nextSection == -1) { // There are no Elimination matches
                nextSection = [self getMatchSectionInfo:currentSection];
                currentSectionType = currentSection;
            }
            break;
        case Elimination:
            currentSectionType = Practice;
            nextSection = [self getMatchSectionInfo:currentSectionType];
            if (nextSection == -1) { // There are no Practice matches
                // Try seeding matches instead
                currentSectionType = Seeding;
                nextSection = [self getMatchSectionInfo:currentSectionType];
                if (nextSection == -1) { // There are no seeding matches either
                    nextSection = [self getMatchSectionInfo:currentSection];
                    currentSectionType = currentSection;
                }
            }
            break;
        case OtherMatch:
            currentSectionType = Testing;
            nextSection = [self getMatchSectionInfo:currentSectionType];
            if (nextSection == -1) { // There are no Test matches
                nextSection = [self getMatchSectionInfo:currentSection];
                currentSectionType = currentSection;
            }
            break;
        case Testing:
            currentSectionType = OtherMatch;
            nextSection = [self getMatchSectionInfo:currentSectionType];
            if (nextSection == -1) { // There are no Other matches
                nextSection = [self getMatchSectionInfo:currentSection];
                currentSectionType = currentSection;
            }
            break;
    }
    return nextSection;
}

-(NSUInteger)GetPreviousSection:(NSUInteger) currentSection {
    //    NSLog(@"GetPreviousSection");
    NSUInteger newSection;
    switch (currentSection) {
        case Practice:
            currentSectionType = Testing;
            newSection = [self getMatchSectionInfo:currentSectionType];
            if (newSection == -1) { // There are no Test matches
                newSection = [self getMatchSectionInfo:currentSection];
                currentSectionType = currentSection;
            }
            break;
        case Seeding:
            currentSectionType = Practice;
            newSection = [self getMatchSectionInfo:currentSectionType];
            if (newSection == -1) { // There are no Practice matches
                newSection = [self getMatchSectionInfo:currentSection];
                currentSectionType = currentSection;
            }
            break;
        case Elimination:
            currentSectionType = Seeding;
            newSection = [self getMatchSectionInfo:currentSectionType];
            if (newSection == -1) { // There are no Seeding matches
                newSection = [self getMatchSectionInfo:currentSection];
                currentSectionType = currentSection;
            }
            break;
        case OtherMatch:
            currentSectionType = Testing;
            newSection = [self getMatchSectionInfo:currentSectionType];
            if (newSection == -1) { // There are no Test matches
                newSection = [self getMatchSectionInfo:currentSection];
                currentSectionType = currentSection;
            }
            break;
        case Testing:
            currentSectionType = OtherMatch;
            newSection = [self getMatchSectionInfo:currentSectionType];
            if (newSection == -1) { // There are no Other matches
                newSection = [self getMatchSectionInfo:currentSection];
                currentSectionType = currentSection;
            }
            break;
    }
    return newSection;
}

-(IBAction)AllianceSelectionChanged:(id)sender {
    //    NSLog(@"AllianceSelectionChanged");
    if ([[prefs objectForKey:@"mode"] isEqualToString:@"Test"]) {
        [self AllianceSelectionPopUp];
    }
    else {
        overrideMode = OverrideAllianceSelection;
        [self checkAdminCode:alliance];
    }
}

-(void)AllianceSelectionPopUp {
    [self CheckDataStatus];
    if (alliancePicker == nil) {
        self.alliancePicker = [[AlliancePickerController alloc]
                               initWithStyle:UITableViewStylePlain];
        alliancePicker.delegate = self;
        alliancePicker.allianceChoices = allianceList;
        self.alliancePickerPopover = [[UIPopoverController alloc]
                                      initWithContentViewController:alliancePicker];
    }
    [self.alliancePickerPopover presentPopoverFromRect:alliance.bounds inView:alliance
                              permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)allianceSelected:(NSString *)newAlliance {
    [self CheckDataStatus];
    [self.alliancePickerPopover dismissPopoverAnimated:YES];    
    for (int i = 0 ; i < [allianceList count] ; i++) {
        if ([newAlliance isEqualToString:[allianceList objectAtIndex:i]]) {
            teamIndex = i;
            [alliance setTitle:newAlliance forState:UIControlStateNormal];
            [self ShowTeam:teamIndex];
            break;
        }
    }
}

-(IBAction)MatchTypeSelectionChanged:(id)sender {
      // NSLog(@"matchTypeSelectionChanged");
    [self CheckDataStatus];
    if (matchTypePicker == nil) {
        self.matchTypePicker = [[MatchTypePickerController alloc] 
                                initWithStyle:UITableViewStylePlain];
        matchTypePicker.delegate = self;
        matchTypePicker.matchTypeChoices = matchTypeList;
        self.matchTypePickerPopover = [[UIPopoverController alloc] 
                                       initWithContentViewController:matchTypePicker];               
    }
    matchTypePicker.matchTypeChoices = matchTypeList;
    // NSLog(@"Match Types = %@", matchTypeList);
    [self.matchTypePickerPopover presentPopoverFromRect:matchType.bounds inView:matchType
                               permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)matchTypeSelected:(NSString *)newMatchType {
    [self.matchTypePickerPopover dismissPopoverAnimated:YES];
    [self CheckDataStatus];
    
    for (int i = 0 ; i < [matchTypeList count] ; i++) {
        if ([newMatchType isEqualToString:[matchTypeList objectAtIndex:i]]) {
            currentSectionType = [[matchDictionary getMatchTypeEnum:newMatchType] intValue];
            sectionIndex = [self getMatchSectionInfo:currentSectionType];
            break;
        }
    }
    rowIndex = 0;
    currentMatch = [self getCurrentMatch];
    [self setTeamList];
    [self ShowTeam:teamIndex];
}

-(IBAction)TeamSelectionChanged:(id)sender {
    //    NSLog(@"TeamSelectionChanged");
    if ([[prefs objectForKey:@"mode"] isEqualToString:@"Test"]) {
        [self TeamSelectionPopUp];
    }
    else {
        overrideMode = OverrideTeamSelection;
        [self checkAdminCode:teamNumber];
    }
}

-(void)TeamSelectionPopUp {
    [self CheckDataStatus];
    if (teamPicker == nil) {
        self.teamPicker = [[TeamPickerController alloc]
                           initWithStyle:UITableViewStylePlain];
        teamPicker.delegate = self;
        teamPicker.teamList = teamList;
        self.teamPickerPopover = [[UIPopoverController alloc]
                                  initWithContentViewController:teamPicker];
    }
    teamPicker.teamList = teamList;
    [self.teamPickerPopover presentPopoverFromRect:teamNumber.bounds inView:teamNumber
                          permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)teamSelected:(NSString *)newTeam {
    [self CheckDataStatus];
    [self.teamPickerPopover dismissPopoverAnimated:YES];
    
    for (int i = 0 ; i < [teamList count] ; i++) {
        if ([newTeam isEqualToString:[teamList objectAtIndex:i]]) {
            teamIndex = i;
            [teamNumber setTitle:newTeam forState:UIControlStateNormal];
            [self ShowTeam:teamIndex];
            break;
        }
    }
}

-(IBAction)MatchNumberChanged {
    // NSLog(@"MatchNumberChanged");
    [self CheckDataStatus];
    
    int matchField = [matchNumber.text intValue];
    
    id <NSFetchedResultsSectionInfo> sectionInfo = 
    [[_fetchedResultsController sections] objectAtIndex:sectionIndex];
    int nmatches = [sectionInfo numberOfObjects];
    if (matchField > nmatches) {
        /* Ooops, not that many matches */
        // For now, just change the match field to the last match in the section
        matchField = nmatches;
    }
    rowIndex = matchField-1;
    currentMatch = [self getCurrentMatch];
    
    [self setTeamList];
    [self ShowTeam:teamIndex];
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
        if ([currentTeam.autonMobility intValue]) {
            currentTeam.autonMobility = [NSNumber numberWithBool:NO];
        }
        else { // It is off, turn it on
            currentTeam.autonMobility = [NSNumber numberWithBool:YES];
        }
        [self setRadioButtonState:_autonMobilityButton forState:[currentTeam.autonMobility intValue]];
    }
    if (sender == _noShowButton) { // It is on, turn it off
        if ([currentTeam.noShow intValue]) {
            currentTeam.noShow = [NSNumber numberWithBool:NO];
        }
        else { // It is off, turn it on
            currentTeam.noShow = [NSNumber numberWithBool:YES];
            // If notes are blank, then go ahead and put no show in the notes
            if (!currentTeam.notes || [currentTeam.notes isEqualToString:@""]) {
                currentTeam.notes = @"No Show";
                notes.text = currentTeam.notes;
            }
        }
        [self setRadioButtonState:_noShowButton forState:[currentTeam.noShow intValue]];
    }
    if (sender == _doaButton) { // It is on, turn it off
        if ([currentTeam.deadOnArrival intValue]) {
            currentTeam.deadOnArrival = [NSNumber numberWithBool:NO];
        }
        else { // It is off, turn it on
            currentTeam.deadOnArrival = [NSNumber numberWithBool:YES];
            // If notes are blank, then go ahead and put DOA in the notes
            if (!currentTeam.notes || [currentTeam.notes isEqualToString:@""]) {
                currentTeam.notes = @"Dead";
                notes.text = currentTeam.notes;
            }
        }
        [self setRadioButtonState:_doaButton forState:[currentTeam.deadOnArrival intValue]];
    }
 
    [self setDataChange];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField != matchNumber && textField != redScore && textField != blueScore && textField != _foulTextField)  return YES;
    
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
    if (textField == notes) {
        [self setDataChange];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
//    NSLog(@"should end editing");
    if (textField == notes) {
		currentTeam.notes = notes.text;
	}
    else if (textField == redScore) {
        currentMatch.redScore = [NSNumber numberWithInt:[redScore.text intValue]];     
    }
    else if (textField == blueScore) {
        currentMatch.blueScore = [NSNumber numberWithInt:[blueScore.text intValue]];     
    }
    else if (textField == _foulTextField) {
        currentTeam.fouls = [NSNumber numberWithInt:[_foulTextField.text intValue]];
    }
    else if (textField == _scouterTextField) {
        scouter = _scouterTextField.text;
		currentTeam.scouter = scouter;
        [prefs setObject:scouter forKey:@"scouter"];
	}
	return YES;
}



// Keeping the score

- (IBAction)scoreButtons:(id)sender {    
    UIButton *button = (UIButton *)sender;
    if (_scoreButtonReset == nil) {
        self.scoreButtonReset = [[PopUpPickerViewController alloc]
                              initWithStyle:UITableViewStylePlain];
        _scoreButtonReset.delegate = self;
        _scoreButtonReset.pickerChoices = _scoreButtonChoices;
        self.scoreButtonPickerPopover = [[UIPopoverController alloc]
                                     initWithContentViewController:_scoreButtonReset];
    }
    _scoreButtonReset.pickerChoices = _scoreButtonChoices;
    popUp = sender;
    [self.scoreButtonPickerPopover presentPopoverFromRect:button.bounds inView:button
                             permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)pickerSelected:(NSString *)newPick {
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
    if (popUp == partnerActionsPicker) {
        [partnerActionsPickerPopover dismissPopoverAnimated:YES];
        [self allianceCatchSelected:newPick];
       return;
    }
    if (popUp == _defenseBullyRating) {
        [ratingPickerPopover dismissPopoverAnimated:YES];
        [self setBullyRate:newPick];
        return;
    }
    else if (popUp == _defenseBlockRating) {
        [ratingPickerPopover dismissPopoverAnimated:YES];
        [self setBlockRate:newPick];
        return;
    }
    else if (popUp == _driverRating) {
        [ratingPickerPopover dismissPopoverAnimated:YES];
        [self setDriverRate:newPick];
        return;
    }
    else if(popUp == _robotSpeed){
        [ratingPickerPopover dismissPopoverAnimated:YES];
        [self setSpeedRate:newPick];
        return;
    }
    else if(popUp == _intakeRatingButton){
        [ratingPickerPopover dismissPopoverAnimated:YES];
        [self setIntakeRate:newPick];
        return;
    }
    else if(popUp == _assistRatingButton){
        [ratingPickerPopover dismissPopoverAnimated:YES];
        [self setAssistRate:newPick];
        return;
    }
    [self.scoreButtonPickerPopover dismissPopoverAnimated:YES];
    if (popUp == _autonHighHotButton) [self autonHighHot:newPick];
    else if (popUp == _autonHighColdButton) [self autonHighCold:newPick];
    else if (popUp == _autonLowColdButton) [self autonLowCold:newPick];
    else if (popUp == _autonLowHotButton) [self autonLowHot:newPick];
    else if (popUp == autonMissButton) [self autonMiss:newPick];
    else if (popUp == autonBlockButton) [self autonBlock:newPick];
    else if (popUp == teleOpHighButton) [self teleOpHigh:newPick];
    else if (popUp == teleOpLowButton) [self teleOpLow:newPick];
    else if (popUp == teleOpMissButton) [self teleOpMiss:newPick];
    else if (popUp == teleOpBlockButton) [self teleOpBlock:newPick];
    else if (popUp == trussThrowButton) [self trussThrow:newPick];
    else if (popUp == _trussThrowMissButton) [self updateButton:_trussThrowMissButton forKey:@"trussThrowMiss" forAction:newPick];
    else if (popUp == _humanTrussButton) [self updateButton:_humanTrussButton forKey:@"trussCatchHuman" forAction:newPick];
    else if (popUp == _humanTrussMissButton) [self updateButton:_humanTrussMissButton forKey:@"trussCatchHumanMiss" forAction:newPick];
    else if (popUp == trussCatchButton) [self trussCatch:newPick];
    else if (popUp == _humanPickUpsButton) [self humanPickUp:newPick];
    else if (popUp == _humanMissButton) [self updateButton:_humanMissButton forKey:@"humanMiss" forAction:newPick];

    else if (popUp == _floorPickUpsButton) [self floorPickUpSelected:newPick];
    else if (popUp == _floorPickUpMissButton) [self updateButton:_floorPickUpMissButton forKey:@"floorPickUpMiss" forAction:newPick];
    else if (popUp == passesFloorButton) [self floorPass:newPick];
    else if (popUp == _passesFloorMissButton) [self updateButton:_passesFloorMissButton forKey:@"floorPassMiss" forAction:newPick];
    else if (popUp == passesAirButton) [self airPass:newPick];
    else if (popUp == _knockoutButton) [self updateButton:_knockoutButton forKey:@"knockout" forAction:newPick];
    else if (popUp == _floorCatchButton) [self floorCatch:newPick];
    else if (popUp == _robotIntakeButton) [self updateButton:_robotIntakeButton forKey:@"RobotIntake" forAction:newPick];
    else if (popUp == _robotMissButton) [self updateButton:_robotMissButton forKey:@"robotIntakeMiss" forAction:newPick];
    else if (popUp == _disruptShotButton) [self updateButton:_disruptShotButton forKey:@"disruptedShot" forAction:newPick];
    else if (popUp == _defensiveDisruptionButton) [self updateButton:_defensiveDisruptionButton forKey:@"defensiveDisruption" forAction:newPick];
}

- (void)valueEnteredAtPrompt:(NSString *)valueEntered {
    [self.valuePromptPopover dismissPopoverAnimated:YES];
}

-(void)floorCatch:(NSString *)choice {
    // Update the number of missed shots
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
    currentTeam.floorCatch = [NSNumber numberWithInt:score];
    [_floorCatchButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.floorCatch intValue]] forState:UIControlStateNormal];
    [self setDataChange];
}

-(void)airCatch:(NSString *)choice {
    // Update the number of missed shots
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
    currentTeam.airCatch = [NSNumber numberWithInt:score];
    [_airCatchButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.airCatch intValue]] forState:UIControlStateNormal];
    [self setDataChange];
}

-(void)airPass:(NSString *)choice {
    // Update the number of missed shots
    int score = [passesAirButton.titleLabel.text intValue];
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
        [self promptForValue:passesAirButton];
        return;
    }
    currentTeam.airPasses = [NSNumber numberWithInt:score];
    [passesAirButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.airPasses intValue]] forState:UIControlStateNormal];
    [self setDataChange];
}

-(void)floorPass:(NSString *)choice {
    // Update the number of floor passes
    int score = [passesFloorButton.titleLabel.text intValue];
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
        [self promptForValue:passesFloorButton];
        return;
    }
    currentTeam.floorPasses = [NSNumber numberWithInt:score];
    [passesFloorButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.floorPasses intValue]] forState:UIControlStateNormal];
    // Update total passes
    score = [currentTeam.totalPasses intValue];
    score++;
    currentTeam.totalPasses = [NSNumber numberWithInt:score];
    // Update total passes
    score = [currentTeam.totalPasses intValue];
    score++;
    currentTeam.totalPasses = [NSNumber numberWithInt:score];
    [self setDataChange];
}


-(void)floorPickUpSelected:(NSString *)choice {
    // Update the number of floor pick ups
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
    currentTeam.floorPickUp = [NSNumber numberWithInt:score];
    [_floorPickUpsButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.floorPickUp intValue]] forState:UIControlStateNormal];
    [self setDataChange];
}

-(void)floorPickUp {
    // NSLog(@"PickUps");
    int score = [_floorPickUpsButton.titleLabel.text intValue];
    score++;
    currentTeam.floorPickUp = [NSNumber numberWithInt:score];
    [_floorPickUpsButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.floorPickUp intValue]] forState:UIControlStateNormal];
    [self setDataChange];
}

-(void)humanPickUp:(NSString *)choice {
    // Update the number of missed shots
    int score = [_humanPickUpsButton.titleLabel.text intValue];
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
    currentTeam.humanPickUp = [NSNumber numberWithInt:score];
    [_humanPickUpsButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.humanPickUp intValue]] forState:UIControlStateNormal];
    
    [self setDataChange];
}


-(void)autonBlock:(NSString *)choice {
    // Update the number of missed shots
    int score = [autonBlockButton.titleLabel.text intValue];
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
        [self promptForValue:teleOpMissButton];
        return;
    }
    currentTeam.autonBlocks = [NSNumber numberWithInt:score];
    [autonBlockButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.autonBlocks intValue]] forState:UIControlStateNormal];
    
    [self setDataChange];
}

-(void)trussCatch:(NSString *)choice {
    // Update the number of missed shots
    int score = [trussCatchButton.titleLabel.text intValue];
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
        [self promptForValue:trussCatchButton];
        return;
    }
    currentTeam.trussCatch = [NSNumber numberWithInt:score];
    [trussCatchButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.trussCatch intValue]] forState:UIControlStateNormal];
    
    [self setDataChange];
}

-(void)trussThrow:(NSString *)choice {
    // Update the number of missed shots
    int score = [trussThrowButton.titleLabel.text intValue];
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
        [self promptForValue:trussThrowButton];
        return;
    }
    currentTeam.trussThrow = [NSNumber numberWithInt:score];
    [trussThrowButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.trussThrow intValue]] forState:UIControlStateNormal];
    
    [self setDataChange];
}


-(void)teleOpBlock:(NSString *)choice {
    // Update the number of missed shots
    int score = [teleOpBlockButton.titleLabel.text intValue];
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
        [self promptForValue:teleOpBlockButton];
        return;
    }
    currentTeam.teleOpBlocks = [NSNumber numberWithInt:score];
    [teleOpBlockButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.teleOpBlocks intValue]] forState:UIControlStateNormal];
    
    [self setDataChange];
}

-(void)teleOpMiss:(NSString *)choice {
    // Update the number of missed shots
    int score = [teleOpMissButton.titleLabel.text intValue];
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
        [self promptForValue:teleOpMissButton];
        return;
    }
    currentTeam.teleOpMissed = [NSNumber numberWithInt:score];
    [teleOpMissButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.teleOpMissed intValue]] forState:UIControlStateNormal];

    // Update the number of shots taken
    int total = [currentTeam.teleOpHigh intValue] + [currentTeam.teleOpLow intValue] + [currentTeam.teleOpMissed intValue];
    currentTeam.totalTeleOpShots = [NSNumber numberWithInt:total];
   
    [self setDataChange];
}

-(void)teleOpHigh:(NSString *)choice {
    // Update the number of high shots
    int score = [teleOpHighButton.titleLabel.text intValue];
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
        [self promptForValue:teleOpHighButton];
        return;
    }
    currentTeam.teleOpHigh = [NSNumber numberWithInt:score];
    [teleOpHighButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.teleOpHigh intValue]] forState:UIControlStateNormal];

    // Update the number of shots taken
    int total = [currentTeam.teleOpHigh intValue] + [currentTeam.teleOpLow intValue] + [currentTeam.teleOpMissed intValue];
    currentTeam.totalTeleOpShots = [NSNumber numberWithInt:total];
    
    // Update the number of shots made
    total = [currentTeam.teleOpHigh intValue] + [currentTeam.teleOpLow intValue];
    currentTeam.teleOpShotsMade = [NSNumber numberWithInt:total];
    [self setDataChange];
}

-(void)teleOpLow:(NSString *)choice {
    // Update the number of high shots
    int score = [teleOpLowButton.titleLabel.text intValue];
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
        [self promptForValue:teleOpLowButton];
        return;
    }
    currentTeam.teleOpLow = [NSNumber numberWithInt:score];
    [teleOpLowButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.teleOpLow intValue]] forState:UIControlStateNormal];

    // Update the number of shots taken
    int total = [currentTeam.teleOpHigh intValue] + [currentTeam.teleOpLow intValue] + [currentTeam.teleOpMissed intValue];
    currentTeam.totalTeleOpShots = [NSNumber numberWithInt:total];
    
    // Update the number of shots made
    total = [currentTeam.teleOpHigh intValue] + [currentTeam.teleOpLow intValue];
    currentTeam.teleOpShotsMade = [NSNumber numberWithInt:total];
    [self setDataChange];
}

-(void)autonMiss:(NSString *)choice {
    // Update the number of missed shots
    int score = [autonMissButton.titleLabel.text intValue];
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
        [self promptForValue:autonMissButton];
        return;
    }
    currentTeam.autonMissed = [NSNumber numberWithInt:score];
    [autonMissButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.autonMissed intValue]] forState:UIControlStateNormal];

    // Update the number of shots taken
    int total = [currentTeam.autonHighCold intValue] + [currentTeam.autonHighHot intValue] +[currentTeam.autonLowHot intValue] + [currentTeam.autonLowCold intValue] + [currentTeam.autonMissed intValue];
    currentTeam.totalAutonShots = [NSNumber numberWithInt:total];

    [self setDataChange];
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
    int score = [_autonHighHotButton.titleLabel.text intValue];
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
    currentTeam.autonHighHot = [NSNumber numberWithInt:score];
    [_autonHighHotButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.autonHighHot intValue]] forState:UIControlStateNormal];
    // Update the number of shots taken
    int total = [currentTeam.autonHighHot intValue] + [currentTeam.autonHighCold intValue] + [currentTeam.autonLowCold intValue] +[currentTeam.autonLowHot intValue] + [currentTeam.autonMissed intValue];
    currentTeam.totalAutonShots = [NSNumber numberWithInt:total];
    
    // Update the number of shots made
    total = [currentTeam.autonHighHot intValue] + [currentTeam.autonHighCold intValue] + [currentTeam.autonLowCold intValue] +[currentTeam.autonLowHot intValue];
    currentTeam.autonShotsMade = [NSNumber numberWithInt:total];
    [self setDataChange];
}

-(void)autonHighCold:(NSString *)choice {
    int score = [_autonHighColdButton.titleLabel.text intValue];
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
    currentTeam.autonHighCold = [NSNumber numberWithInt:score];
    [_autonHighColdButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.autonHighCold intValue]] forState:UIControlStateNormal];
    // Update the number of shots taken
    int total = [currentTeam.autonHighHot intValue] + [currentTeam.autonHighCold intValue] + [currentTeam.autonLowCold intValue] +[currentTeam.autonLowHot intValue] + [currentTeam.autonMissed intValue];
    currentTeam.totalAutonShots = [NSNumber numberWithInt:total];
    
    // Update the number of shots made
    total = [currentTeam.autonHighHot intValue] + [currentTeam.autonHighCold intValue] + [currentTeam.autonLowCold intValue] +[currentTeam.autonLowHot intValue];
    currentTeam.autonShotsMade = [NSNumber numberWithInt:total];
    [self setDataChange];
}

-(void)autonLowCold:(NSString *)choice {
    int score = [_autonLowColdButton.titleLabel.text intValue];
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
    currentTeam.autonLowCold = [NSNumber numberWithInt:score];
    [_autonLowColdButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.autonLowCold intValue]] forState:UIControlStateNormal];

    int total = [currentTeam.autonHighCold intValue] + [currentTeam.autonHighHot intValue] + [currentTeam.autonLowCold intValue] + [currentTeam.autonLowHot intValue] + [currentTeam.autonMissed intValue];
    currentTeam.totalAutonShots = [NSNumber numberWithInt:total];
    
    // Update the number of shots made
    total = [currentTeam.autonHighHot intValue] + [currentTeam.autonHighCold intValue] + [currentTeam.autonLowCold intValue] +[currentTeam.autonLowHot intValue];
    currentTeam.autonShotsMade = [NSNumber numberWithInt:total];
    [self setDataChange];
}

-(void)autonLowHot:(NSString *)choice {
    int score = [_autonLowHotButton.titleLabel.text intValue];
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
    currentTeam.autonLowHot = [NSNumber numberWithInt:score];
    [_autonLowHotButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.autonLowHot intValue]] forState:UIControlStateNormal];
    
    int total = [currentTeam.autonHighCold intValue] + [currentTeam.autonHighHot intValue] + [currentTeam.autonLowCold intValue] + [currentTeam.autonLowHot intValue] + [currentTeam.autonMissed intValue];
    currentTeam.totalAutonShots = [NSNumber numberWithInt:total];
    
    // Update the number of shots made
    total = [currentTeam.autonHighHot intValue] + [currentTeam.autonHighCold intValue] + [currentTeam.autonLowCold intValue] +[currentTeam.autonLowHot intValue];
    currentTeam.autonShotsMade = [NSNumber numberWithInt:total];
    [self setDataChange];
}

-(void)autonBlockedShots: (NSString *)choice {
    // NSLog(@"Blocked Shots");
    
    int score = [autonBlockButton.titleLabel.text intValue];
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
        [self promptForValue:autonBlockButton];
        return;
    }
    currentTeam.autonBlocks = [NSNumber numberWithInt:score];
    [autonBlockButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.autonBlocks intValue]] forState:UIControlStateNormal];
    [self setDataChange];
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
    [currentTeam setValue:[NSNumber numberWithInt:score] forKey:key];
    [button setTitle:[NSString stringWithFormat:@"%d", score] forState:UIControlStateNormal];
    [self setDataChange];
}

-(void)teleOpBlockedShots: (NSString *)choice {
    // NSLog(@"Blocked Shots");
    int score = [teleOpBlockButton.titleLabel.text intValue];
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
        [self promptForValue:teleOpBlockButton];
        return;
    }
    currentTeam.teleOpBlocks= [NSNumber numberWithInt:score];
    [teleOpBlockButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.teleOpBlocks intValue]] forState:UIControlStateNormal];
    [self setDataChange];
}

-(IBAction)humanPickUpsMade:(id) sender {
    UIButton * PressedButton = (UIButton*)sender;
   // NSLog(@"PickUps");
    if (drawMode == DrawDefense || drawMode == DrawTeleop) {
        [self setDataChange];
        int score = [_humanPickUpsButton.titleLabel.text intValue];
        score++;
        currentTeam.humanPickUp = [NSNumber numberWithInt:score];
        [_humanPickUpsButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.humanPickUp intValue]] forState:UIControlStateNormal];
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
            currentTeam.humanPickUp1 = [NSNumber numberWithInt:score];
            [_human1Button setTitle:[NSString stringWithFormat:@"%d", [currentTeam.humanPickUp1 intValue]] forState:UIControlStateNormal];
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
            currentTeam.humanPickUp2 = [NSNumber numberWithInt:score];
            [_human2Button setTitle:[NSString stringWithFormat:@"%d", [currentTeam.humanPickUp2 intValue]] forState:UIControlStateNormal];
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
            currentTeam.humanPickUp3 = [NSNumber numberWithInt:score];
            [_human3Button setTitle:[NSString stringWithFormat:@"%d", [currentTeam.humanPickUp3 intValue]] forState:UIControlStateNormal];
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
            currentTeam.humanPickUp4 = [NSNumber numberWithInt:score];
            [_human4Button setTitle:[NSString stringWithFormat:@"%d", [currentTeam.humanPickUp4 intValue]] forState:UIControlStateNormal];
        }
    }
}

- (IBAction)humanPickUpsMiss:(id)sender {
    UIButton * PressedButton = (UIButton*)sender;
    NSLog(@"Miss Human");
    if (drawMode == DrawDefense || drawMode == DrawTeleop) {
        [self setDataChange];
        int score = [_humanMissButton.titleLabel.text intValue];
        score++;
        currentTeam.humanMiss = [NSNumber numberWithInt:score];
        [_humanMissButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.humanMiss intValue]] forState:UIControlStateNormal];
        [self setDataChange];
        if (PressedButton == _humanMiss1Button) {
            score = [_humanMiss1Button.titleLabel.text intValue];
            CGPoint textPoint;
            CGPoint basePoint;
            CGFloat interval = 20;
            basePoint.x = 210;
            basePoint.y = 45;
            textPoint.x = basePoint.x + (score%4)*interval;
            textPoint.y = basePoint.y + (score/4)*interval;
            [self drawSymbol:humanMissImage location:textPoint];
            score++;
            currentTeam.humanMiss1 = [NSNumber numberWithInt:score];
            [_humanMiss1Button setTitle:[NSString stringWithFormat:@"%d", [currentTeam.humanMiss1 intValue]] forState:UIControlStateNormal];
        } else if (PressedButton == _humanMiss2Button) {
            score = [_humanMiss2Button.titleLabel.text intValue];
            CGPoint textPoint;
            CGPoint basePoint;
            CGFloat interval = 20;
            basePoint.x = 635;
            basePoint.y = 45;
            textPoint.x = basePoint.x - (score%4)*interval;
            textPoint.y = basePoint.y + (score/4)*interval;
            [self drawSymbol:humanMissImage location:textPoint];
            score++;
            currentTeam.humanMiss2 = [NSNumber numberWithInt:score];
            [_humanMiss2Button setTitle:[NSString stringWithFormat:@"%d", [currentTeam.humanMiss2 intValue]] forState:UIControlStateNormal];
        } else if (PressedButton == _humanMiss3Button) {
            score = [_humanMiss3Button.titleLabel.text intValue];
            CGPoint textPoint;
            CGPoint basePoint;
            CGFloat interval = 20;
            basePoint.x = 630;
            basePoint.y = 365;
            textPoint.x = basePoint.x - (score%4)*interval;
            textPoint.y = basePoint.y - (score/4)*interval;
            [self drawSymbol:humanMissImage location:textPoint];
            score++;
            currentTeam.humanMiss3 = [NSNumber numberWithInt:score];
            [_humanMiss3Button setTitle:[NSString stringWithFormat:@"%d", [currentTeam.humanMiss3 intValue]] forState:UIControlStateNormal];
        } else if (PressedButton == _humanMiss4Button) {
            score = [_humanMiss4Button.titleLabel.text intValue];
            CGPoint textPoint;
            CGPoint basePoint;
            CGFloat interval = 20;
            basePoint.x = 215;
            basePoint.y = 365;
            textPoint.x = basePoint.x + (score%4)*interval;
            textPoint.y = basePoint.y - (score/4)*interval;
            [self drawSymbol:humanMissImage location:textPoint];
            score++;
            currentTeam.humanMiss4 = [NSNumber numberWithInt:score];
            [_humanMiss4Button setTitle:[NSString stringWithFormat:@"%d", [currentTeam.humanMiss4 intValue]] forState:UIControlStateNormal];
        }
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self CheckDataStatus];
    
    if ([segue.identifier isEqualToString:@"TeamInfo"]) {
        TeamDetailViewController *detailViewController = [segue destinationViewController];
        [segue.destinationViewController setDataManager:_dataManager];
        detailViewController.team = currentTeam.team;
    }
    /*
    else if ([segue.identifier isEqualToString:@"Sync"]) {
        [segue.destinationViewController setDataManager:_dataManager];
        [segue.destinationViewController setSyncOption:SyncAllSavedSince];
        [segue.destinationViewController setSyncType:SyncMatchResults];
    }
    else {
        [segue.destinationViewController setDataManager:_dataManager];    
    }
    */
}

-(void)setTeamList {
    TeamScore *score;
    NSSortDescriptor *allianceSort = [NSSortDescriptor sortDescriptorWithKey:@"allianceSection" ascending:YES];
    teamData = [[currentMatch.score allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:allianceSort]];

    if (teamList == nil) {
        self.teamList = [NSMutableArray array];
        for (int i = 0; i < 6; i++) {
            score = [teamData objectAtIndex:i];
            [teamList addObject:[NSString stringWithFormat:@"%d", [score.team.number intValue]]];
        }
    }
    else {
        for (int i = 0; i < 6; i++) {
            score = [teamData objectAtIndex:i];
            [teamList replaceObjectAtIndex:i
                           withObject:[NSString stringWithFormat:@"%d", [score.team.number intValue]]];
        }
    }
}

-(void)setPartnerList {
    TeamScore *score;
    int indexStart, indexEnd;
    if ([currentTeam.allianceSection intValue] < 3) {
        // Reds
        indexStart = 0;
        indexEnd = 3;
    }
    else {
        // Blues
        indexStart = 3;
        indexEnd = 6;
    }
    NSMutableArray *list = [[NSMutableArray alloc] init];
    // NSLog(@"Current team = %@", currentTeam.team.number);
    for (int i=indexStart; i<indexEnd; i++) {
        score = [teamData objectAtIndex:i];
        if ([score.team.number intValue] != [currentTeam.team.number intValue]) {
            [list addObject:[NSString stringWithFormat:@"%d", [score.team.number intValue]]];
        }
    }
    [list addObject:[NSString stringWithFormat:@"Human Truss"]];
    [list addObject:[NSString stringWithFormat:@"Human Truss Miss"]];
    partnerActionsList = list;
    partnerActionsPickerPopover = nil;
    partnerActionsPicker = nil;
}

-(MatchData *)getCurrentMatch {
    if (numberMatchTypes == 0) {
        return nil;
    }
    else {
        NSIndexPath *matchIndex = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
        return [_fetchedResultsController objectAtIndexPath:matchIndex];
    }
}

-(void)disableButtons{
    NSLog(@"disabling buttons");
    [_autonHighHotButton setUserInteractionEnabled:NO];
    [_autonHighColdButton setUserInteractionEnabled:NO];
    [_autonLowHotButton setUserInteractionEnabled:NO];
    [_autonLowColdButton setUserInteractionEnabled:NO];
    [autonBlockButton setUserInteractionEnabled:NO];
    [autonMissButton setUserInteractionEnabled:NO];
    [teleOpHighButton setUserInteractionEnabled:NO];
    [teleOpLowButton setUserInteractionEnabled:NO];
    [teleOpMissButton setUserInteractionEnabled:NO];
    [teleOpBlockButton setUserInteractionEnabled:NO];
    [trussThrowButton setUserInteractionEnabled:NO];
    [_trussThrowMissButton setUserInteractionEnabled:NO];
    [_humanTrussButton setUserInteractionEnabled:NO];
    [_humanTrussMissButton setUserInteractionEnabled:NO];
    [passesFloorButton setUserInteractionEnabled:NO];
    [_passesFloorMissButton setUserInteractionEnabled:NO];
    [_robotIntakeButton setUserInteractionEnabled:NO];
    [_robotMissButton setUserInteractionEnabled:NO];
    [_autonMobilityButton setUserInteractionEnabled:NO];
    [_noShowButton setUserInteractionEnabled:NO];
    [_doaButton setUserInteractionEnabled:NO];
    [_human1Button setUserInteractionEnabled:NO];
    [_human2Button setUserInteractionEnabled:NO];
    [_human3Button setUserInteractionEnabled:NO];
    [_human4Button setUserInteractionEnabled:NO];
    [_humanPickUpsButton setUserInteractionEnabled:NO];
    [_humanMiss1Button setUserInteractionEnabled:NO];
    [_humanMiss2Button setUserInteractionEnabled:NO];
    [_humanMiss3Button setUserInteractionEnabled:NO];
    [_humanMiss4Button setUserInteractionEnabled:NO];
    [_humanMissButton setUserInteractionEnabled:NO];
    [_floorPickUpsButton setUserInteractionEnabled:NO];
    [_floorPickUpMissButton setUserInteractionEnabled:NO];
    [_knockoutButton setUserInteractionEnabled:NO];
    [_disruptShotButton setUserInteractionEnabled:NO];
    [_defensiveDisruptionButton setUserInteractionEnabled:NO];
    [_robotSpeed setUserInteractionEnabled:NO];
    [_defenseBlockRating setUserInteractionEnabled:NO];
    [_defenseBullyRating setUserInteractionEnabled:NO];
    [_driverRating setUserInteractionEnabled:NO];
    [_intakeRatingButton setUserInteractionEnabled:NO];
    [_assistRatingButton setUserInteractionEnabled:NO];
    [notes setUserInteractionEnabled:NO];
    [_foulTextField setUserInteractionEnabled:NO];
    [fieldImage setUserInteractionEnabled:FALSE];
    [_eraserButton setUserInteractionEnabled:NO];
}

-(void)enableButtons{
    NSLog(@"enabling Buttons");
    [_autonHighHotButton setUserInteractionEnabled:YES];
    [_autonHighColdButton setUserInteractionEnabled:YES];
    [_autonLowHotButton setUserInteractionEnabled:YES];
    [_autonLowColdButton setUserInteractionEnabled:YES];
    [autonBlockButton setUserInteractionEnabled:YES];
    [autonMissButton setUserInteractionEnabled:YES];
    [teleOpHighButton setUserInteractionEnabled:YES];
    [teleOpLowButton setUserInteractionEnabled:YES];
    [teleOpMissButton setUserInteractionEnabled:YES];
    [teleOpBlockButton setUserInteractionEnabled:YES];
    [trussThrowButton setUserInteractionEnabled:YES];
    [_trussThrowMissButton setUserInteractionEnabled:YES];
    [_humanTrussButton setUserInteractionEnabled:YES];
    [_humanTrussMissButton setUserInteractionEnabled:YES];
    [passesFloorButton setUserInteractionEnabled:YES];
    [_passesFloorMissButton setUserInteractionEnabled:YES];
    [_robotIntakeButton setUserInteractionEnabled:YES];
    [_robotMissButton setUserInteractionEnabled:YES];
    [passesFloorButton setUserInteractionEnabled:YES];
    [passesAirButton setUserInteractionEnabled:YES];
    [_floorCatchButton setUserInteractionEnabled:YES];
    [_airCatchButton setUserInteractionEnabled:YES];
    [_autonMobilityButton setUserInteractionEnabled:YES];
    [_noShowButton setUserInteractionEnabled:YES];
    [_doaButton setUserInteractionEnabled:YES];
    [_human1Button setUserInteractionEnabled:YES];
    [_human2Button setUserInteractionEnabled:YES];
    [_human3Button setUserInteractionEnabled:YES];
    [_human4Button setUserInteractionEnabled:YES];
    [_humanPickUpsButton setUserInteractionEnabled:YES];
    [_humanMiss1Button setUserInteractionEnabled:YES];
    [_humanMiss2Button setUserInteractionEnabled:YES];
    [_humanMiss3Button setUserInteractionEnabled:YES];
    [_humanMiss4Button setUserInteractionEnabled:YES];
    [_humanMissButton setUserInteractionEnabled:YES];
    [_floorPickUpsButton setUserInteractionEnabled:YES];
    [_floorPickUpMissButton setUserInteractionEnabled:YES];
    [_knockoutButton setUserInteractionEnabled:YES];
    [_disruptShotButton setUserInteractionEnabled:YES];
    [_defensiveDisruptionButton setUserInteractionEnabled:YES];
    [_robotSpeed setUserInteractionEnabled:YES];
    [_defenseBlockRating setUserInteractionEnabled:YES];
    [_defenseBullyRating setUserInteractionEnabled:YES];
    [_driverRating setUserInteractionEnabled:YES];
    [_intakeRatingButton setUserInteractionEnabled:YES];
    [_assistRatingButton setUserInteractionEnabled:YES];
    [notes setUserInteractionEnabled:YES];
    [_foulTextField setUserInteractionEnabled:YES];
    [fieldImage setUserInteractionEnabled:YES];
    [_eraserButton setUserInteractionEnabled:YES];
}

-(void)ShowTeam:(NSUInteger)currentTeamIndex {
    currentTeam = [self GetTeam:currentTeamIndex];

    [matchType setTitle:currentMatch.matchType forState:UIControlStateNormal];
    matchNumber.text = [NSString stringWithFormat:@"%d", [currentMatch.number intValue]];
    if ([currentMatch.redScore intValue] == -1) {
        redScore.text = @"";
    }
    else {
        redScore.text = [NSString stringWithFormat:@"%d", [currentMatch.redScore intValue]];
    }
    if ([currentMatch.blueScore intValue] == -1) {
        blueScore.text = @"";
    }
    else {
        blueScore.text = [NSString stringWithFormat:@"%d", [currentMatch.blueScore intValue]];
    }
        
   [teamNumber setTitle:[NSString stringWithFormat:@"%d", [currentTeam.team.number intValue]] forState:UIControlStateNormal];
    teamName.text = currentTeam.team.name;


    notes.text = currentTeam.notes;
    [alliance setTitle:[allianceList objectAtIndex:currentTeamIndex] forState:UIControlStateNormal];
    
    [teleOpMissButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.teleOpMissed intValue]] forState:UIControlStateNormal];
    [teleOpHighButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.teleOpHigh intValue]] forState:UIControlStateNormal];
    [teleOpLowButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.teleOpLow intValue]] forState:UIControlStateNormal];
    [autonMissButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.autonMissed intValue]] forState:UIControlStateNormal];
    [_autonHighHotButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.autonHighHot intValue]] forState:UIControlStateNormal];
    [_autonHighColdButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.autonHighCold intValue]] forState:UIControlStateNormal];
    [_autonLowColdButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.autonLowCold intValue]] forState:UIControlStateNormal];
    [_autonLowHotButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.autonLowHot intValue]] forState:UIControlStateNormal];

    [_humanPickUpsButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.humanPickUp intValue]] forState:UIControlStateNormal];
    [_human1Button setTitle:[NSString stringWithFormat:@"%d", [currentTeam.humanPickUp1 intValue]] forState:UIControlStateNormal];
    [_human2Button setTitle:[NSString stringWithFormat:@"%d", [currentTeam.humanPickUp2 intValue]] forState:UIControlStateNormal];
    [_human3Button setTitle:[NSString stringWithFormat:@"%d", [currentTeam.humanPickUp3 intValue]] forState:UIControlStateNormal];
    [_human4Button setTitle:[NSString stringWithFormat:@"%d", [currentTeam.humanPickUp4 intValue]] forState:UIControlStateNormal];

    [_humanMissButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.humanMiss intValue]] forState:UIControlStateNormal];
    [_humanMiss1Button setTitle:[NSString stringWithFormat:@"%d", [currentTeam.humanMiss1 intValue]] forState:UIControlStateNormal];
    [_humanMiss2Button setTitle:[NSString stringWithFormat:@"%d", [currentTeam.humanMiss2 intValue]] forState:UIControlStateNormal];
    [_humanMiss3Button setTitle:[NSString stringWithFormat:@"%d", [currentTeam.humanMiss3 intValue]] forState:UIControlStateNormal];
    [_humanMiss4Button setTitle:[NSString stringWithFormat:@"%d", [currentTeam.humanMiss4 intValue]] forState:UIControlStateNormal];

    
    [_floorPickUpsButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.floorPickUp intValue]] forState:UIControlStateNormal];
    [_floorPickUpMissButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.floorPickUpMiss intValue]] forState:UIControlStateNormal];
    [passesFloorButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.floorPasses intValue]] forState:UIControlStateNormal];
    [_passesFloorMissButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.floorPassMiss intValue]] forState:UIControlStateNormal];
    [passesAirButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.airPasses intValue]] forState:UIControlStateNormal];
    [trussCatchButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.trussCatch intValue]] forState:UIControlStateNormal];
    [trussThrowButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.trussThrow intValue]] forState:UIControlStateNormal];
    [_trussThrowMissButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.trussThrowMiss intValue]] forState:UIControlStateNormal];
    [_humanTrussButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.trussCatchHuman intValue]] forState:UIControlStateNormal];
    [_humanTrussMissButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.trussCatchHumanMiss intValue]] forState:UIControlStateNormal];
    [_knockoutButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.knockout intValue]] forState:UIControlStateNormal];
    [_disruptShotButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.disruptedShot intValue]] forState:UIControlStateNormal];

    [autonBlockButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.autonBlocks intValue]] forState:UIControlStateNormal];
    [teleOpBlockButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.teleOpBlocks intValue]] forState:UIControlStateNormal];
    [_floorCatchButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.floorCatch intValue]] forState:UIControlStateNormal];
    [_robotIntakeButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.robotIntake intValue]] forState:UIControlStateNormal];
    [_robotMissButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.robotIntakeMiss intValue]] forState:UIControlStateNormal];
    [_defensiveDisruptionButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.defensiveDisruption intValue]] forState:UIControlStateNormal];
    _foulTextField.text = [NSString stringWithFormat:@"%d", [currentTeam.fouls intValue]];

    [_defenseBlockRating setTitle:[NSString stringWithFormat:@"%d", [currentTeam.defenseBlockRating intValue]] forState:UIControlStateNormal];
    [_defenseBullyRating setTitle:[NSString stringWithFormat:@"%d", [currentTeam.defenseBullyRating intValue]] forState:UIControlStateNormal];
    [_driverRating setTitle:[NSString stringWithFormat:@"%d", [currentTeam.driverRating intValue]] forState:UIControlStateNormal];
    [_robotSpeed setTitle:[NSString stringWithFormat:@"%d", [currentTeam.robotSpeed intValue]] forState:UIControlStateNormal];
    [_intakeRatingButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.intakeRating intValue]] forState:UIControlStateNormal];
    [_assistRatingButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.assistRating intValue]] forState:UIControlStateNormal];
    
    [self setRadioButtonState:_noShowButton forState:[currentTeam.noShow intValue]];
    [self setRadioButtonState:_doaButton forState:[currentTeam.deadOnArrival intValue]];
    [self setRadioButtonState:_autonMobilityButton forState:[currentTeam.autonMobility intValue]];

    if ([currentTeam.results boolValue]) _scouterTextField.text = currentTeam.scouter;
    else _scouterTextField.text = scouter;
    
    if ([currentTeam.results boolValue]) drawMode = DrawLock;
    else drawMode = DrawOff;
    // Check the database to see if this team and match have a drawing already
    [_backgroundImage setImage:[UIImage imageNamed:@"2014_field.png"]];
    if (currentTeam.fieldDrawing.trace) {
        [fieldImage setImage:[UIImage imageWithData:currentTeam.fieldDrawing.trace]];
    }
    else {
        [fieldImage setImage:[[UIImage alloc] init]];
    }
    [self drawModeSettings:drawMode];
    eraseMode = FALSE;
    [_eraserButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self setPartnerList];
    
    NSLog(@"Saved by = %@", currentTeam.savedBy);
}

-(TeamScore *)GetTeam:(NSUInteger)currentTeamIndex {
    return [teamData objectAtIndex:currentTeamIndex];
/*    switch (currentTeamIndex) {
        case 0: return [teamData objectAtIndex:3];  // Red 1
        case 1: return [teamData objectAtIndex:4];  // Red 2
        case 2: return [teamData objectAtIndex:5];  // Red 3
        case 3: return [teamData objectAtIndex:0];  // Blue 1
        case 4: return [teamData objectAtIndex:1];  // Blue 2
        case 5: return [teamData objectAtIndex:2];  // Blue 3
    }    
    return nil;*/
}

-(void)floorPickUpGesture:(UITapGestureRecognizer *)gestureRecognizer {
    fieldDrawingChange = YES;
    if(drawMode == DrawAuton){
        // NSLog(@"floorPickUp");
        NSString *marker = @"O";
        currentPoint = [gestureRecognizer locationInView:fieldImage];
        [self drawText:marker location:currentPoint];
    }
    else {
        if (teleOpPickUpPicker == nil) {
            teleOpPickUpPicker = [[PopUpPickerViewController alloc] initWithStyle:UITableViewStylePlain];
            teleOpPickUpPicker.delegate = self;
            teleOpPickUpPicker.pickerChoices = teleOpPickUpList;
            teleOpPickUpPickerPopover = [[UIPopoverController alloc] initWithContentViewController:teleOpPickUpPicker];
        }
        popUp = teleOpPickUpPicker;
        currentPoint = [gestureRecognizer locationInView:fieldImage];
        CGPoint popPoint = [self scorePopOverLocation:currentPoint];
        [teleOpPickUpPickerPopover presentPopoverFromRect:CGRectMake(popPoint.x, popPoint.y, 1.0, 1.0) inView:fieldImage permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    }
}

-(void)scoreDisk:(UITapGestureRecognizer *)gestureRecognizer {
    fieldDrawingChange = YES;
    currentPoint = [gestureRecognizer locationInView:fieldImage];
    // NSLog(@"scoreDisk point = %f %f", currentPoint.x, currentPoint.y);
    popCounter = 0;
    if (drawMode == DrawDefense) {
        if (defensePicker == nil) {
            self.defensePicker = [[DefensePickerController alloc]
                                  initWithStyle:UITableViewStylePlain];
            defensePicker.delegate = self;
            defensePicker.defenseChoices = defenseList;
            self.defensePickerPopover = [[UIPopoverController alloc]
                                         initWithContentViewController:defensePicker];
        }
        CGPoint popPoint = [self defensePopOverLocation:currentPoint];
        [self.defensePickerPopover presentPopoverFromRect:CGRectMake(popPoint.x, popPoint.y, 1.0, 1.0) inView:fieldImage permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    }
    else if(drawMode == DrawAuton){
        if (autonPicker == nil) {
            autonPicker = [[PopUpPickerViewController alloc] initWithStyle:UITableViewStylePlain];
            autonPicker.delegate = self;
            autonPicker.pickerChoices = autonScoreList;
            autonPickerPopover = [[UIPopoverController alloc] initWithContentViewController:autonPicker];
        }
        popUp = autonPicker;
        CGPoint popPoint = [self scorePopOverLocation:currentPoint];
        [autonPickerPopover presentPopoverFromRect:CGRectMake(popPoint.x, popPoint.y, 1.0, 1.0) inView:fieldImage permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    }
    else {
        if (teleOpPicker == nil) {
            teleOpPicker = [[PopUpPickerViewController alloc] initWithStyle:UITableViewStylePlain];
            teleOpPicker.delegate = self;
            teleOpPicker.pickerChoices = teleOpScoreList;
            teleOpPickerPopover = [[UIPopoverController alloc] initWithContentViewController:teleOpPicker];
        }
        popUp = teleOpPicker;
        CGPoint popPoint = [self scorePopOverLocation:currentPoint];
        [teleOpPickerPopover presentPopoverFromRect:CGRectMake(popPoint.x, popPoint.y, 1.0, 1.0) inView:fieldImage permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    }
}

-(void)partnerCatch:(UITapGestureRecognizer *)gestureRecognizer {
    fieldDrawingChange = YES;
    if(drawMode == DrawTeleop || drawMode == DrawDefense) {
        if (partnerActionsPicker == nil) {
            partnerActionsPicker = [[PopUpPickerViewController alloc] initWithStyle:UITableViewStylePlain];
            partnerActionsPicker.pickerChoices = partnerActionsList;
            partnerActionsPicker.delegate = self;
            partnerActionsPickerPopover = [[UIPopoverController alloc] initWithContentViewController:partnerActionsPicker];
        }
        popUp = partnerActionsPicker;
        currentPoint = [gestureRecognizer locationInView:fieldImage];
        CGPoint popPoint = [self scorePopOverLocation:currentPoint];
        [partnerActionsPickerPopover presentPopoverFromRect:CGRectMake(popPoint.x, popPoint.y, 1.0, 1.0) inView:fieldImage permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
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
            if (!currentTeam.team || [currentTeam.team.number intValue] == 0) {
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
            }
            break;
        case DrawAuton:
            drawMode = DrawTeleop;
            break;
        case DrawTeleop:
            drawMode = DrawDefense;
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
            [drawModeButton setBackgroundImage:[UIImage imageNamed:@"Small White Button.jpg"] forState:UIControlStateNormal];
            [drawModeButton setTitle:@"Off" forState:UIControlStateNormal];
            [drawModeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self disableButtons];
            break;
        case DrawAuton:
            red = 255.0/255.0;
            green = 190.0/255.0;
            blue = 0.0/255.0;
            [drawModeButton setBackgroundImage:[UIImage imageNamed:@"Small Green Button.jpg"] forState:UIControlStateNormal];
            [drawModeButton setTitle:@"Auton" forState:UIControlStateNormal];
            [drawModeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self enableButtons];
            break;
        case DrawTeleop:
            red = 0.0/255.0;
            green = 0.0/255.0;
            blue = 0.0/255.0;
            [drawModeButton setBackgroundImage:[UIImage imageNamed:@"Small Blue Button.jpg"] forState:UIControlStateNormal];
            [drawModeButton setTitle:@"TeleOp" forState:UIControlStateNormal];
            [drawModeButton setTitleColor:[UIColor colorWithRed:255.0 green:190.0 blue:0 alpha:1.0] forState:UIControlStateNormal];
            fieldImage.userInteractionEnabled = TRUE;
            break;
        case DrawDefense:
            red = 255.0/255.0;
            green = 0.0/255.0;
            blue = 0.0/255.0;
            [drawModeButton setBackgroundImage:[UIImage imageNamed:@"Small Grey Button.jpg"] forState:UIControlStateNormal];
            [drawModeButton setTitle:@"Defense" forState:UIControlStateNormal];
            [drawModeButton setTitleColor:[UIColor colorWithRed:255.0 green:190.0 blue:0 alpha:1.0] forState:UIControlStateNormal];
            fieldImage.userInteractionEnabled = TRUE;
            break;
        case DrawLock:
            [drawModeButton setBackgroundImage:[UIImage imageNamed:@"Small Red Button.jpg"] forState:UIControlStateNormal];
            [drawModeButton setTitle:@"Locked" forState:UIControlStateNormal];
            [drawModeButton setTitleColor:[UIColor colorWithRed:255.0 green:190.0 blue:0 alpha:1.0] forState:UIControlStateNormal];
            [self disableButtons];
            break;
        default:
            break;
    }
}

- (void)autonScoreSelected:(NSString *)newScore {
    [autonPickerPopover dismissPopoverAnimated:YES];
    NSString *marker;
    CGPoint textPoint;
    textPoint.x = currentPoint.x;
    textPoint.y = currentPoint.y + popCounter*16;
    // NSLog(@"Text Point = %f %f", textPoint.x, textPoint.y);
    popCounter++;
    for (int i = 0 ; i < [autonScoreList count] ; i++) {
        if ([newScore isEqualToString:[autonScoreList objectAtIndex:i]]) {
            switch (i) {
                case 0:
                    marker = @"HH";
                    [self autonHighHot:@"Increment"];
                    break;
                case 1:
                    marker = @"HC";
                    [self autonHighCold:@"Increment"];
                    break;
                case 2:
                    marker = @"X";
                    [self autonMiss:@"Increment"];
                    break;
                case 3:
                    marker = @"LH";
                    [self autonLowHot:@"Increment"];
                    break;
                case 4:
                    marker = @"LC";
                    [self autonLowCold:@"Increment"];
                    break;
                case 5:
                    marker = @"B";
                    [self autonBlock:@"Increment"];
                    break;
            }
            break;
        }
    }
    [self drawText:marker location:textPoint];
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
    
    if ([newScore isEqualToString:@"Pass"]) {
        [self updateButton:passesFloorButton forKey:@"floorPasses" forAction:@"Increment"];
        [self drawSymbol:passImage location:textPoint];
    }
    else if ([newScore isEqualToString:@"Miss Pass"]) {
        [self updateButton:_passesFloorMissButton forKey:@"floorPassMiss" forAction:@"Increment"];
        [self drawSymbol:passMissImage location:textPoint];
    }
    else if ([newScore isEqualToString:@"Disrupt"]) {
        [self updateButton:_disruptShotButton forKey:@"disruptedShot" forAction:@"Increment"];
        [self drawSymbol:disruptedShotImage location:textPoint];
    }
    else if ([newScore isEqualToString:@"Miss Shot"]) {
        marker = @"X";
        [self teleOpMiss:@"Increment"];
        [self drawText:marker location:textPoint];
    }
    else if ([newScore isEqualToString:@"Low"]) {
        marker = @"L";
        [self teleOpLow:@"Increment"];
        [self drawText:marker location:textPoint];
    }
    else if ([newScore isEqualToString:@"High"]) {
        marker = @"H";
        [self teleOpHigh:@"Increment"];
        [self drawText:marker location:textPoint];
    }
    else if ([newScore isEqualToString:@"Truss Throw"]) {
        [self trussThrow:@"Increment"];
        [self drawSymbol:trussThrowImage location:textPoint];
    }
    else if ([newScore isEqualToString:@"Truss Miss"]) {
        [self updateButton:_trussThrowMissButton forKey:@"trussThrowMiss" forAction:@"Increment"];
        [self drawSymbol:trussThrowMissImage location:textPoint];
    }
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
    
    if ([newPickUp isEqualToString:@"Floor Pick Up"]) {
        [self drawSymbol:floorPickUpImage location:textPoint];
        [self floorPickUpSelected:@"Increment"];
    }
    else if ([newPickUp isEqualToString:@"Miss Pick Up"]) {
        [self updateButton:_floorPickUpMissButton forKey:@"floorPickUpMiss" forAction:@"Increment"];
        [self drawSymbol:floorPickUpMissImage location:textPoint];
    }
    else if ([newPickUp isEqualToString:@"Robot Intake"]) {
        [self updateButton:_robotIntakeButton forKey:@"robotIntake" forAction:@"Increment"];
        [self drawSymbol:robotIntakeImage location:textPoint];
    }
    else if ([newPickUp isEqualToString:@"Robot Miss"]) {
        [self updateButton:_robotMissButton forKey:@"robotIntakeMiss" forAction:@"Increment"];
        [self drawSymbol:robotMissImage location:textPoint];
    }
    else if ([newPickUp isEqualToString:@"Knockout"]) {
        marker = @"K";
        [self updateButton:_knockoutButton forKey:@"knockout" forAction:@"Increment"];
        [self drawText:marker location:textPoint];
    }
    else if ([newPickUp isEqualToString:@"Floor Catch"]) {
        marker = @"FC";
        [self drawText:marker location:textPoint];
        [self floorCatch:@"Increment"];
    }
    else if ([newPickUp isEqualToString:@"Floor Catch Miss"]) {
        marker = @"XFC";
        [self drawText:marker location:textPoint];
      // [self floorCatch:@"Increment"];
    }
    else if ([newPickUp isEqualToString:@"Truss Catch"]) {
        [self trussCatch:@"Increment"];
        [self drawSymbol:trussCatchImage location:textPoint];
    }
    else if ([newPickUp isEqualToString:@"Truss Catch Miss"]) {
        [self updateButton:_trussCatchMissButton forKey:@"trussCatchMiss" forAction:@"Increment"];
        [self drawSymbol:trussCatchMissImage location:textPoint];
    }
  
    if (drawMode == DrawDefense) {
        red = 255.0/255.0;
        green = 0.0/255.0;
        blue = 0.0/255.0;
     }
}

-(void)allianceCatchSelected:(NSString *)newPickUp {
    [partnerActionsPickerPopover dismissPopoverAnimated:YES];
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
    }
}

- (void)defenseSelected:(NSString *)newDefense {
    [self.defensePickerPopover dismissPopoverAnimated:YES];
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
    [self drawText:marker location:textPoint];
 }

-(void)drawPath:(UIPanGestureRecognizer *)gestureRecognizer {
    fieldDrawingChange = YES;
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        // NSLog(@"drawPath Began");
        lastPoint = [gestureRecognizer locationInView:fieldImage];
    }
    else {
        currentPoint = [gestureRecognizer locationInView: fieldImage];
        // NSLog(@"current point = %lf, %lf", currentPoint.x, currentPoint.y);
        //        CGContextRef context = UIGraphicsGetCurrentContext();
        UIGraphicsBeginImageContext(fieldImage.frame.size);
        [self.fieldImage.image drawInRect:CGRectMake(0, 0, fieldImage.frame.size.width, fieldImage.frame.size.height)];
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
        self.fieldImage.image = UIGraphicsGetImageFromCurrentImageContext();
        [self.fieldImage setAlpha:opacity];
        UIGraphicsEndImageContext();
        lastPoint = currentPoint;
    }
}

-(void)drawText:(NSString *) marker location:(CGPoint) point {
    fieldDrawingChange = YES;
    UIGraphicsBeginImageContext(fieldImage.frame.size);
    [self.fieldImage.image drawInRect:CGRectMake(0, 0, fieldImage.frame.size.width, fieldImage.frame.size.height)];
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
    self.fieldImage.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

-(void)drawSymbol:(UIImage *) marker location:(CGPoint) point {
    fieldDrawingChange = YES;
    UIGraphicsBeginImageContext(fieldImage.frame.size);
    [self.fieldImage.image drawInRect:CGRectMake(0, 0, fieldImage.frame.size.width, fieldImage.frame.size.height)];
//    CGContextRef myContext = UIGraphicsGetCurrentContext();
    CGRect imageRect = CGRectMake(point.x, point.y, 18, 18);
//    CGContextScaleCTM(myContext, 1.0, -1.0);
    [marker drawInRect:imageRect];
//    CGContextDrawImage(myContext, imageRect, snarf.CGImage);
    CGContextFlush(UIGraphicsGetCurrentContext());
    self.fieldImage.image = UIGraphicsGetImageFromCurrentImageContext();
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
                [self AllianceSelectionPopUp];
            }
            break;

        case OverrideTeamSelection:
            if ([passCodeAttempt isEqualToString:[prefs objectForKey:@"adminCode"]]) {
                [self TeamSelectionPopUp];
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
        if (popUp == matchResetButton) {
            [self matchReset];
        }
        else if (popUp == drawModeButton) {
            drawMode = DrawOff;
            [self drawModeSettings:drawMode];
        }
    }
}

-(void)matchReset {
    dataChange = FALSE;
    fieldDrawingChange = NO;
    currentMatch.redScore = [NSNumber numberWithInt:-1];
    currentMatch.blueScore = [NSNumber numberWithInt:-1];

    currentTeam.saved = [NSNumber numberWithFloat:0.0];
    currentTeam.savedBy = @"";
    currentTeam.received = [NSNumber numberWithFloat:0.0];
    currentTeam.results = [NSNumber numberWithBool:NO];

    currentTeam.airCatch = [NSNumber numberWithInt:0];
    currentTeam.airPasses = [NSNumber numberWithInt:0];
    currentTeam.airPassMiss = [NSNumber numberWithInt:0];
    currentTeam.assistRating = [NSNumber numberWithInt:0];
    currentTeam.autonBlocks = [NSNumber numberWithInt:0];
    currentTeam.autonHighCold = [NSNumber numberWithInt:0];
    currentTeam.autonHighHot = [NSNumber numberWithInt:0];
    currentTeam.autonHighMiss = [NSNumber numberWithInt:0];
    currentTeam.autonLowCold = [NSNumber numberWithInt:0];
    currentTeam.autonLowHot = [NSNumber numberWithInt:0];
    currentTeam.autonLowMiss = [NSNumber numberWithInt:0];
    currentTeam.autonMissed = [NSNumber numberWithInt:0];
    currentTeam.autonMobility = [NSNumber numberWithBool:YES];
    currentTeam.autonShotsMade = [NSNumber numberWithInt:0];
    currentTeam.deadOnArrival = [NSNumber numberWithBool:NO];
    currentTeam.defenseBlockRating = [NSNumber numberWithInt:0];
    currentTeam.defenseBullyRating = [NSNumber numberWithInt:0];
    currentTeam.defensiveDisruption = [NSNumber numberWithInt:0];
    currentTeam.disruptedShot = [NSNumber numberWithInt:0];
    currentTeam.driverRating = [NSNumber numberWithInt:0];
    currentTeam.floorCatch = [NSNumber numberWithInt:0];
    currentTeam.floorPasses = [NSNumber numberWithInt:0];
    currentTeam.floorPassMiss = [NSNumber numberWithInt:0];
    currentTeam.floorPickUp = [NSNumber numberWithInt:0];
    currentTeam.floorPickUpMiss = [NSNumber numberWithInt:0];
    currentTeam.fouls = [NSNumber numberWithInt:0];
    currentTeam.humanMiss = [NSNumber numberWithInt:0];
    currentTeam.humanMiss1 = [NSNumber numberWithInt:0];
    currentTeam.humanMiss2 = [NSNumber numberWithInt:0];
    currentTeam.humanMiss3 = [NSNumber numberWithInt:0];
    currentTeam.humanMiss4 = [NSNumber numberWithInt:0];
    currentTeam.humanPickUp = [NSNumber numberWithInt:0];
    currentTeam.humanPickUp1 = [NSNumber numberWithInt:0];
    currentTeam.humanPickUp2 = [NSNumber numberWithInt:0];
    currentTeam.humanPickUp3 = [NSNumber numberWithInt:0];
    currentTeam.humanPickUp4 = [NSNumber numberWithInt:0];
    currentTeam.intakeRating = [NSNumber numberWithInt:0];
    currentTeam.knockout = [NSNumber numberWithInt:0];
    currentTeam.noShow = [NSNumber numberWithBool:NO];
    currentTeam.notes = @"";
    currentTeam.otherRating = [NSNumber numberWithInt:0];
    currentTeam.passesCaught = [NSNumber numberWithInt:0];
    currentTeam.robotIntake = [NSNumber numberWithInt:0];
    currentTeam.robotIntakeMiss = [NSNumber numberWithInt:0];
    currentTeam.robotSpeed = [NSNumber numberWithInt:0];
    currentTeam.sc1 = [NSNumber numberWithInt:0];
    currentTeam.sc2 = [NSNumber numberWithInt:0];
    currentTeam.sc3 = [NSNumber numberWithInt:0];
    currentTeam.sc4 = [NSNumber numberWithInt:0];
    currentTeam.sc5 = [NSNumber numberWithInt:0];
    currentTeam.sc6 = [NSNumber numberWithInt:0];
    currentTeam.sc7 = @"";
    currentTeam.sc8 = @"";
    currentTeam.sc9 = @"";
    currentTeam.scouter = @"";
    currentTeam.teleOpBlocks = [NSNumber numberWithInt:0];
    currentTeam.teleOpHigh = [NSNumber numberWithInt:0];
    currentTeam.teleOpHighMiss = [NSNumber numberWithInt:0];
    currentTeam.teleOpLow = [NSNumber numberWithInt:0];
    currentTeam.teleOpLowMiss = [NSNumber numberWithInt:0];
    currentTeam.teleOpMissed = [NSNumber numberWithInt:0];
    currentTeam.teleOpShotsMade = [NSNumber numberWithInt:0];
    currentTeam.totalAutonShots = [NSNumber numberWithInt:0];
    currentTeam.totalPasses = [NSNumber numberWithInt:0];
    currentTeam.totalTeleOpShots = [NSNumber numberWithInt:0];
    currentTeam.trussCatch = [NSNumber numberWithInt:0];
    currentTeam.trussCatchHuman = [NSNumber numberWithInt:0];
    currentTeam.trussCatchHumanMiss = [NSNumber numberWithInt:0];
    currentTeam.trussCatchMiss = [NSNumber numberWithInt:0];
    currentTeam.trussThrow = [NSNumber numberWithInt:0];
    currentTeam.trussThrowMiss = [NSNumber numberWithInt:0];
    currentTeam.fieldDrawing.trace = nil;

    NSError *error;
    if (![_dataManager.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    [self ShowTeam:teamIndex];
}

-(IBAction)toggleGrid:(id)sender{
    if(_backgroundImage.image == [UIImage imageNamed:@"2014_field.png"]){
        _backgroundImage.image = [UIImage imageNamed:@"2014_field_grid.png"];
        [toggleGridButton setTitle:@"On" forState:UIControlStateNormal];
    }
    else{
        _backgroundImage.image = [UIImage imageNamed:@"2014_field.png"];
        [toggleGridButton setTitle:@"Off" forState:UIControlStateNormal];
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
    currentTeam.robotSpeed = [NSNumber numberWithInt:[newPick intValue]];
    [_robotSpeed setTitle:[NSString stringWithFormat:@"%d", [currentTeam.robotSpeed intValue]] forState:UIControlStateNormal];
    [self setDataChange];
}

-(void)setBlockRate:(NSString *)newPick {
    currentTeam.defenseBlockRating = [NSNumber numberWithInt:[newPick intValue]];
    [_defenseBlockRating setTitle:[NSString stringWithFormat:@"%d", [currentTeam.defenseBlockRating intValue]] forState:UIControlStateNormal];
    [self setDataChange];
}

-(void)setBullyRate:(NSString *)newPick {
    currentTeam.defenseBullyRating = [NSNumber numberWithInt:[newPick intValue]];
    [_defenseBullyRating setTitle:[NSString stringWithFormat:@"%d", [currentTeam.defenseBullyRating intValue]] forState:UIControlStateNormal];
    [self setDataChange];
}

-(void)setDriverRate:(NSString *)newPick {
    currentTeam.driverRating = [NSNumber numberWithInt:[newPick intValue]];
    [_driverRating setTitle:[NSString stringWithFormat:@"%d", [currentTeam.driverRating intValue]] forState:UIControlStateNormal];
    [self setDataChange];
}

-(void)setIntakeRate:(NSString *)newPick {
    currentTeam.intakeRating = [NSNumber numberWithInt:[newPick intValue]];
    [_intakeRatingButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.intakeRating intValue]] forState:UIControlStateNormal];
    [self setDataChange];
}

-(void)setAssistRate:(NSString *)newPick {
    NSLog(@"Hook up asssit rating");
    currentTeam.assistRating = [NSNumber numberWithInt:[newPick intValue]];
    [_assistRatingButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.assistRating intValue]] forState:UIControlStateNormal];
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

-(void)SetTextBoxDefaults:(UITextField *)currentTextField {
    currentTextField.font = [UIFont fontWithName:@"Helvetica" size:24.0];
}

-(void)SetBigButtonDefaults:(UIButton *)currentButton {
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

-(void)SetSmallButtonDefaults:(UIButton *)currentButton {
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

- (NSFetchedResultsController *)fetchedResultsController {
    // Set up the fetched results controller if needed.
    if (_fetchedResultsController == nil) {
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"MatchData" inManagedObjectContext:_dataManager.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Edit the sort key as appropriate.
        NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"matchTypeSection" ascending:YES];
        NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:typeDescriptor, numberDescriptor, nil];
        // Add the search for tournament name
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"tournamentName = %@", tournamentName];
        [fetchRequest setPredicate:pred];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController =
        [[NSFetchedResultsController alloc]
         initWithFetchRequest:fetchRequest
         managedObjectContext:_dataManager.managedObjectContext
         sectionNameKeyPath:@"matchTypeSection"
         cacheName:@"Root"];
        aFetchedResultsController.delegate = self;
        self.fetchedResultsController = aFetchedResultsController;
    }
	
	return _fetchedResultsController;
}

/**
 Returns the path to the application's Library directory.
 */
- (NSString *)applicationLibraryDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
}


@end
