//
//  MasonPageViewController.m
// Robonauts Scouting
//
//  Created by FRC on 3/21/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "MasonPageViewController.h"
#import "TournamentData.h"
#import "DataManager.h"
#import "MatchTypeDictionary.h"
#import "MatchData.h"
#import "TeamData.h"
#import "TeamDataInterfaces.h"
#import "TeamScore.h"
#import "CalculateTeamStats.h"
#import "TeamDetailViewController.h"
#import "FieldDrawingViewController.h"
#import "parseCSV.h"
#import "QuartzCore/QuartzCore.h"

@implementation MasonPageViewController {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    int numberMatchTypes;
    int ourCurrentIndex;
    CalculateTeamStats *teamStats;
    MatchTypeDictionary *matchDictionary;
    NSFileManager *fileManager;
    NSString *storePath;
}
@synthesize dataManager = _dataManager;
@synthesize fetchedResultsController = _fetchedResultsController;

// Match Control Buttons
@synthesize prevMatch;
@synthesize nextMatch;

// Match Data
@synthesize matchNumber;
@synthesize matchType;
@synthesize matchTypeList;
@synthesize matchTypePicker;
@synthesize matchTypePickerPopover;

@synthesize teamData;
@synthesize teamList = _teamList;
@synthesize teamMatches = _teamMatches;
@synthesize teamAuton = _teamAuton;
@synthesize teamTeleOp = _teamTeleOp;
@synthesize teamHang = _teamHang;
@synthesize teamHangLevel = _teamHangLevel;
@synthesize teamDriving = _teamDriving;
@synthesize teamDefense = _teamDefense;
@synthesize teamSpeed = _teamSpeed;
@synthesize teamHeader = _teamHeader;
@synthesize teamInfo = _teamInfo;

// Team Match List
@synthesize red1Matches = _red1Matches;
@synthesize red1 = _red1;



// Team Tables
@synthesize red1Team = _red1Team;
@synthesize red1Stats = _red1Stats;
@synthesize red1Table = _red1Table;

@synthesize red2Team = _red2Team;
@synthesize red2Table = _red2Table;

@synthesize red3Team = _red3Team;
@synthesize red3Table = _red3Table;

@synthesize blue1Team = _blue1Team;
@synthesize blue1Table = _blue1Table;

@synthesize blue2Team = _blue2Team;
@synthesize blue2Table = _blue2Table;

@synthesize blue3Team = _blue3Team;
@synthesize blue3Table = _blue3Table;

