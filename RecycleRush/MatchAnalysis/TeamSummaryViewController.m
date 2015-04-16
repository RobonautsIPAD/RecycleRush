//
//  TeamSummaryViewController.m
//  RecycleRush
//
//  Created by FRC on 2/7/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import "TeamSummaryViewController.h"
#import "UIDefaults.h"
#import "DataManager.h"
#import "TeamData.h"
#import "MatchAccessors.h"
#import "TeamScore.h"
#import "ScoreAccessors.h"
#import "MatchPhotoCollectionViewController.h"
#import "MatchAccessors.h"
#import "PlotDefinition.h"
#import "PieSlices.h"
#import "PieCharts.h"
#import "ScatterPlot.h"
#import "CalculateTeamStats.h"
#import "TeamDetailViewController.h"
#import "MatchSummaryViewController.h"

@interface TeamSummaryViewController ()
@property (weak, nonatomic) IBOutlet UIButton *teamNumberButton;
@property (weak, nonatomic) IBOutlet UITextField *teamNameField;
@property (weak, nonatomic) IBOutlet UITextField *matchNumberField;
@property (weak, nonatomic) IBOutlet UIButton *matchPhotoButton;
@property (nonatomic, weak) IBOutlet UITableView *matchInfo;
@property (weak, nonatomic) IBOutlet UITableView *teamStatsTable;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *homeButton;
@property (weak, nonatomic) IBOutlet UIView *graphView;

@end

@implementation TeamSummaryViewController {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSDictionary *matchTypeDictionary;
    NSDictionary *allianceDictionary;
    UIView *matchHeader;
    NSArray *matchList;
    TeamData *currentTeam;
    CalculateTeamStats *teamStats;
    NSMutableDictionary *stats;

    NSMutableArray *teamPopUpList;
    PopUpPickerViewController *teamPicker;
    UIPopoverController *teamPickerPopover;

    UIView *pieView;
    UIView *scatterView;
    PieCharts *totePieChart;
    ScatterPlot *toteCanScatterPlot;
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
    // Get the preferences needed for this VC
    prefs = [NSUserDefaults standardUserDefaults];
    tournamentName = [prefs objectForKey:@"tournament"];
    if (tournamentName) {
        self.title =  [NSString stringWithFormat:@"%@ Team Summary", tournamentName];
    }
    else {
        self.title = @"Team Summary";
    }
    [UIDefaults setBigButtonDefaults:_teamNumberButton withFontSize:nil];
    [UIDefaults setBigButtonDefaults:_matchPhotoButton withFontSize:nil];

    matchTypeDictionary = _dataManager.matchTypeDictionary;
    allianceDictionary = _dataManager.allianceDictionary;

    teamPopUpList = [[NSMutableArray alloc] init];
    for (TeamData *team in _teamList) {
        [teamPopUpList addObject:[NSString stringWithFormat:@"%@", team.number]];
    }
    currentTeam = _initialTeam;
    [self createMatchHeader];
    teamStats = [[CalculateTeamStats alloc] init:_dataManager];
    [self showTeam];
    [scatterView setHidden:TRUE];
}

-(void)createTotePieChart {
    PlotDefinition *plotDefinition = [[PlotDefinition alloc] init:@"Human vs Landfill Intake"];
#ifdef __IPHONE_7_0
    if (!pieView) {
        pieView = [[UIView alloc] initWithFrame:_graphView.bounds];
        [_graphView addSubview:pieView];
    }
    totePieChart = [[PieCharts alloc] init];
    PieSlices *slice1 = [[PieSlices alloc] init:@"" withLegend:@"Totes from Landfill" forValue:[[stats objectForKey:@"toteIntakeLandfill"] objectForKey:@"total"]];
    PieSlices *slice2 = [[PieSlices alloc] init:@"" withLegend:@"Totes from HP" forValue:[[stats objectForKey:@"toteIntakeHP"] objectForKey:@"total"]];
    NSArray *slices = [NSArray arrayWithObjects:slice1, slice2, nil];
    plotDefinition.plotData = slices;
    [totePieChart initPlot:pieView withDefinition:plotDefinition];
#endif
}

