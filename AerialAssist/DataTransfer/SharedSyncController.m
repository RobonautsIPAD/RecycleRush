//
//  SharedSyncController.m
//  AerialAssist
//
//  Created by FRC on 4/14/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "SharedSyncController.h"
#import "DataManager.h"
#import "TournamentData.h"
#import "TournamentDataInterfaces.h"
#import "TeamData.h"
#import "TeamDataInterfaces.h"
#import "MatchData.h"
#import "MatchDataInterfaces.h"
#import "TeamScore.h"
#import "TeamScoreInterfaces.h"
#import "ImportDataFromiTunes.h"

@implementation SharedSyncController {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSString *deviceName;
    GKSession *currentSession;
    
    XFerOption xFerOption;
    SyncType syncType;
    SyncOptions syncOption;
    BOOL helloReceipt;
    BOOL firstReceipt;
    
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
    
    //NSFileManager *fileManager;
    NSString *exportFilePath;
    NSString *transferFilePath;
    NSString *transferDataFile;
    
    NSArray *receivedPhotoList;
    ImportDataFromiTunes *importPackage;
}
GKPeerPickerController *picker;

/*
 * Initializes class
 */
- (id)initWithDataManager:(DataManager *)initManager {
    if (self = [super init]) {
        _dataManager = initManager;
	}
    
    [_connectButton addTarget:self action:@selector(btnConnect) forControlEvents:UIControlEventTouchUpInside];
    [_disconnectButton addTarget:self action:@selector(btnDisconnect) forControlEvents:UIControlEventTouchUpInside];
    [_sendButton addTarget:self action:@selector(btnSend) forControlEvents:UIControlEventTouchUpInside];
    [_packageDataButton addTarget:self action:@selector(packageDataForiTunes) forControlEvents:UIControlEventTouchUpInside];
    
    [_xFerOptionButton setHidden:NO];
    [_syncTypeButton setHidden:YES];
    [_syncOptionButton setHidden:YES];
    [_connectButton setHidden:YES];
    [_disconnectButton setHidden:YES];
    [_sendButton setHidden:YES];
    [_peerName setHidden:YES];
    
    // Retrieve all preferences
    prefs = [NSUserDefaults standardUserDefaults];
    tournamentName = [prefs objectForKey:@"tournament"];
    deviceName = [prefs objectForKey:@"deviceName"];
    teamDataSync = [prefs objectForKey:@"teamDataSync"];
    matchScheduleSync = [prefs objectForKey:@"matchScheduleSync"];
    matchResultsSync = [prefs objectForKey:@"matchResultsSync"];
    
    // Initialize all data packages
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
    importPackage = [[ImportDataFromiTunes alloc] init:_dataManager];
    
    // Set the notification to receive information after a bluetooth has been received
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionFailed:) name:@"BluetoothDeviceConnectFailedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bluetoothNotice:) name:@"BluetoothDeviceUpdatedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bluetoothNotice:) name:@"BluetoothDeviceDiscoveredNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bluetoothNotice:) name:@"BluetoothDiscoveryStateChangedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bluetoothNotice:) name:@"BluetoothConnectabilityChangedNotification" object:nil];
    
    return self;
}

/*
 * Bluetooth notifications and stuff
 */
- (void)connectionFailed:(NSNotification *)notification {
    [self shutdownBluetooth];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"BOOM!" message:@"Connection Failed." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [_connectButton setHidden:NO];
    [_disconnectButton setHidden:YES];
    [_sendButton setHidden:YES];
    [_peerName setHidden:YES];
    picker.delegate = nil;
    [picker dismiss];
}

- (void)bluetoothNotice:(NSNotification *)notification {
    NSLog(@"%@ %@", notification.name, [notification userInfo]);
}

- (void)shutdownBluetooth {
    [currentSession disconnectFromAllPeers];
    currentSession.available = NO;
    [currentSession setDataReceiveHandler:nil withContext:nil];
    currentSession = nil;
    _xFerOptionButton.enabled = true;
}

/*
 * Set sync options
 */
