//
//  TabletSyncViewController.m
//  RecycleRush
//
//  Created by FRC on 1/20/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import "TabletSyncViewController.h"
#import "UIDefaults.h"
#import "DataManager.h"
#import "ConnectionUtility.h"
#import "Packet.h"
#import "DataSync.h"
#import "SyncTableCells.h"
#import "SyncMethods.h"
#import "MatchAccessors.h"
#import "MatchIntegrityViewController.h"
#import "PopUpPickerViewController.h"

@interface TabletSyncViewController ()
@property (weak, nonatomic) IBOutlet UIView *bluetoothView;
@property (weak, nonatomic) IBOutlet UIButton *connectionStatusButton;
@property (weak, nonatomic) IBOutlet UITableView *serverTable;
@property (weak, nonatomic) IBOutlet UIButton *connectedDeviceButton;
@property (weak, nonatomic) IBOutlet UIButton *eliminationRadio;
@property (weak, nonatomic) IBOutlet UIButton *qualificationRadio;
@property (weak, nonatomic) IBOutlet UIButton *oneMatchRadio;
@property (weak, nonatomic) IBOutlet UITextField *quickRequestMatch;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *quickRequestButton;
@property (weak, nonatomic) IBOutlet UIButton *syncOptionsButton;
@property (weak, nonatomic) IBOutlet UIButton *syncTypeButton;
@property (weak, nonatomic) IBOutlet UIButton *packageDataButton;
@property (weak, nonatomic) IBOutlet UIButton *importDataButton;
@property (weak, nonatomic) IBOutlet UIButton *createMitchButton;
@property (weak, nonatomic) IBOutlet UITableView *syncDataTable;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *homeButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *matchIntegrityButton;

@end

