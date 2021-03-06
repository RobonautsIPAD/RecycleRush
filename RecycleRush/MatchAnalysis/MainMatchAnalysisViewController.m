//
//  MasonPageViewController.m
// Robonauts Scouting
//
//  Created by FRC on 3/21/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "MainMatchAnalysisViewController.h"
#import "UIDefaults.h"
#import "TournamentData.h"
#import "DataManager.h"
#import "DataConvenienceMethods.h"
#import "TeamAccessors.h"
#import "MatchData.h"
#import "MatchAccessors.h"
#import "MatchUtilities.h"
#import "TeamData.h"
#import "TeamScore.h"
#import "MatchFlow.h"
#import "CalculateTeamStats.h"
#import "TeamDetailViewController.h"
#import "SketchSpaceViewController.h"
#import "TeamSummaryViewController.h"
#import "FieldDrawingViewController.h"
#import "SpreadsheetViewController.h"
#import "FileIOMethods.h"
#import "LNNumberpad.h"
#import "MatchAccessors.h"

@interface MainMatchAnalysisViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *homeButton;
@property (nonatomic, weak) IBOutlet UIButton *prevMatch;
@property (nonatomic, weak) IBOutlet UIButton *nextMatch;
@property (nonatomic, weak) IBOutlet UIButton *ourPrevMatchButton;
@property (nonatomic, weak) IBOutlet UIButton *ourNextMatchButton;
@property (nonatomic, weak) IBOutlet UITextField *matchNumber;
@property (nonatomic, weak) IBOutlet UIButton *matchType;
@property (nonatomic, strong) NSMutableArray *teamData;
@property (weak, nonatomic) IBOutlet UIButton *redSketchButton;
@property (weak, nonatomic) IBOutlet UIButton *blueSketchButton;
@property (weak, nonatomic) IBOutlet UIButton *spreadsheetButton;
@property (weak, nonatomic) IBOutlet UIButton *coverSheetButton;

@property (nonatomic, weak) IBOutlet UITableView *teamInfo;
@property (nonatomic, strong) UIView *teamHeader;
@property (nonatomic, weak) IBOutlet UILabel *red1Team;
@property (nonatomic, weak) IBOutlet UILabel *red2Team;
@property (nonatomic, weak) IBOutlet UILabel *red3Team;
@property (nonatomic, weak) IBOutlet UILabel *blue1Team;
@property (nonatomic, weak) IBOutlet UILabel *blue2Team;
@property (nonatomic, weak) IBOutlet UILabel *blue3Team;

@property (nonatomic, weak) IBOutlet UITableView *red1Table;
@property (nonatomic, weak) IBOutlet UITableView *red2Table;
@property (nonatomic, weak) IBOutlet UITableView *red3Table;
@property (nonatomic, weak) IBOutlet UITableView *blue1Table;
@property (nonatomic, weak) IBOutlet UITableView *blue2Table;
@property (nonatomic, weak) IBOutlet UITableView *blue3Table;

@end