-(void)createToteCanScatterPlot {
    PlotDefinition *plotDefinition = [[PlotDefinition alloc] init:@"Totes and Cans Stacked Per Match"];
#ifdef __IPHONE_7_0
    if (!scatterView) {
        scatterView = [[UIView alloc] initWithFrame:_graphView.bounds];
        [_graphView addSubview:scatterView];
    }
    plotDefinition.xAxisTitle = @"Match Number";
    plotDefinition.yAxisTitle = @"Totes/Cans Stacked";
    toteCanScatterPlot = [[ScatterPlot alloc] init];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"results = %@ AND matchType = %@", [NSNumber numberWithBool:YES], [MatchAccessors getMatchTypeFromString:@"Qualification" fromDictionary:matchTypeDictionary]];

    NSArray *matches = [matchList filteredArrayUsingPredicate:pred];
    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"matchNumber" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:numberDescriptor, nil];
    matches = [matches sortedArrayUsingDescriptors:sortDescriptors];

    NSArray *totes = [self getPlotValues:@"matchNumber" forYKey:@"totalTotesScored" fromMatches:matches];
    NSArray *cans = [self getPlotValues:@"matchNumber" forYKey:@"totalCansScored" fromMatches:matches];
    plotDefinition.plotData = [[NSArray alloc] initWithObjects:totes, cans, nil];
    [toteCanScatterPlot initPlot:scatterView withDefinition:plotDefinition];
#endif
}

-(NSArray *)getPlotValues:(NSString *)xKey forYKey:(NSString *)yKey fromMatches:(NSArray *)scores {
    NSMutableArray *plotData = [[NSMutableArray alloc] init];
    for (TeamScore *score in scores) {
        NSNumber *xValue = [score valueForKey:xKey];
        NSNumber *yValue = [score valueForKey:yKey];
        NSArray *dataPoint = [[NSArray alloc] initWithObjects:xValue, yValue, nil];
        [plotData addObject:dataPoint];
    }
    //NSLog(@"%@", plotData);
    return plotData;
}

-(IBAction)showIntakePie:(id)sender {
    [pieView setHidden:FALSE];
    [scatterView setHidden:TRUE];
}

-(IBAction)showStackScatter:(id)sender {
    [pieView setHidden:TRUE];
    [scatterView setHidden:FALSE];
}

-(void)createMatchHeader {
    // Header for the match list table
    matchHeader = [[UIView alloc] initWithFrame:CGRectMake(0,0,768,50)];
    matchHeader.backgroundColor = [UIColor lightGrayColor];
    matchHeader.opaque = YES;
    
	UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 35)];
	label1.text = @"Match";
    label1.backgroundColor = [UIColor clearColor];
    [matchHeader addSubview:label1];
    
	UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 200, 35)];
	label2.text = @"Type";
    label2.backgroundColor = [UIColor clearColor];
    [matchHeader addSubview:label2];
    
 	UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(180, 0, 200, 35)];
	label3.text = @"Score";
    label3.backgroundColor = [UIColor clearColor];
    [matchHeader addSubview:label3];
    
    UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(255, 0, 200, 35)];
	label4.text = @"Alliance Members";
    label4.backgroundColor = [UIColor clearColor];
    [matchHeader addSubview:label4];
    
    UILabel *label5 = [[UILabel alloc] initWithFrame:CGRectMake(405, 0, 200, 35)];
	label5.text = @"Robot Type";
    label5.backgroundColor = [UIColor clearColor];
    [matchHeader addSubview:label5];
}

-(void)showTeam {
    [_teamNumberButton setTitle:[NSString stringWithFormat:@"%@", currentTeam.number] forState:UIControlStateNormal];
    _teamNameField.text = currentTeam.name;
    _matchNumberField.text = [NSString stringWithFormat:@"%@", _matchNumber];
    matchList = [ScoreAccessors getMatchListForTeam:currentTeam.number forTournament:tournamentName fromDataManager:_dataManager];
    stats = [teamStats calculateMasonStats:currentTeam forTournament:tournamentName];
    [_matchInfo reloadData];
    [_teamStatsTable reloadData];
    [self createTotePieChart];
    [self createToteCanScatterPlot];
}