@implementation TabletSyncViewController  {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSString *deviceName;
    BlueToothType bluetoothRole;
    DataSync *dataSyncPackage;
    SyncTableCells *syncTableCells;
    id popUp;
    // Connection Handling
    NSUInteger connectedClients;
    NSMutableArray *clientList;
    NSMutableDictionary *peerList;
    PopUpPickerViewController *clientPicker;
    UIPopoverController *clientPickerPopover;
    NSString *serverID;
    NSString *serverName;
    NSString *displayID;
    NSString *peerID;
	GKSession *session;
    //
    NSArray *syncTypeList;
    PopUpPickerViewController *syncTypePicker;
    UIPopoverController *syncTypePopover;
    
    NSArray *syncOptionList;
    PopUpPickerViewController *syncOptionPicker;
    UIPopoverController *syncOptionPopover;

    NSArray *importFileList;
    PopUpPickerViewController *importFilePicker;
    UIPopoverController *importFilePopover;

    SyncType syncType;
    SyncOptions syncOption;
    NSArray *filteredSendList;
    NSArray *receivedList;
    NSArray *displayList;

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
    prefs = [NSUserDefaults standardUserDefaults];
    tournamentName = [prefs objectForKey:@"tournament"];
    deviceName = [prefs objectForKey:@"deviceName"];
    bluetoothRole = [[prefs objectForKey:@"bluetooth"] intValue];
    
    if (tournamentName) {
        self.title = [NSString stringWithFormat:@"%@ Sync", tournamentName];
    }
    else {
        self.title = @"Sync";
    }
    dataSyncPackage = [[DataSync alloc] init:_dataManager];
    syncTableCells = [[SyncTableCells alloc] init:_dataManager];
    syncTypeList = [SyncMethods getSyncTypeList];
    syncOptionList = [SyncMethods getSyncOptionList];
    [_syncTypeButton setTitle:@"SyncMatchResults" forState:UIControlStateNormal];
    [_syncOptionsButton setTitle:@"SyncAllSavedSince" forState:UIControlStateNormal];
    syncType = SyncMatchResults;
    syncOption = SyncAllSavedSince;
    [self setSendList];
    [_qualificationRadio setImage:[UIImage imageNamed:@"RadioButton-Selected.png"] forState:UIControlStateSelected];
    [_qualificationRadio setSelected:YES];
    // NSLog(@"%@", filteredSendList);

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
    
    [UIDefaults setBigButtonDefaults:_connectionStatusButton withFontSize:[NSNumber numberWithFloat:16.0]];
    [_serverTable setHidden:TRUE];
    [_bluetoothView setHidden:FALSE];
    if (_connectionUtility.matchMakingServer) {
        // We are already set up as the server
        bluetoothRole = Master;
        session = _connectionUtility.matchMakingServer.session;
        peerID = _connectionUtility.matchMakingServer.session.peerID;
        displayID = [_connectionUtility.matchMakingServer displayNameForPeerID:peerID];
        connectedClients = [_connectionUtility.matchMakingServer connectedClientCount];
        [self setServerStatus];
        connectedClients = [_connectionUtility.matchMakingServer connectedClientCount];
        [self buildClientList];
    }
    else if (_connectionUtility.matchMakingClient) {
        // We are already set up as a client
        bluetoothRole = Scouter;
        session = _connectionUtility.matchMakingClient.session;
        peerID = _connectionUtility.matchMakingClient.session.peerID;
        displayID = [_connectionUtility.matchMakingClient displayNameForPeerID:peerID];
        serverID = [_connectionUtility.matchMakingClient getServerID];
        serverName = [_connectionUtility.matchMakingClient displayNameForPeerID:serverID];
        [self setClientStatus];
    }
    else {
        // We are in an idle, unconnected state
        [_bluetoothView setHidden:TRUE];
        [_sendButton setHidden:TRUE];
        [_quickRequestButton setHidden:TRUE];
        [_connectedDeviceButton setHidden:TRUE];
        if (bluetoothRole == Master) {
           [self setServerStatus];
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
//    [_matchIntegrityButton setTitle:@"Match Integrity" forState:UIControlStateNormal];
//    _matchIntegrityButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:20.0];
}

- (IBAction)goHome:(id)sender {
    UINavigationController * navigationController = self.navigationController;
    [navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)connectionAction:(id)sender {
    if (bluetoothRole == Master) {
        [self serverAction:sender];
    }
    else {
        [self clientAction:sender];
    }
}

-(void)serverAction:(id)sender {
    if ([_connectionUtility.matchMakingServer getServerState] == ServerStateIdle) {
        _connectionUtility.matchMakingServer = [_connectionUtility setMatchMakingServer];
        [_connectionUtility.matchMakingServer startAcceptingConnectionsForSessionID:SESSION_ID];
        peerID = _connectionUtility.matchMakingServer.session.peerID;
        displayID = [_connectionUtility.matchMakingServer displayNameForPeerID:peerID];
        NSLog(@"%@", displayID);
        session = _connectionUtility.matchMakingServer.session;
        [session setDataReceiveHandler:_connectionUtility withContext:nil];
    }
    else {
        NSLog(@"End Session");
        [_connectionUtility.matchMakingServer endSession];
        _connectionUtility.matchMakingServer = nil;
        session = nil;
    }
    [self setServerStatus];
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

-(void)setServerStatus {
    if ([_connectionUtility.matchMakingServer getServerState]) {
        [_connectionStatusButton setTitle:[NSString stringWithFormat:@"Server Running %lu", (unsigned long)connectedClients] forState:UIControlStateNormal];
        [_connectionStatusButton setBackgroundImage:[UIImage imageNamed:@"Small Green Button.jpg"] forState:UIControlStateNormal];
        [_connectionStatusButton setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
    }
    else {
        [_connectionStatusButton setTitle:@"Start Server" forState:UIControlStateNormal];
        [_connectionStatusButton setBackgroundImage:[UIImage imageNamed:@"Small Red Button.jpg"] forState:UIControlStateNormal];
        [_connectionStatusButton setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
        [_sendButton setHidden:TRUE];
        [_quickRequestButton setHidden:TRUE];
        [_connectedDeviceButton setHidden:TRUE];
    }
}

-(void)setClientStatus {
    switch ([_connectionUtility.matchMakingClient getClientState]) {
        case ClientStateIdle:
            [_connectionStatusButton setTitle:@"Look for Server" forState:UIControlStateNormal];
            [_connectionStatusButton setBackgroundImage:[UIImage imageNamed:@"Small Red Button.jpg"] forState:UIControlStateNormal];
            [_connectionStatusButton setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
            [_serverTable setHidden:TRUE];
            break;
            
        case ClientStateSearchingForServers:
            [_connectionStatusButton setTitle:@"Search in Process" forState:UIControlStateNormal];
            [_serverTable setUserInteractionEnabled:NO];
            [_connectionStatusButton setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
            break;

        case ClientStateConnecting:
            [_connectionStatusButton setTitle:@"Connecting in Process" forState:UIControlStateNormal];
            [_connectionStatusButton setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
            break;

        case ClientStateConnected:
            [_serverTable setHidden:TRUE];
            [_connectionStatusButton setTitle:serverName forState:UIControlStateNormal];
            [_connectionStatusButton setBackgroundImage:[UIImage imageNamed:@"Small Green Button.jpg"] forState:UIControlStateNormal];
            [_connectionStatusButton setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
            peerID = _connectionUtility.matchMakingClient.session.peerID;
            displayID = [_connectionUtility.matchMakingClient displayNameForPeerID:peerID];
            [self buildClientList];
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
        connectedClients = [_connectionUtility.matchMakingServer connectedClientCount];
        NSLog(@"%@", notification);
        [self buildClientList];
        [self setServerStatus];
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
        NSLog(@"%@", notification);
        connectedClients = [_connectionUtility.matchMakingServer connectedClientCount];
        NSLog(@"%lu", (unsigned long)connectedClients);
        [self buildClientList];
        [self setServerStatus];
    }
}

-(void)buildClientList {
    if (bluetoothRole == Master) {
        if (connectedClients) {
            peerList = [[NSMutableDictionary alloc] init];
            for (int i=0; i<connectedClients; i++) {
                NSString *peer = [_connectionUtility.matchMakingServer peerIDForConnectedClientAtIndex:i];
                [peerList setObject:peer forKey:[_connectionUtility.matchMakingServer displayNameForPeerID:peer]];
            }
            clientList = [[peerList allKeys] mutableCopy];
            if (connectedClients > 1) {
                [clientList sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            }
            [_sendButton setHidden:FALSE];
            [_quickRequestButton setHidden:FALSE];
            [_connectedDeviceButton setHidden:FALSE];
            [_connectedDeviceButton setTitle:[clientList objectAtIndex:0] forState:UIControlStateNormal];
        }
        else {
            clientList = [[NSMutableArray alloc] initWithObjects:@"No Clients", nil];
            [_sendButton setHidden:TRUE];
            [_quickRequestButton setHidden:TRUE];
            [_connectedDeviceButton setHidden:TRUE];
        }
    }
    else {
        [_sendButton setHidden:FALSE];
    }
}

- (IBAction)selectAction:(id)sender {
    popUp = sender;
    if (popUp == _syncTypeButton) {
        if (syncTypePicker == nil) {
            syncTypePicker = [[PopUpPickerViewController alloc] initWithStyle:UITableViewStylePlain];
            syncTypePicker.delegate = self;
            syncTypePicker.pickerChoices = syncTypeList;
        }
        if (!syncTypePopover) {
            syncTypePopover = [[UIPopoverController alloc] initWithContentViewController:syncTypePicker];
        }
        [syncTypePopover presentPopoverFromRect:((UIButton*)popUp).bounds inView:((UIButton*)popUp) permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else if (popUp == _syncOptionsButton) {
        if (syncOptionPicker == nil) {
            syncOptionPicker = [[PopUpPickerViewController alloc]
                                initWithStyle:UITableViewStylePlain];
            syncOptionPicker.delegate = self;
            syncOptionPicker.pickerChoices = syncOptionList;
        }
        if (!syncOptionPopover) {
            syncOptionPopover = [[UIPopoverController alloc] initWithContentViewController:syncOptionPicker];
        }
        [syncOptionPopover presentPopoverFromRect:((UIButton*)popUp).bounds inView:((UIButton*)popUp) permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else if (popUp == _importDataButton) {
        if (importFilePicker == nil) {
            importFilePicker = [[PopUpPickerViewController alloc]
                                    initWithStyle:UITableViewStylePlain];
            importFilePicker.delegate = self;
        }
        importFileList = [dataSyncPackage getImportFileList];
        importFilePicker.pickerChoices = [importFileList mutableCopy];
        if (!importFilePopover) {
            importFilePopover = [[UIPopoverController alloc] initWithContentViewController:importFilePicker];
        }
        [importFilePopover presentPopoverFromRect:_importDataButton.bounds inView:_importDataButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (IBAction)destinationSelected:(id)sender {
    //    NSLog(@"destinationSelected");
    if (clientPicker == nil) {
        clientPicker = [[PopUpPickerViewController alloc]
                            initWithStyle:UITableViewStylePlain];
        clientPicker.delegate = self;
        clientPicker.pickerChoices = clientList;
        clientPickerPopover = [[UIPopoverController alloc]
                                   initWithContentViewController:clientPicker];
    }
    popUp = sender;
    [clientPickerPopover presentPopoverFromRect:_connectedDeviceButton.bounds inView:_connectedDeviceButton
                           permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

-(void)pickerSelected:(NSString *)newPick {
    // NSLog(@"Picker = %@", newPick);
    if (popUp == _connectedDeviceButton) {
        [self newDestination:newPick];
    } else if (popUp == _syncTypeButton) {
        [syncTypePopover dismissPopoverAnimated:YES];
        [self selectSyncType:newPick];
    } else if (popUp == _syncOptionsButton) {
        [syncOptionPopover dismissPopoverAnimated:YES];
        [self selectSyncOption:newPick];
    }  else if (popUp == _importDataButton) {
        [importFilePopover dismissPopoverAnimated:YES];
        [self iTunesImportSelected:newPick];
    }
}

-(void)newDestination:(NSString *)destination {
    [clientPickerPopover dismissPopoverAnimated:YES];
    NSUInteger index = [clientList indexOfObject:destination];
    if (index == NSNotFound) return;
    [_connectedDeviceButton setTitle:destination forState:UIControlStateNormal];
    clientPicker = nil;
    clientPickerPopover = nil;
}

-(void)selectSyncType:(NSString *)typeChoice {
    [_syncTypeButton setTitle:typeChoice forState:UIControlStateNormal];
    syncType = [SyncMethods getSyncType:typeChoice];
 //   xFerOption = Sending;
    [self setSendList];
    [_syncDataTable reloadData];
}

-(void)selectSyncOption:(NSString *)optionChoice {
    [_syncOptionsButton setTitle:optionChoice forState:UIControlStateNormal];
    syncOption = [SyncMethods getSyncOption:optionChoice];
    [self setSendList];
    [_syncDataTable reloadData];
}

- (IBAction)quickRequest:(id)sender {
    // Create quick request packet
    Packet *packet = [Packet packetWithType:PacketTypeQuickRequest];
    // Determine if destination is one or all
    if ([_connectedDeviceButton.titleLabel.text isEqualToString:@"Send All"]) {
        [_connectionUtility sendPacketToAllClients:packet inSession:session];
    }
    else {
        NSString *receiver = _connectedDeviceButton.titleLabel.text;
        [_connectionUtility sendPacketToClient:packet forClient:[peerList objectForKey:receiver] inSession:session];
    }
}

- (IBAction)sendThroughBluetooth:(id)sender {
    NSString *receiver = nil;
    if (bluetoothRole == Master) {
        if (![_connectedDeviceButton.titleLabel.text isEqualToString:@"Send All"]) {
            NSString *destination = _connectedDeviceButton.titleLabel.text;
            receiver = [peerList objectForKey:destination];
        }
    }
    else {
        receiver = serverID;
    }
    [dataSyncPackage bluetoothDataTranfer:filteredSendList toPeers:receiver forConnection:_connectionUtility inSession:session];
}

- (IBAction)selectPackageData:(id)sender {
    NSError *error = nil;
    BOOL transferSuccess = [dataSyncPackage packageDataForiTunes:syncType forData:filteredSendList error:&error];
    if (!transferSuccess || error) {
        [_dataManager writeErrorMessage:error forType:[error code]];
    }
}

-(void)dataReceived:(NSNotification *)notification {
    NSLog(@"%@", notification);
}

-(void)iTunesImportSelected:(NSString *)importFile {
    importFilePicker = nil;
    importFilePopover = nil;
    NSError *error;
    receivedList = [dataSyncPackage importiTunesSelected:importFile error:&error];
    if (error) {
        [_dataManager writeErrorMessage:error forType:[error code]];
    }
    displayList = receivedList;
//    importedFile = importFile;
    [_syncDataTable reloadData];
    NSLog(@"%@", displayList);
}

- (IBAction)createScoutingBundle:(id)sender {
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
    else if (syncType == SyncQuickRequest) {
        filteredSendList = nil;
        NSNumber *matchType;
        if ([_qualificationRadio isSelected]) matchType = [MatchAccessors getMatchTypeFromString:@"Qualification" fromDictionary:_dataManager.matchTypeDictionary];
        else if ([_eliminationRadio isSelected]) matchType = [MatchAccessors getMatchTypeFromString:@"Elimination" fromDictionary:_dataManager.matchTypeDictionary];
        else matchType = [MatchAccessors getMatchTypeFromString:@"Qualification" fromDictionary:_dataManager.matchTypeDictionary];
        displayList = [dataSyncPackage getQuickRequestStatus:matchType];
    }
}

-(IBAction)toggleRadioButtonState:(id)sender {
    if (sender == _qualificationRadio) {
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
}

-(void) coupledRadioButtons:(UIButton *)button1 forPair:(UIButton *)button2 {
    if ([button1 isSelected]) {
        [button1 setImage:[UIImage imageNamed:@"RadioButton-Unselected.png"] forState:UIControlStateNormal];
        [button1 setSelected:NO];
    } else {
        [button1 setImage:[UIImage imageNamed:@"RadioButton-Selected.png"] forState:UIControlStateSelected];
        [button1 setSelected:YES];
        [button2 setImage:[UIImage imageNamed:@"RadioButton-Unselected.png"] forState:UIControlStateNormal];
        [button2 setSelected:NO];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setDataManager:_dataManager];
}

@end
