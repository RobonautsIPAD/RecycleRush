//
//  PhoneSyncViewController.m
//  RecycleRush
//
//  Created by FRC on 2/20/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "PhoneSyncViewController.h"
#import "DataManager.h"
#import "SyncTypeDictionary.h"
#import "SyncOptionDictionary.h"
#import "TournamentData.h"
#import "TournamentUtilities.h"
#import "TeamData.h"
#import "MatchData.h"
#import "TeamScore.h"
#import "SharedSyncController.h"
#import "DataSync.h"
#import "SyncTableCells.h"

@interface PhoneSyncViewController ()

@property (nonatomic, weak) IBOutlet UITableView *syncDataTable;
@property (nonatomic, weak) IBOutlet UIButton *syncTypeButton;
@property (nonatomic, weak) IBOutlet UIButton *syncOptionButton;
@property (nonatomic, weak) IBOutlet UIButton *xFerOptionButton;
@property (nonatomic, weak) IBOutlet UIButton *connectButton;
@property (nonatomic, weak) IBOutlet UIButton *disconnectButton;
@property (nonatomic, weak) IBOutlet UILabel *peerName;
@property (nonatomic, weak) IBOutlet UIButton *sendButton;
@property (nonatomic, weak) IBOutlet UIButton *packageDataButton;
@property (nonatomic, weak) IBOutlet UIButton *importFromiTunesButton;

@end

@implementation PhoneSyncViewController {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSString *deviceName;
    DataSync *dataSyncPackage;
    SyncTableCells *syncTableCells;
    SharedSyncController *syncController;
    
    SyncTypeDictionary *syncTypeDictionary;
    NSMutableArray *syncTypeList;
    
    SyncOptionDictionary *syncOptionDictionary;
    NSMutableArray *syncOptionList;
    
    UIActionSheet *xFerOptionAction;
    UIActionSheet *syncTypeAction;
    UIActionSheet *syncOptionAction;
    
    BOOL firstReceipt;
    SyncType syncType;
    SyncOptions syncOption;
    NSArray *filteredSendList;
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
    
    if (tournamentName) {
        self.title =  [NSString stringWithFormat:@"%@ Sync", tournamentName];
    } else {
        self.title = @"Sync";
    }
    
    dataSyncPackage = [[DataSync alloc] init:_dataManager];
    syncTableCells = [[SyncTableCells alloc] init:_dataManager];

    [syncController setSyncType:SyncMatchResults];
    syncTypeDictionary = [[SyncTypeDictionary alloc] init];
    syncTypeList = [[syncTypeDictionary getSyncTypes] mutableCopy];
    
    [syncController setSyncOption:SyncAllSavedSince];
    syncOptionDictionary = [[SyncOptionDictionary alloc] init];
    syncOptionList = [[syncOptionDictionary getSyncOptions] mutableCopy];
    
    [self selectXFerOption:Receiving];
    syncType = SyncMatchList;
    syncOption = SyncAllSavedSince;

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

- (IBAction)selectAction:(id)sender {
    if (sender == _xFerOptionButton) {
        if (!xFerOptionAction) {
            xFerOptionAction = [[UIActionSheet alloc] initWithTitle:@"Select Transfer Mode" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
            [xFerOptionAction addButtonWithTitle:@"Send Data"];
            [xFerOptionAction addButtonWithTitle:@"Receive Data"];
            [xFerOptionAction addButtonWithTitle:@"Cancel"];
            [xFerOptionAction setCancelButtonIndex:2];
            xFerOptionAction.actionSheetStyle = UIActionSheetStyleDefault;
        }
        [xFerOptionAction showInView:self.view];
    } else if (sender == _syncTypeButton) {
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
            [syncController setXFerOption:Sending];
            [_xFerOptionButton setTitle:@"Sending" forState:UIControlStateNormal];
            break;
        case 1:     // Receive button
            [syncController setXFerOption:Receiving];
            [_xFerOptionButton setTitle:@"Receiving" forState:UIControlStateNormal];
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
    [self setSendList];
    [_syncDataTable reloadData];
}

-(void)selectSyncOption:(NSString *)optionChoice {
    syncOption = [SyncMethods getSyncOption:optionChoice];
    switch (syncOption) {
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
    return 0;
/*    if (tableView == _serverTable) {
        if (_connectionUtility.matchMakingClient != nil) return [_connectionUtility.matchMakingClient availableServerCount];
        else return 0;
    }
    else return [filteredSendList count];*/
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier1 = @"ServerList";
 //   UITableViewCell *cell;
/*    if (tableView == _serverTable) {
        cell = [tableView dequeueReusableCellWithIdentifier:identifier1 forIndexPath:indexPath];
        UILabel *label1 = (UILabel *)[cell viewWithTag:0];
        NSString *server = [_connectionUtility.matchMakingClient peerIDForAvailableServerAtIndex:indexPath.row];
        label1.text = [_connectionUtility.matchMakingClient displayNameForPeerID:server];
        return cell;
    }
    else {
        UITableViewCell *cell = [syncTableCells configureCell:tableView forTableData:[filteredSendList objectAtIndex:indexPath.row] atIndexPath:indexPath];
        return cell;
    }*/
    UITableViewCell *cell = [syncTableCells configureCell:tableView forTableData:[filteredSendList objectAtIndex:indexPath.row] atIndexPath:indexPath];
    return cell;}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
