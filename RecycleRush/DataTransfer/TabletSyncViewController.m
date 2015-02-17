//
//  TabletSyncViewController.m
//  RecycleRush
//
//  Created by FRC on 1/20/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import "TabletSyncViewController.h"
#import <QuartzCore/CALayer.h>
#import "DataManager.h"
#import "ConnectionUtility.h"
#import "Packet.h"
#import "DataSync.h"
#import "SyncTableCells.h"
#import "SyncTypeDictionary.h"
#import "SyncOptionDictionary.h"
#import "MatchIntegrityViewController.h"
#import "PopUpPickerViewController.h"

@interface TabletSyncViewController ()
@property (weak, nonatomic) IBOutlet UIView *serverView;
@property (weak, nonatomic) IBOutlet UIView *clientView;
@property (weak, nonatomic) IBOutlet UIButton *serverStatusButton;
@property (weak, nonatomic) IBOutlet UILabel *connectedClientsLabel;
@property (weak, nonatomic) IBOutlet UIButton *clientStatusButton;
@property (weak, nonatomic) IBOutlet UILabel *scoutMaster;
@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;
@property (weak, nonatomic) IBOutlet UITableView *serverTable;
@property (weak, nonatomic) IBOutlet UIButton *messageDestinationButton;
@property (weak, nonatomic) IBOutlet UIButton *quickRequestButton;
@property (weak, nonatomic) IBOutlet UIButton *matchIntegrityButton;
@property (weak, nonatomic) IBOutlet UIButton *syncOptionsButton;
@property (weak, nonatomic) IBOutlet UIButton *syncTypeButton;
@property (weak, nonatomic) IBOutlet UIButton *importExportOptions;
@property (weak, nonatomic) IBOutlet UITableView *syncDataTable;

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
    NSString *displayID;
    NSString *peerId;
	GKSession *session;
    //
    NSArray *syncTypeList;
    PopUpPickerViewController *syncTypePicker;
    UIPopoverController *syncTypePopover;
    
    NSArray *syncOptionList;
    PopUpPickerViewController *syncOptionPicker;
    UIPopoverController *syncOptionPopover;
 
    SyncType syncType;
    SyncOptions syncOption;
    NSArray *filteredSendList;

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
    NSLog(@"%@", filteredSendList);

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
    
    [self setBigButtonDefaults:_serverStatusButton];
    if (_connectionUtility.matchMakingServer) {
        // We are already set up as the server
        bluetoothRole = Master;
        session = _connectionUtility.matchMakingServer.session;
        peerId = _connectionUtility.matchMakingServer.session.peerID;
        displayID = [_connectionUtility.matchMakingServer displayNameForPeerID:peerId];
        [_serverView setHidden:FALSE];
        [_clientView setHidden:TRUE];
        [self setServerStatus];
        connectedClients = [_connectionUtility.matchMakingServer connectedClientCount];
        [self buildClientList];
    }
    else if (_connectionUtility.matchMakingClient) {
        // We are already set up as a client
        bluetoothRole = Scouter;
        session = _connectionUtility.matchMakingClient.session;
        peerId = _connectionUtility.matchMakingClient.session.peerID;
        displayID = [_connectionUtility.matchMakingClient displayNameForPeerID:peerId];
        [_serverView setHidden:TRUE];
        [_clientView setHidden:FALSE];
        [self setClientStatus];
    }
    else {
        // We are in an idle, unconnected state
        if (bluetoothRole == Master) {
            [_serverView setHidden:FALSE];
            [_clientView setHidden:TRUE];
           [self setServerStatus];
        }
        else {
            [_clientView setHidden:FALSE];
            [_serverView setHidden:TRUE];
            [self setClientStatus];
            // if no server avail, look for server on
            // if server avail, then display server in label
            // if already connected, display connected status
            // if not connected, show connect button
        }
    }
    // Set the notification to receive information after a client had connected or disconnected
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateClientStatus:) name:@"clientStatusChanged" object:nil];
    // Set the notification to receive information after the server changes status
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateServerStatus:) name:@"serverStatusChanged" object:nil];
    [_matchIntegrityButton setTitle:@"Match Integrity" forState:UIControlStateNormal];
    _matchIntegrityButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:20.0];
}