- (IBAction)goHome:(id)sender {
    UINavigationController * navigationController = self.navigationController;
    [navigationController popToRootViewControllerAnimated:YES];
}

-(IBAction)teamSelectionChanged:(id)sender {
    if (teamPicker == nil) {
        teamPicker = [[PopUpPickerViewController alloc]
                           initWithStyle:UITableViewStylePlain];
        teamPicker.delegate = self;
        teamPicker.pickerChoices = teamPopUpList;
    }
    if (!teamPickerPopover) {
        teamPickerPopover = [[UIPopoverController alloc]
                                  initWithContentViewController:teamPicker];
    }
    [teamPickerPopover presentPopoverFromRect:_teamNumberButton.bounds inView:_teamNumberButton
                          permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)pickerSelected:(NSString *)newPick {
    [teamPickerPopover dismissPopoverAnimated:YES];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"number = %@", [NSNumber numberWithInt:[newPick intValue]]];
    NSArray *teams = [_teamList filteredArrayUsingPredicate:pred];
    if (!teams || ![teams count]) return;
    currentTeam  = [teams objectAtIndex:0];
    [self showTeam];
}

 #pragma mark - Navigation
 
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [segue.destinationViewController setDataManager:_dataManager];
    if ([segue.identifier isEqualToString:@"MatchPhoto"]) {
        [segue.destinationViewController setTeamNumber:currentTeam.number];
        [segue.destinationViewController setMatchList:matchList];
        [segue.destinationViewController setTeamList:teamPopUpList];
   }
    else if ([segue.identifier isEqualToString:@"TeamDetail"]) {
     [segue.destinationViewController setTeam:currentTeam];
    }
    else if ([segue.identifier isEqualToString:@"MatchSummary"])  {
        [segue.destinationViewController setDataManager:_dataManager];
        NSIndexPath *indexPath = [self.matchInfo indexPathForCell:sender];
        [segue.destinationViewController setCurrentScore:[matchList objectAtIndex:indexPath.row]];
        [_matchInfo deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (tableView == _matchInfo) return matchHeader;
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _matchInfo) return [matchList count];
    else if (tableView == _teamStatsTable) return 11;
    else return 0;
}

