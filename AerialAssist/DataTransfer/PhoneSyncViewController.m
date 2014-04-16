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
#import "SharedSyncController.h"

@interface PhoneSyncViewController ()
@property (nonatomic, weak) IBOutlet UIButton *syncTypeButton;
@property (nonatomic, weak) IBOutlet UIButton *syncOptionButton;
@property (nonatomic, weak) IBOutlet UIButton *xFerOptionButton;
@property (nonatomic, weak) IBOutlet UIButton *connectButton;
@property (nonatomic, weak) IBOutlet UIButton *disconnectButton;
@property (nonatomic, weak) IBOutlet UIButton *sendButton;
@property (nonatomic, weak) IBOutlet UILabel *peerName;
@property (nonatomic, weak) IBOutlet UITableView *syncDataTable;

@end

@implementation PhoneSyncViewController {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSString *deviceName;
    GKSession *currentSession;
    SharedSyncController *syncController;
    
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
    BOOL firstReceipt;

    UIView *tableHeader;
    UILabel *headerLabel1;
    UILabel *headerLabel2;
    UILabel *headerLabel3;
}

GKPeerPickerController *picker;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    if (!_dataManager) {
        _dataManager = [[DataManager alloc] init];
    }

    syncController = [[SharedSyncController alloc] initWithDataManager:_dataManager andTableView:_syncDataTable];
    self.syncDataTable.delegate = syncController;
    self.syncDataTable.dataSource = syncController;
    
    prefs = [NSUserDefaults standardUserDefaults];
    tournamentName = [prefs objectForKey:@"tournament"];
    deviceName = [prefs objectForKey:@"deviceName"];
    /*
    teamDataSync = [prefs objectForKey:@"teamDataSync"];
    matchScheduleSync = [prefs objectForKey:@"matchScheduleSync"];
    matchResultsSync = [prefs objectForKey:@"matchResultsSync"];
    */
    if (tournamentName) {
        self.title =  [NSString stringWithFormat:@"%@ Sync", tournamentName];
    }
    else {
        self.title = @"Sync";
    }
    /*
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
     
    firstReceipt = TRUE;
    */
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
    
    syncOption = SyncAllSavedSince;
    syncOptionDictionary = [[SyncOptionDictionary alloc] init];
    syncOptionList = [[syncOptionDictionary getSyncOptions] mutableCopy];
    
    // Set the notification to receive information after a bluetooth has been received
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionFailed:) name:@"BluetoothDeviceConnectFailedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bluetoothNotice:) name:@"BluetoothDeviceUpdatedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bluetoothNotice:) name:@"BluetoothDeviceDiscoveredNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bluetoothNotice:) name:@"BluetoothDiscoveryStateChangedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bluetoothNotice:) name:@"BluetoothConnectabilityChangedNotification" object:nil];

}

