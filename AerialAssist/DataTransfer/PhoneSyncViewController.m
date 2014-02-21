//
//  PhoneSyncViewController.m
//  AerialAssist
//
//  Created by FRC on 2/20/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "PhoneSyncViewController.h"
#import "DataManager.h"
#import "SyncTypeDictionary.h"
#import "SyncOptionDictionary.h"
#import "TournamentData.h"
#import "TournamentDataInterfaces.h"
#import "TeamData.h"
#import "TeamDataInterfaces.h"
#import "MatchData.h"
#import "MatchDataInterfaces.h"
#import "TeamScore.h"
#import "TeamScoreInterfaces.h"

@interface PhoneSyncViewController ()
@property (nonatomic, weak) IBOutlet UIButton *syncTypeButton;
@property (nonatomic, weak) IBOutlet UIButton *syncOptionButton;
@property (nonatomic, weak) IBOutlet UIButton *xFerOptionButton;
@property (nonatomic, weak) IBOutlet UIButton *connectButton;
@property (nonatomic, weak) IBOutlet UIButton *disconnectButton;
@property (nonatomic, weak) IBOutlet UIButton *sendButton;
@property (nonatomic, weak) IBOutlet UILabel *peerName;
@property (nonatomic, weak) IBOutlet UITableView *syncDataTable;

typedef enum {
    Sending,
	Receiving,
} XFerOption;

@end

@implementation PhoneSyncViewController {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSString *deviceName;

    XFerOption xFerOption;
    SyncType syncType;
    SyncTypeDictionary *syncTypeDictionary;
    NSMutableArray *syncTypeList;
    SyncOptions syncOption;
    SyncOptionDictionary *syncOptionDictionary;
    NSMutableArray *syncOptionList;
    UIActionSheet *xFerOptionAction;
    UIActionSheet *syncTypeAction;
    UIActionSheet *syncOptionAction;

    UIView *tableHeader;
    UILabel *headerLabel1;
    UILabel *headerLabel2;
    UILabel *headerLabel3;

    NSArray *tournamentList;
    NSMutableArray *filteredTournamentList;
    NSArray *receivedTournamentList;
    TournamentDataInterfaces *tournamentDataPackage;
    
    NSNumber *teamDataSync;
    NSArray *teamList;
    NSArray *filteredTeamList;
    NSMutableArray *receivedTeamList;
    TeamDataInterfaces *teamDataPackage;
    
    NSNumber *matchScheduleSync;
    NSArray *matchScheduleList;
    NSArray *filteredMatchList;
    NSMutableArray *receivedMatchList;
    MatchDataInterfaces *matchDataPackage;
    
    NSNumber *matchResultsSync;
    NSArray *matchResultsList;
    NSArray *filteredResultsList;
    NSMutableArray *receivedResultsList;
    TeamScoreInterfaces *matchResultsPackage;
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
    if (!_dataManager) {
        _dataManager = [[DataManager alloc] init];
    }

    prefs = [NSUserDefaults standardUserDefaults];
    tournamentName = [prefs objectForKey:@"tournament"];
    deviceName = [prefs objectForKey:@"deviceName"];
    teamDataSync = [prefs objectForKey:@"teamDataSync"];
    matchScheduleSync = [prefs objectForKey:@"matchScheduleSync"];
    matchResultsSync = [prefs objectForKey:@"matchResultsSync"];
   
    if (!tournamentDataPackage) {
        tournamentDataPackage = [[TournamentDataInterfaces alloc] initWithDataManager:_dataManager];
    }
    if (!teamDataPackage) {
        teamDataPackage = [[TeamDataInterfaces alloc] initWithDataManager:_dataManager];
    }
    if (!matchDataPackage) {
        matchDataPackage = [[MatchDataInterfaces alloc] initWithDataManager:_dataManager];
    }
    if (!matchResultsPackage) {
        matchResultsPackage = [[TeamScoreInterfaces alloc] initWithDataManager:_dataManager];
    }
    
    [_xFerOptionButton setHidden:NO];
    [_syncTypeButton setHidden:YES];
    [_syncOptionButton setHidden:YES];
    [_connectButton setHidden:YES];
    [_disconnectButton setHidden:YES];
    [_sendButton setHidden:YES];
    [_peerName setHidden:YES];
    
    syncType = SyncMatchResults;
    syncTypeDictionary = [[SyncTypeDictionary alloc] init];
    syncTypeList = [[syncTypeDictionary getSyncTypes] mutableCopy];
    [_syncTypeButton setTitle:@"Results" forState:UIControlStateNormal];
    
    syncOption = SyncAllSavedSince;
    syncOptionDictionary = [[SyncOptionDictionary alloc] init];
    syncOptionList = [[syncOptionDictionary getSyncOptions] mutableCopy];
    [_syncOptionButton setTitle:@"All" forState:UIControlStateNormal];
}

