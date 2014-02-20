//
//  MainScoutingPageViewController.m
// Robonauts Scouting
//
//  Created by Kris Pettinger on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainScoutingPageViewController.h"
#import "TeamDetailViewController.h"
#import "TabletSyncViewController.h"
#import "MatchData.h"
#import "TeamScore.h"
#import "FieldDrawing.h"
#import "TeamData.h"
#import "TournamentData.h"
#import "DataManager.h"
#import "MatchTypeDictionary.h"
#import "parseCSV.h"
#import "PopUpPickerViewController.h"

@implementation MainScoutingPageViewController {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    MatchTypeDictionary *matchDictionary;
    int numberMatchTypes;
    NSTimer *climbTimer;
    int timerCount;
    id popUp;


    // Auton Scoring pop up
    NSMutableArray *autonScoreList;
    UIPopoverController *autonPickerPopover;
    PopUpPickerViewController *autonPicker;
    // TeleOp Scoring pop up
    NSMutableArray *teleOpScoreList;
    UIPopoverController *teleOpPickerPopover;
    PopUpPickerViewController *teleOpPicker;
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
@synthesize driverRating;
@synthesize defenseRating;
@synthesize robotSpeed = _robotSpeed;
@synthesize climbLevel;
@synthesize notes;
@synthesize teleOpBlockButton;
@synthesize teleOpMissButton;
@synthesize teleOpHighButton;
@synthesize teleOpLowButton;
@synthesize autonBlockButton;
@synthesize autonMissButton;
@synthesize autonHighHotButton = _autonHighHotButton;
@synthesize autonHighColdButton = _autonHighColdButton;
@synthesize autonLowColdButton = _autonLowColdButton;
@synthesize autonLowHotButton = _autonLowHotButton;
@synthesize passesFloorButton;
@synthesize passesAirButton;
@synthesize humanPickUpsButton;
@synthesize human1Button;
@synthesize human2Button;
@synthesize human3Button;
@synthesize human4Button;
@synthesize floorPickUpsButton;
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
    NSLog(@"Main Scouting viewDidLoad");
    NSError *error = nil;
    if (!_dataManager) {
        _dataManager = [[DataManager alloc] init];
    }

    prefs = [NSUserDefaults standardUserDefaults];
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
    
    overrideMode = NoOverride;
    teamName.font = [UIFont fontWithName:@"Helvetica" size:24.0];
    [self SetBigButtonDefaults:prevMatch];
    [self SetBigButtonDefaults:nextMatch];
    [self SetTextBoxDefaults:matchNumber];
    [self SetBigButtonDefaults:matchType];
    [self SetBigButtonDefaults:teamNumber];
    [self SetBigButtonDefaults:teleOpMissButton];
    [self SetBigButtonDefaults:teleOpHighButton];
    [self SetBigButtonDefaults:teleOpLowButton];
    [self SetBigButtonDefaults:autonMissButton];
    [self SetBigButtonDefaults:_autonHighHotButton];
    [_autonHighHotButton setTitleColor:[UIColor redColor]forState: UIControlStateNormal];
    [self SetBigButtonDefaults:_autonHighColdButton];
    [_autonHighColdButton setTitleColor:[UIColor blueColor]forState: UIControlStateNormal];
    [self SetBigButtonDefaults:_autonLowColdButton];
    [_autonLowColdButton setTitleColor:[UIColor blueColor]forState: UIControlStateNormal];
    [self SetBigButtonDefaults:_autonLowHotButton];
    [_autonLowHotButton setTitleColor:[UIColor redColor]forState: UIControlStateNormal];
    [self SetBigButtonDefaults:passesFloorButton];
    [self SetBigButtonDefaults:passesAirButton];
    //[self SetBigButtonDefaults:bigHumanPickUpsButton];
    [self SetSmallButtonDefaults:human1Button];
    [self SetSmallButtonDefaults:human2Button];
    [self SetSmallButtonDefaults:human3Button];
    [self SetSmallButtonDefaults:human4Button];
    [self SetSmallButtonDefaults:_eraserButton];
    [self SetBigButtonDefaults:floorPickUpsButton];
    [self SetBigButtonDefaults:humanPickUpsButton];
    [self SetTextBoxDefaults:redScore];
    [self SetTextBoxDefaults:blueScore];
    matchResetButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    [self SetBigButtonDefaults:teamEdit];
    [teamEdit setTitle:@"Edit Team Info" forState:UIControlStateNormal];
    [self SetBigButtonDefaults:syncButton];
    [syncButton setTitle:@"Sync" forState:UIControlStateNormal];
    [self SetBigButtonDefaults:matchListButton];
    [matchListButton setTitle:@"Show Match List" forState:UIControlStateNormal];
    [self SetSmallButtonDefaults:toggleGridButton];
    [toggleGridButton setTitle:@"Off" forState:UIControlStateNormal];
    [self SetSmallButtonDefaults:matchResetButton];
    [self SetBigButtonDefaults:trussThrowButton];
    [self SetBigButtonDefaults:trussCatchButton];
    [self SetBigButtonDefaults:passesAirButton];
    [self SetBigButtonDefaults:autonBlockButton];
    [self SetBigButtonDefaults:teleOpBlockButton];
    
    driverRating.maximumValue = 5.0;
    driverRating.continuous = NO;
    defenseRating.maximumValue = 5.0;
    defenseRating.continuous = NO;
    _robotSpeed.maximumValue = 5.0;
    _robotSpeed.continuous = NO;

    
    [self SetTextBoxDefaults:notes];

    [self SetBigButtonDefaults:alliance];
    allianceList = [[NSMutableArray alloc] initWithObjects:@"Red 1", @"Red 2", @"Red 3", @"Blue 1", @"Blue 2", @"Blue 3", nil];

    _scoreButtonChoices = [[NSMutableArray alloc] initWithObjects:@"Reset to 0", @"Decrement", @"Increment", nil];

    // Drawing Stuff
    autonScoreList = [[NSMutableArray alloc] initWithObjects: @"High (Hot)", @"High (Cold)", @"Missed", @"Low (Hot)",@"Low (Cold)", nil];
    teleOpScoreList = [[NSMutableArray alloc] initWithObjects: @"High", @"Missed",@"Low", nil];
    defenseList = [[NSMutableArray alloc] initWithObjects:@"Passed", @"Blocked", nil];
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(floorDiskPickUp:)];
    doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    [fieldImage addGestureRecognizer:doubleTapGestureRecognizer];
    
    UITapGestureRecognizer *tapPressGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scoreDisk:)];
    tapPressGesture.numberOfTapsRequired = 1;
    [tapPressGesture requireGestureRecognizerToFail: doubleTapGestureRecognizer];
    [fieldImage addGestureRecognizer:tapPressGesture];
    
    UIPanGestureRecognizer *drawGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drawPath:)];
    [fieldImage addGestureRecognizer:drawGesture];


    brush = 3.0;
    opacity = 1.0;
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated
{
    NSLog(@"viewWillAppear");
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
        storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"dataMarker.csv"];
        fileManager = [NSFileManager defaultManager];
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