- (void)setXFerOption:(XFerOption)optionChoice {
    xFerOption = optionChoice;
    if (currentSession == nil) {
        [_connectButton setHidden:NO];
        [_disconnectButton setHidden:YES];
    } else {
        [_connectButton setHidden:YES];
        [_disconnectButton setHidden:NO];
    }
    if (xFerOption == Sending) {
        [_syncTypeButton setHidden:NO];
        [_syncOptionButton setHidden:NO];
    } else if (xFerOption == Receiving) {
        [_syncTypeButton setHidden:YES];
        [_syncOptionButton setHidden:YES];
    }
}

- (void)setSyncType:(SyncType)typeChoice {
    syncType = typeChoice;
}

- (void)setSyncOption:(SyncOptions)optionChoice {
    syncOption = optionChoice;
}

/*
 * UITableViewDataSource methods
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (xFerOption == Sending) {
        if (syncType == SyncTeams) return [filteredTeamList count];
        if (syncType == SyncTournaments) return [filteredTournamentList count];
        if (syncType == SyncMatchList) return [filteredMatchList count];
        if (syncType == SyncMatchResults) return [filteredResultsList count];
    } else if (xFerOption == Receiving) {
        NSLog(@"number of rows");
        if (syncType == SyncTournaments) return [receivedTournamentList count];
        if (syncType == SyncTeams) return [receivedTeamList count];
        if (syncType == SyncMatchList) return [receivedMatchList count];
        if (syncType == SyncMatchResults) return [receivedResultsList count];
        NSLog(@"number of rows end");
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier1 = @"Tournament";
    static NSString *identifier2 = @"Team";
    static NSString *identifier3 = @"MatchList";
    static NSString *identifier4 = @"MatchResult";
    UITableViewCell *cell;
    // Set up the cell...
    switch (syncType) {
        case SyncTournaments:
            cell = [tableView dequeueReusableCellWithIdentifier:identifier1 forIndexPath:indexPath];
            [self configureTournamentCell:cell atIndexPath:indexPath];
            break;
        case SyncTeams:
            cell = [tableView dequeueReusableCellWithIdentifier:identifier2 forIndexPath:indexPath];
            [self configureTeamCell:cell atIndexPath:indexPath];
            break;
        case SyncMatchList:
            cell = [tableView dequeueReusableCellWithIdentifier:identifier3 forIndexPath:indexPath];
            [self configureMatchListCell:cell atIndexPath:indexPath];
            break;
        case SyncMatchResults:
            cell = [tableView dequeueReusableCellWithIdentifier:identifier4 forIndexPath:indexPath];
            [self configureResultsCell:cell atIndexPath:indexPath];
            break;
        default:
            break;
    }
    return cell;
}

- (void)configureTournamentCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSArray *tournament;
    if (xFerOption == Sending) {
        tournament = [filteredTournamentList objectAtIndex:indexPath.row];
    } else {
        tournament = [receivedTournamentList objectAtIndex:indexPath.row];
    }
    
	UILabel *label1 = (UILabel *)[cell viewWithTag:10];
	label1.text = tournament[0];
    
	UILabel *label2 = (UILabel *)[cell viewWithTag:20];
    label2.text = tournament[1];
}

- (void)configureTeamCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (xFerOption == Sending) {
        TeamData *team = [filteredTeamList objectAtIndex:indexPath.row];
        
        UILabel *label1 = (UILabel *)[cell viewWithTag:10];
        label1.text = [NSString stringWithFormat:@"%@", team.number];
        
        UILabel *label2 = (UILabel *)[cell viewWithTag:20];
        label2.text = team.name;
    } else {
        NSDictionary *team = [receivedTeamList objectAtIndex:indexPath.row];
        
        UILabel *label1 = (UILabel *)[cell viewWithTag:10];
        label1.text = [NSString stringWithFormat:@"%@", [team objectForKey:@"team"]];
        
        UILabel *label2 = (UILabel *)[cell viewWithTag:20];
        label2.text = [team objectForKey:@"name"];
    }
}

- (void)configureMatchListCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (xFerOption == Sending) {
        MatchData *match = [filteredMatchList objectAtIndex:indexPath.row];
        
        NSSortDescriptor *allianceSort = [NSSortDescriptor sortDescriptorWithKey:@"allianceSection" ascending:YES];
        NSArray *data = [[match.score allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:allianceSort]];
        
        UILabel *label1 = (UILabel *)[cell viewWithTag:10];
        label1.text = [NSString stringWithFormat:@"%@", match.number];
        
        UILabel *label2 = (UILabel *)[cell viewWithTag:20];
        label2.text = [match.matchType substringToIndex:4];
        
        TeamScore *score;
        for (int i = 0; i < 6; i++) {
            score = [data objectAtIndex:i];
            UILabel *label = (UILabel *)[cell viewWithTag:(i + 3) * 10];
            label.text = [NSString stringWithFormat:@"%@", score.team.number];
        }
    } else {
        NSDictionary *match = [receivedMatchList objectAtIndex:indexPath.row];
        NSDictionary *teams = [match objectForKey:@"teams"];
        
        UILabel *label1 = (UILabel *)[cell viewWithTag:10];
        label1.text = [NSString stringWithFormat:@"%d", [[match objectForKey:@"match"] intValue]];
        
        UILabel *label2 = (UILabel *)[cell viewWithTag:20];
        label2.text = [[match objectForKey:@"type"] substringToIndex:4];
        
        UILabel *label3 = (UILabel *)[cell viewWithTag:30];
        label3.text = [NSString stringWithFormat:@"%@", [teams objectForKey:@"Red 1"]];
        
        UILabel *label4 = (UILabel *)[cell viewWithTag:40];
        label4.text = [NSString stringWithFormat:@"%@", [teams objectForKey:@"Red 2"]];
        
        UILabel *label5 = (UILabel *)[cell viewWithTag:50];
        label5.text = [NSString stringWithFormat:@"%@", [teams objectForKey:@"Red 3"]];
        
        UILabel *label6 = (UILabel *)[cell viewWithTag:60];
        label6.text = [NSString stringWithFormat:@"%@", [teams objectForKey:@"Blue 1"]];
        
        UILabel *label7 = (UILabel *)[cell viewWithTag:70];
        label7.text = [NSString stringWithFormat:@"%@", [teams objectForKey:@"Blue 2"]];
        
        UILabel *label8 = (UILabel *)[cell viewWithTag:80];
        label8.text = [NSString stringWithFormat:@"%@", [teams objectForKey:@"Blue 3"]];
    }
}

- (void)configureResultsCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (xFerOption == Sending) {
        TeamScore *score = [filteredResultsList objectAtIndex:indexPath.row];
        
        UILabel *label1 = (UILabel *)[cell viewWithTag:10];
        label1.text = [NSString stringWithFormat:@"%@", score.match.number];
        
        UILabel *label2 = (UILabel *)[cell viewWithTag:20];
        label2.text = [score.match.matchType substringToIndex:4];
        
        UILabel *label3 = (UILabel *)[cell viewWithTag:30];
        label3.text = score.alliance;
        
        UILabel *label4 = (UILabel *)[cell viewWithTag:40];
        label4.text = [NSString stringWithFormat:@"%@", score.team.number];
        
        UILabel *label5 = (UILabel *)[cell viewWithTag:50];
        label5.text = [NSString stringWithFormat:@"%@", score.results];
        
        UIColor *color;
        if ([[score.alliance substringToIndex:1] isEqualToString:@"R"]) {
            color = [UIColor colorWithRed:1 green: 0 blue: 0 alpha:1];
        } else {
            color = [UIColor colorWithRed:0 green: 0 blue: 1 alpha:1];
        }
        label3.textColor = color;
        label4.textColor = color;
        label5.textColor = color;
    } else {
        NSDictionary *score = [receivedResultsList objectAtIndex:indexPath.row];
        
        UILabel *label1 = (UILabel *)[cell viewWithTag:10];
        label1.text = [NSString stringWithFormat:@"%@", [score objectForKey:@"match"]];
        
        UILabel *label2 = (UILabel *)[cell viewWithTag:20];
        label2.text = [[score objectForKey:@"type"] substringToIndex:4];
        
        UILabel *label3 = (UILabel *)[cell viewWithTag:30];
        label3.text = [score objectForKey:@"alliance"];
        
        UILabel *label4 = (UILabel *)[cell viewWithTag:40];
        label4.text = [NSString stringWithFormat:@"%@", [score objectForKey:@"team"]];
        
        UILabel *label5 = (UILabel *)[cell viewWithTag:50];
        label5.text = [NSString stringWithFormat:@"%@", [score objectForKey:@"results"]];
        
        UIColor *color;
        if ([[[score objectForKey:@"alliance"] substringToIndex:1] isEqualToString:@"R"]) {
            color = [UIColor colorWithRed:1 green: 0 blue: 0 alpha:1];
        } else {
            color = [UIColor colorWithRed:0 green: 0 blue: 1 alpha:1];
        }
        label3.textColor = color;
        label4.textColor = color;
        label5.textColor = color;
    }
}

/*
 * Updates data in the table
 */