@implementation MainMatchAnalysisViewController {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSString *previousTournament;
    NSMutableDictionary *settingsDictionary;
    NSArray *outputDictionary;
    NSUInteger numberMatchTypes;
    NSMutableArray *teamList;
    NSUInteger sectionIndex;
    NSUInteger rowIndex;
    MatchData *currentMatch;
    NSArray *scoreList;
    MatchUtilities *matchUtilities;
    CalculateTeamStats *teamStatsPackage;
    NSDictionary *matchDictionary;
    NSDictionary *allianceDictionary;
    NSArray *matchTypeList;
    PopUpPickerViewController *matchTypePicker;
    UIPopoverController *matchTypePickerPopover;
    id popUp;

    int ourCurrentIndex;
    NSArray *red1Scores;
    NSArray *red2Scores;
    NSArray *red3Scores;
    NSArray *blue1Scores;
    NSArray *blue2Scores;
    NSArray *blue3Scores;
    NSMutableArray *teamStats;
    NSMutableArray *spreadsheetData;
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
    // can be reached 2 ways, one will load specific match info the other won't
    // For the one that won't, datamanager should be the only instance variable with a value
        // In this case, the saved match number info in the settings will be used to set the initial match
        // labels for our next and prev should change to say 118
    // For the one that does, a match number and type and a team number should be passed in for the
        // the initial match. Label out next and prev should change to show team number next and prev
    [super viewDidLoad];
    NSError *error = nil;
    if (!_dataManager) {
        _dataManager = [[DataManager alloc] init];
    }
    
    prefs = [NSUserDefaults standardUserDefaults];
    tournamentName = [prefs objectForKey:@"tournament"];
    if (tournamentName) {
        self.title =  [NSString stringWithFormat:@"%@ Match Analysis", tournamentName];
    }
    else {
        self.title = @"Match Analysis";
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
    
    [_ourPrevMatchButton setTitle:[NSString stringWithFormat:@"%@ Prev", _teamNumber] forState:UIControlStateNormal];
    [_ourNextMatchButton setTitle:[NSString stringWithFormat:@"%@ Next", _teamNumber] forState:UIControlStateNormal];

    [self setTableDefaults];
    [self createStatsTableHeader];
    [UIDefaults setTextBoxDefaults:_matchNumber];
    [UIDefaults setBigButtonDefaults:_matchType withFontSize:nil];
    [UIDefaults setBigButtonDefaults:_prevMatch withFontSize:nil];
    [UIDefaults setBigButtonDefaults:_nextMatch withFontSize:nil];
    [UIDefaults setBigButtonDefaults:_ourPrevMatchButton withFontSize:nil];
    [UIDefaults setBigButtonDefaults:_ourNextMatchButton withFontSize:nil];
    [UIDefaults setBigButtonDefaults:_redSketchButton withFontSize:nil];
    [UIDefaults setBigButtonDefaults:_blueSketchButton withFontSize:nil];
    [UIDefaults setBigButtonDefaults:_spreadsheetButton withFontSize:nil];
    [UIDefaults setBigButtonDefaults:_coverSheetButton withFontSize:nil];
     _matchNumber.inputView  = [LNNumberpad defaultLNNumberpad];

    matchUtilities = [[MatchUtilities alloc] init:_dataManager];
    allianceDictionary = _dataManager.allianceDictionary;
    matchDictionary = _dataManager.matchTypeDictionary;
    matchTypeList = [self getMatchTypeList];
    teamStatsPackage = [[CalculateTeamStats alloc] init:_dataManager];
    [self setValidMatchNumber:_initialMatchNumber forType:_initialMatchType];
    
    numberMatchTypes = [matchTypeList count];
    teamList = [[NSMutableArray alloc] init];
    teamStats = [[NSMutableArray alloc] init];
    currentMatch = [self getCurrentMatch];
    [self showMatch];
}

-(NSMutableArray *)getMatchTypeList {
    NSMutableArray *matchTypes = [[NSMutableArray alloc] init];
    NSString *sectionName;
    for (int i=0; i < [[_fetchedResultsController sections] count]; i++) {
        sectionName = [[[_fetchedResultsController sections] objectAtIndex:i] name];
        // NSLog(@"Section = %@", sectionName);
        [matchTypes addObject:[MatchAccessors getMatchTypeString:[NSNumber numberWithInt:[sectionName intValue]] fromDictionary:matchDictionary]];
    }
    // NSLog(@"match types = %@", matchTypes);
    return matchTypes;
}

-(NSUInteger)getNumberOfMatches:(NSUInteger)section {
    if ([[_fetchedResultsController sections] count]) {
        return [[[[_fetchedResultsController sections] objectAtIndex:section] objects] count];
    }
    else return 0;
}

-(void)setValidMatchNumber:(NSNumber *)matchNumber forType:(NSNumber *)matchType {
    if (matchNumber && matchType) {
        // Find the sectionIndex of the match type first
        NSString *typeString = [MatchAccessors getMatchTypeString:matchType fromDictionary:matchDictionary];
        sectionIndex = [matchTypeList indexOfObject:typeString];
        if (sectionIndex == NSNotFound) {
            // If that section does not exist, go to the first section and match
            sectionIndex = 0;
            rowIndex = 0;
        }
        else {
            // Process the match number
            rowIndex = [self findMatchNumber:matchNumber];
            if (rowIndex == NSNotFound) rowIndex = 0;
        }
    }
    else {
        if (sectionIndex > [[_fetchedResultsController sections] count]) {
            sectionIndex = 0;
            rowIndex = 0;
        }
        else {
            NSUInteger maxRow = [self getNumberOfMatches:sectionIndex];
            if (rowIndex > maxRow) rowIndex = maxRow - 1;
        }
    }
}


-(NSInteger)findMatchNumber:(NSNumber *)matchNumber {
    // NSLog(@"findMatchNumber");
    for(int i = 0; i < [self getNumberOfMatches:sectionIndex]; i++){
        NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:sectionIndex];
        MatchData *match = [_fetchedResultsController objectAtIndexPath:index];
        if([match.number intValue] == [matchNumber intValue]) {
            return i;
        }
    }
    return NSNotFound;
}
- (IBAction)goHome:(id)sender {
    UINavigationController * navigationController = self.navigationController;
    [navigationController popToRootViewControllerAnimated:YES];
}