// Team Score for Segue
@synthesize red1Scores = _red1Scores;
@synthesize red2Scores = _red2Scores;
@synthesize red3Scores = _red3Scores;
@synthesize blue1Scores = _blue1Scores;
@synthesize blue2Scores = _blue2Scores;
@synthesize blue3Scores = _blue3Scores;

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
    teamStats = [[CalculateTeamStats alloc] initWithDataManager:_dataManager];
    matchDictionary = [[MatchTypeDictionary alloc] init];
    
    matchTypeList = [self getMatchTypeList];
    numberMatchTypes = [matchTypeList count];
    // NSLog(@"Match Type List Count = %@", matchTypeList);
    
    // If there are no matches in any section then don't set this stuff. ShowMatch will set currentMatch to
    // nil, printing out blank info in all the display items.
    if (numberMatchTypes) {
        // Temporary method to save the data markers
        storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"dataMarkerMason.csv"];
        fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:storePath]) {
            // Loading Default Data Markers
            _currentSectionType = [[matchDictionary getMatchTypeEnum:[matchTypeList objectAtIndex:0]] intValue];
            _rowIndex = 0;
            _teamIndex = 0;
            _sectionIndex = [self getMatchSectionInfo:_currentSectionType];
        }
        else {
            CSVParser *parser = [CSVParser new];
            [parser openFile: storePath];
            NSMutableArray *csvContent = [parser parseFile];
            // NSLog(@"data marker = %@", csvContent);
            _rowIndex = [[[csvContent objectAtIndex:0] objectAtIndex:0] intValue];
            _teamIndex = [[[csvContent objectAtIndex:0] objectAtIndex:2] intValue];
            _currentSectionType = [[[csvContent objectAtIndex:0] objectAtIndex:1] intValue];
            _sectionIndex = [self getMatchSectionInfo:_currentSectionType];
            if (_sectionIndex == -1) { // The selected match type does not exist
                // Go back to the first section in the table
                _currentSectionType = [[matchDictionary getMatchTypeEnum:[matchTypeList objectAtIndex:0]] intValue];
                _sectionIndex = [self getMatchSectionInfo:_currentSectionType];
            }
        }
    }
        
    [self SetTextBoxDefaults:matchNumber];
    [self SetBigButtonDefaults:matchType];
    [self SetBigButtonDefaults:prevMatch];
    [self SetBigButtonDefaults:nextMatch];
    [self SetBigButtonDefaults:_ourPrevMatchButton];
    [self SetBigButtonDefaults:_ourNextMatchButton];

    _red1Table.layer.borderWidth = 2.0;
    _red2Table.layer.borderWidth = 2.0;
    _red3Table.layer.borderWidth = 2.0;
    _blue1Table.layer.borderWidth = 2.0;
    _blue2Table.layer.borderWidth = 2.0;
    _blue3Table.layer.borderWidth = 2.0;

    _teamHeader = [[UIView alloc] initWithFrame:CGRectMake(0,0,768,50)];
    _teamHeader.backgroundColor = [UIColor lightGrayColor];
    _teamHeader.opaque = YES;
    
	UILabel *teamLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 50)];
	teamLabel.text = @"Team";
    teamLabel.backgroundColor = [UIColor clearColor];
    [_teamHeader addSubview:teamLabel];
    
	UILabel *nMatchesLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 0, 200, 50)];
	nMatchesLabel.text = @"Matches";
    nMatchesLabel.backgroundColor = [UIColor clearColor];
    [_teamHeader addSubview:nMatchesLabel];
    
	UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(180, 0, 200, 50)];
	label1.text = @"High Hot";
    label1.backgroundColor = [UIColor clearColor];
    [_teamHeader addSubview:label1];

    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(290, 0, 200, 50)];
	label2.text = @"TeleOp High";
    label2.backgroundColor = [UIColor clearColor];
    [_teamHeader addSubview:label2];

    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(420, 0, 200, 50)];
	label3.text = @"Truss Throw";
    label3.backgroundColor = [UIColor clearColor];
    [_teamHeader addSubview:label3];
   
    UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(540, 0, 200, 50)];
	label4.text = @"Speed";
    label4.backgroundColor = [UIColor clearColor];
    [_teamHeader addSubview:label4];

    UILabel *lable5 = [[UILabel alloc] initWithFrame:CGRectMake(620, 0, 200, 50)];
	lable5.text = @"Drive";
    lable5.backgroundColor = [UIColor clearColor];
    [_teamHeader addSubview:lable5];

    UILabel *label6 = [[UILabel alloc] initWithFrame:CGRectMake(710, 0, 200, 50)];
	label6.text = @"Bully";
    label6.backgroundColor = [UIColor clearColor];
    [_teamHeader addSubview:label6];
    
    UILabel *label7 = [[UILabel alloc] initWithFrame:CGRectMake(800, 0, 200, 50)];
	label7.text = @"Block";
    label7.backgroundColor = [UIColor clearColor];
    [_teamHeader addSubview:label7];
    
    UILabel *label8 = [[UILabel alloc] initWithFrame:CGRectMake(880, 0, 200, 50)];
	label8.text = @"Floor Pass";
    label8.backgroundColor = [UIColor clearColor];
    [_teamHeader addSubview:label8];

    teamData = [NSMutableArray arrayWithCapacity:6];
    _teamList = [[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"0", @"0", @"0", nil];
    _teamMatches = [[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"0", @"0", @"0", nil];
    _teamAuton = [[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"0", @"0", @"0", nil];
    _teamTeleOp = [[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"0", @"0", @"0", nil];
    _teamHang = [[NSMutableArray alloc] initWithObjects:@"", @"", @"", @"", @"", @"", nil];
    _teamHangLevel = [[NSMutableArray alloc] initWithObjects:@"0.0", @"0.0", @"0.0", @"0.0", @"0.0", @"0.0", nil];
    _teamDriving = [[NSMutableArray alloc] initWithObjects:@"0.0", @"0.0", @"0.0", @"0.0", @"0.0", @"0.0", nil];
    _teamDefense = [[NSMutableArray alloc] initWithObjects:@"0.0", @"0.0", @"0.0", @"0.0", @"0.0", @"0.0", nil];
    _teamSpeed = [[NSMutableArray alloc] initWithObjects:@"0.0", @"0.0", @"0.0", @"0.0", @"0.0", @"0.0", nil];
    _teamHeight = [[NSMutableArray alloc] initWithObjects:@"0.0", @"0.0", @"0.0", @"0.0", @"0.0", @"0.0", nil];

    if (_teamScores) {
        _currentMatch = [self getOurCurrentMatch:_startingIndex];
    }
    else {
        _currentMatch = [self getCurrentMatch];
        [_ourPrevMatchButton setHidden:YES];
        [_ourNextMatchButton setHidden:YES];
    }
    [self ShowMatch];
}


-(NSMutableArray *)getMatchTypeList {
    NSMutableArray *matchTypes = [NSMutableArray array];
    NSString *sectionName;
    for (int i=0; i < [[_fetchedResultsController sections] count]; i++) {
        sectionName = [[[_fetchedResultsController sections] objectAtIndex:i] name];
        // NSLog(@"Section = %@", sectionName);
        [matchTypes addObject:[matchDictionary getMatchTypeString:[NSNumber numberWithInt:[sectionName intValue]]]];
    }
    return matchTypes;
    
}

-(NSUInteger)getMatchSectionInfo:(MatchType)matchSection {
    NSString *sectionName;
    _sectionIndex = -1;
    // Loop for number of sections in table
    for (int i=0; i < [[_fetchedResultsController sections] count]; i++) {
        sectionName = [[[_fetchedResultsController sections] objectAtIndex:i] name];
        if ([sectionName intValue] == matchSection) {
            _sectionIndex = i;
            break;
        }
    }
    return _sectionIndex;
}

-(int)getNumberOfMatches:(NSUInteger)section {
    if ([[_fetchedResultsController sections] count]) {
        return [[[[_fetchedResultsController sections] objectAtIndex:_sectionIndex] objects] count];
    }
    else return 0;
}

-(IBAction)MatchNumberChanged {
    // NSLog(@"MatchNumberChanged");
    
    int matchField = [matchNumber.text intValue];
    int nmatches =  [self getNumberOfMatches:_sectionIndex];
    
    if (matchField > nmatches) { /* Ooops, not that many matches */
        // For now, just change the match field to the last match in the section
        matchField = nmatches;
    }
    _rowIndex = matchField-1;
    
    _currentMatch = [self getCurrentMatch];
    [self ShowMatch];
    
}

-(IBAction)MatchTypeSelectionChanged:(id)sender {
    //    NSLog(@"matchTypeSelectionChanged");
    if (matchTypePicker == nil) {
        self.matchTypePicker = [[MatchTypePickerController alloc]
                                initWithStyle:UITableViewStylePlain];
        matchTypePicker.delegate = self;
        matchTypePicker.matchTypeChoices = matchTypeList;
        self.matchTypePickerPopover = [[UIPopoverController alloc]
                                       initWithContentViewController:matchTypePicker];
    }
    [self.matchTypePickerPopover presentPopoverFromRect:matchType.bounds inView:matchType
                               permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)matchTypeSelected:(NSString *)newMatchType {
    [self.matchTypePickerPopover dismissPopoverAnimated:YES];
    
    for (int i = 0 ; i < [matchTypeList count] ; i++) {
        if ([newMatchType isEqualToString:[matchTypeList objectAtIndex:i]]) {
            // NSLog(@"New section = %@", newMatchType);
            _currentSectionType = [[matchDictionary getMatchTypeEnum:newMatchType] intValue];
            _sectionIndex = [self getMatchSectionInfo:_currentSectionType];
            break;
        }
    }
    _rowIndex = 0;
    _currentMatch = [self getCurrentMatch];
    [self ShowMatch];
}

-(IBAction)PrevButton {
    if (_rowIndex > 0) _rowIndex--;
    else {
        _sectionIndex = [self GetPreviousSection:_currentSectionType];
        _rowIndex =  [[[[_fetchedResultsController sections] objectAtIndex:_sectionIndex] objects] count]-1;
    }
    _currentMatch = [self getCurrentMatch];
   [self ShowMatch];
}

-(IBAction)NextButton {
    int nrows;
    nrows =  [self getNumberOfMatches:_sectionIndex];
    if (_rowIndex < (nrows-1)) _rowIndex++;
    else {
        _rowIndex = 0;
        _sectionIndex = [self GetNextSection:_currentSectionType];
    }
    _currentMatch = [self getCurrentMatch];
    [self ShowMatch];
}

-(NSUInteger)GetNextSection:(MatchType) currentSection {
    //    NSLog(@"GetNextSection");
    NSUInteger nextSection;
    switch (currentSection) {
        case Practice:
            _currentSectionType = Seeding;
            nextSection = [self getMatchSectionInfo:_currentSectionType];
            if (nextSection == -1) { // There are no seeding matches
                nextSection = [self getMatchSectionInfo:currentSection];
                _currentSectionType = currentSection;
            }
            break;
        case Seeding:
            _currentSectionType = Elimination;
            nextSection = [self getMatchSectionInfo:_currentSectionType];
            if (nextSection == -1) { // There are no Elimination matches
                nextSection = [self getMatchSectionInfo:currentSection];
                _currentSectionType = currentSection;
            }
            break;
        case Elimination:
            _currentSectionType = Practice;
            nextSection = [self getMatchSectionInfo:_currentSectionType];
            if (nextSection == -1) { // There are no Practice matches
                // Try seeding matches instead
                _currentSectionType = Seeding;
                nextSection = [self getMatchSectionInfo:_currentSectionType];
                if (nextSection == -1) { // There are no seeding matches either
                    nextSection = [self getMatchSectionInfo:currentSection];
                    _currentSectionType = currentSection;
                }
            }
            break;
        case OtherMatch:
            _currentSectionType = Testing;
            nextSection = [self getMatchSectionInfo:_currentSectionType];
            if (nextSection == -1) { // There are no Test matches
                nextSection = [self getMatchSectionInfo:currentSection];
                _currentSectionType = currentSection;
            }
            break;
        case Testing:
            _currentSectionType = OtherMatch;
            nextSection = [self getMatchSectionInfo:_currentSectionType];
            if (nextSection == -1) { // There are no Other matches
                nextSection = [self getMatchSectionInfo:currentSection];
                _currentSectionType = currentSection;
            }
            break;
    }
    return nextSection;
}

// Move through the rounds
-(NSUInteger)GetPreviousSection:(NSUInteger) currentSection {
    //    NSLog(@"GetPreviousSection");
    NSUInteger newSection;
    switch (currentSection) {
        case Practice:
            _currentSectionType = Testing;
            newSection = [self getMatchSectionInfo:_currentSectionType];
            if (newSection == -1) { // There are no Test matches
                newSection = [self getMatchSectionInfo:currentSection];
                _currentSectionType = currentSection;
            }
            break;
        case Seeding:
            _currentSectionType = Practice;
            newSection = [self getMatchSectionInfo:_currentSectionType];
            if (newSection == -1) { // There are no Practice matches
                newSection = [self getMatchSectionInfo:currentSection];
                _currentSectionType = currentSection;
            }
            break;
        case Elimination:
            _currentSectionType = Seeding;
            newSection = [self getMatchSectionInfo:_currentSectionType];
            if (newSection == -1) { // There are no Seeding matches
                newSection = [self getMatchSectionInfo:currentSection];
                _currentSectionType = currentSection;
            }
            break;
        case OtherMatch:
            _currentSectionType = Testing;
            newSection = [self getMatchSectionInfo:_currentSectionType];
            if (newSection == -1) { // There are no Test matches
                newSection = [self getMatchSectionInfo:currentSection];
                _currentSectionType = currentSection;
            }
            break;
        case Testing:
            _currentSectionType = OtherMatch;
            newSection = [self getMatchSectionInfo:_currentSectionType];
            if (newSection == -1) { // There are no Other matches
                newSection = [self getMatchSectionInfo:currentSection];
                _currentSectionType = currentSection;
            }
            break;
    }
    return newSection;
}

- (IBAction)ourPreviousMatch:(id)sender {
    ourCurrentIndex--;
    if (ourCurrentIndex < 0) ourCurrentIndex = [_teamScores count]-1;
    _currentMatch = [self getOurCurrentMatch:ourCurrentIndex];
    [self ShowMatch];
}

- (IBAction)ourNextMatch:(id)sender {
    ourCurrentIndex++;
    if (ourCurrentIndex == [_teamScores count]) ourCurrentIndex = 0;
    _currentMatch = [self getOurCurrentMatch:ourCurrentIndex];
    [self ShowMatch];
}

-(MatchData *)getCurrentMatch {
    if (numberMatchTypes == 0) {
        return nil;
    }
    else {
        NSIndexPath *matchIndex = [NSIndexPath indexPathForRow:_rowIndex inSection:_sectionIndex];
        return [_fetchedResultsController objectAtIndexPath:matchIndex];
    }
}

-(MatchData *)getOurCurrentMatch:(int) desiredIndex {
    ourCurrentIndex = desiredIndex;
    return [_teamScores objectAtIndex:desiredIndex];
}

-(void)ShowMatch {
    [self setTeamList];
    
    [matchType setTitle:_currentMatch.matchType forState:UIControlStateNormal];
    matchNumber.text = [NSString stringWithFormat:@"%d", [_currentMatch.number intValue]];
//    [red1 setTitle: [teamOrder objectAtIndex:0] forState:UIControlStateNormal];
//    [red2 setTitle:[teamOrder objectAtIndex:1] forState:UIControlStateNormal];
//    [red3 setTitle:[teamOrder objectAtIndex:2] forState:UIControlStateNormal];
//    [blue1 setTitle:[teamOrder objectAtIndex:3] forState:UIControlStateNormal];
//    [blue2 setTitle:[teamOrder objectAtIndex:4] forState:UIControlStateNormal];
//    [blue3 setTitle:[teamOrder objectAtIndex:5] forState:UIControlStateNormal];
}

-(void)setTeamList {
    NSSortDescriptor *allianceSort = [NSSortDescriptor sortDescriptorWithKey:@"allianceSection" ascending:YES];
    NSArray *data = [[_currentMatch.score allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:allianceSort]];

    if (!data) return;

    TeamScore *score;
    [teamData removeAllObjects];

    if ([data count] == 6) {
        // Reds
        for (int i=0; i<6; i++) {
            score = [data objectAtIndex:i];
            [_teamList replaceObjectAtIndex:i
                                withObject:[NSString stringWithFormat:@"%d", [score.team.number intValue]]];
            NSMutableDictionary *stats = [teamStats calculateMasonStats:score.team forTournament:tournamentName];
            
            [_teamMatches replaceObjectAtIndex:i
                                    withObject:[NSString stringWithFormat:@"%d", [[stats objectForKey:@"matches"] intValue]]];
            [_teamAuton replaceObjectAtIndex:i
                                    withObject:[NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"HighHot"] objectForKey:@"average"] floatValue]]];
            [_teamTeleOp replaceObjectAtIndex:i
                                  withObject:[NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"High"] objectForKey:@"average"] floatValue]]];
            [_teamHang replaceObjectAtIndex:i
                                   withObject:[NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"TrussThrow"] objectForKey:@"average"] floatValue]]];
            [_teamHangLevel replaceObjectAtIndex:i
                                    withObject:[NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"Speed"] objectForKey:@"average"] floatValue]]];
            [_teamDriving replaceObjectAtIndex:i
                                 withObject:[NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"DriverSkill"] objectForKey:@"average"] floatValue]]];
            [_teamDefense replaceObjectAtIndex:i
                                 withObject:[NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"BullySkill"] objectForKey:@"average"] floatValue]]];
            [_teamSpeed replaceObjectAtIndex:i
                                 withObject:[NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"BlockSkill"] objectForKey:@"average"] floatValue]]];
            [_teamHeight replaceObjectAtIndex:i
                                  withObject:[NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"FloorPass"] objectForKey:@"average"] floatValue]]];
         }
    }
    _red1Team.text = [_teamList objectAtIndex:0];
    [_red1Scores removeAllObjects];
    _red1Scores = [self getScoreList:[[data objectAtIndex:0] valueForKey:@"team"]];
    _red2Team.text = [_teamList objectAtIndex:1];
    [_red2Scores removeAllObjects];
    _red2Scores = [self getScoreList:[[data objectAtIndex:1] valueForKey:@"team"]];
    _red3Team.text = [_teamList objectAtIndex:2];
    [_red3Scores removeAllObjects];
    _red3Scores = [self getScoreList:[[data objectAtIndex:2] valueForKey:@"team"]];
    _blue1Team.text = [_teamList objectAtIndex:3];
    [_blue1Scores removeAllObjects];
    _blue1Scores = [self getScoreList:[[data objectAtIndex:3] valueForKey:@"team"]];
    _blue2Team.text = [_teamList objectAtIndex:4];
    [_blue2Scores removeAllObjects];
    _blue2Scores = [self getScoreList:[[data objectAtIndex:4] valueForKey:@"team"]];
    _blue3Team.text = [_teamList objectAtIndex:5];
    [_blue3Scores removeAllObjects];
    _blue3Scores = [self getScoreList:[[data objectAtIndex:5] valueForKey:@"team"]];
    [self.teamInfo reloadData];
    [self.red1Table reloadData];
    [self.red2Table reloadData];
    [self.red3Table reloadData];
    [self.blue1Table reloadData];
    [self.blue2Table reloadData];
    [self.blue3Table reloadData];
}