- (void)updateTableData {
    switch (syncType) {
        case SyncTournaments:
            filteredTournamentList = [self fetchTournamentList];
            break;
        case SyncTeams:
            filteredTeamList = [self fetchTeamList];
            break;
        case SyncMatchList:
            filteredMatchList = [self fetchMatchList];
            break;
        case SyncMatchResults:
            filteredResultsList = [self fetchResultsList];
            break;
        default:
            break;
    }
    [_syncDataTable reloadData];
}

/*
 * Fetches filtered lists
 */
- (NSMutableArray *)fetchTournamentList {
    if (!tournamentList) {
        NSError *error;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"TournamentData" inManagedObjectContext:_dataManager.managedObjectContext];
        [fetchRequest setEntity:entity];
        tournamentList = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    }
    
    if (filteredTournamentList) {
        [filteredTournamentList removeAllObjects];
    } else {
        filteredTournamentList = [[NSMutableArray alloc] init];
    }
    for (int i = 0; i < [tournamentList count]; i++) {
        [filteredTournamentList addObject:[NSArray arrayWithObjects:[[tournamentList objectAtIndex:i] valueForKey:@"code"], [[tournamentList objectAtIndex:i] valueForKey:@"name"], nil]];
    }
    
    return filteredTournamentList;
}