-(IBAction)matchNumberChanged {
    // NSLog(@"MatchNumberChanged");
    if ([_matchNumber.text isEqualToString:@""]) {
        _matchNumber.text = [NSString stringWithFormat:@"%d", [currentMatch.number intValue]];
        return;
    }
    int matchField = [_matchNumber.text intValue];
    int nmatches =  [self getNumberOfMatches:sectionIndex];
    
    if (matchField > nmatches) { /* Ooops, not that many matches */
        // For now, just change the match field to the last match in the section
        matchField = nmatches;
        rowIndex = matchField-1;
    }
    else {
        NSInteger newIndex = [self findMatchNumber:[NSNumber numberWithInt:[_matchNumber.text intValue]]];
        if (newIndex == NSNotFound) {
            _matchNumber.text = [NSString stringWithFormat:@"%d", [currentMatch.number intValue]];
        }
        else {
            rowIndex = newIndex;
        }
    }
    
    currentMatch = [self getCurrentMatch];
    [self showMatch];
    
}

-(IBAction)matchTypeSelectionChanged:(id)sender {
    //    NSLog(@"matchTypeSelectionChanged");
    popUp = _matchType;
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
    [matchTypePickerPopover presentPopoverFromRect:_matchType.bounds inView:_matchType
                          permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)pickerSelected:(NSString *)newPick {
    // The user has made a selection on one of the pop-ups. Dismiss the pop-up
    //  and call the correct method to change the right field.
    // NSLog(@"new pick = %@", newPick);
    if (popUp == _matchType) {
        [matchTypePickerPopover dismissPopoverAnimated:YES];

        NSUInteger currectSection = sectionIndex;
        sectionIndex = [matchTypeList indexOfObject:newPick];
        if (sectionIndex == NSNotFound) sectionIndex = currectSection;
        [self setValidMatchNumber:Nil forType:Nil];
        currentMatch = [self getCurrentMatch];
        [self showMatch];
    }
    [popUp setTitle:newPick forState:UIControlStateNormal];
}

// Move through the rounds
-(IBAction)prevButton {
    if (rowIndex > 0) rowIndex--;
    else {
        sectionIndex = [self getPreviousSection:currentMatch.matchType];
        rowIndex =  [[[[_fetchedResultsController sections] objectAtIndex:sectionIndex] objects] count]-1;
    }
    currentMatch = [self getCurrentMatch];
   [self showMatch];
}

-(IBAction)nextButton {
    NSUInteger nrows;
    nrows =  [self getNumberOfMatches:sectionIndex];
    if (rowIndex < (nrows-1)) rowIndex++;
    else {
        rowIndex = 0;
        sectionIndex = [self getNextSection:currentMatch.matchType];
    }
    currentMatch = [self getCurrentMatch];
    [self showMatch];
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

- (IBAction)ourPreviousMatch:(id)sender {
    NSPredicate *pred =  [NSPredicate predicateWithFormat:@"teamNumber = %@", _teamNumber];
    NSUInteger start = rowIndex-1;
    NSUInteger nMatches = [self getNumberOfMatches:sectionIndex];
    BOOL found = FALSE;
    for (int j=0; j<2; j++) {
        for(NSUInteger i=start; i > 0; i--) {
            NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:sectionIndex];
            MatchData *match = [_fetchedResultsController objectAtIndexPath:index];
            NSArray *scores = [[match.score allObjects] filteredArrayUsingPredicate:pred];
            if (scores && [scores count]) {
                rowIndex = i;
                currentMatch = [self getCurrentMatch];
                [self showMatch];
                found = TRUE;
                break;
            }
        }
        if (found) break;
        else start = nMatches-1;
    }
}


- (IBAction)ourNextMatch:(id)sender {
    NSPredicate *pred =  [NSPredicate predicateWithFormat:@"teamNumber = %@", _teamNumber];
    NSUInteger start = rowIndex + 1;
    NSUInteger nMatches = [self getNumberOfMatches:sectionIndex];
    BOOL found = FALSE;
    for (int j=0; j<2; j++) {
        for(NSUInteger i=start; i < nMatches; i++) {
            NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:sectionIndex];
            MatchData *match = [_fetchedResultsController objectAtIndexPath:index];
            NSArray *scores = [[match.score allObjects] filteredArrayUsingPredicate:pred];
            if (scores && [scores count]) {
                rowIndex = i;
                currentMatch = [self getCurrentMatch];
                [self showMatch];
                found = TRUE;
                break;
            }
        }
        if (found) break;
        else start = 0;
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

-(void)showMatch {
    [self setTeamList];
    [_matchType setTitle:[MatchAccessors getMatchTypeString:currentMatch.matchType fromDictionary:matchDictionary] forState:UIControlStateNormal];
    _matchNumber.text = [NSString stringWithFormat:@"%@", currentMatch.number];
}

-(void)setTeamList {
    NSSortDescriptor *allianceSort = [NSSortDescriptor sortDescriptorWithKey:@"allianceStation" ascending:YES];
    scoreList = [[currentMatch.score allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:allianceSort]];
    [teamList removeAllObjects];
    [teamStats removeAllObjects];
    for (TeamScore *score in scoreList) {
        TeamData *team = [TeamAccessors getTeam:score.teamNumber inTournament:tournamentName fromDataManager:_dataManager];
        [teamList addObject:team];
        NSMutableDictionary *stats = [teamStatsPackage calculateMasonStats:team forTournament:tournamentName];
        [teamStats addObject:stats];
    }
    [self.teamInfo reloadData];
    [self setTeamMatches];
}

-(NSNumber *)getTeamNumber:(NSString *)allianceString {
    // current match
    // make pred for alliance
    // get the team number from alliance
    if (!teamList || ![teamList count]) return Nil;
    NSNumber *teamNumber = [matchUtilities getTeamFromList:scoreList forAllianceStation:[MatchAccessors getAllianceStation:allianceString fromDictionary:allianceDictionary]];
    return teamNumber;
}

-(NSArray *)getMatchList:(NSNumber *)team {
 //   NSArray *scores = [DataConvenienceMethods getMatchListForTeam:team forTournament:tournamentName fromContext:_dataManager.managedObjectContext];
    return nil;//scores;
}

-(void)setTeamMatches {
    // Red 1
    NSNumber *team = [self getTeamNumber:@"Red 1"];
    _red1Team.text = team ? [NSString stringWithFormat:@"%d", [team intValue]]: @"Red 1";
    red1Scores = [self getMatchList:team];

    team = [self getTeamNumber:@"Red 2"];
    _red2Team.text = team ? [NSString stringWithFormat:@"%d", [team intValue]]: @"Red 2";
    red2Scores = [self getMatchList:team];

    team = [self getTeamNumber:@"Red 3"];
    _red3Team.text = team ? [NSString stringWithFormat:@"%d", [team intValue]]: @"Red 3";
    red3Scores = [self getMatchList:team];

    team = [self getTeamNumber:@"Blue 1"];
    _blue1Team.text = team ? [NSString stringWithFormat:@"%d", [team intValue]]: @"Blue 1";
    blue1Scores = [self getMatchList:team];

    team = [self getTeamNumber:@"Blue 2"];
    _blue2Team.text = team ? [NSString stringWithFormat:@"%d", [team intValue]]: @"Blue 2";
    blue2Scores = [self getMatchList:team];

    team = [self getTeamNumber:@"Blue 3"];
    _blue3Team.text = team ? [NSString stringWithFormat:@"%d", [team intValue]]: @"Blue 3";
    blue3Scores = [self getMatchList:team];

    [self.red1Table reloadData];
    [self.red2Table reloadData];
    [self.red3Table reloadData];
    [self.blue1Table reloadData];
    [self.blue2Table reloadData];
    [self.blue3Table reloadData];
}

-(NSMutableArray *)getScoreList:(TeamData *)team {
    NSArray *allMatches;// = [team.match allObjects];
    NSMutableArray *scores = [allMatches mutableCopy];

    NSPredicate *pred = [NSPredicate predicateWithFormat:@"tournamentName = %@", tournamentName];
    [scores filterUsingPredicate:pred];

    NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"match.matchTypeSection" ascending:YES];
    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"match.number" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:typeDescriptor, numberDescriptor, nil];

    [scores sortUsingDescriptors:sortDescriptors];
    return scores;
}

