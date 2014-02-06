//
//  SyncViewController.m
// Robonauts Scouting
//
//  Created by FRC on 3/13/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "TabletSyncViewController.h"
#import "DataManager.h"
#import "TournamentData.h"
#import "MatchData.h"
#import "TeamData.h"
#import "TeamScore.h"
#import "TeamDataInterfaces.h"
#import "TournamentDataInterfaces.h"
#import "SyncOptionDictionary.h"
#import "SyncTypeDictionary.h"
#import "MatchResultsObject.h"

@interface TabletSyncViewController ()

@end

@implementation TabletSyncViewController {
    UIView *sendHeader;
    UILabel *sendLabel1;
    UILabel *sendLabel2;
    UILabel *sendLabel3;
    UIView *receiveHeader;
    UILabel *receiveLabel1;
    UILabel *receiveLabel2;
    UILabel *receiveLabel3;
    NSMutableArray *receivedMatches;
    NSMutableArray *receivedMatchTypes;
    MatchResultsObject *dataFromTransfer;
    id popUp;
    SyncOptionDictionary *syncOptionDictionary;
    SyncTypeDictionary *syncTypeDictionary;
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSString *deviceName;
    BlueToothType *bluetoothType;

    NSArray *tournamentList;
    NSMutableArray *filteredTournamentList;
    NSArray *receivedTournamentList;
    TournamentDataInterfaces *tournamentDataPackage;

    NSNumber *teamDataSync;
    NSArray *teamList;
    NSArray *filteredTeamList;
    NSMutableArray *receivedTeamList;
    TeamDataInterfaces *teamDataPackage;
}

@synthesize dataManager = _dataManager;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize currentSession = _currentSession;
@synthesize syncOption = _syncOption;
@synthesize syncType = _syncType;
@synthesize blueToothType = _blueToothType;
@synthesize sendDataTable = _sendDataTable;
@synthesize receiveDataTable = _receiveDataTable;
@synthesize connectButton = _connectButton;
@synthesize disconnectButton = _disconnectButton;
@synthesize sendButton = _sendButton;
@synthesize peerLabel = _peerLabel;
@synthesize peerName = _peerName;
@synthesize alertPrompt = _alertPrompt;
@synthesize alertPromptPopover = _alertPromptPopover;

GKPeerPickerController *picker;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    NSLog(@"TableSync Unload");
    prefs = nil;
    tournamentName = nil;
    sendHeader = nil;
    receiveHeader = nil;
    _fetchedResultsController = nil;
    _dataManager = nil;
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
        self.title =  [NSString stringWithFormat:@"%@ Synchronization", tournamentName];
    }
    else {
        self.title = @"Synchronization";
    }

    NSLog(@"sync option = %d", _syncOption);
    bluetoothType = [[prefs objectForKey:@"bluetooth"] intValue];
    teamDataSync = [prefs objectForKey:@"teamDataSync"];
    deviceName = [prefs objectForKey:@"deviceName"];

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
    [_connectButton setHidden:NO];
    [_disconnectButton setHidden:YES];
    [_peerLabel setHidden:YES];
    [_peerName setHidden:YES];
    
    if (bluetoothType == Scouter) {
        [_sendDataTable setHidden:NO];
        [_receiveDataTable setHidden:YES];
    }
    else {
        [_sendDataTable setHidden:YES];
        [_receiveDataTable setHidden:NO];
    }
    
    [self createHeaders];

    if (!teamDataPackage) {
        teamDataPackage = [[TeamDataInterfaces alloc] initWithDataManager:_dataManager];
    }

    if (!tournamentDataPackage) {
        tournamentDataPackage = [[TournamentDataInterfaces alloc] initWithDataManager:_dataManager];
    }

    syncOptionDictionary = [[SyncOptionDictionary alloc] init];
    _syncOptionList = [[syncOptionDictionary getSyncOptions] mutableCopy];
    [_syncOptionButton setTitle:[syncOptionDictionary getSyncOptionString:_syncOption] forState:UIControlStateNormal];

    syncTypeDictionary = [[SyncTypeDictionary alloc] init];
    _syncTypeList = [[syncTypeDictionary getSyncTypes] mutableCopy];
    [_syncTypeButton setTitle:[syncTypeDictionary getSyncTypeString:_syncType] forState:UIControlStateNormal];
}