- (void)viewDidUnload
{
    [self setEraserButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillDisappear:(BOOL)animated
{
//    NSLog(@"viewWillDisappear");
    NSString *dataMarkerString;
    storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"dataMarker.csv"];
    dataMarkerString = [NSString stringWithFormat:@"%d, %d, %d\n", rowIndex, currentSectionType, teamIndex];
    [dataMarkerString writeToFile:storePath 
                       atomically:YES 
                         encoding:NSUTF8StringEncoding 
                            error:nil];
   [self CheckDataStatus];
    //    [delegate scoutingPageStatus:sectionIndex forRow:rowIndex forTeam:teamIndex];
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

-(void)CheckDataStatus {
    //    NSLog(@"Check to Save");
    //    NSLog (@"Data changed: %@", dataChange ? @"YES" : @"NO");
    if (fieldDrawingChange) {
        // Save the picture
        currentTeam.fieldDrawing.trace = [NSData dataWithData:UIImagePNGRepresentation(fieldImage.image)];
        fieldDrawingChange = NO;
        dataChange = YES;
    }
    if (dataChange) {
        currentTeam.saved = [NSNumber numberWithInt:1];
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
        case Other:
            currentSectionType = Testing;
            nextSection = [self getMatchSectionInfo:currentSectionType];
            if (nextSection == -1) { // There are no Test matches
                nextSection = [self getMatchSectionInfo:currentSection];
                currentSectionType = currentSection;
            }
            break;
        case Testing:
            currentSectionType = Other;
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
        case Other:
            currentSectionType = Testing;
            newSection = [self getMatchSectionInfo:currentSectionType];
            if (newSection == -1) { // There are no Test matches
                newSection = [self getMatchSectionInfo:currentSection];
                currentSectionType = currentSection;
            }
            break;
        case Testing:
            currentSectionType = Other;
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
    NSLog(@"Match Types = %@", matchTypeList);
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField != matchNumber && textField != redScore && textField != blueScore)  return YES;
    
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
    dataChange = YES;
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
	return YES;
}

- (IBAction) updateDriverRating:(id) sender  
{
    driverRating.value = roundf(driverRating.value);
    dataChange = YES;
    currentTeam.DriverRating = [NSNumber numberWithInt:driverRating.value];
}

- (IBAction) updateRobotSpeed:(id) sender
{
    _robotSpeed.value = roundf(_robotSpeed.value);
    dataChange = YES;
    currentTeam.robotSpeed = [NSNumber numberWithInt:_robotSpeed.value];
}

- (IBAction) updateDefenseRating:(id) sender
{
    defenseRating.value = roundf(defenseRating.value);
    dataChange = YES;
//    currentTeam.defenseRating = [NSNumber numberWithInt:defenseRating.value];
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
    else if (popUp == trussCatchButton) [self trussCatch:newPick];
    else if (popUp == humanPickUpsButton) [self humanPickUp:newPick];
    else if (popUp == floorPickUpsButton) [self floorPickUp:newPick];
    else if (popUp == passesFloorButton) [self floorPass:newPick];
    else if (popUp == passesAirButton) [self airPass:newPick];
}

- (void)valueEnteredAtPrompt:(NSString *)valueEntered {
    [self.valuePromptPopover dismissPopoverAnimated:YES];
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
    
    dataChange = YES;
}


-(void)floorPass:(NSString *)choice {
    // Update the number of missed shots
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
    
    dataChange = YES;
}


-(void)floorPickUp:(NSString *)choice {
    // Update the number of missed shots
    int score = [floorPickUpsButton.titleLabel.text intValue];
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
        [self promptForValue:floorPickUpsButton];
        return;
    }
    currentTeam.floorPickUp = [NSNumber numberWithInt:score];
    [floorPickUpsButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.floorPickUp intValue]] forState:UIControlStateNormal];
    

    dataChange = YES;
}