-(void)createSpreadsheetData {
    int i = 0;
    NSMutableDictionary *stats = [teamStats objectAtIndex:0];
    NSArray *headers = [NSArray arrayWithObjects:@"Team Number",
                          @"Ave Totes",
                          @"Ave Cans",
                          @"Ave Litter",
                          @"Ave CanDom", nil];
    spreadsheetData = [[NSMutableArray alloc] init];
    [spreadsheetData addObject:headers];
    for (TeamData *team in teamList) {
        stats = [teamStats objectAtIndex:i];
        NSString *teamNumber = [NSString stringWithFormat:@"%@", team.number];
        NSString *column2 = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"totalTotesScored"] objectForKey:@"average"] floatValue]];
        NSString *column3 = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"totalCansScored"] objectForKey:@"average"] floatValue]];
        NSString *column4 = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"litterInCan"] objectForKey:@"average"] floatValue]];
        NSString *column5 = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"autonCansFromStep"] objectForKey:@"average"] floatValue]];
        NSArray *row = [NSArray arrayWithObjects:teamNumber, column2, column3, column4, column5, nil];
        i++;
        [spreadsheetData addObject:row];
    }
}

-(void)createStatsTableHeader {
    _teamHeader = [[UIView alloc] initWithFrame:CGRectMake(0,0,768,50)];
    _teamHeader.backgroundColor = [UIColor lightGrayColor];
    _teamHeader.opaque = YES;
    
	UILabel *teamLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 50)];
	teamLabel.text = @"Team";
    teamLabel.backgroundColor = [UIColor clearColor];
    [_teamHeader addSubview:teamLabel];
    
    for (NSDictionary *column in outputDictionary) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake([[column objectForKey:@"location"] floatValue], 0, 200, 50)];
        label.text = [column objectForKey:@"header"];
        label.backgroundColor = [UIColor clearColor];
        [_teamHeader addSubview:label];
    }
}
//        detailViewController.team = [teamList objectAtIndex:indexPath.row];

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setDataManager:_dataManager];
    if ([segue.identifier isEqualToString:@"TeamSummary"]) {
        NSIndexPath *indexPath = [self.teamInfo indexPathForCell:sender];
        TeamSummaryViewController *detailViewController = [segue destinationViewController];
        // NSLog(@"Team = %@", [_teamList objectAtIndex:indexPath.row]);
        detailViewController.initialTeam = [teamList objectAtIndex:indexPath.row];
        detailViewController.teamList = teamList;
        detailViewController.matchNumber = currentMatch.number;
        [_teamInfo deselectRowAtIndexPath:indexPath animated:YES];
    }
    else if ([segue.identifier isEqualToString:@"RedSketch"]) {
        [segue.destinationViewController setAllianceString:@"Red"];
       // NSNumber *teamNumber = [matchUtilities getTeamFromList:scoreList forAllianceStation:[MatchAccessors getAllianceStation:@"Red 1" fromDictionary:allianceDictionary]];
      //  [segue.destinationViewController setAlliance1:[NSString stringWithFormat:@"%d", [teamNumber intValue]]];
       // teamNumber = [matchUtilities getTeamFromList:scoreList forAllianceStation:[MatchAccessors getAllianceStation:@"Red 2" fromDictionary:allianceDictionary]];
      //  [segue.destinationViewController setAlliance2:[NSString stringWithFormat:@"%d", [teamNumber intValue]]];
      //  teamNumber = [matchUtilities getTeamFromList:scoreList forAllianceStation:[MatchAccessors getAllianceStation:@"Red 3" fromDictionary:allianceDictionary]];
      //  [segue.destinationViewController setAlliance3:[NSString stringWithFormat:@"%d", [teamNumber intValue]]];
   }
    else if ([segue.identifier isEqualToString:@"BlueSketch"]) {
        [segue.destinationViewController setAllianceString:@"Blue"];
       // NSNumber *teamNumber = [matchUtilities getTeamFromList:scoreList forAllianceStation:[MatchAccessors getAllianceStation:@"Blue 1" fromDictionary:allianceDictionary]];
      //  [segue.destinationViewController setAlliance1:[NSString stringWithFormat:@"%d", [teamNumber intValue]]];
      //  teamNumber = [matchUtilities getTeamFromList:scoreList forAllianceStation:[MatchAccessors getAllianceStation:@"Blue 2" fromDictionary:allianceDictionary]];
       // [segue.destinationViewController setAlliance2:[NSString stringWithFormat:@"%d", [teamNumber intValue]]];
    //    teamNumber = [matchUtilities getTeamFromList:scoreList forAllianceStation:[MatchAccessors getAllianceStation:@"Blue 3" fromDictionary:allianceDictionary]];
    //    [segue.destinationViewController setAlliance3:[NSString stringWithFormat:@"%d", [teamNumber intValue]]];
    }
    else if ([segue.identifier isEqualToString:@"RedSketchHome"]) {
        [segue.destinationViewController setAllianceString:@"Red"];
    }
    else if ([segue.identifier isEqualToString:@"BlueSketchHome"]) {
        [segue.destinationViewController setAllianceString:@"Blue"];
    }
    else if ([segue.identifier isEqualToString:@"CoverSheet"]) {
        [segue.destinationViewController setTeamList:teamList];
    }
    else if ([segue.identifier isEqualToString:@"Spreadsheet"]) {
        [self createSpreadsheetData];
        [segue.destinationViewController setDataRows:spreadsheetData];
    }
    else {
        NSIndexPath *indexPath;
        if ([segue.identifier isEqualToString:@"Red1"]) {
            indexPath = [self.red1Table indexPathForCell:sender];
            [_red1Table deselectRowAtIndexPath:indexPath animated:YES];
            [segue.destinationViewController setTeamScores:red1Scores];
        }
        else if ([segue.identifier isEqualToString:@"Red2"]) {
            indexPath = [self.red2Table indexPathForCell:sender];
            [_red2Table deselectRowAtIndexPath:indexPath animated:YES];
            [segue.destinationViewController setTeamScores:red2Scores];
        }
        else if ([segue.identifier isEqualToString:@"Red3"]) {
            indexPath = [self.red3Table indexPathForCell:sender];
            [_red3Table deselectRowAtIndexPath:indexPath animated:YES];
            [segue.destinationViewController setTeamScores:red3Scores];
        }
        else if ([segue.identifier isEqualToString:@"Blue1"]) {
            indexPath = [self.blue1Table indexPathForCell:sender];
            [_blue1Table deselectRowAtIndexPath:indexPath animated:YES];
            [segue.destinationViewController setTeamScores:blue1Scores];
        }
        else if ([segue.identifier isEqualToString:@"Blue2"]) {
            indexPath = [self.blue2Table indexPathForCell:sender];
            [_blue2Table deselectRowAtIndexPath:indexPath animated:YES];
            [segue.destinationViewController setTeamScores:blue2Scores];
        }
        else if ([segue.identifier isEqualToString:@"Blue3"]) {
            indexPath = [self.blue3Table indexPathForCell:sender];
            [_blue3Table deselectRowAtIndexPath:indexPath animated:YES];
            [segue.destinationViewController setTeamScores:blue3Scores];
        }
        [segue.destinationViewController setStartingIndex:indexPath.row];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self saveSettings];
    //    NSLog(@"viewWillDisappear");
}

