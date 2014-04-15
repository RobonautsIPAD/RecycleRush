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

@implementation SharedSyncController {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSString *deviceName;
    GKSession *currentSession;
    SharedSyncController *syncController;
    
    NSArray *tournamentList;
    NSMutableArray *filteredTournamentList;
    TournamentDataInterfaces *tournamentDataPackage;
    
    NSNumber *teamDataSync;
    NSArray *teamList;
    NSArray *filteredTeamList;
    TeamDataInterfaces *teamDataPackage;
    
    NSNumber *matchScheduleSync;
    NSArray *matchScheduleList;
    NSArray *filteredMatchList;
    MatchDataInterfaces *matchDataPackage;
    
    NSNumber *matchResultsSync;
    NSArray *matchResultsList;
    NSArray *filteredResultsList;
    TeamScoreInterfaces *matchResultsPackage;
}

-(id)initWithDataManager:(DataManager *)initManager {
    if (self = [super init]) {
        _dataManager = initManager;
	}
    
    prefs = [NSUserDefaults standardUserDefaults];
    tournamentName = [prefs objectForKey:@"tournament"];
    deviceName = [prefs objectForKey:@"deviceName"];
    teamDataSync = [prefs objectForKey:@"teamDataSync"];
    
    return self;
}

-(NSArray *)fetchTournamentList:(SyncOptions)syncOption {
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
    } else {
        filteredTournamentList = [[NSMutableArray alloc] init];
    }
    for (int i = 0; i < [tournamentList count]; i++) {
        [filteredTournamentList addObject:[NSArray arrayWithObjects:[[tournamentList objectAtIndex:i] valueForKey:@"code"], [[tournamentList objectAtIndex:i] valueForKey:@"name"], nil]];
    }
    
    return [[NSArray alloc] initWithArray:filteredTournamentList];
}

-(NSArray *)fetchTeamList:(SyncOptions)syncOption {
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

-(NSArray *)fetchMatchList:(SyncOptions)syncOption {
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

-(NSArray *)fetchResultsList:(SyncOptions)syncOption {
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

-(void)connectionFailed:(NSNotification *)notification {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"BOOM!"
                                                    message:@"Connection Failed."
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [self shutdownBluetooth];
    [alert show];
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

- (void)mySendDataToPeers:(NSData *)data type:(SyncType)syncType {
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

-(IBAction)createDataPackage:(SyncType)syncType {
    NSDictionary *syncDict = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:syncType]] forKeys:@[@"syncType"]];
    NSData *myData = [NSKeyedArchiver archivedDataWithRootObject:syncDict];
    NSLog(@"sync dict = %@", syncDict);
    [self mySendDataToPeers:myData type:syncType withSession:currentSession];
    
    switch (syncType) {
        case SyncTournaments: {
            NSData *myData = [tournamentDataPackage packageTournamentsForXFer:filteredTournamentList];
            [self mySendDataToPeers:myData type:syncType withSession:currentSession];
        }
            break;
        case SyncTeams:
            for (int i=0; i<[filteredTeamList count]; i++) {
                TeamData *team = [filteredTeamList objectAtIndex:i];
                NSData *myData = [teamDataPackage packageTeamForXFer:team];
                [self mySendDataToPeers:myData type:syncType withSession:currentSession];
                //       NSLog(@"Team = %@, saved = %@", team.number, team.saved);
            }
            break;
        case SyncMatchList:
            for (int i=0; i<[filteredMatchList count]; i++) {
                MatchData *match = [filteredMatchList objectAtIndex:i];
                NSData *myData = [matchDataPackage packageMatchForXFer:match];
                [self mySendDataToPeers:myData type:syncType withSession:currentSession];
                NSLog(@"Match = %@, saved = %@", match.number, match.saved);
            }
            break;
        case SyncMatchResults:
            for (int i=0; i<[filteredResultsList count]; i++) {
                TeamScore *score = [filteredResultsList objectAtIndex:i];
                NSData *myData = [matchResultsPackage packageScoreForXFer:score];
                [self mySendDataToPeers:myData type:syncType withSession:currentSession];
                NSLog(@"Match = %@, Type = %@, Team = %@", score.match.number, score.match.matchType, score.team.number);
            }
            break;
            
        default:
            break;
    }
}

@end