-(void)humanPickUp:(NSString *)choice {
    // Update the number of missed shots
    int score = [humanPickUpsButton.titleLabel.text intValue];
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
        [self promptForValue:humanPickUpsButton];
        return;
    }
    currentTeam.humanPickUp = [NSNumber numberWithInt:score];
    [humanPickUpsButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.humanPickUp intValue]] forState:UIControlStateNormal];
    
    dataChange = YES;
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
    
    dataChange = YES;
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
    
    dataChange = YES;
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
    
    dataChange = YES;
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
    
    dataChange = YES;
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

    NSLog(@"Check teleop calc");
    // Update the number of shots taken
    int total = [currentTeam.teleOpHigh intValue] + [currentTeam.teleOpLow intValue] + [currentTeam.teleOpMissed intValue];
    currentTeam.totalTeleOpShots = [NSNumber numberWithInt:total];
   
    dataChange = YES;
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
    NSLog(@"Check teleop calc");

    // Update the number of shots taken
    int total = [currentTeam.teleOpHigh intValue] + [currentTeam.teleOpLow intValue] + [currentTeam.teleOpMissed intValue];
    currentTeam.totalTeleOpShots = [NSNumber numberWithInt:total];
    
    // Update the number of shots made
    total = [currentTeam.teleOpHigh intValue] + [currentTeam.teleOpLow intValue];
    currentTeam.teleOpShots = [NSNumber numberWithInt:total];
    dataChange = YES;
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

    NSLog(@"Check teleop calc");
    // Update the number of shots taken
    int total = [currentTeam.teleOpHigh intValue] + [currentTeam.teleOpLow intValue] + [currentTeam.teleOpMissed intValue];
    currentTeam.totalTeleOpShots = [NSNumber numberWithInt:total];
    
    // Update the number of shots made
    total = [currentTeam.teleOpHigh intValue] + [currentTeam.teleOpLow intValue];
    currentTeam.teleOpShots = [NSNumber numberWithInt:total];
    dataChange = YES;
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

    NSLog(@"Check auton calc");
    // Update the number of shots taken
    int total = [currentTeam.autonHighCold intValue] + [currentTeam.autonHighHot intValue] +[currentTeam.autonLowHot intValue] + [currentTeam.autonLowCold intValue] + [currentTeam.autonMissed intValue];
    currentTeam.totalAutonShots = [NSNumber numberWithInt:total];

    dataChange = YES;
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
    NSLog(@"Check auton calc");
    
    // Update the number of shots made
    total = [currentTeam.autonHighHot intValue] + [currentTeam.autonHighCold intValue] + [currentTeam.autonLowCold intValue] +[currentTeam.autonLowHot intValue];
    currentTeam.autonShotsMade = [NSNumber numberWithInt:total];
    dataChange = YES;
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
    NSLog(@"Check auton calc");
    
    // Update the number of shots made
    total = [currentTeam.autonHighHot intValue] + [currentTeam.autonHighCold intValue] + [currentTeam.autonLowCold intValue] +[currentTeam.autonLowHot intValue];
    currentTeam.autonShotsMade = [NSNumber numberWithInt:total];
    dataChange = YES;
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
    
    NSLog(@"Check auton calc");
    // Update the number of shots made
    total = [currentTeam.autonHighHot intValue] + [currentTeam.autonHighCold intValue] + [currentTeam.autonLowCold intValue] +[currentTeam.autonLowHot intValue];
    currentTeam.autonShotsMade = [NSNumber numberWithInt:total];
    dataChange = YES;
    dataChange = YES;
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
    
    NSLog(@"Check auton calc");
    // Update the number of shots made
    total = [currentTeam.autonHighHot intValue] + [currentTeam.autonHighCold intValue] + [currentTeam.autonLowCold intValue] +[currentTeam.autonLowHot intValue];
    currentTeam.autonShotsMade = [NSNumber numberWithInt:total];
    dataChange = YES;
}

