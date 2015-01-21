//
//  TabletSyncViewController.m
//  RecycleRush
//
//  Created by FRC on 1/20/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import "TabletSyncViewController.h"
#import "DataManager.h"
#import "ConnectionUtility.h"
#import "DataSync.h"
#import <QuartzCore/CALayer.h>

@interface TabletSyncViewController ()
@property (weak, nonatomic) IBOutlet UIView *serverView;
@property (weak, nonatomic) IBOutlet UIView *clientView;
@property (weak, nonatomic) IBOutlet UIButton *serverStatusButton;
@property (weak, nonatomic) IBOutlet UILabel *connectedClients;
@property (weak, nonatomic) IBOutlet UIButton *clientStatusButton;
@property (weak, nonatomic) IBOutlet UILabel *scoutMaster;
@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;
@property (weak, nonatomic) IBOutlet UITableView *serverTable;

@end

@implementation TabletSyncViewController  {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSString *deviceName;
    NSNumber *bluetoothRole;
    MatchmakingServer *matchMakingServer;
    MatchmakingClient *matchMakingClient;
    BOOL serverState;
    BOOL clientState;
    DataSync *dataSyncPackage;
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
    
    [self setBigButtonDefaults:_serverStatusButton];
    if ([bluetoothRole intValue] == Master) {
        [_serverView setHidden:FALSE];
        [_clientView setHidden:TRUE];
        matchMakingServer = _dataManager.connectionUtility.matchMakingServer;
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
    if (serverState) {
        NSLog(@"End Session");
        [matchMakingServer endSession];
        matchMakingServer = nil;
    }
    else {
        if (!_dataManager.connectionUtility) {
            [_dataManager setConnectionUtility];
        }
        matchMakingServer = [_dataManager.connectionUtility setMatchMakingServer];
        [matchMakingServer startAcceptingConnectionsForSessionID:SESSION_ID];
    }
 //   [self setServerStatus];
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
            break;
            
        case ClientStateSearchingForServers:
        case ClientStateConnecting:
        case ClientStateConnected:
            NSLog(@"End Session");
            clientState = FALSE;
            [matchMakingClient disconnectFromServer];
            matchMakingClient = nil;
            break;
            
        case ClientStateFoundServer:
            [matchMakingClient connectToServerWithPeerID:[matchMakingClient peerIDForAvailableServerAtIndex:0]];
            break;

        default:
            break;
    }
    [self setClientStatus];
}

-(void)setServerStatus {
    if ([matchMakingServer getServerState]) {
        serverState = TRUE;
        [_serverStatusButton setTitle:@"Server Running" forState:UIControlStateNormal];
        [_serverStatusButton setBackgroundImage:[UIImage imageNamed:@"Small Green Button.jpg"] forState:UIControlStateNormal];
        [_serverStatusButton setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
        [_connectedClients setHidden:FALSE];
        _connectedClients.text = [NSString stringWithFormat:@"%u", [matchMakingServer connectedClientCount]];
    }
    else {
        serverState = FALSE;
        [_serverStatusButton setTitle:@"Start Server" forState:UIControlStateNormal];
        [_serverStatusButton setBackgroundImage:[UIImage imageNamed:@"Small Red Button.jpg"] forState:UIControlStateNormal];
        [_serverStatusButton setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
        [_connectedClients setHidden:TRUE];
        _connectedClients.text = @"";
    }
}

-(void)setClientStatus {
    switch ([matchMakingClient getClientState]) {
        case ClientStateIdle:
            [_clientStatusButton setTitle:@"Look for Server" forState:UIControlStateNormal];
            [_clientStatusButton setBackgroundImage:[UIImage imageNamed:@"Small Red Button.jpg"] forState:UIControlStateNormal];
            [_clientStatusButton setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
            [_scoutMaster setHidden:TRUE];
            break;
            
        case ClientStateSearchingForServers:
            [_scoutMaster setHidden:TRUE];
            clientState = FALSE;
            [_clientStatusButton setTitle:@"Search in Process" forState:UIControlStateNormal];
            // [_clientStatusButton setBackgroundImage:[UIImage imageNamed:@"Small Green Button.jpg"] forState:UIControlStateNormal];
            [_clientStatusButton setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
            break;

        case ClientStateFoundServer:
            [_scoutMaster setHidden:FALSE];
            clientState = FALSE;
            NSLog(@"add stuff for multiple servers");
            [_clientStatusButton setTitle:@"Ready to Connect" forState:UIControlStateNormal];
            _scoutMaster.text = [matchMakingClient displayNameForPeerID:[matchMakingClient peerIDForAvailableServerAtIndex:0]];
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
    }
    else {
        _connectedClients.text = [NSString stringWithFormat:@"%u", [matchMakingServer connectedClientCount]];
    }
}

-(void)updateServerStatus:(NSNotification *)notification {
    if ([bluetoothRole intValue] == Scouter) {
        if (clientState) {
            NSLog(@"Server Crash");
            clientState = FALSE;
            [matchMakingClient disconnectFromServer];
            matchMakingClient = nil;
        }
        [self setClientStatus];
    }
    else {
        _connectedClients.text = [NSString stringWithFormat:@"%u", [matchMakingServer connectedClientCount]];
        NSLog(@"%u", [matchMakingServer connectedClientCount]);
        [self setServerStatus];
    }
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
    UITableViewCell *cell;
    if (tableView == _serverTable) {
        UITableViewCell *cell = [tableView
                                 dequeueReusableCellWithIdentifier:@"ServerList"];
        UILabel *label1 = (UILabel *)[cell viewWithTag:0];
        NSString *peerID = [matchMakingClient peerIDForAvailableServerAtIndex:indexPath.row];
        label1.text = [matchMakingClient displayNameForPeerID:peerID];
    }
    return cell;
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