#pragma mark - Transfer Options

- (IBAction)selectAction:(id)sender {
    if (sender == _xFerOptionButton) {
        if (!xFerOptionAction) {
            xFerOptionAction = [[UIActionSheet alloc] initWithTitle:@"Select Transfer Mode" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Send Data", @"Receive Data",  nil];
            xFerOptionAction.actionSheetStyle = UIActionSheetStyleDefault;
        }
        [xFerOptionAction showInView:self.view];
    }
    else if (sender == _syncTypeButton) {
        NSLog(@"Sync Type Button");
        if (!syncTypeAction) {
            syncTypeAction = [[UIActionSheet alloc] initWithTitle:@"Select Data Sync" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
            for (NSString *item in syncTypeList) {
                [syncTypeAction addButtonWithTitle:item];
            }
            syncTypeAction.actionSheetStyle = UIActionSheetStyleDefault;
        }
        [syncTypeAction showInView:self.view];
    }
    else if (sender == _syncOptionButton) {
        NSLog(@"Sync Option Button");
        if (!syncOptionAction) {
            syncOptionAction = [[UIActionSheet alloc] initWithTitle:@"Select Data Type" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
            for (NSString *item in syncOptionList) {
                [syncOptionAction addButtonWithTitle:item];
            }
            syncOptionAction.actionSheetStyle = UIActionSheetStyleDefault;
        }
        [syncOptionAction showInView:self.view];    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (actionSheet == xFerOptionAction) {
        [self selectXFerOption:buttonIndex];
    }
    else if (actionSheet == syncTypeAction) {
        [self selectSyncType:buttonIndex];
    }
    else if (actionSheet == syncOptionAction) {
        [self selectSyncOption:buttonIndex];
    }
}

-(void)selectXFerOption:(NSInteger)xFerChoice {
    switch (xFerChoice) {
        case 0:     // Send button
            NSLog(@"Sending");
            xFerOption = Sending;
            [self updateTableData];
            [_syncTypeButton setHidden:NO];
            [_syncOptionButton setHidden:NO];
            [_connectButton setHidden:NO];
            break;
        case 1:     // Receive button
            NSLog(@"Receiving");
            xFerOption = Receiving;
            [_connectButton setHidden:NO];
            [_syncTypeButton setHidden:YES];
            [_syncOptionButton setHidden:YES];
            break;
        case 2:     // Cancel button
            NSLog(@"Cancelling");
            return;
            break;
            
        default:
            break;
    }
}

-(void)selectSyncType:(SyncType)typeChoice {
    syncType = typeChoice;
    switch (syncType) {
        case SyncTeams:
            [_syncTypeButton setTitle:@"Teams" forState:UIControlStateNormal];
            break;
        case SyncTournaments:
            [_syncTypeButton setTitle:@"Tournaments" forState:UIControlStateNormal];
            break;
        case SyncMatchResults:
            [_syncTypeButton setTitle:@"Results" forState:UIControlStateNormal];
            break;
        case SyncMatchList:
            [_syncTypeButton setTitle:@"Schedule" forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
    [self updateTableData];
}

-(void)selectSyncOption:(SyncOptions)optionChoice {
    syncOption = optionChoice;
    switch (optionChoice) {
        case SyncAll:
            [_syncOptionButton setTitle:@"All" forState:UIControlStateNormal];
            break;
        case SyncAllSavedHere:
            [_syncOptionButton setTitle:@"Local" forState:UIControlStateNormal];
            break;
        case SyncAllSavedSince:
            [_syncOptionButton setTitle:@"Latest" forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
    [self updateTableData];
}

-(void)updateTableData {
    switch (syncType) {
        case SyncTournaments:
            [self createTournamentList];
            break;
        case SyncTeams:
            [self createTeamList];
            break;
        case SyncMatchList:
            [self createMatchList];
            break;
        case SyncMatchResults:
            [self createResultsList];
            break;
        default:
            break;
    }
    [_syncDataTable reloadData];
}

-(void)createTournamentList {
    if (!tournamentList) {
        NSError *error;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:@"TournamentData" inManagedObjectContext:_dataManager.managedObjectContext];
        [fetchRequest setEntity:entity];
        tournamentList = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    }
    if (filteredTournamentList) {
        [filteredTournamentList removeAllObjects];
    }
    else {
        filteredTournamentList = [[NSMutableArray alloc] init];
    }
    for (int i=0; i<[tournamentList count]; i++) {
        [filteredTournamentList addObject:[[tournamentList objectAtIndex:i] valueForKey:@"name"]];
    }
    NSLog(@"T List = %@", filteredTournamentList);
}

-(void)createTeamList {
    if (!teamList) {
        NSError *error;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:@"TeamData" inManagedObjectContext:_dataManager.managedObjectContext];
        [fetchRequest setEntity:entity];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"ANY tournament.name = %@", tournamentName];
        [fetchRequest setPredicate:pred];
        teamList = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    }
    
    NSPredicate *pred;
    filteredTeamList = [NSArray arrayWithArray:teamList];
    switch (syncOption) {
        case SyncAll:
            filteredTeamList = [NSArray arrayWithArray:teamList];
            break;
        case SyncAllSavedHere:
            pred = [NSPredicate predicateWithFormat:@"savedBy = %@", deviceName];
            filteredTeamList = [teamList filteredArrayUsingPredicate:pred];
            break;
        case SyncAllSavedSince:
            // For the phone, we are interested in passing along anything
            //  saved or received
            pred = [NSPredicate predicateWithFormat:@"saved > %@ OR received > %@", teamDataSync, teamDataSync];
            filteredTeamList = [teamList filteredArrayUsingPredicate:pred];
            break;
        default:
            filteredTeamList = [NSArray arrayWithArray:teamList];
            break;
    }
    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:numberDescriptor, nil];
    filteredTeamList = [filteredTeamList sortedArrayUsingDescriptors:sortDescriptors];
}

-(void)createMatchList {
    if (!matchScheduleList) {
        NSError *error;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:@"MatchData" inManagedObjectContext:_dataManager.managedObjectContext];
        [fetchRequest setEntity:entity];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"tournamentName = %@", tournamentName];
        [fetchRequest setPredicate:pred];
        matchScheduleList = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    }
    
    NSPredicate *pred;
    filteredMatchList = [NSArray arrayWithArray:matchScheduleList];
    switch (syncOption) {
        case SyncAll:
            filteredMatchList = [NSArray arrayWithArray:matchScheduleList];
            break;
        case SyncAllSavedHere:
            pred = [NSPredicate predicateWithFormat:@"savedBy = %@", deviceName];
            filteredMatchList = [matchScheduleList filteredArrayUsingPredicate:pred];
            break;
        case SyncAllSavedSince:
            // For the phone, we are interested in passing along anything
            //  saved or received
            pred = [NSPredicate predicateWithFormat:@"saved > %@ OR received > %@", matchScheduleSync, matchScheduleSync];
            filteredMatchList = [matchScheduleList filteredArrayUsingPredicate:pred];
            break;
        default:
            filteredMatchList = [NSArray arrayWithArray:matchScheduleList];
            break;
    }
    NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"matchTypeSection" ascending:YES];
    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:typeDescriptor, numberDescriptor, nil];
    filteredMatchList = [filteredMatchList sortedArrayUsingDescriptors:sortDescriptors];
}