-(void)passesMade {
    // NSLog(@"Passes Made");
    int score = [passesFloorButton.titleLabel.text intValue];
    score++;
//    currentTeam.passes = [NSNumber numberWithInt:score];
//    [passesButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.passes intValue]] forState:UIControlStateNormal];
    dataChange = YES;
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
    NSLog(@"Fix auton blocks");
//    [autonLowColdButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.autonBlocks intValue]] forState:UIControlStateNormal];
    dataChange = YES;
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
        [self promptForValue:autonBlockButton];
        return;
    }
    currentTeam.teleOpBlocks= [NSNumber numberWithInt:score];
    [teleOpBlockButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.teleOpBlocks intValue]] forState:UIControlStateNormal];
    dataChange = YES;
}
/*
-(IBAction)wallPickUpsMade:(id) sender {
    UIButton * PressedButton = (UIButton*)sender;
   // NSLog(@"PickUps");
    if (drawMode == DrawAuton || drawMode == DrawDefense || drawMode == DrawTeleop) {
        int score = [humanPickUpsButton.titleLabel.text intValue];
        score++;
        currentTeam.wallPickUp = [NSNumber numberWithInt:score];
        [humanPickUpsButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.wallPickUp intValue]] forState:UIControlStateNormal];
        dataChange = YES;
        if (PressedButton == human1Button) {
            score = [human1Button.titleLabel.text intValue];
            score++;
            currentTeam.wallPickUp1 = [NSNumber numberWithInt:score];
            [human1Button setTitle:[NSString stringWithFormat:@"%d", [currentTeam.wallPickUp1 intValue]] forState:UIControlStateNormal];
        } else if (PressedButton == human2Button) {
            score = [human2Button.titleLabel.text intValue];
            score++;
            currentTeam.wallPickUp2 = [NSNumber numberWithInt:score];
            [human2Button setTitle:[NSString stringWithFormat:@"%d", [currentTeam.wallPickUp2 intValue]] forState:UIControlStateNormal];
        } else if (PressedButton == human3Button) {
            score = [human3Button.titleLabel.text intValue];
            score++;
            currentTeam.wallPickUp3 = [NSNumber numberWithInt:score];
            [human3Button setTitle:[NSString stringWithFormat:@"%d", [currentTeam.wallPickUp3 intValue]] forState:UIControlStateNormal];
        } else if (PressedButton == human4Button) {
            score = [human4Button.titleLabel.text intValue];
            score++;
            currentTeam.wallPickUp4 = [NSNumber numberWithInt:score];
            [human4Button setTitle:[NSString stringWithFormat:@"%d", [currentTeam.wallPickUp4 intValue]] forState:UIControlStateNormal];
        }
    }
}
 */

