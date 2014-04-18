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
    SharedSyncController *syncController;
    
    SyncTypeDictionary *syncTypeDictionary;
    NSMutableArray *syncTypeList;
    
    SyncOptionDictionary *syncOptionDictionary;
    NSMutableArray *syncOptionList;
    
    UIActionSheet *xFerOptionAction;
    UIActionSheet *syncTypeAction;
    UIActionSheet *syncOptionAction;
    
    BOOL firstReceipt;
}

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
    syncController = [SharedSyncController alloc];
    syncController.xFerOptionButton = _xFerOptionButton;
    syncController.syncTypeButton = _syncTypeButton;
    syncController.syncOptionButton = _syncOptionButton;
    syncController.connectButton = _connectButton;
    syncController.disconnectButton = _disconnectButton;
    syncController.peerName = _peerName;
    syncController.sendButton = _sendButton;
    syncController.syncDataTable = _syncDataTable;
    syncController.packageDataButton = _packageDataButton;
    syncController.importFromiTunesButton = _importFromiTunesButton;
    syncController = [syncController initWithDataManager:_dataManager];
    
    self.syncDataTable.delegate = syncController;
    self.syncDataTable.dataSource = syncController;
    
    prefs = [NSUserDefaults standardUserDefaults];
    tournamentName = [prefs objectForKey:@"tournament"];
    deviceName = [prefs objectForKey:@"deviceName"];
    
    if (tournamentName) {
        self.title =  [NSString stringWithFormat:@"%@ Sync", tournamentName];
    } else {
        self.title = @"Sync";
    }
    
    [syncController setSyncType:SyncMatchResults];
    syncTypeDictionary = [[SyncTypeDictionary alloc] init];
    syncTypeList = [[syncTypeDictionary getSyncTypes] mutableCopy];
    
    [syncController setSyncOption:SyncAllSavedSince];
    syncOptionDictionary = [[SyncOptionDictionary alloc] init];
    syncOptionList = [[syncOptionDictionary getSyncOptions] mutableCopy];
    
    [self selectXFerOption:Sending];
    [self selectSyncType:SyncMatchResults];
    [self selectSyncOption:SyncAllSavedHere];
}

- (void) viewWillDisappear:(BOOL)animated {
    NSError *error;
    if (![_dataManager.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

#pragma mark - Transfer Options

- (IBAction)selectAction:(id)sender {
    if (sender == _xFerOptionButton) {
        if (!xFerOptionAction) {
            xFerOptionAction = [[UIActionSheet alloc] initWithTitle:@"Select Transfer Mode" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Send Data", @"Receive Data", nil];
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
        [syncOptionAction showInView:self.view];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet == xFerOptionAction) {
        [self selectXFerOption:buttonIndex];
    } else if (actionSheet == syncTypeAction) {
        [self selectSyncType:buttonIndex];
    } else if (actionSheet == syncOptionAction) {
        [self selectSyncOption:buttonIndex];
    }
}

-(void)selectXFerOption:(NSInteger)xFerChoice {
    switch (xFerChoice) {
        case 0:     // Send button
            [syncController setXFerOption:Sending];
            [_xFerOptionButton setTitle:@"Sending" forState:UIControlStateNormal];
            [_syncTypeButton setHidden:NO];
            [_syncOptionButton setHidden:NO];
            [_connectButton setHidden:NO];
            break;
        case 1:     // Receive button
            [syncController setXFerOption:Receiving];
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
    [syncController updateTableData];
}

-(void)selectSyncType:(SyncType)typeChoice {
    [syncController setSyncType:typeChoice];
    if (typeChoice == SyncMatchList) {
        [_syncDataTable setRowHeight:52];
    } else {
        [_syncDataTable setRowHeight:40];
    }
    switch (typeChoice) {
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
    [syncController updateTableData];
}

-(void)selectSyncOption:(SyncOptions)optionChoice {
    [syncController setSyncOption:optionChoice];
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
    [syncController updateTableData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