-(void)createHeaders {
    sendHeader = [[UIView alloc] initWithFrame:CGRectMake(0,0,282,50)];
    sendHeader.backgroundColor = [UIColor lightGrayColor];
    sendHeader.opaque = YES;

    sendLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(9, 11, 55, 21)];
    sendLabel1.backgroundColor = [UIColor clearColor];
    [sendHeader addSubview:sendLabel1];

    sendLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(85, 11, 65, 21)];
    sendLabel2.backgroundColor = [UIColor clearColor];
    [sendHeader addSubview:sendLabel2];

    sendLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(195, 11, 65, 21)];
    sendLabel3.backgroundColor = [UIColor clearColor];
    [sendHeader addSubview:sendLabel3];
 
    receiveHeader = [[UIView alloc] initWithFrame:CGRectMake(0,0,282,50)];
    receiveHeader.backgroundColor = [UIColor orangeColor];
    receiveHeader.opaque = YES;
    
    [self setHeaders];
}

-(void)setHeaders {
    switch (_syncType) {
        case SyncMatchList:
        case SyncMatchResults:
            sendLabel1.text = @"Match";
            sendLabel2.text = @"Type";
            sendLabel3.text = @"Team";
            receiveLabel1.text = @"Match";
            receiveLabel2.text = @"Type";
            receiveLabel3.text = @"Team";
            break;
        case SyncTeams:
            sendLabel1.text = @"Team Number";
            sendLabel2.text = @"Team Name";
            sendLabel3.text = @"";
            receiveLabel1.text = @"Team Number";
            receiveLabel2.text = @"Team Name";
            receiveLabel3.text = @"";
            [self createTeamList];
            break;
        case SyncTournaments:
            sendLabel1.text = @"Tournament";
            sendLabel2.text = @"";
            sendLabel3.text = @"";
            receiveLabel1.text = @"Tournament";
            receiveLabel2.text = @"";
            receiveLabel3.text = @"";
        default:
            break;
    }
   
    UILabel *syncLabel = [[UILabel alloc] initWithFrame:CGRectMake(290, 11, 65, 21)];
	syncLabel.text = @"";
    syncLabel.backgroundColor = [UIColor clearColor];
    [sendHeader addSubview:syncLabel];
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
    [_sendDataTable reloadData];
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
    switch (_syncOption) {
        case SyncAll:
            filteredTeamList = [NSArray arrayWithArray:teamList];
            break;
        case SyncAllSavedHere:
            pred = [NSPredicate predicateWithFormat:@"savedBy = %@", deviceName];
            filteredTeamList = [teamList filteredArrayUsingPredicate:pred];
            break;
        case SyncAllSavedSince:
            pred = [NSPredicate predicateWithFormat:@"saved > %@", teamDataSync];
            filteredTeamList = [teamList filteredArrayUsingPredicate:pred];
            break;
        default:
            filteredTeamList = [NSArray arrayWithArray:teamList];
            break;
    }
    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:numberDescriptor, nil];
    filteredTeamList = [filteredTeamList sortedArrayUsingDescriptors:sortDescriptors];
    [_sendDataTable reloadData];
}

