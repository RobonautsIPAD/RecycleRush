//
//  PhoneSyncViewController.m
//  RecycleRush
//
//  Created by FRC on 2/20/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "PhoneSyncViewController.h"
#import "DataManager.h"
#import "SyncMethods.h"
#import "ConnectionUtility.h"
#import "Packet.h"
#import "SyncMethods.h"
#import "TournamentData.h"
#import "TournamentUtilities.h"
#import "TeamData.h"
#import "MatchData.h"
#import "TeamScore.h"
#import "DataSync.h"
#import "SyncTableCells.h"

@interface PhoneSyncViewController ()

@property (nonatomic, weak) IBOutlet UITableView *syncDataTable;
@property (nonatomic, weak) IBOutlet UIButton *syncTypeButton;
@property (nonatomic, weak) IBOutlet UIButton *syncOptionButton;
@property (weak, nonatomic) IBOutlet UIButton *connectionStatusButton;
@property (weak, nonatomic) IBOutlet UITableView *serverTable;
@property (nonatomic, weak) IBOutlet UIButton *sendButton;
@property (nonatomic, weak) IBOutlet UIButton *packageDataButton;
@property (nonatomic, weak) IBOutlet UIButton *importFromiTunesButton;

@end

@implementation PhoneSyncViewController {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSString *deviceName;
    BlueToothType bluetoothRole;
    DataSync *dataSyncPackage;
    SyncTableCells *syncTableCells;
    
    NSArray *syncTypeList;
    NSArray *syncOptionList;
    
    UIActionSheet *xFerOptionAction;
    UIActionSheet *syncTypeAction;
    UIActionSheet *syncOptionAction;
    
    BOOL firstReceipt;
    SyncType syncType;
    SyncOptions syncOption;
    NSArray *filteredSendList;
    NSArray *receivedList;
    NSArray *displayList;
    NSUInteger nRecordsReceived;
    NSUInteger nRecordsSent;
    NSMutableArray *recordsReceived;
	GKSession *session;
    NSString *serverID;
    NSString *serverName;
    NSString *displayID;
    NSString *peerID;
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
   
    prefs = [NSUserDefaults standardUserDefaults];
    tournamentName = [prefs objectForKey:@"tournament"];
    deviceName = [prefs objectForKey:@"deviceName"];
    bluetoothRole = [[prefs objectForKey:@"bluetooth"] intValue];
    
    if (tournamentName) {
        self.title =  [NSString stringWithFormat:@"%@ Sync", tournamentName];
    } else {
        self.title = @"Sync";
    }
    
    dataSyncPackage = [[DataSync alloc] init:_dataManager];
    syncTableCells = [[SyncTableCells alloc] init:_dataManager];

    syncTypeList = [SyncMethods getSyncTypeList];
    syncOptionList = [SyncMethods getSyncOptionList];
    
    [self selectXFerOption:Receiving];
    syncType = SyncMatchList;
    syncOption = SyncAllSavedSince;
    [_syncTypeButton setTitle:[SyncMethods getPhoneSyncTypeString:syncType] forState:UIControlStateNormal];
    [_syncOptionButton setTitle:[SyncMethods getPhoneSyncOptionString:syncOption] forState:UIControlStateNormal];
    [self setSendList];
}

- (void) viewWillDisappear:(BOOL)animated {
}

#pragma mark - Transfer Options

- (IBAction)tempAction:(id)sender {
    NSError *error = nil;
    BOOL transferSuccess = [dataSyncPackage packageDataForiTunes:syncType forData:filteredSendList error:&error];
    if (!transferSuccess || error) {
        [_dataManager writeErrorMessage:error forType:[error code]];
    }
}

- (IBAction)connectionAction:(id)sender {
    if (bluetoothRole == Master) {
       // [self serverAction:sender];
    }
    else {
        [self clientAction:sender];
    }
}

- (void)clientAction:(id)sender {
    switch ([_connectionUtility.matchMakingClient getClientState]) {
        case ClientStateIdle:
            _connectionUtility.matchMakingClient = [_connectionUtility setMatchMakingClient];
            [_connectionUtility.matchMakingClient startSearchingForServersWithSessionID:SESSION_ID];
            session = _connectionUtility.matchMakingClient.session;
            [session setDataReceiveHandler:_connectionUtility withContext:nil];
            break;
            
        case ClientStateSearchingForServers:
        case ClientStateConnecting:
        case ClientStateConnected:
            NSLog(@"End Session");
            [_connectionUtility.matchMakingClient disconnectFromServer];
            session = nil;
            _connectionUtility.matchMakingClient = nil;
            break;
            
        default:
            break;
    }
}

