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
#import "PacketQuickRequest.h"
#import "DataSync.h"
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

@end

@implementation TabletSyncViewController  {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSString *deviceName;
    NSNumber *bluetoothRole;
    MatchmakingServer *matchMakingServer;
    MatchmakingClient *matchMakingClient;
    ServerState serverState;
    BOOL clientState;
    DataSync *dataSyncPackage;
    NSUInteger connectedClients;
    id popUp;
    NSMutableArray *clientList;
    PopUpPickerViewController *clientPicker;
    UIPopoverController *clientPickerPopover;
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
    bluetoothRole = [prefs objectForKey:@"bluetooth"];
    
    if (tournamentName) {
        self.title = [NSString stringWithFormat:@"%@ Sync", tournamentName];
    }
    else {
        self.title = @"Sync";
    }
    //    _allianceList = [[NSMutableArray alloc] initWithObjects:@"Red 1", @"Red 2", @"Red 3", @"Blue 1", @"Blue 2", @"Blue 3", nil];

    [self setBigButtonDefaults:_serverStatusButton];
    if ([bluetoothRole intValue] == Master) {
        [_serverView setHidden:FALSE];
        [_clientView setHidden:TRUE];
        matchMakingServer = _dataManager.connectionUtility.matchMakingServer;
        serverState = [matchMakingServer getServerState];
        connectedClients = [matchMakingServer connectedClientCount];
        [self buildClientList];
        [self setServerStatus];
     //		NSLog(@"%@", matchMakingServer.session);
     }
    else {
        [_clientView setHidden:FALSE];
        [_serverView setHidden:TRUE];
        matchMakingClient = _dataManager.connectionUtility.matchMakingClient;
        [self setClientStatus];
        // if no server avail, look for server on
        // if server avail, then display server in label
            // if already connected, display connected status
            // if not connected, show connect button
    }
    // Set the notification to receive information after a client had connected or disconnected
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateClientStatus:) name:@"clientStatusChanged" object:nil];
    // Set the notification to receive information after the server changes status
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateServerStatus:) name:@"serverStatusChanged" object:nil];
}

-(IBAction)serverAction:(id)sender {
    if (serverState == ServerStateIdle) {
        if (!_dataManager.connectionUtility) {
            [_dataManager setConnectionUtility];
        }
        matchMakingServer = [_dataManager.connectionUtility setMatchMakingServer];
        [matchMakingServer startAcceptingConnectionsForSessionID:SESSION_ID];
        [matchMakingServer.session setDataReceiveHandler:_dataManager.connectionUtility withContext:nil];
    }
    else {
        NSLog(@"End Session");
        [matchMakingServer endSession];
        matchMakingServer = nil;
    }
    [self setServerStatus];
}

- (IBAction)clientAction:(id)sender {
    // idle - create client
    // looking - popup to cancel looking
    // found - connect
    // connecting - popup to cancel connecting
    // connected - popup to cancel disconnect
    switch ([matchMakingClient getClientState]) {
        case ClientStateIdle:
            if (!_dataManager.connectionUtility) {
                [_dataManager setConnectionUtility];
            }
            matchMakingClient = [_dataManager.connectionUtility setMatchMakingClient];
            [matchMakingClient startSearchingForServersWithSessionID:SESSION_ID];
            [matchMakingClient.session setDataReceiveHandler:_dataManager.connectionUtility withContext:nil];
            break;
            
        case ClientStateSearchingForServers:
        case ClientStateConnecting:
        case ClientStateConnected:
            NSLog(@"End Session");
            clientState = FALSE;
            [matchMakingClient disconnectFromServer];
            matchMakingClient = nil;
            break;
            
/*        case ClientStateFoundServer:
            [matchMakingClient connectToServerWithPeerID:[matchMakingClient peerIDForAvailableServerAtIndex:0]];
            break;*/

        default:
            break;
    }
    [self setClientStatus];
}