-(void)createResultsList {
    if (!matchResultsList) {
        NSError *error;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:@"TeamScore" inManagedObjectContext:_dataManager.managedObjectContext];
        [fetchRequest setEntity:entity];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"tournamentName = %@", tournamentName];
        [fetchRequest setPredicate:pred];
        matchResultsList = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    }
    
    NSPredicate *pred;
    filteredResultsList = [NSArray arrayWithArray:matchResultsList];
    switch (syncOption) {
        case SyncAll:
            filteredResultsList = [NSArray arrayWithArray:matchResultsList];
            break;
        case SyncAllSavedHere:
            pred = [NSPredicate predicateWithFormat:@"savedBy = %@", deviceName];
            filteredResultsList = [matchResultsList filteredArrayUsingPredicate:pred];
            break;
        case SyncAllSavedSince:
            // For the phone, we are interested in passing along anything
            //  saved or received
            pred = [NSPredicate predicateWithFormat:@"saved > %@ OR received > %@", matchResultsSync, matchResultsSync];
            filteredResultsList = [matchResultsList filteredArrayUsingPredicate:pred];
            break;
        default:
            filteredResultsList = [NSArray arrayWithArray:matchResultsList];
            break;
    }
    NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"match.matchTypeSection" ascending:YES];
    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"match.number" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:typeDescriptor, numberDescriptor, nil];
    filteredResultsList = [filteredResultsList sortedArrayUsingDescriptors:sortDescriptors];
}