-(IBAction)syncChanged:(id)sender {
    UIButton * PressedButton = (UIButton*)sender;
    if (PressedButton == _syncOptionButton) {
        popUp = _syncOptionButton;
        if (_syncOptionPicker == nil) {
            _syncOptionPicker = [[PopUpPickerViewController alloc]
                             initWithStyle:UITableViewStylePlain];
            _syncOptionPicker.delegate = self;
        }
        _syncOptionPicker.pickerChoices = _syncOptionList;
        self.syncOptionPopover = [[UIPopoverController alloc]
                                    initWithContentViewController:_syncOptionPicker];
        [self.syncOptionPopover presentPopoverFromRect:PressedButton.bounds inView:PressedButton
                                permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else if (PressedButton == _syncTypeButton) {
        popUp = _syncTypeButton;
        if (_syncTypePicker == nil) {
            _syncTypePicker = [[PopUpPickerViewController alloc]
                                initWithStyle:UITableViewStylePlain];
            _syncTypePicker.delegate = self;
        }
        _syncTypePicker.pickerChoices = _syncTypeList;
        self.syncPickerPopover = [[UIPopoverController alloc]
                                   initWithContentViewController:_syncTypePicker];
        [self.syncPickerPopover presentPopoverFromRect:PressedButton.bounds inView:PressedButton
                               permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (void)pickerSelected:(NSString *)newPick {
    if (popUp == _syncOptionButton) {
        [_syncOptionPopover dismissPopoverAnimated:YES];
        _syncOptionPopover = nil;
        [self changeSyncOption:newPick];
    }
    else if (popUp == _syncTypeButton) {
        [_syncPickerPopover dismissPopoverAnimated:YES];
        _syncPickerPopover = nil;
        [self changeSyncType:newPick];
    }
}

-(void)changeSyncOption:(NSString *)newSyncOption {
    for (int i = 0 ; i < [_syncOptionList count] ; i++) {
        if ([newSyncOption isEqualToString:[_syncOptionList objectAtIndex:i]]) {
            [_syncOptionButton setTitle:newSyncOption forState:UIControlStateNormal];
            _syncOption = i;
            break;
        }
    }
    switch (_syncType) {
        case SyncTournaments:
            [self createTournamentList];
            break;
            
        case SyncTeams:
            [self createTeamList];
            break;
            
        default:
            break;
    }
}

-(void)changeSyncType:(NSString *)newSyncType {
    for (int i = 0 ; i < [_syncTypeList count] ; i++) {
        if ([newSyncType isEqualToString:[_syncTypeList objectAtIndex:i]]) {
            [_syncTypeButton setTitle:newSyncType forState:UIControlStateNormal];
            _syncType = i;
            break;
        }
    }
    [self setHeaders];
    switch (_syncType) {
        case SyncTournaments:
            [_syncOptionButton setHidden:YES];
            [self createTournamentList];
            break;
            
        case SyncTeams:
            [_syncOptionButton setHidden:NO];
            [self createTeamList];
            break;
            
        default:
            break;
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    //    NSLog(@"viewWillDisappear");
    NSError *error;
    if (![_dataManager.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

-(IBAction) btnConnect:(id) sender {
    picker = [[GKPeerPickerController alloc] init];
    picker.delegate = self;
    picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
    [_connectButton setHidden:YES];
    [_disconnectButton setHidden:NO];
    [picker show];
}

-(IBAction) btnDisconnect:(id) sender {
    [self.currentSession disconnectFromAllPeers];
    _currentSession = nil;
    
    [_connectButton setHidden:NO];
    [_disconnectButton setHidden:YES];
}

-(IBAction) createDataPackage:(id) sender {
    switch (_syncType) {
        case SyncTournaments: {
                NSData *myData = [tournamentDataPackage packageTournamentsForXFer:filteredTournamentList];
                [self mySendDataToPeers:myData];
            }
            break;
        case SyncTeams:
            for (int i=0; i<[filteredTeamList count]; i++) {
                TeamData *team = [filteredTeamList objectAtIndex:i];
                NSData *myData = [teamDataPackage packageTeamForXFer:team];
                [self mySendDataToPeers:myData];
         //       NSLog(@"Team = %@, saved = %@", team.number, team.saved);
            }
            break;
        case SyncMatchList:
            break;
        case SyncMatchResults:
            break;
            
        default:
            break;
    }
}

- (void)peerPickerController:(GKPeerPickerController *)picker
              didConnectPeer:(NSString *)peerID
                   toSession:(GKSession *) session {
    self.currentSession = session;
    session.delegate = self;
    [session setDataReceiveHandler:self withContext:nil];
    [_peerLabel setHidden:NO];
    [_peerName setHidden:NO];
    _peerName.text = [session displayNameForPeer:peerID];
    [_sendDataTable setHidden:NO];
    [_receiveDataTable setHidden:NO];
    picker.delegate = nil;
    
    [picker dismiss];

}

- (void)session:(GKSession *)sessionpeer
           peer:(NSString *)peerID
 didChangeState:(GKPeerConnectionState)state {
    switch (state)
    {
        case GKPeerStateConnected:
            NSLog(@"connected");
            // [_sendDataTable setHidden:NO];
            // [_receiveDataTable setHidden:NO];
            break;
        case GKPeerStateDisconnected:
            NSLog(@"disconnected");
            _currentSession = nil;
            [_connectButton setHidden:NO];
            [_disconnectButton setHidden:YES];
            [_peerLabel setHidden:YES];
            [_peerName setHidden:YES];
            break;
        case GKPeerStateAvailable:
        case GKPeerStateConnecting:
        case GKPeerStateUnavailable:
            break;
    }
}

- (void) mySendDataToPeers:(NSData *) data
{
    if (_currentSession)
        [self.currentSession sendDataToAllPeers:data
                                   withDataMode:GKSendDataReliable
                                          error:nil];
}

- (void) receiveData:(NSData *)data
            fromPeer:(NSString *)peer
           inSession:(GKSession *)session
             context:(void *)context {
    
    [_sendDataTable setHidden:YES];
    [_receiveDataTable setHidden:NO];
    switch (_syncType) {
        case SyncTournaments:
            receivedTournamentList = [tournamentDataPackage unpackageTournamentsForXFer:data];
            break;
        case SyncTeams: {
            if (receivedTeamList == nil) {
                receivedTeamList = [NSMutableArray array];
            }
            TeamData *teamReceived = [teamDataPackage unpackageTeamForXFer:data];
            if (teamReceived) [receivedTeamList addObject:teamReceived];
        }
            break;
        case SyncMatchList:
            break;
        case SyncMatchResults:
            break;
        default:
            break;
    }
    
    [_receiveDataTable reloadData];

/*    dataFromTransfer = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    //---convert the NSData to NSString---
    if (receivedMatches == nil) {
        receivedMatches = [NSMutableArray array];
    }
    if (receivedMatchTypes == nil) {
        receivedMatchTypes = [NSMutableArray array];
    }
    if (receivedTeams == nil) {
        receivedTeams = [NSMutableArray array];
    }
    if ([self addMatchScore:dataFromTransfer]) {
        [receivedMatches addObject:dataFromTransfer.match];
        [receivedMatchTypes addObject:dataFromTransfer.matchType];
        [receivedTeams addObject:dataFromTransfer.team];
        [_receiveDataTable reloadData];
    }
    else {
        NSString* str = [NSString stringWithFormat:@"Match %@, Team %@ Already Synced", dataFromTransfer.match, dataFromTransfer.team];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sync Again?"
                                                        message:str
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
        [alert show];
    }*/
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error {
    NSLog(@"error = %@", error);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"alert");
    if (buttonIndex == 1) { // Yes
        NSLog(@"Resync Match");
        if ([self addMatchScore:dataFromTransfer]) {
            [receivedMatches addObject:dataFromTransfer.match];
            [receivedMatchTypes addObject:dataFromTransfer.matchType];
            [receivedTeamList addObject:dataFromTransfer.team];
            [_receiveDataTable reloadData];
        }        
    }
}

-(BOOL)addMatchScore:(MatchResultsObject *) xferData {
    // Fetch score record
    // Copy the data into the right places
    // Put the match drawing in the correct directory
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"TeamScore" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"match.number == %@ AND match.matchType CONTAINS %@ and tournament.name CONTAINS %@ and team.number == %@", xferData.match, xferData.matchType, xferData.tournament, xferData.team];
    [fetchRequest setPredicate:predicate];
    
    NSArray *scoreData = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!scoreData) {
        NSLog(@"Karma disruption error");
        return FALSE;
    }
    else {
        if([scoreData count] > 0) {  // Match Exists
            TeamScore *score = [scoreData objectAtIndex:0];
 /*           if ([score.saved intValue]) {
                // Match already saved on this device
                return FALSE;
            }*/
            [self unpackXferData:xferData forScore:score];
            return TRUE;
        }
        else {
            return FALSE;
        }
    }
}

-(void)unpackXferData:(MatchResultsObject *)xferData forScore:(TeamScore *)score {
    score.alliance = xferData.alliance;
    score.autonHigh = xferData.autonHigh;
    score.autonLow = xferData.autonLow;
    score.autonMid = xferData.autonMid;
    score.autonMissed = xferData.autonMissed;
    score.autonShotsMade = xferData.autonShotsMade;
    score.blocks = xferData.blocks;
    score.climbAttempt = xferData.climbAttempt;
    score.climbLevel = xferData.climbLevel;
    score.climbTimer = xferData.climbTimer;
    score.defenseRating = xferData.defenseRating;
    score.driverRating = xferData.driverRating;
//    score.fieldDrawing = xferData.fieldDrawing;
    score.floorPickUp = xferData.floorPickUp;
    score.notes = xferData.notes;
    score.otherRating = xferData.otherRating;
    score.passes = xferData.passes;
    score.pyramid = xferData.pyramid;
    score.robotSpeed = xferData.robotSpeed;
    score.teleOpHigh = xferData.teleOpHigh;
    score.teleOpLow = xferData.teleOpLow;
    score.teleOpMid = score.teleOpMid;
    score.teleOpMissed = xferData.teleOpMissed;
    score.teleOpShots = xferData.teleOpShots;
    score.totalAutonShots = xferData.totalAutonShots;
    score.totalTeleOpShots = xferData.totalTeleOpShots;
    score.wallPickUp = xferData.wallPickUp;
    score.wallPickUp1 = xferData.wallPickUp1;
    score.wallPickUp2 = xferData.wallPickUp2;
    score.wallPickUp3 = xferData.wallPickUp3;
    score.wallPickUp4 = xferData.wallPickUp4;
    score.allianceSection = xferData.allianceSection;
    score.sc1 = xferData.sc1;
    score.sc2 = xferData.sc2;
    score.sc3 = xferData.sc3;
    score.sc4 = xferData.sc4;
    score.sc5 = xferData.sc5;
    score.sc6 = xferData.sc6;
    score.sc7 = xferData.sc7;
    score.sc8 = xferData.sc8;
    score.sc9 = xferData.sc9;
    // For now, set saved to zero so that we know that this iPad didn't do the scouting
    // score.saved = [NSNumber numberWithInt:0];
    // Set synced to one so that we know it has been received
    score.synced = [NSNumber numberWithInt:1];
    
    // Save the picture
    NSString *baseDrawingPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",xferData.drawingPath]];

    // Check if robot directory exists, if not, create it
    if (![[NSFileManager defaultManager] fileExistsAtPath:baseDrawingPath isDirectory:NO]) {
        if (![[NSFileManager defaultManager]createDirectoryAtPath:baseDrawingPath
                                      withIntermediateDirectories: YES
                                                       attributes: nil
                                                            error: NULL]) {
            NSLog(@"Dreadful error creating directory to save field drawings");
            return;
        }
    }
/*    baseDrawingPath = [baseDrawingPath stringByAppendingPathComponent:score.fieldDrawing];
    NSLog(@"score = %@", score);
    NSLog(@"base path = %@", baseDrawingPath);
    UIImage *imge = [UIImage imageWithData:xferData.fieldDrawingImage];
    [UIImagePNGRepresentation(imge) writeToFile:baseDrawingPath atomically:YES];
    NSError *error;
    if (![_dataManager.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }*/
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == _receiveDataTable) {
        return receiveHeader;
    }
    else return sendHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == _receiveDataTable) {
        return 1;
    }
    if (tableView == _sendDataTable) {
        NSInteger count = [[_fetchedResultsController sections] count];
        if (count == 0) {
            count = 1;
        }
        return count;
    }
    else {
        if ([receivedMatches count]) return 1;
        else return 0;
    }
}
        
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (tableView == _sendDataTable) {
        if (_sendDataTable.hidden) return 0;
        if (_syncType == SyncTeams) return [filteredTeamList count];
        if (_syncType == SyncTournaments) return [filteredTournamentList count];
        id <NSFetchedResultsSectionInfo> sectionInfo =
        [[_fetchedResultsController sections] objectAtIndex:section];
    
        return [sectionInfo numberOfObjects];
    }
    else {
        if (_receiveDataTable.hidden) return 0;
        if (_syncType == SyncTournaments) return [receivedTournamentList count];
    }
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

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    switch (_syncType) {
        case SyncTournaments:
            [self configureTournamentCell:cell atIndexPath:indexPath];
            break;
        case SyncTeams:
            [self configureTeamCell:cell atIndexPath:indexPath];
            break;
            
        default:
            break;
    }
}

- (void)configureReceivedTournamentCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSString *tournament = [receivedTournamentList objectAtIndex:indexPath.row];
    
	UILabel *label1 = (UILabel *)[cell viewWithTag:10];
	label1.text = tournament;
    
	UILabel *label2 = (UILabel *)[cell viewWithTag:20];
    label2.text = @"";
    
	UILabel *label3 = (UILabel *)[cell viewWithTag:30];
    label3.text = @"";
    
	UILabel *label4 = (UILabel *)[cell viewWithTag:40];
    label4.text = @"";
}

- (void)configureReceivedTeamCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    TeamData *team = [receivedTeamList objectAtIndex:indexPath.row];
    
	UILabel *label1 = (UILabel *)[cell viewWithTag:10];
	label1.text = [NSString stringWithFormat:@"%d", [team.number intValue]];
    
	UILabel *label2 = (UILabel *)[cell viewWithTag:20];
    label2.text = team.name;
    
	UILabel *label3 = (UILabel *)[cell viewWithTag:30];
    label3.text = @"";
    
	UILabel *label4 = (UILabel *)[cell viewWithTag:40];
    label4.text = @"";
}

- (void)configureReceivedCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    switch (_syncType) {
        case SyncTournaments:
            [self configureReceivedTournamentCell:cell atIndexPath:indexPath];
            break;
        case SyncTeams:
            [self configureReceivedTeamCell:cell atIndexPath:indexPath];
            break;
        default:
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _sendDataTable) {
        UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:@"SendData"];
        // Set up the cell...
        [self configureCell:cell atIndexPath:indexPath];
        return cell;
    }
    else {
        UITableViewCell *cell = [tableView
                                 dequeueReusableCellWithIdentifier:@"ReceiveData"];
        [self configureReceivedCell:cell atIndexPath:indexPath];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _receiveDataTable) return;
    
    MatchResultsObject *transferObject = [[MatchResultsObject alloc] initWithScore:[_fetchedResultsController objectAtIndexPath:indexPath]];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:transferObject];
    [self mySendDataToPeers:data];
    TeamScore *info = [_fetchedResultsController objectAtIndexPath:indexPath];
    info.synced = [NSNumber numberWithInt:1];
    NSString* str = @"Sending";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Data sending"
                                                    message:str
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];