-(NSMutableArray *)getScoreList:(TeamData *)team {
    NSArray *allMatches = [team.match allObjects];
    NSMutableArray *scores = [allMatches mutableCopy];

    NSPredicate *pred = [NSPredicate predicateWithFormat:@"tournamentName = %@", tournamentName];
    [scores filterUsingPredicate:pred];

    NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"match.matchTypeSection" ascending:YES];
    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"match.number" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:typeDescriptor, numberDescriptor, nil];

    [scores sortUsingDescriptors:sortDescriptors];
    return scores;
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"TeamDetail"]) {
        NSIndexPath *indexPath = [ self.teamInfo indexPathForCell:sender];
        TeamDetailViewController *detailViewController = [segue destinationViewController];
        [segue.destinationViewController setDataManager:_dataManager];
        // NSLog(@"Team = %@", [_teamList objectAtIndex:indexPath.row]);
        TeamData *team = [[[TeamDataInterfaces alloc] initWithDataManager:_dataManager] getTeam:[_teamList objectAtIndex:indexPath.row]];
        detailViewController.team = team;
        [_teamInfo deselectRowAtIndexPath:indexPath animated:YES];
    }
    else {
        NSIndexPath *indexPath;
        if ([segue.identifier isEqualToString:@"Red1"]) {
            indexPath = [self.red1Table indexPathForCell:sender];
            [_red1Table deselectRowAtIndexPath:indexPath animated:YES];
            [segue.destinationViewController setTeamScores:_red1Scores];
        }
        else if ([segue.identifier isEqualToString:@"Red2"]) {
            indexPath = [self.red2Table indexPathForCell:sender];
            [_red2Table deselectRowAtIndexPath:indexPath animated:YES];
            [segue.destinationViewController setTeamScores:_red2Scores];
        }
        else if ([segue.identifier isEqualToString:@"Red3"]) {
            indexPath = [self.red3Table indexPathForCell:sender];
            [_red3Table deselectRowAtIndexPath:indexPath animated:YES];
            [segue.destinationViewController setTeamScores:_red3Scores];
        }
        else if ([segue.identifier isEqualToString:@"Blue1"]) {
            indexPath = [self.blue1Table indexPathForCell:sender];
            [_blue1Table deselectRowAtIndexPath:indexPath animated:YES];
            [segue.destinationViewController setTeamScores:_blue1Scores];
        }
        else if ([segue.identifier isEqualToString:@"Blue2"]) {
            indexPath = [self.blue2Table indexPathForCell:sender];
            [_blue2Table deselectRowAtIndexPath:indexPath animated:YES];
            [segue.destinationViewController setTeamScores:_blue2Scores];
        }
        else if ([segue.identifier isEqualToString:@"Blue3"]) {
            indexPath = [self.blue3Table indexPathForCell:sender];
            [_blue3Table deselectRowAtIndexPath:indexPath animated:YES];
            [segue.destinationViewController setTeamScores:_blue3Scores];
        }
        [segue.destinationViewController setStartingIndex:indexPath.row];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    //    NSLog(@"viewWillDisappear");
    NSString *dataMarkerString;
    storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"dataMarkerMason.csv"];
    dataMarkerString = [NSString stringWithFormat:@"%d, %d, %d\n", _rowIndex, _currentSectionType, _teamIndex];
    [dataMarkerString writeToFile:storePath
                       atomically:YES
                         encoding:NSUTF8StringEncoding
                            error:nil];
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
    if (tableView == _teamInfo) return [_teamList count];
    if (tableView == _red1Table) return [_red1Scores count];
    if (tableView == _red2Table) return [_red2Scores count];
    if (tableView == _red3Table) return [_red3Scores count];
    if (tableView == _blue1Table) return [_blue1Scores count];
    if (tableView == _blue2Table) return [_blue2Scores count];
    if (tableView == _blue3Table) return [_blue3Scores count];
    else return [teamData count];
}