#pragma mark - Game Kit

- (IBAction)btnConnect:(id)sender {
}

- (IBAction)btnDisconnect:(id)sender {
}

#pragma mark - Table view

/*
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == _receiveDataTable) {
        return receiveHeader;
    }
    else return sendHeader;
}
*/
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (xFerOption == Sending) {
        if (syncType == SyncTeams) return [filteredTeamList count];
        if (syncType == SyncTournaments) return [filteredTournamentList count];
        if (syncType == SyncMatchList) return [filteredMatchList count];
        if (syncType == SyncMatchResults) return [filteredResultsList count];
    }
/*    else {
        if (_receiveDataTable.hidden) return 0;
        if (_syncType == SyncTournaments) return [receivedTournamentList count];
        if (_syncType == SyncTeams) return [receivedTeamList count];
        if (_syncType == SyncMatchList) return [receivedMatchList count];
        if (_syncType == SyncMatchResults) return [receivedResultsList count];
    }*/
    return 0;
}

- (void)configureTournamentCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSString *tournament = [filteredTournamentList objectAtIndex:indexPath.row];
    // Configure the cell...
    // Set a background for the cell
    
	UILabel *label1 = (UILabel *)[cell viewWithTag:10];
	label1.text = tournament;
    
	UILabel *label2 = (UILabel *)[cell viewWithTag:20];
    label2.text = @"";
    
	UILabel *label3 = (UILabel *)[cell viewWithTag:30];
    label3.text = @"";
    
	UILabel *label4 = (UILabel *)[cell viewWithTag:40];
    label4.text = @"";
}

- (void)configureTeamCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    TeamData *team = [filteredTeamList objectAtIndex:indexPath.row];
    // Configure the cell...
    // Set a background for the cell
    
	UILabel *label1 = (UILabel *)[cell viewWithTag:10];
	label1.text = [NSString stringWithFormat:@"%d", [team.number intValue]];
    
	UILabel *label2 = (UILabel *)[cell viewWithTag:20];
    label2.text = team.name;
    
	UILabel *label3 = (UILabel *)[cell viewWithTag:30];
    label3.text = @"";
    
	UILabel *label4 = (UILabel *)[cell viewWithTag:40];
    label4.text = @"";
}

- (void)configureMatchListCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    MatchData *match = [filteredMatchList objectAtIndex:indexPath.row];
    // Configure the cell...
    // Set a background for the cell
    
	UILabel *label1 = (UILabel *)[cell viewWithTag:10];
	label1.text = [NSString stringWithFormat:@"%d", [match.number intValue]];
    
	UILabel *label2 = (UILabel *)[cell viewWithTag:20];
    label2.text = match.matchType;
    
	UILabel *label3 = (UILabel *)[cell viewWithTag:30];
    label3.text = @"";
    
	UILabel *label4 = (UILabel *)[cell viewWithTag:40];
    label4.text = @"";
}

- (void)configureResultsCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    TeamScore *score = [filteredResultsList objectAtIndex:indexPath.row];
    // Configure the cell...
    // Set a background for the cell
    
	UILabel *label1 = (UILabel *)[cell viewWithTag:10];
	label1.text = [NSString stringWithFormat:@"%d", [score.match.number intValue]];
    
	UILabel *label2 = (UILabel *)[cell viewWithTag:20];
    label2.text = score.match.matchType;
    
	UILabel *label3 = (UILabel *)[cell viewWithTag:30];
    label3.text = [NSString stringWithFormat:@"%d", [score.team.number intValue]];
    
	UILabel *label4 = (UILabel *)[cell viewWithTag:40];
    label4.text = @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView
                                dequeueReusableCellWithIdentifier:@"XFerData"];
    // Set up the cell...
    switch (syncType) {
        case SyncTournaments:
            [self configureTournamentCell:cell atIndexPath:indexPath];
            break;
        case SyncTeams:
            [self configureTeamCell:cell atIndexPath:indexPath];
            break;
        case SyncMatchList:
            [self configureMatchListCell:cell atIndexPath:indexPath];
            break;
        case SyncMatchResults:
            [self configureResultsCell:cell atIndexPath:indexPath];
            break;
     
        default:
            break;
    }
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