-(void)loadSettings {
    NSString *plistPath = [[FileIOMethods applicationLibraryDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"Preferences/AnalysisPage.plist"]];
    settingsDictionary = [[FileIOMethods getDictionaryFromPListFile:plistPath] mutableCopy];
    if (settingsDictionary) previousTournament = [settingsDictionary valueForKey:@"Tournament"];
    if (!_teamNumber) _teamNumber = [NSNumber numberWithInt:118];
    sectionIndex = 0;
    rowIndex = 0;
    if ([tournamentName isEqualToString:previousTournament]) {
        if (!_initialMatchType || !_initialMatchNumber) {
            sectionIndex = [[settingsDictionary valueForKey:@"Section Index"] unsignedLongValue];
            rowIndex = [[settingsDictionary valueForKey:@"Row Index"] unsignedLongValue];
        }
    }
    plistPath = [[NSBundle mainBundle] pathForResource:@"AnalysisPage" ofType:@"plist"];
    outputDictionary = [[NSArray alloc] initWithContentsOfFile:plistPath];
}

-(void)saveSettings {
    if (!settingsDictionary) {
        settingsDictionary = [[NSMutableDictionary alloc] init];
    }
    [settingsDictionary setObject:tournamentName forKey:@"Tournament"];
    [settingsDictionary setObject:[NSNumber numberWithUnsignedLong:sectionIndex] forKey:@"Section Index"];
    [settingsDictionary setObject:[NSNumber numberWithUnsignedLong:rowIndex] forKey:@"Row Index"];

    NSString *plistPath = [[FileIOMethods applicationLibraryDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"Preferences/AnalysisPage.plist"]];
    NSError *error = nil;
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:settingsDictionary format:NSPropertyListXMLFormat_v1_0 options:nil error:&error];
    if(data) {
        [data writeToFile:plistPath atomically:YES];
    }
    else {
        NSLog(@"An error has occured %@", error);
    }
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == _teamInfo) return _teamHeader;
    else return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == _teamInfo) return 50;
    else return 0;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _teamInfo) return [teamList count];
    if (tableView == _red1Table) return [red1Scores count];
    if (tableView == _red2Table) return [red2Scores count];
    if (tableView == _red3Table) return [red3Scores count];
    if (tableView == _blue1Table) return [blue1Scores count];
    if (tableView == _blue2Table) return [blue2Scores count];
    if (tableView == _blue3Table) return [blue3Scores count];
    else return 0;
}