-(void)setServerStatus {
    serverState = [matchMakingServer getServerState];
    if (serverState) {
        [_serverStatusButton setTitle:@"Server Running" forState:UIControlStateNormal];
        [_serverStatusButton setBackgroundImage:[UIImage imageNamed:@"Small Green Button.jpg"] forState:UIControlStateNormal];
        [_serverStatusButton setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
        [_connectedClientsLabel setHidden:FALSE];
    }
    else {
        [_serverStatusButton setTitle:@"Start Server" forState:UIControlStateNormal];
        [_serverStatusButton setBackgroundImage:[UIImage imageNamed:@"Small Red Button.jpg"] forState:UIControlStateNormal];
        [_serverStatusButton setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
        [_connectedClientsLabel setHidden:TRUE];
    }
}

-(void)setClientStatus {
    switch ([matchMakingClient getClientState]) {
        case ClientStateIdle:
            clientState = FALSE;
            [_clientStatusButton setTitle:@"Look for Server" forState:UIControlStateNormal];
            [_clientStatusButton setBackgroundImage:[UIImage imageNamed:@"Small Red Button.jpg"] forState:UIControlStateNormal];
            [_clientStatusButton setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
            [_scoutMaster setHidden:TRUE];
            [_instructionLabel setHidden:TRUE];
            [_serverTable setHidden:TRUE];
            break;
            
        case ClientStateSearchingForServers:
            [_scoutMaster setHidden:TRUE];
            clientState = FALSE;
            [_clientStatusButton setTitle:@"Search in Process" forState:UIControlStateNormal];
            // [_clientStatusButton setBackgroundImage:[UIImage imageNamed:@"Small Green Button.jpg"] forState:UIControlStateNormal];
            [_clientStatusButton setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
            break;

        case ClientStateConnecting:
            [_scoutMaster setHidden:FALSE];
            clientState = FALSE;
            [_clientStatusButton setTitle:@"Connecting in Process" forState:UIControlStateNormal];
            _scoutMaster.text = [matchMakingClient displayNameForPeerID:[matchMakingClient peerIDForAvailableServerAtIndex:0]];
            // [_clientStatusButton setBackgroundImage:[UIImage imageNamed:@"Small Green Button.jpg"] forState:UIControlStateNormal];
            [_clientStatusButton setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
            break;

        case ClientStateConnected:
            [_scoutMaster setHidden:FALSE];
            [_serverTable setHidden:TRUE];
            _instructionLabel.text = @"Tap \"Connected\" to disconnect";
            [_instructionLabel setHidden:FALSE];
            clientState = TRUE;
            [_clientStatusButton setTitle:@"Connected" forState:UIControlStateNormal];
            _scoutMaster.text = [matchMakingClient displayNameForPeerID:[matchMakingClient peerIDForAvailableServerAtIndex:0]];
            [_clientStatusButton setBackgroundImage:[UIImage imageNamed:@"Small Green Button.jpg"] forState:UIControlStateNormal];
            [_clientStatusButton setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
            break;

        default:
            break;
    }
}

-(void)updateClientStatus:(NSNotification *)notification {
    if ([bluetoothRole intValue] == Scouter) {
        [self setClientStatus];
        [self setServerStatus];
    }
    else {
        connectedClients = [matchMakingServer connectedClientCount];
        NSLog(@"%@", notification);
        [self buildClientList];
        [self setServerStatus];
    }
}

-(void)updateServerStatus:(NSNotification *)notification {
    if ([bluetoothRole intValue] == Scouter) {
        if ([matchMakingClient availableServerCount]) {
            _instructionLabel.text = @"Tap server name to connect";
            [_instructionLabel setHidden:FALSE];
            [_serverTable setHidden:FALSE];
        }
        else {
            [_serverTable setHidden:TRUE];
        }
        [_serverTable reloadData];
    }
    else {
        NSLog(@"%@", notification);
        connectedClients = [matchMakingServer connectedClientCount];
        _connectedClientsLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)connectedClients];
        NSLog(@"%lu", (unsigned long)connectedClients);
        [self buildClientList];
        [self setServerStatus];
    }
}

-(void)buildClientList {
    if (connectedClients) {
        NSString *peerID = [matchMakingServer peerIDForConnectedClientAtIndex:0];
        clientList = [[NSMutableArray alloc] initWithObjects:[matchMakingServer displayNameForPeerID:peerID], nil];
        for (int i=1; i<connectedClients; i++) {
            peerID = [matchMakingServer peerIDForConnectedClientAtIndex:i];
            [clientList addObject:[matchMakingServer displayNameForPeerID:peerID]];
        }
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
//        [_quickRequestButton setHidden:TRUE];
    }
    _connectedClientsLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)connectedClients];
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

- (IBAction)quickRequest:(id)sender {
    // Create quick request packet
    Packet *packet = [Packet packetWithType:PacketTypeQuickRequest];
    // Determine if destination is one or all
    if ([_messageDestinationButton.titleLabel.text isEqualToString:@"Send All"]) {
       // [self sendPacketToAllClients:packet];
    }
    else {
        // send to just one client
    }
    [_dataManager.connectionUtility sendPacketToAllClients:packet];

}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _serverTable) {
        if (matchMakingClient != nil) return [matchMakingClient availableServerCount];
        else return 0;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier1 = @"ServerList";
    UITableViewCell *cell;
    if (tableView == _serverTable) {
        cell = [tableView dequeueReusableCellWithIdentifier:identifier1 forIndexPath:indexPath];
        UILabel *label1 = (UILabel *)[cell viewWithTag:0];
        NSString *peerID = [matchMakingClient peerIDForAvailableServerAtIndex:indexPath.row];
        label1.text = [matchMakingClient displayNameForPeerID:peerID];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
	if (matchMakingClient != nil) {
	//	[self.view addSubview:self.waitView];
        
		NSString *peerID = [matchMakingClient peerIDForAvailableServerAtIndex:indexPath.row];
		[matchMakingClient connectToServerWithPeerID:peerID];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