- (IBAction)selectAction:(id)sender {
    if (sender == _syncTypeButton) {
        if (!syncTypeAction) {
            syncTypeAction = [[UIActionSheet alloc] initWithTitle:@"Select Data Sync" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
            for (NSString *item in syncTypeList) {
                [syncTypeAction addButtonWithTitle:item];
 
            }
            [syncTypeAction addButtonWithTitle:@"Cancel"];
            [syncTypeAction setCancelButtonIndex:[syncTypeList count]];
            syncTypeAction.actionSheetStyle = UIActionSheetStyleDefault;
        }
        [syncTypeAction showInView:self.view];
        } else if (sender == _syncOptionButton) {
            if (!syncOptionAction) {
                syncOptionAction = [[UIActionSheet alloc] initWithTitle:@"Select Data Type" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
                for (NSString *item in syncOptionList) {
                [syncOptionAction addButtonWithTitle:item];
            }
            [syncOptionAction addButtonWithTitle:@"Cancel"];
            [syncOptionAction setCancelButtonIndex:[syncOptionList count]];
            syncOptionAction.actionSheetStyle = UIActionSheetStyleDefault;
        }
        [syncOptionAction showInView:self.view];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) return;
    if (actionSheet == xFerOptionAction) {
        [self selectXFerOption:buttonIndex];
    } else if (actionSheet == syncTypeAction) {
        [self selectSyncType:[syncTypeList objectAtIndex:buttonIndex]];
    } else if (actionSheet == syncOptionAction) {
        [self selectSyncOption:[syncOptionList objectAtIndex:buttonIndex]];
    }
}

-(void)selectXFerOption:(NSInteger)xFerChoice {
    switch (xFerChoice) {
        case 0:     // Send button
 //           [_xFerOptionButton setTitle:@"Sending" forState:UIControlStateNormal];
            break;
        case 1:     // Receive button
//            [_xFerOptionButton setTitle:@"Receiving" forState:UIControlStateNormal];
            break;
        case 2:     // Cancel button
            NSLog(@"Cancelled");
            break;
        default:
            break;
    }
    [_syncDataTable reloadData];
}

-(void)selectSyncType:(NSString *)typeChoice {
    syncType = [SyncMethods getSyncType:typeChoice];
    [_syncTypeButton setTitle:[SyncMethods getPhoneSyncTypeString:syncType] forState:UIControlStateNormal];
    if (syncType == SyncMatchList) {
        [_syncDataTable setRowHeight:52];
    } else {
        [_syncDataTable setRowHeight:40];
    }
    [self setSendList];
    [_syncDataTable reloadData];
}

-(void)selectSyncOption:(NSString *)optionChoice {
    syncOption = [SyncMethods getSyncOption:optionChoice];
    [_syncOptionButton setTitle:[SyncMethods getPhoneSyncOptionString:syncOption] forState:UIControlStateNormal];
    [self setSendList];
    [_syncDataTable reloadData];
}

-(void)setSendList {
    if (syncType == SyncTeams) {
        filteredSendList = [dataSyncPackage getFilteredTeamList:syncOption];
    }
    else if (syncType == SyncMatchList) {
        filteredSendList = [dataSyncPackage getFilteredMatchList:syncOption];
    }
    else if (syncType == SyncMatchResults) {
        filteredSendList = [dataSyncPackage getFilteredResultsList:syncOption];
    }
    else if (syncType == SyncTournaments) {
        filteredSendList = [dataSyncPackage getFilteredTournamentList:syncOption];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _serverTable) {
        if (_connectionUtility.matchMakingClient != nil) return [_connectionUtility.matchMakingClient availableServerCount];
        else return 0;
    }
    else return [displayList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier1 = @"ServerList";
    UITableViewCell *cell;
    if (tableView == _serverTable) {
        cell = [tableView dequeueReusableCellWithIdentifier:identifier1 forIndexPath:indexPath];
        UILabel *label1 = (UILabel *)[cell viewWithTag:0];
        NSString *server = [_connectionUtility.matchMakingClient peerIDForAvailableServerAtIndex:indexPath.row];
        label1.text = [_connectionUtility.matchMakingClient displayNameForPeerID:server];
        return cell;
    }
    else {
        UITableViewCell *cell = [syncTableCells configureCell:tableView forTableData:[displayList objectAtIndex:indexPath.row] atIndexPath:indexPath];
        return cell;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