- (void)configureScoreCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    // Set a background for the cell
    // UIImageView *tableBackground = [[UIImageView alloc] initWithFrame:cell.frame];
    // UIImage *image = [UIImage imageNamed:@"Blue Fade.gif"];
    // tableBackground.image = image;
    //  cell.backgroundView = imageView; Change Variable Name "soon"
    
	UILabel *teamNumber = (UILabel *)[cell viewWithTag:10];
    TeamData *team = [teamList objectAtIndex:indexPath.row];
	teamNumber.text = [NSString stringWithFormat:@"%d", [team.number intValue]];
    NSMutableDictionary *stats = [teamStats objectAtIndex:indexPath.row];

    UILabel *label0 = (UILabel *)[cell viewWithTag:20];
    label0.text = [NSString stringWithFormat:@"%d", [[stats objectForKey:@"matches"] intValue]];

    
    UILabel *label1 = (UILabel *)[cell viewWithTag:30];

    label1.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"toteIntakeLandfill"] objectForKey:@"average"] floatValue]];

    UILabel *label2 = (UILabel *)[cell viewWithTag:40];
    label2.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"toteIntakeHP"] objectForKey:@"average"] floatValue]];

    UILabel *label3 = (UILabel *)[cell viewWithTag:50];
    label3.text = [NSString stringWithFormat:@"%d", [[[stats objectForKey:@"totalTotesScored"] objectForKey:@"total"] intValue]];

    UILabel *label4 = (UILabel *)[cell viewWithTag:60];
    label4.text = [NSString stringWithFormat:@"%@", team.maxToteStack];

    UILabel *label5 = (UILabel *)[cell viewWithTag:70];
    label5.text = [NSString stringWithFormat:@"%d", [[[stats objectForKey:@"stackKnockdowns"] objectForKey:@"total"] intValue]];

    UILabel *label6 = (UILabel *)[cell viewWithTag:80];
    label6.text = [NSString stringWithFormat:@"%d", [[[stats objectForKey:@"autonCansFromStep"] objectForKey:@"total"] intValue]];

    UILabel *label7 = (UILabel *)[cell viewWithTag:90];
    label7.text = [NSString stringWithFormat:@"%d", [[[stats objectForKey:@"autonCansScored"] objectForKey:@"total"] intValue]];

    UILabel *label8 = (UILabel *)[cell viewWithTag:100];
    label8.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"driverRating"] objectForKey:@"average"] floatValue]];

    //NSLog(@"%@", stats);

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _teamInfo) {
        UITableViewCell *cell = [tableView
                                 dequeueReusableCellWithIdentifier:@"TeamInfo"];
        // Set up the cell...
        [self configureScoreCell:cell atIndexPath:indexPath];
        
        return cell;
    }
    else {
        UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:@"TeamCell"];
        TeamScore *score;
        if (tableView == _red1Table) {
            score = [red1Scores objectAtIndex:indexPath.row];
        }
        else if (tableView == _red2Table) {
            score = [red2Scores objectAtIndex:indexPath.row];
        }
        else if (tableView == _red3Table) {
            score = [red3Scores objectAtIndex:indexPath.row];
        }
        else if (tableView == _blue1Table) {
            score = [blue1Scores objectAtIndex:indexPath.row];
        }
        else if (tableView == _blue2Table) {
            score = [blue2Scores objectAtIndex:indexPath.row];
        }
        else if (tableView == _blue3Table) {
            score = [blue3Scores objectAtIndex:indexPath.row];
        }
        UILabel *number = (UILabel *)[cell viewWithTag:10];
        number.text = [NSString stringWithFormat:@"%d", [score.match.number intValue]];
 
        UILabel *type = (UILabel *)[cell viewWithTag:20];
        type.text = [MatchAccessors getMatchTypeString:score.match.matchType fromDictionary:matchDictionary];
        return cell;
    }
}
/*
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _red1Table) {
    NSLog(@"Cell frame.size.width=%f", cell.frame.size.width);
//        cell.frame.size.width = 125.0;
    }
}*/