- (void)configureMatchCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    TeamScore *score = [matchList objectAtIndex:indexPath.row];
    
	UILabel *label1 = (UILabel *)[cell viewWithTag:10];
	label1.text = [NSString stringWithFormat:@"%@", score.matchNumber];
    
    UILabel *label2 = (UILabel *)[cell viewWithTag:20];
    label2.text  = [[MatchAccessors getMatchTypeString:score.matchType fromDictionary:matchTypeDictionary] substringToIndex:4];
    UILabel *label3 = (UILabel *)[cell viewWithTag:30];
    label3.text = [NSString stringWithFormat:@"%@", score.totalScore];
    
    UILabel *label5 = (UILabel *)[cell viewWithTag:70];
    label5.text = [score.robotType substringToIndex:4];
    
    //UILabel *label4 = (UILabel *)[cell viewWithTag:40];
	//label4.text = [NSString stringWithFormat:@"%d", [matchList.  intValue]];
    NSDictionary *allianceMembersDictionary = [MatchAccessors buildTeamList:score.match forAllianceDictionary:allianceDictionary];
    NSString *allianceString = [MatchAccessors getAllianceString:score.allianceStation fromDictionary:allianceDictionary];
    NSArray *allKeys = [allianceMembersDictionary allKeys];
    if ([[allianceString substringToIndex:1] isEqualToString:@"R"]) {
        int tag = 40;
        for (NSString *key in allKeys) {
            if ([[key substringToIndex:1] isEqualToString:@"R"]) {
                int otherMembers = [[allianceMembersDictionary objectForKey:key] intValue];
                if ([currentTeam.number intValue]== otherMembers) continue;
                UILabel *label = (UILabel *)[cell viewWithTag:tag];
                label.text = [NSString stringWithFormat:@"%d", otherMembers];
                tag = 50;
            }
        }
    }
    else if ([[allianceString substringToIndex:1] isEqualToString:@"B"]) {
        int tag = 40;
        for (NSString *key in allKeys) {
            if ([[key substringToIndex:1] isEqualToString:@"B"]) {
                int otherMembers = [[allianceMembersDictionary objectForKey:key] intValue];
                if ([currentTeam.number intValue]== otherMembers) continue;
                UILabel *label = (UILabel *)[cell viewWithTag:tag];
                label.text = [NSString stringWithFormat:@"%d", otherMembers];
                tag = 50;
            }
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (tableView == _matchInfo) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MatchSchedule"];
        // Set up the cell...
        [self configureMatchCell:cell atIndexPath:indexPath];
   }
    if (tableView == _teamStatsTable){
        cell = [tableView dequeueReusableCellWithIdentifier:@"MatchStats"];
        [self configureTeamStatsCell:cell atIndexPath:indexPath];
    }
     return cell;
}

        
- (void)configureTeamStatsCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    //NSLog(@"%@", stats);
        if (indexPath.row == 0) {
            UILabel *label1 = (UILabel *)[cell viewWithTag:10];
            label1.text = @"";
            UILabel *label2 = (UILabel *)[cell viewWithTag:20];
            label2.text = @"Totes Land";
            label2.font = [UIFont boldSystemFontOfSize:14.0];
            UILabel *label3 = (UILabel *)[cell viewWithTag:30];
            label3.text = @"Totes Step";
            label3.font = [UIFont boldSystemFontOfSize:14.0];
            UILabel *label4 = (UILabel *)[cell viewWithTag:40];
            label4.text = @"Totes HP";
            label4.font = [UIFont boldSystemFontOfSize:14.0];
            UILabel *label5 = (UILabel *)[cell viewWithTag:50];
            label5.text = @"Cans Step";
            label5.font = [UIFont boldSystemFontOfSize:14.0];
            UILabel *label6 = (UILabel *)[cell viewWithTag:60];
            label6.text = @"Cans Floor";
            label6.font = [UIFont boldSystemFontOfSize:14.0];
            UILabel *label7 = (UILabel *)[cell viewWithTag:70];
            label7.text = @"Driver Rate";
            label7.font = [UIFont boldSystemFontOfSize:14.0];
            UILabel *label8 = (UILabel *)[cell viewWithTag:80];
            label8.text = @"Litter Cans";
            label8.font = [UIFont boldSystemFontOfSize:14.0];
            UILabel *label9 = (UILabel *)[cell viewWithTag:90];
            label9.text = @"C Dom Time";
            label9.font = [UIFont boldSystemFontOfSize:14.0];
            UILabel *label10 = (UILabel *)[cell viewWithTag:100];
            label10.text = @"C Dom Cans";
            label10.font = [UIFont boldSystemFontOfSize:14.0];
            
        } else if (indexPath.row == 1) {
            //NSLog(@"%@",stats);
            UILabel *label1 = (UILabel *)[cell viewWithTag:10];
            label1.text = @"Total";
            label1.font = [UIFont boldSystemFontOfSize:14.0];
            
            UILabel *label2 = (UILabel *)[cell viewWithTag:20];
            label2.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"toteIntakeLandfill"] objectForKey:@"total"] floatValue]];
            UILabel *label3 = (UILabel *)[cell viewWithTag:30];
            label3.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"toteIntakeStep"] objectForKey:@"total"] floatValue]];
            UILabel *label4 = (UILabel *)[cell viewWithTag:40];
            label4.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"toteIntakeHP"] objectForKey:@"total"] floatValue]];
            UILabel *label5 = (UILabel *)[cell viewWithTag:50];
            label5.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"cansFromStep"] objectForKey:@"total"] floatValue]];
            UILabel *label6 = (UILabel *)[cell viewWithTag:60];
            label6.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"canIntakeFloor"] objectForKey:@"total"] floatValue]];
            UILabel *label7 = (UILabel *)[cell viewWithTag:70];
            label7.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"driverRating"] objectForKey:@"total"] floatValue]];
            UILabel *label8 = (UILabel *)[cell viewWithTag:80];
            label8.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"litterInCan"] objectForKey:@"total"] floatValue]];
            UILabel *label9 = (UILabel *)[cell viewWithTag:90];
            label9.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"canDominationTime"] objectForKey:@"total"] floatValue]];
            UILabel *label10 = (UILabel *)[cell viewWithTag:100];
            label10.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"autonCansFromStep"] objectForKey:@"total"] floatValue]];
            
        } else if (indexPath.row == 2) {
            UILabel *label1 = (UILabel *)[cell viewWithTag:10];
            label1.text = @"Average";
            label1.font = [UIFont boldSystemFontOfSize:14.0];
            
            UILabel *label2 = (UILabel *)[cell viewWithTag:20];
            label2.text = [NSString stringWithFormat:@"%1.1f", [[[stats objectForKey:@"toteIntakeLandfill"] objectForKey:@"average"] floatValue]];
            UILabel *label3 = (UILabel *)[cell viewWithTag:30];
            label3.text = [NSString stringWithFormat:@"%1.1f", [[[stats objectForKey:@"toteIntakeStep"] objectForKey:@"average"] floatValue]];
            UILabel *label4 = (UILabel *)[cell viewWithTag:40];
            label4.text = [NSString stringWithFormat:@"%1.1f", [[[stats objectForKey:@"toteIntakeHP"] objectForKey:@"average"] floatValue]];
            UILabel *label5 = (UILabel *)[cell viewWithTag:50];
            label5.text = [NSString stringWithFormat:@"%1.1f", [[[stats objectForKey:@"cansFromStep"] objectForKey:@"average"] floatValue]];
            UILabel *label6 = (UILabel *)[cell viewWithTag:60];
            label6.text = [NSString stringWithFormat:@"%1.1f", [[[stats objectForKey:@"canIntakeFloor"] objectForKey:@"average"] floatValue]];
            UILabel *label7 = (UILabel *)[cell viewWithTag:70];
            label7.text = [NSString stringWithFormat:@"%1.1f", [[[stats objectForKey:@"driverRating"] objectForKey:@"average"] floatValue]];
            UILabel *label8 = (UILabel *)[cell viewWithTag:80];
            label8.text = [NSString stringWithFormat:@"%1.1f", [[[stats objectForKey:@"litterInCan"] objectForKey:@"average"] floatValue]];
            UILabel *label9 = (UILabel *)[cell viewWithTag:90];
            label9.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"canDominationTime"] objectForKey:@"average"] floatValue]];
            UILabel *label10 = (UILabel *)[cell viewWithTag:100];
            label10.text = [NSString stringWithFormat:@"%1.1f", [[[stats objectForKey:@"autonCansFromStep"] objectForKey:@"average"] floatValue]];
            
            
        } else if (indexPath.row == 3) {
                UILabel *label1 = (UILabel *)[cell viewWithTag:10];
                label1.text = @"";
                UILabel *label2 = (UILabel *)[cell viewWithTag:20];
                label2.text = @"Knockdowns";
                label2.font = [UIFont boldSystemFontOfSize:14.0];
                UILabel *label3 = (UILabel *)[cell viewWithTag:30];
                label3.text = @"Coop Set #";
                label3.font = [UIFont boldSystemFontOfSize:14.0];
                UILabel *label4 = (UILabel *)[cell viewWithTag:40];
                label4.text = @"Coop Stack #";
                label4.font = [UIFont boldSystemFontOfSize:14.0];
                UILabel *label5 = (UILabel *)[cell viewWithTag:50];
                label5.text = @"Robot Set";
                label5.font = [UIFont boldSystemFontOfSize:14.0];
                UILabel *label6 = (UILabel *)[cell viewWithTag:60];
                label6.text = @"Can Set";
                label6.font = [UIFont boldSystemFontOfSize:14.0];
                UILabel *label7 = (UILabel *)[cell viewWithTag:70];
                label7.text = @"Tote Set";
                label7.font = [UIFont boldSystemFontOfSize:14.0];
                UILabel *label8 = (UILabel *)[cell viewWithTag:80];
                label8.text = @"Tote Stack";
                label8.font = [UIFont boldSystemFontOfSize:14.0];
                UILabel *label9 = (UILabel *)[cell viewWithTag:90];
                label9.text = @"Total Totes";
                label9.font = [UIFont boldSystemFontOfSize:14.0];
                UILabel *label10 = (UILabel *)[cell viewWithTag:100];
                label10.text = @"Total Cans";
                label10.font = [UIFont boldSystemFontOfSize:14.0];
            
            } else if (indexPath.row == 4) {
                UILabel *label1 = (UILabel *)[cell viewWithTag:10];
                label1.text = @"Total";
                label1.font = [UIFont boldSystemFontOfSize:14.0];
                
                UILabel *label2 = (UILabel *)[cell viewWithTag:20];
                label2.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"stackKnockdowns"] objectForKey:@"total"] floatValue]];
                UILabel *label3 = (UILabel *)[cell viewWithTag:30];
                label3.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"coopSetNumerator"] objectForKey:@"total"] floatValue]];
                UILabel *label4 = (UILabel *)[cell viewWithTag:40];
                label4.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"coopStackNumerator"] objectForKey:@"total"] floatValue]];
                UILabel *label5 = (UILabel *)[cell viewWithTag:50];
                label5.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"autonRobotSet"] objectForKey:@"total"] floatValue]];
                UILabel *label6 = (UILabel *)[cell viewWithTag:60];
                label6.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"autonCansScored"] objectForKey:@"total"] floatValue]];
                UILabel *label7 = (UILabel *)[cell viewWithTag:70];
                label7.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"autonToteSet"] objectForKey:@"total"] floatValue]];
                UILabel *label8 = (UILabel *)[cell viewWithTag:80];
                label8.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"autonToteStack"] objectForKey:@"total"] floatValue]];
                UILabel *label9 = (UILabel *)[cell viewWithTag:90];
                label9.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"totalTotesScored"] objectForKey:@"total"] floatValue]];
                UILabel *label10 = (UILabel *)[cell viewWithTag:100];
                label10.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"totalCansScored"] objectForKey:@"total"] floatValue]];
                
                
            } else if (indexPath.row == 5) {
                UILabel *label1 = (UILabel *)[cell viewWithTag:10];
                label1.text = @"Average";
                label1.font = [UIFont boldSystemFontOfSize:14.0];
                
                UILabel *label2 = (UILabel *)[cell viewWithTag:20];
                label2.text = [NSString stringWithFormat:@"%1.1f", [[[stats objectForKey:@"stackKnockdowns"] objectForKey:@"average"] floatValue]];
                UILabel *label3 = (UILabel *)[cell viewWithTag:30];
                label3.text = [NSString stringWithFormat:@"%1.1f", [[[stats objectForKey:@"coopSetNumerator"] objectForKey:@"total"] floatValue]];
                UILabel *label4 = (UILabel *)[cell viewWithTag:40];
                label4.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"coopStackNumerator"] objectForKey:@"total"] floatValue]];
                UILabel *label5 = (UILabel *)[cell viewWithTag:50];
                label5.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"autonRobotSet"] objectForKey:@"total"] floatValue]];
                UILabel *label6 = (UILabel *)[cell viewWithTag:60];
                label6.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"autonCansScored"] objectForKey:@"total"] floatValue]];
                UILabel *label7 = (UILabel *)[cell viewWithTag:70];
                label7.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"autonToteSet"] objectForKey:@"total"] floatValue]];
                UILabel *label8 = (UILabel *)[cell viewWithTag:80];
                label8.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"autonToteStack"] objectForKey:@"total"] floatValue]];
                UILabel *label9 = (UILabel *)[cell viewWithTag:90];
                label9.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"totalTotesScored"] objectForKey:@"average"] floatValue]];
                UILabel *label10 = (UILabel *)[cell viewWithTag:100];
                label10.text = [NSString stringWithFormat:@"%1.1f", [[[stats objectForKey:@"totalCansScored"] objectForKey:@"average"] floatValue]];
                
            } else if (indexPath.row == 6) {
                UILabel *label1 = (UILabel *)[cell viewWithTag:10];
                label1.text = @"";
                UILabel *label2 = (UILabel *)[cell viewWithTag:30];
                label2.text = @"Non Scored";
                label2.font = [UIFont boldSystemFontOfSize:14.0];
                UILabel *label3 = (UILabel *)[cell viewWithTag:40];
                label3.text = @"#1";
                label3.font = [UIFont boldSystemFontOfSize:14.0];
                UILabel *label4 = (UILabel *)[cell viewWithTag:50];
                label4.text = @"#2";
                label4.font = [UIFont boldSystemFontOfSize:14.0];
                UILabel *label5 = (UILabel *)[cell viewWithTag:60];
                label5.text = @"#3";
                label5.font = [UIFont boldSystemFontOfSize:14.0];
                UILabel *label6 = (UILabel *)[cell viewWithTag:70];
                label6.text = @"#4";
                label6.font = [UIFont boldSystemFontOfSize:14.0];
                UILabel *label7 = (UILabel *)[cell viewWithTag:80];
                label7.text = @"#5";
                label7.font = [UIFont boldSystemFontOfSize:14.0];
                UILabel *label8 = (UILabel *)[cell viewWithTag:90];
                label8.text = @"#6";
                label8.font = [UIFont boldSystemFontOfSize:14.0];
                UILabel *label9 = (UILabel *)[cell viewWithTag:100];
                label9.text = @"";
                label9.font = [UIFont boldSystemFontOfSize:14.0];
                UILabel *label10 = (UILabel *)[cell viewWithTag:20];
                label10.text = @"";
                label10.font = [UIFont boldSystemFontOfSize:14.0];
                
            } else if (indexPath.row == 7) {
                UILabel *label1 = (UILabel *)[cell viewWithTag:10];
                label1.text = @"Stack Of";
                label1.font = [UIFont boldSystemFontOfSize:14.0];
                
                UILabel *label2 = (UILabel *)[cell viewWithTag:30];
                label2.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"totesOn0"] objectForKey:@"total"] floatValue]];
                UILabel *label3 = (UILabel *)[cell viewWithTag:40];
                label3.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"totesOn1"] objectForKey:@"total"] floatValue]];
                UILabel *label4 = (UILabel *)[cell viewWithTag:50];
                label4.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"totesOn2"] objectForKey:@"total"] floatValue]];
                UILabel *label5 = (UILabel *)[cell viewWithTag:60];
                label5.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"totesOn3"] objectForKey:@"total"] floatValue]];
                UILabel *label6 = (UILabel *)[cell viewWithTag:70];
                label6.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"totesOn4"] objectForKey:@"total"] floatValue]];
                UILabel *label7 = (UILabel *)[cell viewWithTag:80];
                label7.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"totesOn5"] objectForKey:@"total"] floatValue]];
                UILabel *label8 = (UILabel *)[cell viewWithTag:90];
                label8.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"totesOn6"] objectForKey:@"total"] floatValue]];
                UILabel *label9 = (UILabel *)[cell viewWithTag:100];
                label9.text = @"";
                label9.font = [UIFont boldSystemFontOfSize:14.0];
                UILabel *label10 = (UILabel *)[cell viewWithTag:20];
                label10.text = @"";
                label10.font = [UIFont boldSystemFontOfSize:14.0];
                
            } else if (indexPath.row == 8) {
                UILabel *label1 = (UILabel *)[cell viewWithTag:10];
                label1.text = @"w/Cans";
                label1.font = [UIFont boldSystemFontOfSize:14.0];
                
                UILabel *label2 = (UILabel *)[cell viewWithTag:30];
                label2.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"cansOn0"] objectForKey:@"total"] floatValue]];
                UILabel *label3 = (UILabel *)[cell viewWithTag:40];
                label3.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"cansOn1"] objectForKey:@"total"] floatValue]];
                UILabel *label4 = (UILabel *)[cell viewWithTag:50];
                label4.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"cansOn2"] objectForKey:@"total"] floatValue]];
                UILabel *label5 = (UILabel *)[cell viewWithTag:60];
                label5.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"cansOn3"] objectForKey:@"total"] floatValue]];
                UILabel *label6 = (UILabel *)[cell viewWithTag:70];
                label6.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"cansOn4"] objectForKey:@"total"] floatValue]];
                UILabel *label7 = (UILabel *)[cell viewWithTag:80];
                label7.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"cansOn5"] objectForKey:@"total"] floatValue]];
                UILabel *label8 = (UILabel *)[cell viewWithTag:90];
                label8.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"cansOn6"] objectForKey:@"total"] floatValue]];
                UILabel *label9 = (UILabel *)[cell viewWithTag:100];
                label9.text = @"";
                label9.font = [UIFont boldSystemFontOfSize:14.0];
                UILabel *label10 = (UILabel *)[cell viewWithTag:20];
                label10.text = @"";
                label10.font = [UIFont boldSystemFontOfSize:14.0];
                
                
            } else if (indexPath.row == 9) {
                UILabel *label1 = (UILabel *)[cell viewWithTag:10];
                label1.text = @"";
                UILabel *label2 = (UILabel *)[cell viewWithTag:20];
                label2.text = @"Wow Robot";
                label2.font = [UIFont boldSystemFontOfSize:14.0];
                UILabel *label3 = (UILabel *)[cell viewWithTag:30];
                label3.text = @"Wow HP";
                label3.font = [UIFont boldSystemFontOfSize:14.0];
                UILabel *label4 = (UILabel *)[cell viewWithTag:40];
                label4.text = @"Wow Driver";
                label4.font = [UIFont boldSystemFontOfSize:14.0];
                UILabel *label5 = (UILabel *)[cell viewWithTag:50];
                label5.text = @"Black Robot";
                label5.font = [UIFont boldSystemFontOfSize:14.0];
                UILabel *label6 = (UILabel *)[cell viewWithTag:60];
                label6.text = @"Black HP";
                label6.font = [UIFont boldSystemFontOfSize:14.0];
                UILabel *label7 = (UILabel *)[cell viewWithTag:70];
                label7.text = @"Black Driver";
                label7.font = [UIFont boldSystemFontOfSize:14.0];
                UILabel *label8 = (UILabel *)[cell viewWithTag:90];
                label8.text = @"Red Cards";
                label8.font = [UIFont boldSystemFontOfSize:14.0];
                UILabel *label9 = (UILabel *)[cell viewWithTag:100];
                label9.text = @"Yellow Cards";
                label9.font = [UIFont boldSystemFontOfSize:14.0];
                UILabel *label10 = (UILabel *)[cell viewWithTag:80];
                label10.text = @"";
                label10.font = [UIFont boldSystemFontOfSize:14.0];

            } else if (indexPath.row == 10) {
                UILabel *label1 = (UILabel *)[cell viewWithTag:10];
                label1.text = @"Total";
                label1.font = [UIFont boldSystemFontOfSize:14.0];
                
                UILabel *label12 = (UILabel *)[cell viewWithTag:80];
                label12.text = @"";
                label12.font = [UIFont boldSystemFontOfSize:14.0];
                UILabel *label3 = (UILabel *)[cell viewWithTag:20];
                label3.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"Wowlist Robot"] objectForKey:@"total"] floatValue]];
                UILabel *label4 = (UILabel *)[cell viewWithTag:30];
                label4.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"Wowlist HP"] objectForKey:@"total"] floatValue]];
                UILabel *label5 = (UILabel *)[cell viewWithTag:40];
                label5.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"Wowlist Driver"] objectForKey:@"total"] floatValue]];
                UILabel *label6 = (UILabel *)[cell viewWithTag:50];
                label6.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"Blacklist Robot"] objectForKey:@"total"] floatValue]];
                UILabel *label7 = (UILabel *)[cell viewWithTag:60];
                label7.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"Blacklist HP"] objectForKey:@"total"] floatValue]];
                UILabel *label8 = (UILabel *)[cell viewWithTag:70];
                label8.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"Blacklist Driver"] objectForKey:@"total"] floatValue]];
                UILabel *label9 = (UILabel *)[cell viewWithTag:90];
                label9.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"Red Cards"] objectForKey:@"total"] floatValue]];
                UILabel *label10 = (UILabel *)[cell viewWithTag:100];
                label10.text = [NSString stringWithFormat:@"%1.0f", [[[stats objectForKey:@"Yellow Cards"] objectForKey:@"total"] floatValue]];
            }
    }



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
