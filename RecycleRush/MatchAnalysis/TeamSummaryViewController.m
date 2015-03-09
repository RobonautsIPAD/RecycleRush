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

@interface TeamSummaryViewController ()
@property (weak, nonatomic) IBOutlet UIButton *teamNumberButton;
@property (weak, nonatomic) IBOutlet UITextField *teamNameField;
@property (weak, nonatomic) IBOutlet UITextField *matchNumberField;
@property (weak, nonatomic) IBOutlet UIButton *matchPhotoButton;
@property (nonatomic, weak) IBOutlet UITableView *matchInfo;
@property (weak, nonatomic) IBOutlet UITableView *teamStatsTable;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *homeButton;

@end

@implementation TeamSummaryViewController {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSDictionary *matchTypeDictionary;
    NSDictionary *allianceDictionary;
    UIView *matchHeader;
    NSArray *matchList;
    TeamData *currentTeam;

    NSMutableArray *teamPopUpList;
    PopUpPickerViewController *teamPicker;
    UIPopoverController *teamPickerPopover;
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
    [self showTeam];
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
}

-(void)showTeam {
    [_teamNumberButton setTitle:[NSString stringWithFormat:@"%@", currentTeam.number] forState:UIControlStateNormal];
    _teamNameField.text = currentTeam.name;
    _matchNumberField.text = [NSString stringWithFormat:@"%@", _matchNumber];
    matchList = [ScoreAccessors getMatchListForTeam:currentTeam.number forTournament:tournamentName fromDataManager:_dataManager];
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
    else if (tableView == _teamStatsTable) return [matchList count];
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
    NSLog(@"table view");
    UITableViewCell *cell = nil;
    if (tableView == _matchInfo) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MatchSchedule"];
        // Set up the cell...
        [self configureMatchCell:cell atIndexPath:indexPath];
    }
    else if (tableView == _teamStatsTable){
        cell = [tableView dequeueReusableCellWithIdentifier:@"MatchStats"];
        [self configureTeamStatsCell:cell atIndexPath:indexPath];
    }
     return cell;
}

        
- (void)configureTeamStatsCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    
        if (indexPath.row == 0) {
            UILabel *label1 = (UILabel *)[cell viewWithTag:10];
            label1.text = @"";
            UILabel *label2 = (UILabel *)[cell viewWithTag:20];
            label2.text = @"Totes Intake Landfill";
            label2.font = [UIFont boldSystemFontOfSize:16.0];
            UILabel *label3 = (UILabel *)[cell viewWithTag:30];
            label3.text = @"Totes Intake Step";
            label3.font = [UIFont boldSystemFontOfSize:16.0];
            UILabel *label4 = (UILabel *)[cell viewWithTag:40];
            label4.text = @"Totes Intake HP";
            label4.font = [UIFont boldSystemFontOfSize:16.0];
            UILabel *label5 = (UILabel *)[cell viewWithTag:50];
            label5.text = @"Cans Intake Step";
            label5.font = [UIFont boldSystemFontOfSize:16.0];
            UILabel *label6 = (UILabel *)[cell viewWithTag:60];
            label6.text = @"Cans Intake Floor";
            label6.font = [UIFont boldSystemFontOfSize:16.0];
            UILabel *label7 = (UILabel *)[cell viewWithTag:70];
            label7.text = @"Litter Intake HP";
            label7.font = [UIFont boldSystemFontOfSize:16.0];
            UILabel *label8 = (UILabel *)[cell viewWithTag:80];
            label8.text = @"Litter In Cans";
            label8.font = [UIFont boldSystemFontOfSize:16.0];
            UILabel *label9 = (UILabel *)[cell viewWithTag:90];
            label9.text = @"Can Dom";
            label9.font = [UIFont boldSystemFontOfSize:16.0];
            UILabel *label10 = (UILabel *)[cell viewWithTag:100];
            label10.text = @"Auton Can Intake";
            label10.font = [UIFont boldSystemFontOfSize:16.0];
            
        } else if (indexPath.row == 1) {
            UILabel *label1 = (UILabel *)[cell viewWithTag:10];
            label1.text = @"Total";
            label1.font = [UIFont boldSystemFontOfSize:16.0];
            
        } else if (indexPath.row == 2) {
            UILabel *label1 = (UILabel *)[cell viewWithTag:10];
            label1.text = @"Average";
            label1.font = [UIFont boldSystemFontOfSize:16.0];
            
        } else if (indexPath.row == 3) {
            UILabel *label1 = (UILabel *)[cell viewWithTag:10];
            label1.text = @"Percent";
            label1.font = [UIFont boldSystemFontOfSize:16.0];
            
        } else if (indexPath.row == 4) {
                UILabel *label1 = (UILabel *)[cell viewWithTag:10];
                label1.text = @"";
                UILabel *label2 = (UILabel *)[cell viewWithTag:20];
                label2.text = @"Knockdowns";
                label2.font = [UIFont boldSystemFontOfSize:16.0];
                UILabel *label3 = (UILabel *)[cell viewWithTag:30];
                label3.text = @"Coop Set";
                label3.font = [UIFont boldSystemFontOfSize:16.0];
                UILabel *label4 = (UILabel *)[cell viewWithTag:40];
                label4.text = @"Coop Stack";
                label4.font = [UIFont boldSystemFontOfSize:16.0];
                UILabel *label5 = (UILabel *)[cell viewWithTag:50];
                label5.text = @"Robot Set";
                label5.font = [UIFont boldSystemFontOfSize:16.0];
                UILabel *label6 = (UILabel *)[cell viewWithTag:60];
                label6.text = @"Can Set";
                label6.font = [UIFont boldSystemFontOfSize:16.0];
                UILabel *label7 = (UILabel *)[cell viewWithTag:70];
                label7.text = @"Tote Set";
                label7.font = [UIFont boldSystemFontOfSize:16.0];
                UILabel *label8 = (UILabel *)[cell viewWithTag:80];
                label8.text = @"Tote Stack";
                label8.font = [UIFont boldSystemFontOfSize:16.0];
                UILabel *label9 = (UILabel *)[cell viewWithTag:90];
                label9.text = @"Total Totes";
                label9.font = [UIFont boldSystemFontOfSize:16.0];
                UILabel *label10 = (UILabel *)[cell viewWithTag:100];
                label10.text = @"Total Cans";
                label10.font = [UIFont boldSystemFontOfSize:16.0];
            
            } else if (indexPath.row == 5) {
                UILabel *label1 = (UILabel *)[cell viewWithTag:10];
                label1.text = @"Total";
                label1.font = [UIFont boldSystemFontOfSize:16.0];
                
            } else if (indexPath.row == 6) {
                UILabel *label1 = (UILabel *)[cell viewWithTag:10];
                label1.text = @"Average";
                label1.font = [UIFont boldSystemFontOfSize:16.0];
                
            } else if (indexPath.row == 7) {
                UILabel *label1 = (UILabel *)[cell viewWithTag:10];
                label1.text = @"Percent";
                label1.font = [UIFont boldSystemFontOfSize:16.0];
            }
    }



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