/*
    NSLog(@"Temp =====================================================");
    TeamScore *info = [_fetchedResultsController objectAtIndexPath:indexPath];
    if (receivedMatches == nil) {
        receivedMatches = [NSMutableArray array];
    }
    if (receivedMatchTypes == nil) {
        receivedMatchTypes = [NSMutableArray array];
    }
    if (receivedTeams == nil) {
        receivedTeams = [NSMutableArray array];
    }
    [receivedMatches addObject:info.match.number];
    [receivedMatchTypes addObject:info.match.matchType];
    [receivedTeams addObject:info.team.number];
    [_receiveDataTable reloadData];
 */

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];

}

- (NSFetchedResultsController *)fetchedResultsController {
    // Set up the fetched results controller if needed.
    if (_fetchedResultsController == nil) {
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"TeamScore" inManagedObjectContext:_dataManager.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Edit the sort key as appropriate.
        NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"match.matchTypeSection" ascending:YES];
        NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"match.number" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:typeDescriptor, numberDescriptor, nil];
        NSLog(@"Fix this");
 //       NSPredicate *pred = [NSPredicate predicateWithFormat:@"ANY tournament = %@", settings.tournament];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"(ANY tournamentName = %@) AND (saved == 1)", tournamentName];
        [fetchRequest setPredicate:pred];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController =
        [[NSFetchedResultsController alloc]
         initWithFetchRequest:fetchRequest
         managedObjectContext:_dataManager.managedObjectContext
         sectionNameKeyPath:nil
         cacheName:@"Root"];
        aFetchedResultsController.delegate = self;
        self.fetchedResultsController = aFetchedResultsController;
    }
	
	return _fetchedResultsController;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