- (NSArray *)fetchTeamList {
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
    
    return filteredTeamList;
}

- (NSArray *)fetchMatchList {
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
    
    return filteredMatchList;
}

- (NSArray *)fetchResultsList {
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
    
    return filteredResultsList;
}

/*
 * GKSessionDelegate methods
 */
- (void)session:(GKSession *)sessionpeer peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
    switch (state) {
        case GKPeerStateConnected:
            NSLog(@"connected");
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

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID {
    NSLog(@"didReceiveConnectionRequestFromPeer");
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error {
    NSLog(@"connectionWithPeerFailed");
    NSLog(@"error = %@", error);
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError");
    NSLog(@"error = %@", error);
    [self shutdownBluetooth];
}

/*
 * GKPeerPickerControllerDelegate methods
 */
- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *) session {
    NSLog(@"didConnectPeer");
    currentSession = session;
    session.delegate = self;
    [session setDataReceiveHandler:self withContext:nil];
    [_peerName setHidden:NO];
    _peerName.text = [session displayNameForPeer:peerID];
    _xFerOptionButton.enabled = false;
    picker.delegate = nil;
    [picker dismiss];
    helloReceipt = TRUE;
    firstReceipt = TRUE;
    [self sendData:[NSKeyedArchiver archivedDataWithRootObject:[NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:xFerOption]] forKeys:@[@"xFerOption"]]]];
}

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker {
    NSLog(@"peerPickerControllerDidCancel");
    picker.delegate = nil;
    [self shutdownBluetooth];
    [_connectButton setHidden:NO];
    [_sendButton setHidden:YES];
    [_disconnectButton setHidden:YES];
    [_peerName setHidden:YES];
}