- (void) viewWillDisappear:(BOOL)animated {
    //    NSLog(@"viewWillDisappear");
    NSError *error;
    if (![_dataManager.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
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
            xFerOption = Sending;
            [_xFerOptionButton setTitle:@"Sending" forState:UIControlStateNormal];
            [_syncTypeButton setHidden:NO];
            [_syncOptionButton setHidden:NO];
            [_connectButton setHidden:NO];
            break;
        case 1:     // Receive button
            xFerOption = Receiving;
            [_xFerOptionButton setTitle:@"Receiving" forState:UIControlStateNormal];
            [_connectButton setHidden:NO];
            [_syncTypeButton setHidden:YES];
            [_syncOptionButton setHidden:YES];
            break;
        case 2:     // Cancel button
            NSLog(@"Cancelled");
            break;
        default:
            break;
    }
    [syncController setXFerOption:xFerOption];
}

-(void)selectSyncType:(SyncType)typeChoice {
    syncType = typeChoice;
    [syncController setSyncType:syncType];
    if (syncType == SyncMatchList) {
        [_syncDataTable setRowHeight:52];
    } else {
        [_syncDataTable setRowHeight:40];
    }
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
}

-(void)selectSyncOption:(SyncOptions)optionChoice {
    syncOption = optionChoice;
    [syncController setSyncOption:syncOption];
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
}
/*
-(void)updateTableData {
    switch (syncType) {
        case SyncTournaments:
            filteredTournamentList = [syncController fetchTournamentList];
            break;
        case SyncTeams:
            filteredTeamList = [syncController fetchTeamList];
            break;
        case SyncMatchList:
            filteredMatchList = [syncController fetchMatchList];
            break;
        case SyncMatchResults:
            filteredResultsList = [syncController fetchResultsList];
            break;
        default:
            break;
    }
    [_syncDataTable reloadData];
}
 
-(IBAction) createDataPackage:(id) sender {
    NSDictionary *syncDict = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:syncType]] forKeys:@[@"syncType"]];
    NSData *myData = [NSKeyedArchiver archivedDataWithRootObject:syncDict];
    NSLog(@"sync dict = %@", syncDict);
    [self mySendDataToPeers:myData];
    
    switch (syncType) {
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
            for (int i=0; i<[filteredMatchList count]; i++) {
                MatchData *match = [filteredMatchList objectAtIndex:i];
                NSData *myData = [matchDataPackage packageMatchForXFer:match];
                [self mySendDataToPeers:myData];
                NSLog(@"Match = %@, saved = %@", match.number, match.saved);
            }
            break;
        case SyncMatchResults:
            for (int i=0; i<[filteredResultsList count]; i++) {
                TeamScore *score = [filteredResultsList objectAtIndex:i];
                NSData *myData = [matchResultsPackage packageScoreForXFer:score];
                [self mySendDataToPeers:myData];
                NSLog(@"Match = %@, Type = %@, Team = %@", score.match.number, score.match.matchType, score.team.number);
            }
            break;
            
        default:
            break;
    }
}
*/
#pragma mark - Game Kit

- (IBAction)btnConnect:(id)sender {
    picker = [[GKPeerPickerController alloc] init];
    picker.delegate = self;
    picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
    [_connectButton setHidden:YES];
    [_disconnectButton setHidden:NO];
    [_sendButton setHidden:NO];
    [picker show];
}

- (IBAction)btnDisconnect:(id)sender {
    [syncController shutdownBluetooth];
    [_connectButton setHidden:NO];
    [_disconnectButton setHidden:YES];
    [_sendButton setHidden:YES];
}
/*
-(void)connectionFailed:(NSNotification *)notification {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"BOOM!"
                                                    message:@"Connection Failed."
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [self shutdownBluetooth];
    [alert show];
    [_connectButton setHidden:NO];
    [_disconnectButton setHidden:YES];
    [_sendButton setHidden:YES];
    picker.delegate = nil;
    [picker dismiss];
}

-(void)bluetoothNotice:(NSNotification *)notification {
    NSLog(@"%@ %@", notification.name, [notification userInfo]);
}

- (void)shutdownBluetooth {
    [currentSession disconnectFromAllPeers];
    currentSession.available = NO;
    [currentSession setDataReceiveHandler:nil withContext:nil];
    currentSession = nil;
    currentSession = nil;
}

- (void)peerPickerController:(GKPeerPickerController *)picker
              didConnectPeer:(NSString *)peerID
                   toSession:(GKSession *) session {
    NSLog(@"didConnectPeer");
    currentSession = session;
    session.delegate = self;
    [session setDataReceiveHandler:self withContext:nil];
    [_peerName setHidden:NO];
    _peerName.text = [session displayNameForPeer:peerID];
    firstReceipt = TRUE;
    picker.delegate = nil;
    
    [picker dismiss];
    
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError");
    NSLog(@"error = %@", error);
    [self shutdownBluetooth];
}

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker
{
    picker.delegate = nil;
    NSLog(@"Cancelling peer connect");
    [self shutdownBluetooth];
    [_connectButton setHidden:NO];
    [_sendButton setHidden:YES];
    [_disconnectButton setHidden:YES];
    [_peerName setHidden:YES];
}

-(void)session:(GKSession *)sessionpeer
          peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
    switch (state)
    {
        case GKPeerStateConnected:
            NSLog(@"connected");
            // [_sendDataTable setHidden:NO];
            // [_receiveDataTable setHidden:NO];
            break;
        case GKPeerStateDisconnected:
            NSLog(@"disconnected");
            [self shutdownBluetooth];
            [_connectButton setHidden:NO];
            [_disconnectButton setHidden:YES];
            [_sendButton setHidden:YES];
            [_peerName setHidden:YES];
            break;
        case GKPeerStateAvailable:
            NSLog(@"GKPeerStateAvailable");
            break;
        case GKPeerStateConnecting:
            NSLog(@"GKPeerStateConnecting");
            break;
        case GKPeerStateUnavailable:
            NSLog(@"GKPeerStateUnavailable");
            break;
    }
}

- (void) mySendDataToPeers:(NSData *) data
{
    if (currentSession)
        [currentSession sendDataToAllPeers:data
                                   withDataMode:GKSendDataReliable
                                          error:nil];
    switch (syncType) {
        case SyncTeams:
            teamDataSync = [NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()];
            [prefs setObject:teamDataSync forKey:@"teamDataSync"];
            break;
        case SyncMatchList:
            matchScheduleSync = [NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()];
            [prefs setObject:matchScheduleSync forKey:@"matchScheduleSync"];
            break;
        case SyncMatchResults:
            matchResultsSync = [NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()];
            [prefs setObject:matchResultsSync forKey:@"matchResultsSync"];
            break;
        default:
            break;
    }
}

- (void) receiveData:(NSData *)data
            fromPeer:(NSString *)peer
           inSession:(GKSession *)session
             context:(void *)context {
    
    if (firstReceipt) {
        NSDictionary *myType = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSLog(@"myType = %@", myType);
        [self selectSyncType:[[myType valueForKey:@"syncType"] intValue]];
        NSLog(@"sync type = %d", syncType);
        firstReceipt = FALSE;
        return;
    }
    switch (syncType) {
        case SyncTournaments:
            NSLog(@"Tournament Data Detected");
            receivedTournamentList = [tournamentDataPackage unpackageTournamentsForXFer:data];
            break;
        case SyncTeams: {
            if (receivedTeamList == nil) {
                receivedTeamList = [NSMutableArray array];
            }
            NSDictionary *teamReceived = [teamDataPackage unpackageTeamForXFer:data];
            if (teamReceived) [receivedTeamList addObject:teamReceived];
        }
            break;
        case SyncMatchList: {
            if (receivedMatchList == nil) {
                receivedMatchList = [NSMutableArray array];
            }
            NSDictionary *matchReceived = [matchDataPackage unpackageMatchForXFer:data];
            if (matchReceived) [receivedMatchList addObject:matchReceived];
        }
            break;
        case SyncMatchResults: {
            if (receivedResultsList == nil) {
                receivedResultsList = [NSMutableArray array];
            }
            NSDictionary *scoreReceived = [matchResultsPackage unpackageScoreForXFer:data];
            if (scoreReceived) [receivedResultsList addObject:scoreReceived];
        }
            break;
        default:
            break;
    }
    [_syncDataTable reloadData];
}
*/
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