-(void)setTableDefaults {
    //_red1Table.layer.borderWidth = 2.0;
    //_red2Table.layer.borderWidth = 2.0;
    //_red3Table.layer.borderWidth = 2.0;
    //_blue1Table.layer.borderWidth = 2.0;
    //_blue2Table.layer.borderWidth = 2.0;
    //_blue3Table.layer.borderWidth = 2.0;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField != _matchNumber)  return YES;
    
    NSString *resultingString = [textField.text stringByReplacingCharactersInRange: range withString: string];
    
    // This allows backspace
    if ([resultingString length] == 0) {
        return true;
    }
    
    NSInteger holder;
    NSScanner *scan = [NSScanner scannerWithString: resultingString];
    
    return [scan scanInteger: &holder] && [scan isAtEnd];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField == _matchNumber) {
        
    }
    //    NSLog(@"should end editing");
	return YES;
}

#pragma mark -
#pragma mark Text

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
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
            [NSFetchedResultsController deleteCacheWithName:@"AnalysisPage"];
        }
       // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController =
        [[NSFetchedResultsController alloc]
         initWithFetchRequest:fetchRequest
         managedObjectContext:_dataManager.managedObjectContext
         sectionNameKeyPath:@"matchType"
         cacheName:@"AnalysisPage"];
        aFetchedResultsController.delegate = self;
        self.fetchedResultsController = aFetchedResultsController;
    }
	
	return _fetchedResultsController;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{   return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