/*
 * Data handling methods
 */
- (void)btnConnect {
    [self shutdownBluetooth];
    picker = [[GKPeerPickerController alloc] init];
    picker.delegate = self;
    picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
    [_connectButton setHidden:YES];
    [_disconnectButton setHidden:NO];
    [_sendButton setHidden:NO];
    [picker show];
}

- (void)btnDisconnect {
    [self shutdownBluetooth];
    [_connectButton setHidden:NO];
    [_disconnectButton setHidden:YES];
    [_sendButton setHidden:YES];
    [_peerName setHidden:YES];
}

- (void)btnSend {
    NSDictionary *syncDict = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:syncType]] forKeys:@[@"syncType"]];
    NSData *myData = [NSKeyedArchiver archivedDataWithRootObject:syncDict];
    NSLog(@"syncDict = %@", syncDict);
    [self sendData:myData];
    
    switch (syncType) {
        case SyncTournaments:
            [self sendData:[tournamentDataPackage packageTournamentsForXFer:filteredTournamentList]];
            break;
        case SyncTeams:
            for (int i = 0; i < [filteredTeamList count]; i++) {
                TeamData *team = [filteredTeamList objectAtIndex:i];
                NSData *myData = [teamDataPackage packageTeamForXFer:team];
                [self sendData:myData];
                //       NSLog(@"Team = %@, saved = %@", team.number, team.saved);
            }
            break;
        case SyncMatchList:
            for (int i = 0; i < [filteredMatchList count]; i++) {
                MatchData *match = [filteredMatchList objectAtIndex:i];
                NSData *myData = [matchDataPackage packageMatchForXFer:match];
                [self sendData:myData];
                NSLog(@"Match = %@, saved = %@", match.number, match.saved);
            }
            break;
        case SyncMatchResults:
            for (int i = 0; i < [filteredResultsList count]; i++) {
                TeamScore *score = [filteredResultsList objectAtIndex:i];
                NSData *myData = [matchResultsPackage packageScoreForXFer:score];
                [self sendData:myData];
                NSLog(@"Match = %@, Type = %@, Team = %@", score.match.number, score.match.matchType, score.team.number);
            }
            break;
        default:
            break;
    }
}