-(void)floorPickUpsMade: (NSString *)choice {
    // NSLog(@"PickUps");
    int score = [floorPickUpsButton.titleLabel.text intValue];
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
    currentTeam.floorPickUp = [NSNumber numberWithInt:score];
    [floorPickUpsButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.floorPickUp intValue]] forState:UIControlStateNormal];
    dataChange = YES;
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIButton *button = (UIButton *)sender;

    [self CheckDataStatus];
    
    if (button == teamEdit) {
        TeamDetailViewController *detailViewController = [segue destinationViewController];
        [segue.destinationViewController setDataManager:_dataManager];
        detailViewController.team = currentTeam.team;
    }
    else {
        [segue.destinationViewController setDataManager:_dataManager];
        [segue.destinationViewController setSyncOption:SyncAllSavedSince];
        [segue.destinationViewController setSyncType:SyncMatchResults];
    }
}

-(void)setTeamList {
    TeamScore *score;
    NSSortDescriptor *allianceSort = [NSSortDescriptor sortDescriptorWithKey:@"alliance" ascending:YES];
    teamData = [[currentMatch.score allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:allianceSort]];

    if (teamList == nil) {
        self.teamList = [NSMutableArray array];
        // Reds
        for (int i = 3; i < 6; i++) {
            score = [teamData objectAtIndex:i];
            [teamList addObject:[NSString stringWithFormat:@"%d", [score.team.number intValue]]];
        }
        // Blues
        for (int i = 0; i < 3; i++) {
            score = [teamData objectAtIndex:i];
            [teamList addObject:[NSString stringWithFormat:@"%d", [score.team.number intValue]]];
        }

    }
    else {
        // Reds
        for (int i = 3; i < 6; i++) {
            score = [teamData objectAtIndex:i];
            [teamList replaceObjectAtIndex:(i-3)
                           withObject:[NSString stringWithFormat:@"%d", [score.team.number intValue]]];
        }
        // Blues
       for (int i = 0; i < 3; i++) {
            score = [teamData objectAtIndex:i];
            [teamList replaceObjectAtIndex:(i+3)
                            withObject:[NSString stringWithFormat:@"%d", [score.team.number intValue]]];
       }
    }
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
    driverRating.value =  [currentTeam.driverRating floatValue];
    defenseRating.value =  [currentTeam.defenseBullyRating floatValue];
    _robotSpeed.value =  [currentTeam.robotSpeed floatValue];


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
//    [blocksButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.blocks intValue]] forState:UIControlStateNormal];
//    [passesButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.passes intValue]] forState:UIControlStateNormal];
    [humanPickUpsButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.wallPickUp intValue]] forState:UIControlStateNormal];
    [human1Button setTitle:[NSString stringWithFormat:@"%d", [currentTeam.wallPickUp1 intValue]] forState:UIControlStateNormal];
    [human2Button setTitle:[NSString stringWithFormat:@"%d", [currentTeam.wallPickUp2 intValue]] forState:UIControlStateNormal];
    [human3Button setTitle:[NSString stringWithFormat:@"%d", [currentTeam.wallPickUp3 intValue]] forState:UIControlStateNormal];
    [human4Button setTitle:[NSString stringWithFormat:@"%d", [currentTeam.wallPickUp4 intValue]] forState:UIControlStateNormal];
    [floorPickUpsButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.floorPickUp intValue]] forState:UIControlStateNormal];
    [passesFloorButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.floorPasses intValue]] forState:UIControlStateNormal];
    [passesAirButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.airPasses intValue]] forState:UIControlStateNormal];
    [trussCatchButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.trussCatch intValue]] forState:UIControlStateNormal];
    [trussThrowButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.trussThrow intValue]] forState:UIControlStateNormal];
    [autonBlockButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.autonBlocks intValue]] forState:UIControlStateNormal];
    [teleOpBlockButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.teleOpBlocks intValue]] forState:UIControlStateNormal];
    
    // NSLog(@"Load the Picture");
    // Check the database to see if this team and match have a drawing already
    if (currentTeam.fieldDrawing.trace) {
        [fieldImage setImage:[UIImage imageWithData:currentTeam.fieldDrawing.trace]];
        drawMode = DrawLock;
    }
    else {
        // NSLog(@"Field Drawing= %@", currentTeam.fieldDrawing);
        [fieldImage setImage:[UIImage imageNamed:@"2014_field.png"]];
        drawMode = DrawOff;
    }
    [self drawModeSettings:drawMode];
}