- (void)configureScoreCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    // Set a background for the cell
    // UIImageView *tableBackground = [[UIImageView alloc] initWithFrame:cell.frame];
    // UIImage *image = [UIImage imageNamed:@"Blue Fade.gif"];
    // tableBackground.image = image;
    //  cell.backgroundView = imageView; Change Varable Name "soon"
    
	UILabel *teamNumber = (UILabel *)[cell viewWithTag:10];
	teamNumber.text = [_teamList objectAtIndex:indexPath.row];

	UILabel *nMatchesLabel = (UILabel *)[cell viewWithTag:20];
    nMatchesLabel.text = [_teamMatches objectAtIndex:indexPath.row];

	UILabel *autonLabel = (UILabel *)[cell viewWithTag:30];
	autonLabel.text = [_teamAuton objectAtIndex:indexPath.row];

    UILabel *teleOpLabel = (UILabel *)[cell viewWithTag:40];
	teleOpLabel.text = [_teamTeleOp objectAtIndex:indexPath.row];

    UILabel *hangLabel = (UILabel *)[cell viewWithTag:50];
    hangLabel.text = [_teamHang objectAtIndex:indexPath.row];

    UILabel *hangLevel = (UILabel *)[cell viewWithTag:55];
	hangLevel.text = [_teamHangLevel objectAtIndex:indexPath.row];

    UILabel *drivingLabel = (UILabel *)[cell viewWithTag:60];
	drivingLabel.text = [_teamDriving objectAtIndex:indexPath.row];

    UILabel *defenseLabel = (UILabel *)[cell viewWithTag:70];
	defenseLabel.text = [_teamDefense objectAtIndex:indexPath.row];

    UILabel *speedLabel = (UILabel *)[cell viewWithTag:80];
	speedLabel.text = [_teamSpeed objectAtIndex:indexPath.row];

    UILabel *heightLabel = (UILabel *)[cell viewWithTag:90];
	heightLabel.text = [_teamHeight objectAtIndex:indexPath.row];

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
            score = [_red1Scores objectAtIndex:indexPath.row];
        }
        else if (tableView == _red2Table) {
            score = [_red2Scores objectAtIndex:indexPath.row];
        }
        else if (tableView == _red3Table) {
            score = [_red3Scores objectAtIndex:indexPath.row];
        }
        else if (tableView == _blue1Table) {
            score = [_blue1Scores objectAtIndex:indexPath.row];
        }
        else if (tableView == _blue2Table) {
            score = [_blue2Scores objectAtIndex:indexPath.row];
        }
        else if (tableView == _blue3Table) {
            score = [_blue3Scores objectAtIndex:indexPath.row];
        }
        UILabel *number = (UILabel *)[cell viewWithTag:10];
        number.text = [NSString stringWithFormat:@"%d", [score.match.number intValue]];
 
        UILabel *type = (UILabel *)[cell viewWithTag:20];
        type.text = score.match.matchType; 
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

-(void)SetTextBoxDefaults:(UITextField *)currentTextField {
    currentTextField.font = [UIFont fontWithName:@"Helvetica" size:24.0];
}

-(void)SetBigButtonDefaults:(UIButton *)currentButton {
    currentButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:24.0];
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField != matchNumber)  return YES;
    
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{   return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setRed2Team:nil];
    [self setRed3Team:nil];
    [self setRed3Table:nil];
    [self setBlue1Table:nil];
    [self setBlue2Team:nil];
    [self setBlue2Table:nil];
    [self setBlue3Table:nil];
    [super viewDidUnload];
}
@end