-(IBAction)serverAction:(id)sender {
    if ([_connectionUtility.matchMakingServer getServerState] == ServerStateIdle) {
        _connectionUtility.matchMakingServer = [_connectionUtility setMatchMakingServer];
        [_connectionUtility.matchMakingServer startAcceptingConnectionsForSessionID:SESSION_ID];
        peerId = _connectionUtility.matchMakingServer.session.peerID;
        displayID = [_connectionUtility.matchMakingServer displayNameForPeerID:peerId];
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

- (IBAction)clientAction:(id)sender {
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
        [_serverStatusButton setTitle:@"Server Running" forState:UIControlStateNormal];
        [_serverStatusButton setBackgroundImage:[UIImage imageNamed:@"Small Green Button.jpg"] forState:UIControlStateNormal];
        [_serverStatusButton setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
    }
    else {
        [_serverStatusButton setTitle:@"Start Server" forState:UIControlStateNormal];
        [_serverStatusButton setBackgroundImage:[UIImage imageNamed:@"Small Red Button.jpg"] forState:UIControlStateNormal];
        [_serverStatusButton setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
        [_quickRequestButton setHidden:TRUE];
        [_messageDestinationButton setHidden:TRUE];
        [_connectedClientsLabel setHidden:TRUE];
    }
}

-(void)setClientStatus {
    switch ([_connectionUtility.matchMakingClient getClientState]) {
        case ClientStateIdle:
            [_clientStatusButton setTitle:@"Look for Server" forState:UIControlStateNormal];
            [_clientStatusButton setBackgroundImage:[UIImage imageNamed:@"Small Red Button.jpg"] forState:UIControlStateNormal];
            [_clientStatusButton setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
            [_scoutMaster setHidden:TRUE];
            [_instructionLabel setHidden:TRUE];
            [_serverTable setHidden:TRUE];
            break;
            
        case ClientStateSearchingForServers:
            [_scoutMaster setHidden:TRUE];
            [_clientStatusButton setTitle:@"Search in Process" forState:UIControlStateNormal];
            [_serverTable setUserInteractionEnabled:NO];
            [_clientStatusButton setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
            break;

        case ClientStateConnecting:
            [_scoutMaster setHidden:FALSE];
            [_clientStatusButton setTitle:@"Connecting in Process" forState:UIControlStateNormal];
            _scoutMaster.text = [_connectionUtility.matchMakingClient displayNameForPeerID:[_connectionUtility.matchMakingClient peerIDForAvailableServerAtIndex:0]];
            [_clientStatusButton setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
            break;

        case ClientStateConnected:
            [_scoutMaster setHidden:FALSE];
            [_serverTable setHidden:TRUE];
            _instructionLabel.text = @"Tap \"Connected\" to disconnect";
            [_instructionLabel setHidden:FALSE];
            [_clientStatusButton setTitle:@"Connected" forState:UIControlStateNormal];
            _scoutMaster.text = [_connectionUtility.matchMakingClient displayNameForPeerID:[_connectionUtility.matchMakingClient peerIDForAvailableServerAtIndex:0]];
            [_clientStatusButton setBackgroundImage:[UIImage imageNamed:@"Small Green Button.jpg"] forState:UIControlStateNormal];
            [_clientStatusButton setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
            peerId = _connectionUtility.matchMakingClient.session.peerID;
            displayID = [_connectionUtility.matchMakingClient displayNameForPeerID:peerId];
            break;

        default:
            break;
    }
}

-(void)updateClientStatus:(NSNotification *)notification {
    if (bluetoothRole == Scouter) {
        [self setClientStatus];
        [self setServerStatus];
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
            _instructionLabel.text = @"Tap server name to connect";
            [_instructionLabel setHidden:FALSE];
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
        _connectedClientsLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)connectedClients];
        NSLog(@"%lu", (unsigned long)connectedClients);
        [self buildClientList];
        [self setServerStatus];
    }
}

-(void)buildClientList {
    if (connectedClients) {
        peerList = [[NSMutableDictionary alloc] init];
        for (int i=0; i<connectedClients; i++) {
            NSString *peerID = [_connectionUtility.matchMakingServer peerIDForConnectedClientAtIndex:i];
            [peerList setObject:peerID forKey:[_connectionUtility.matchMakingServer displayNameForPeerID:peerID]];
        }
        clientList = [[peerList allKeys] mutableCopy];
        if (connectedClients > 1) {
            [clientList sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            [clientList addObject:@"Send All"];
        }
        [_messageDestinationButton setHidden:FALSE];
        [_quickRequestButton setHidden:FALSE];
    }
    else {
        clientList = [[NSMutableArray alloc] initWithObjects:@"No Clients", nil];
        [_messageDestinationButton setHidden:TRUE];
        [_quickRequestButton setHidden:TRUE];
    }
    _connectedClientsLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)connectedClients];
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
    [clientPickerPopover presentPopoverFromRect:_messageDestinationButton.bounds inView:_messageDestinationButton
                           permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

-(void)pickerSelected:(NSString *)newPick {
    NSLog(@"Picker = %@", newPick);
    if (popUp == _messageDestinationButton) {
        [self newDestination:newPick];
    } else if (popUp == _syncTypeButton) {
        [syncTypePopover dismissPopoverAnimated:YES];
        [self selectSyncType:newPick];
    } else if (popUp == _syncOptionsButton) {
        [syncOptionPopover dismissPopoverAnimated:YES];
        [self selectSyncOption:newPick];
    }
}

-(void)newDestination:(NSString *)destination {
    [clientPickerPopover dismissPopoverAnimated:YES];
    NSUInteger index = [clientList indexOfObject:destination];
    if (index == NSNotFound) return;
    [_messageDestinationButton setTitle:destination forState:UIControlStateNormal];
    clientPicker = nil;
    clientPickerPopover = nil;
}

-(void)selectSyncType:(NSString *)typeChoice {
    [_syncTypeButton setTitle:typeChoice forState:UIControlStateNormal];
    syncType = [SyncMethods getSyncType:typeChoice];
 //   xFerOption = Sending;
    [self setSendList];
    NSLog(@"%@", filteredSendList);
    [_syncDataTable reloadData];
}

-(void)selectSyncOption:(NSString *)optionChoice {
    [_syncOptionsButton setTitle:optionChoice forState:UIControlStateNormal];
    syncOption = [SyncMethods getSyncOption:optionChoice];
    [self setSendList];
    NSLog(@"%@", filteredSendList);
    [_syncDataTable reloadData];
}

- (IBAction)quickRequest:(id)sender {
    // Create quick request packet
    Packet *packet = [Packet packetWithType:PacketTypeQuickRequest];
    // Determine if destination is one or all
    if ([_messageDestinationButton.titleLabel.text isEqualToString:@"Send All"]) {
        [_connectionUtility sendPacketToAllClients:packet inSession:session];
    }
    else {
        NSString *receiver = _messageDestinationButton.titleLabel.text;
        [_connectionUtility sendPacketToClient:packet forClient:[peerList objectForKey:receiver] inSession:session];
    }
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
    else return [filteredSendList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier1 = @"ServerList";
    UITableViewCell *cell;
    if (tableView == _serverTable) {
        cell = [tableView dequeueReusableCellWithIdentifier:identifier1 forIndexPath:indexPath];
        UILabel *label1 = (UILabel *)[cell viewWithTag:0];
        NSString *serverID = [_connectionUtility.matchMakingClient peerIDForAvailableServerAtIndex:indexPath.row];
        label1.text = [_connectionUtility.matchMakingClient displayNameForPeerID:serverID];
        return cell;
    }
    else {
        UITableViewCell *cell = [syncTableCells configureCell:tableView forTableData:[filteredSendList objectAtIndex:indexPath.row] atIndexPath:indexPath];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
	if (_connectionUtility.matchMakingClient != nil) {
	//	[self.view addSubview:self.waitView];
        
		NSString *serverID = [_connectionUtility.matchMakingClient peerIDForAvailableServerAtIndex:indexPath.row];
		[_connectionUtility.matchMakingClient connectToServerWithPeerID:serverID];
	}
}

-(void)setBigButtonDefaults:(UIButton *)currentButton {
    currentButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0];
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