-(TeamScore *)GetTeam:(NSUInteger)currentTeamIndex {
    switch (currentTeamIndex) {
        case 0: return [teamData objectAtIndex:3];  // Red 1
        case 1: return [teamData objectAtIndex:4];  // Red 2
        case 2: return [teamData objectAtIndex:5];  // Red 3
        case 3: return [teamData objectAtIndex:0];  // Blue 1
        case 4: return [teamData objectAtIndex:1];  // Blue 2
        case 5: return [teamData objectAtIndex:2];  // Blue 3
    }    
    return nil;
}

-(void)floorDiskPickUp:(UITapGestureRecognizer *)gestureRecognizer {
    fieldDrawingChange = YES;
    // NSLog(@"floorDiskPickUp");
    NSString *marker = @"O";
    currentPoint = [gestureRecognizer locationInView:fieldImage];
    [self drawText:marker location:currentPoint];
    [self floorPickUpsMade];
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

-(void)drawPath:(UIPanGestureRecognizer *)gestureRecognizer {
    fieldDrawingChange = YES;
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        // NSLog(@"drawPath Began");
        lastPoint = [gestureRecognizer locationInView:fieldImage];
    }
    else {
        currentPoint = [gestureRecognizer locationInView: fieldImage];
        // NSLog(@"current point = %lf, %lf", currentPoint.x, currentPoint.y);
        UIGraphicsBeginImageContext(fieldImage.frame.size);
        [self.fieldImage.image drawInRect:CGRectMake(0, 0, fieldImage.frame.size.width, fieldImage.frame.size.height)];
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush );
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1.0);
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
        
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        self.fieldImage.image = UIGraphicsGetImageFromCurrentImageContext();
        [self.fieldImage setAlpha:opacity];
        UIGraphicsEndImageContext();        
        lastPoint = currentPoint;
    }
}

- (IBAction)eraserPressed:(id)sender {
    red = 255.0/255.0;
    green = 255.0/255.0;
    blue = 255.0/255.0;
    opacity = 1.0;
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

-(CGPoint)defensePopOverLocation:(CGPoint)location; {
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
            drawMode = DrawAuton;
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
            overrideMode = OverrideDrawLock;
            [self checkOverrideCode:drawModeButton];
            break;
        default:
            NSLog(@"Bad things have happened in drawModeChange");
    }
    [self drawModeSettings:drawMode];
}

- (IBAction)eraserChosen:(id)sender {
}

