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
@property (weak, nonatomic) IBOutlet UIButton *autoConnectButton;
@property (weak, nonatomic) IBOutlet UILabel *autoConnectLabel;
@property (weak, nonatomic) IBOutlet UITableView *serverTable;
@property (nonatomic, weak) IBOutlet UIButton *sendButton;
@property (nonatomic, weak) IBOutlet UIButton *packageDataButton;
@property (nonatomic, weak) IBOutlet UIButton *importFromiTunesButton;
@property (weak, nonatomic) IBOutlet UIButton *iTunesButton;

@end

@implementation PhoneSyncViewController {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSString *deviceName;
    BlueToothType bluetoothRole;
    BOOL autoConnect;
    DataSync *dataSyncPackage;
    SyncTableCells *syncTableCells;
    
    NSArray *syncTypeList;
    NSArray *syncOptionList;
    NSArray *iTunesOptionList;
    NSArray *importFileList;
    
    UIActionSheet *iTunesOptionAction;
    UIActionSheet *iTunesImportAction;
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
    autoConnect = [[prefs objectForKey:@"autoConnect"] boolValue];
    
    if (tournamentName) {
        self.title =  [NSString stringWithFormat:@"%@ Sync", tournamentName];
    } else {
        self.title = @"Sync";
    }
    
    dataSyncPackage = [[DataSync alloc] init:_dataManager];
    syncTableCells = [[SyncTableCells alloc] init:_dataManager];
    recordsReceived = [NSMutableArray array];

    syncTypeList = [SyncMethods getSyncTypeList];
    syncOptionList = [SyncMethods getSyncOptionList];
    
    syncType = SyncMatchList;
    syncOption = SyncAllSavedSince;
    [_syncTypeButton setTitle:[SyncMethods getPhoneSyncTypeString:syncType] forState:UIControlStateNormal];
    [_syncOptionButton setTitle:[SyncMethods getPhoneSyncOptionString:syncOption] forState:UIControlStateNormal];

    iTunesOptionList = [NSArray arrayWithObjects:@"Package", @"Import", nil];
    [_iTunesButton setTitle:@"iTunes" forState:UIControlStateNormal];
    [self setSendList];
    if (autoConnect) {
        [_autoConnectButton setImage:[UIImage imageNamed:@"RadioButton-Selected.png"] forState:UIControlStateSelected];
        [_autoConnectButton setSelected:YES];
    }
    else {
        [_autoConnectButton setImage:[UIImage imageNamed:@"RadioButton-Unselected.png"] forState:UIControlStateSelected];
        [_autoConnectButton setSelected:NO];
    }
    [_serverTable setHidden:TRUE];
    // Check if either server or client already exists. If both exist, bad things.
    // Check if role matches the matchmaking that is active
    // If only one is on, then set up for that role.
    // If neither are on, then set up in off mode
    // Add view did disappear to set state
    if (_connectionUtility.matchMakingServer && _connectionUtility.matchMakingClient) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Error"
                                                        message:@"All connections will be terminated"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [_connectionUtility.matchMakingServer endSession];
        _connectionUtility.matchMakingServer = nil;
        [_connectionUtility.matchMakingClient disconnectFromServer];
        _connectionUtility.matchMakingClient = nil;
    }
    if (_connectionUtility.matchMakingServer) {
        // We are already set up as the server
        if (bluetoothRole == Master) {
            // Everything is good.
            session = _connectionUtility.matchMakingServer.session;
            peerID = _connectionUtility.matchMakingServer.session.peerID;
            displayID = [_connectionUtility.matchMakingServer displayNameForPeerID:peerID];
            //        connectedClients = [_connectionUtility.matchMakingServer connectedClientCount];
            //        [self setServerStatus];
            //        connectedClients = [_connectionUtility.matchMakingServer connectedClientCount];
            //        [self buildClientList];
            //        syncType = SyncQuickRequest;
        }
        else {
            // We've switched roles. Disconnect and allow things to proceed.
            [_connectionUtility.matchMakingServer endSession];
            _connectionUtility.matchMakingServer = nil;
            //        [self setServerStatus];
            [self setClientStatus];
        }
    }
    else if (_connectionUtility.matchMakingClient) {
        // We are already set up as a client
        if (bluetoothRole == Scouter) {
            // Everything is good.
            bluetoothRole = Scouter;
            session = _connectionUtility.matchMakingClient.session;
            peerID = _connectionUtility.matchMakingClient.session.peerID;
            displayID = [_connectionUtility.matchMakingClient displayNameForPeerID:peerID];
            serverID = [_connectionUtility.matchMakingClient getServerID];
            serverName = [_connectionUtility.matchMakingClient displayNameForPeerID:serverID];
            [self setClientStatus];
        }
        else {
            // We've switched roles. Disconnect and allow things to proceed.
            [_connectionUtility.matchMakingClient disconnectFromServer];
            _connectionUtility.matchMakingClient = nil;
            //        [self setServerStatus];
            [self setClientStatus];
        }
    }
    else {
        // We are in an idle, unconnected state
        [_sendButton setHidden:TRUE];
 //       [_quickRequestButton setHidden:TRUE];
 //       [_connectedDeviceButton setHidden:TRUE];
        if (bluetoothRole == Master) {
//            [self setServerStatus];
        }
        else {
            [self setClientStatus];
        }
    }
    // Set the notification to receive information after a client had connected or disconnected
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateClientStatus:) name:@"clientStatusChanged" object:nil];
    // Set the notification to receive information after the server changes status
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateServerStatus:) name:@"serverStatusChanged" object:nil];
    // Set the notification to receive information after data is received via bluetooth
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataReceived:) name:@"ReceivedData" object:nil];
    // Set the notification to expect to receive data via bluetooth
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startReceiving:) name:@"StartReceivingData" object:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setClientStatus {
    switch ([_connectionUtility.matchMakingClient getClientState]) {
        case ClientStateIdle:
            [_connectionStatusButton setTitle:@"Connect" forState:UIControlStateNormal];
            [_connectionStatusButton setBackgroundImage:[UIImage imageNamed:@"Small Red Button.jpg"] forState:UIControlStateNormal];
            [_connectionStatusButton setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
            [_sendButton setHidden:TRUE];
            [_serverTable setHidden:TRUE];
            [_autoConnectButton setHidden:TRUE];
            [_autoConnectLabel setHidden:TRUE];
            break;
            
        case ClientStateSearchingForServers:
            [_connectionStatusButton setTitle:@"Searching" forState:UIControlStateNormal];
            [_serverTable setUserInteractionEnabled:NO];
            [_connectionStatusButton setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
            break;
            
        case ClientStateConnecting:
            [_serverTable setUserInteractionEnabled:NO];
            [_connectionStatusButton setTitle:@"Connecting" forState:UIControlStateNormal];
            [_connectionStatusButton setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
            break;
            
        case ClientStateConnected:
            [_serverTable setHidden:TRUE];
            [_sendButton setHidden:FALSE];
            [_autoConnectButton setHidden:FALSE];
            [_autoConnectLabel setHidden:FALSE];
            [_connectionStatusButton setTitle:serverName forState:UIControlStateNormal];
            [_connectionStatusButton setBackgroundImage:[UIImage imageNamed:@"Small Green Button.jpg"] forState:UIControlStateNormal];
            [_connectionStatusButton setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
            peerID = _connectionUtility.matchMakingClient.session.peerID;
            displayID = [_connectionUtility.matchMakingClient displayNameForPeerID:peerID];
            break;
            
        default:
            break;
    }
}

-(void)updateClientStatus:(NSNotification *)notification {
    if (bluetoothRole == Scouter) {
        [self setClientStatus];
    }
    else {
        /*        connectedClients = [_connectionUtility.matchMakingServer connectedClientCount];
         NSLog(@"%@", notification);
         [self buildClientList];
         [self setServerStatus];*/
    }
}
-(void)updateServerStatus:(NSNotification *)notification {
    if (bluetoothRole == Scouter) {
        if ([_connectionUtility.matchMakingClient availableServerCount]) {
            [_serverTable setHidden:FALSE];
            [_serverTable setUserInteractionEnabled:TRUE];
        }
        else {
            [_serverTable setHidden:TRUE];
        }
        [_serverTable reloadData];
    }
    else {
/*        NSLog(@"%@", notification);
        connectedClients = [_connectionUtility.matchMakingServer connectedClientCount];
        NSLog(@"%lu", (unsigned long)connectedClients);
        [self buildClientList];
        [self setServerStatus];*/
    }
}

-(IBAction)toggleRadioButtonState:(id)sender {
/*    if (sender == _qualificationRadio) {
        [self coupledRadioButtons:(UIButton *)_qualificationRadio forPair:(UIButton *)_eliminationRadio];
    }
    else if (sender == _eliminationRadio) {
        [self coupledRadioButtons:(UIButton *)_eliminationRadio forPair:(UIButton *)_qualificationRadio];
    }
    else if (sender == _oneMatchRadio) {
        if ([_oneMatchRadio isSelected]) {
            [_oneMatchRadio setImage:[UIImage imageNamed:@"RadioButton-Unselected.png"] forState:UIControlStateNormal];
            [_oneMatchRadio setSelected:NO];
        }
        else {
            [_oneMatchRadio setImage:[UIImage imageNamed:@"RadioButton-Selected.png"] forState:UIControlStateSelected];
            [_oneMatchRadio setSelected:YES];
        }
    }
    else*/
    if (sender == _autoConnectButton) {
        if ([_autoConnectButton isSelected]) {
            [_autoConnectButton setImage:[UIImage imageNamed:@"RadioButton-Unselected.png"] forState:UIControlStateNormal];
            [_autoConnectButton setSelected:NO];
            [prefs setObject:[NSNumber numberWithBool:FALSE] forKey:@"autoConnect"];
        }
        else {
            [_autoConnectButton setImage:[UIImage imageNamed:@"RadioButton-Selected.png"] forState:UIControlStateSelected];
            [_autoConnectButton setSelected:YES];
            [prefs setObject:[NSNumber numberWithBool:TRUE] forKey:@"autoConnect"];
            if (bluetoothRole == Scouter) {
                [prefs setObject:serverName forKey:@"serverName"];
            }
            else {
                [prefs setObject:@"" forKey:@"serverName"];
            }
        }
    }
}


#pragma mark - Transfer Options

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
    } else if (sender == _iTunesButton) {
        if (!iTunesOptionAction) {
            iTunesOptionAction = [[UIActionSheet alloc] initWithTitle:@"iTunes" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
            for (NSString *item in iTunesOptionList) {
                [iTunesOptionAction addButtonWithTitle:item];
            }
            [iTunesOptionAction addButtonWithTitle:@"Cancel"];
            [iTunesOptionAction setCancelButtonIndex:[iTunesOptionList count]];
            iTunesOptionAction.actionSheetStyle = UIActionSheetStyleDefault;
        }
        [iTunesOptionAction showInView:self.view];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) return;
    if (actionSheet == syncTypeAction) {
        [self selectSyncType:[syncTypeList objectAtIndex:buttonIndex]];
    } else if (actionSheet == syncOptionAction) {
        [self selectSyncOption:[syncOptionList objectAtIndex:buttonIndex]];
    } else if (actionSheet == iTunesOptionAction) {
        [self selectiTunesOption:[iTunesOptionList objectAtIndex:buttonIndex]];
    }  else if (actionSheet == iTunesImportAction) {
        NSError *error = nil;
        receivedList = [dataSyncPackage importiTunesSelected:[importFileList objectAtIndex:buttonIndex] error:&error];
        if (error) {
            [_dataManager writeErrorMessage:error forType:[error code]];
        }
        displayList = receivedList;
        //    importedFile = importFile;
        [_syncDataTable reloadData];
        //NSLog(@"%@", displayList);
    }
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


-(void)selectiTunesOption:(NSString *)optionChoice {
    if ([optionChoice isEqualToString:@"Package"]) {
        [self selectPackageData];
    }
    else {
        NSLog(@"Add import list");
        importFileList = [dataSyncPackage getImportFileList];
        if (!iTunesImportAction) {
            iTunesImportAction = [[UIActionSheet alloc] initWithTitle:@"iTunes" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
            for (NSString *item in importFileList) {
                [iTunesImportAction addButtonWithTitle:item];
            }
            [iTunesImportAction addButtonWithTitle:@"Cancel"];
            [iTunesImportAction setCancelButtonIndex:[importFileList count]];
            iTunesImportAction.actionSheetStyle = UIActionSheetStyleDefault;
        }
        [iTunesImportAction showInView:self.view];
    }
}


-(void)iTunesImportSelected:(NSString *)importFile {
    NSError *error;
    receivedList = [dataSyncPackage importiTunesSelected:importFile error:&error];
    if (error) {
        [_dataManager writeErrorMessage:error forType:[error code]];
    }
    displayList = receivedList;
    //    importedFile = importFile;
    [_syncDataTable reloadData];
    //NSLog(@"%@", displayList);
}

-(void)selectPackageData {
    NSError *error = nil;
    BOOL transferSuccess = [dataSyncPackage packageDataForiTunes:syncType forData:filteredSendList error:&error];
    if (!transferSuccess || error) {
        [_dataManager writeErrorMessage:error forType:[error code]];
    }
}

-(void)dataReceived:(NSNotification *)notification {
    NSDictionary *dictionary = [notification userInfo];
    if (![dictionary objectForKey:@"Error"]) {
        [recordsReceived addObject:dictionary];
    }
    nRecordsReceived++;
    //NSLog(@"%d", nRecordsReceived);
    if (nRecordsReceived == nRecordsSent) {
        displayList = recordsReceived;
        [_syncDataTable reloadData];
    }
}

-(void)startReceiving:(NSNotification *)notification {
    //NSLog(@"%@", notification);
    NSDictionary *dictionary = [notification userInfo];
    NSNumber *records = [dictionary objectForKey:@"Records"];
    nRecordsSent = [records unsignedLongValue];
    nRecordsReceived = 0;
    [recordsReceived removeAllObjects];
}

-(void)setSendList {
    if (syncType == SyncTeams) {
        filteredSendList = [dataSyncPackage getFilteredTeamList:syncOption];
        displayList = filteredSendList;
    }
    else if (syncType == SyncMatchList) {
        filteredSendList = [dataSyncPackage getFilteredMatchList:syncOption];
        displayList = filteredSendList;
    }
    else if (syncType == SyncMatchResults) {
        filteredSendList = [dataSyncPackage getFilteredResultsList:syncOption];
        displayList = filteredSendList;
    }
    else if (syncType == SyncTournaments) {
        filteredSendList = [dataSyncPackage getFilteredTournamentList:syncOption];
        displayList = filteredSendList;
    }
/*    else if (syncType == SyncQuickRequest) {
        filteredSendList = nil;
        NSNumber *matchType;
        if ([_qualificationRadio isSelected]) matchType = [MatchAccessors getMatchTypeFromString:@"Qualification" fromDictionary:_dataManager.matchTypeDictionary];
        else if ([_eliminationRadio isSelected]) matchType = [MatchAccessors getMatchTypeFromString:@"Elimination" fromDictionary:_dataManager.matchTypeDictionary];
        else matchType = [MatchAccessors getMatchTypeFromString:@"Qualification" fromDictionary:_dataManager.matchTypeDictionary];
        displayList = [dataSyncPackage getQuickRequestStatus:matchType];
    }*/
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
	if (_connectionUtility.matchMakingClient != nil) {
        //	[self.view addSubview:self.waitView];
		serverID = [_connectionUtility.matchMakingClient peerIDForAvailableServerAtIndex:indexPath.row];
		[_connectionUtility.matchMakingClient connectToServerWithPeerID:serverID];
        serverName = [_connectionUtility.matchMakingClient displayNameForPeerID:serverID];
	}
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