- (void)sendData:(NSData *)data {
    if (currentSession)
        [currentSession sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];
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

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context {
    if (helloReceipt) {
        NSDictionary *peerXFer = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSLog(@"Peer xFerOption = %@", peerXFer);
        if ([[peerXFer valueForKey:@"xFerOption"] intValue] == xFerOption) {
            [self shutdownBluetooth];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Conflicting Tranfer Option"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        } else {
            helloReceipt = FALSE;
        }
        return;
    }
    if (firstReceipt) {
        NSDictionary *myType = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSLog(@"myType = %@", myType);
        [self setSyncType:[[myType valueForKey:@"syncType"] intValue]];
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
    [self updateTableData];
}

/*
 * iTune related methods
 */
- (void)packageDataForiTunes {
    if (![self createExportPaths]) return;
    switch (syncType) {
        case SyncTournaments: {
            NSData *myData = [tournamentDataPackage packageTournamentsForXFer:filteredTournamentList];
        }
            break;
        case SyncTeams:
            for (int i=0; i<[filteredTeamList count]; i++) {
                TeamData *team = [filteredTeamList objectAtIndex:i];
                [teamDataPackage exportTeamForXFer:team toFile:transferFilePath];
                NSLog(@"Team = %@, saved = %@", team.number, team.saved);
            }
            teamDataSync = [NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()];
            transferDataFile = [exportFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@ %@ Team Data %0.f.tmd", deviceName, tournamentName, [teamDataSync floatValue]]];
            [self serializeDataForTransfer:transferDataFile];
            break;
        case SyncMatchList:
            for (int i=0; i<[filteredMatchList count]; i++) {
                MatchData *match = [filteredMatchList objectAtIndex:i];
                [matchDataPackage exportMatchForXFer:match toFile:transferFilePath];
                NSLog(@"Match = %@, saved = %@", match.number, match.saved);
                matchScheduleSync = [NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()];
                transferDataFile = [exportFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@ %@ Match Schedule %0.f.msd", deviceName, tournamentName, [matchScheduleSync floatValue]]];
                [self serializeDataForTransfer:transferDataFile];
            }
            break;
        case SyncMatchResults:
            for (int i=0; i<[filteredResultsList count]; i++) {
                TeamScore *score = [filteredResultsList objectAtIndex:i];
                [matchResultsPackage exportScoreForXFer:score toFile:transferFilePath];
                //  NSLog(@"Match = %@, Type = %@, Team = %@ Saved = %@, SavedBy = %@", score.match.number, score.match.matchType, score.team.number, score.saved, score.savedBy);
            }
            matchResultsSync = [NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()];
            [prefs setObject:matchResultsSync forKey:@"matchResultsSync"];
            transferDataFile = [exportFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@ %@ Match Results %0.f.mrd", deviceName, tournamentName, [matchResultsSync floatValue]]];
            [self serializeDataForTransfer:transferDataFile];
            break;
            
        default:
            break;
    }
    NSError *error = nil;
    for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:transferFilePath error:&error]) {
        NSString *name = [transferFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", file]];
        [[NSFileManager defaultManager] removeItemAtPath:name error:&error];
    }
}

- (BOOL)createExportPaths {
    BOOL success = TRUE;
    if (!transferFilePath) {
        transferFilePath = [[self applicationLibraryDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"Transfer Data"]];
        NSError *error;
        success &= [[NSFileManager defaultManager] createDirectoryAtPath:transferFilePath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    if (!exportFilePath) {
        exportFilePath = [self applicationDocumentsDirectory];
        /*
         exportFilePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"Transfer Data"];
         NSError *error;
         [fileManager removeItemAtPath:exportFilePath error:&error];
         success &= [fileManager createDirectoryAtPath:exportFilePath withIntermediateDirectories:YES attributes:nil error:&error];
         */
    }
    if (!success) {
        UIAlertView *prompt  = [[UIAlertView alloc] initWithTitle:@"Transfer Alert" message:@"Unable to Save Transfer Data" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [prompt setAlertViewStyle:UIAlertViewStyleDefault];
        [prompt show];
    }
    return success;
}

- (void) serializeDataForTransfer:(NSString *)fileName {
    NSError *error;
    NSURL *url = [NSURL fileURLWithPath:transferFilePath];
    NSFileWrapper *dirWrapper = [[NSFileWrapper alloc] initWithURL:url options:0 error:&error];
    if (dirWrapper == nil) {
        NSLog(@"Error creating directory wrapper: %@", error.localizedDescription);
        return;
    }
    NSData *transferData = [dirWrapper serializedRepresentation];
    [transferData writeToFile:transferDataFile atomically:YES];
}

- (NSArray *)getImportFileList {
    return [importPackage getImportFileList];
}

- (void)importiTunesSelected:(NSString *)importFile {
    NSLog(@"file selected = %@", importFile);
    if ([importFile.pathExtension compare:@"pho" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        NSLog(@"Photo package");
        receivedPhotoList = [importPackage importDataPhoto:importFile];
        //receiveLabel1.text = @"Photo";
        //receiveLabel2.text = @"";
        //receiveLabel3.text = @"Thumbnail";
    } else {
        if ([importFile.pathExtension compare:@"mrd" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            receivedResultsList = [importPackage importData:importFile];
        } else if ([importFile.pathExtension compare:@"tmd" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            receivedTeamList = [importPackage importData:importFile];
        } else if ([importFile.pathExtension compare:@"msd" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            receivedMatchList = [importPackage importData:importFile];
        }
    }
    [self updateTableData];
}

- (NSString *)applicationLibraryDirectory {
    // Returns the path to the application's Library directory.
	return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSString *)applicationDocumentsDirectory {
    // Returns the path to the application's Documents directory.
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

@end