-(void) drawModeSettings:(DrawingMode) mode {
    switch (mode) {
        case DrawOff:
            [drawModeButton setBackgroundImage:[UIImage imageNamed:@"Small White Button.jpg"] forState:UIControlStateNormal];
            [drawModeButton setTitle:@"Off" forState:UIControlStateNormal];
            [drawModeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            fieldImage.userInteractionEnabled = FALSE;
            break;
        case DrawAuton:
            red = 255.0/255.0;
            green = 190.0/255.0;
            blue = 0.0/255.0;
            [drawModeButton setBackgroundImage:[UIImage imageNamed:@"Small Green Button.jpg"] forState:UIControlStateNormal];
            [drawModeButton setTitle:@"Auton" forState:UIControlStateNormal];
            [drawModeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            fieldImage.userInteractionEnabled = TRUE;
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
            fieldImage.userInteractionEnabled = FALSE;
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
            }
            NSLog(@"score selection = %@", [autonScoreList objectAtIndex:i]);
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
    for (int i = 0 ; i < [teleOpScoreList count] ; i++) {
        if ([newScore isEqualToString:[teleOpScoreList objectAtIndex:i]]) {
            switch (i) {
                case 0:
                    marker = @"H";
                    [self teleOpHigh:@"Increment"];
                    break;
                case 1:
                    marker = @"X";
                    [self teleOpMiss:@"Increment"];
                    break;
                case 2:
                    marker = @"L";
                    [self teleOpLow:@"Increment"];
                    break;
            }
            NSLog(@"score selection = %@", [autonScoreList objectAtIndex:i]);
            break;
        }
    }
    [self drawText:marker location:textPoint];
}

- (void)defenseSelected:(NSString *)newDefense {
//    [self.defensePickerPopover dismissPopoverAnimated:YES];
    NSString *marker;
    CGPoint textPoint;
    textPoint.x = currentPoint.x;
    textPoint.y = currentPoint.y + popCounter*16;
    popCounter++;
    for (int i = 0 ; i < [defenseList count] ; i++) {
        if ([newDefense isEqualToString:[defenseList objectAtIndex:i]]) {
            switch (i) {
                case 0:
                    marker = @"P";
                    [self passesMade];
                    break;
                case 1:
                    marker = @"B";
                    //[self teleOpBlockedShots];
                    break;
                default:
                    break;
            }
            
            // NSLog(@"defense selection = %@", [defenseList objectAtIndex:i]);
            break;
        }
    }
    [self drawText:marker location:textPoint];
 }

-(void)drawText:(NSString *) marker location:(CGPoint) point {
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

-(IBAction)matchResetRequest:(id) sender {
    NSLog(@"matchReset");
    overrideMode = OverrideMatchReset;
    [self checkOverrideCode:matchResetButton];
    // Different message for saved, locked, synced
 }

-(void)matchReset {
    currentMatch.redScore = [NSNumber numberWithInt:-1];
    currentMatch.blueScore = [NSNumber numberWithInt:-1];
    currentTeam.autonHighHot = [NSNumber numberWithInt:0];
    currentTeam.autonHighCold = [NSNumber numberWithInt:0];
    currentTeam.autonLowHot = [NSNumber numberWithInt:0];
    currentTeam.autonLowCold = [NSNumber numberWithInt:0];
    currentTeam.autonMissed = [NSNumber numberWithInt:0];
    currentTeam.autonShotsMade = [NSNumber numberWithInt:0];
    currentTeam.totalAutonShots = [NSNumber numberWithInt:0];
    currentTeam.teleOpHigh = [NSNumber numberWithInt:0];
    currentTeam.teleOpLow = [NSNumber numberWithInt:0];
    currentTeam.teleOpMissed = [NSNumber numberWithInt:0];
    currentTeam.teleOpShots = [NSNumber numberWithInt:0];
    currentTeam.totalTeleOpShots = [NSNumber numberWithInt:0];
    currentTeam.autonBlocks = [NSNumber numberWithInt:0];
    currentTeam.teleOpBlocks = [NSNumber numberWithInt:0];
//    currentTeam.wallPickUp = [NSNumber numberWithInt:0];
//    currentTeam.wallPickUp1 = [NSNumber numberWithInt:0];
//    currentTeam.wallPickUp2 = [NSNumber numberWithInt:0];
//    currentTeam.wallPickUp3 = [NSNumber numberWithInt:0];
//    currentTeam.wallPickUp4 = [NSNumber numberWithInt:0];
    currentTeam.floorPickUp = [NSNumber numberWithInt:0];
    currentTeam.driverRating = [NSNumber numberWithInt:0];
    currentTeam.robotSpeed = [NSNumber numberWithInt:0];
    currentTeam.notes = @"";
    currentTeam.saved = [NSNumber numberWithInt:0];
    currentTeam.fieldDrawing = nil;
    currentTeam.defenseBullyRating = [NSNumber numberWithInt:0];
    currentTeam.floorPasses = [NSNumber numberWithInt:0];
    currentTeam.trussCatch = [NSNumber numberWithInt:0];
    currentTeam.trussThrow = [NSNumber numberWithInt:0];
    currentTeam.airPasses = [NSNumber numberWithInt:0];
    currentTeam.autonBlocks = [NSNumber numberWithInt:0];
    currentTeam.teleOpBlocks = [NSNumber numberWithInt:0];
    [self ShowTeam:teamIndex];   
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
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

-(IBAction)toggleGrid:(id)sender{
    if(fieldImage.image == [UIImage imageNamed:@"2014_field.png"]){
        fieldImage.image = [UIImage imageNamed:@"2014_field_grid.png"];
        [toggleGridButton setTitle:@"On" forState:UIControlStateNormal];
    }
    else{
        fieldImage.image = [UIImage imageNamed:@"2014_field.png"];
        [toggleGridButton setTitle:@"Off" forState:UIControlStateNormal];
    }
}


@end
