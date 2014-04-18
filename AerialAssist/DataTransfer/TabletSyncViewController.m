//
//  SyncViewController.m
// Robonauts Scouting
//
//  Created by FRC on 3/13/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <QuartzCore/CALayer.h>
#import "TabletSyncViewController.h"
#import "DataManager.h"
#import "TournamentData.h"
#import "MatchData.h"
#import "TeamData.h"
#import "TeamScore.h"
#import "TournamentDataInterfaces.h"
#import "TeamDataInterfaces.h"
#import "MatchDataInterfaces.h"
#import "TeamScoreInterfaces.h"
#import "SyncOptionDictionary.h"
#import "SyncTypeDictionary.h"
#import "ImportDataFromiTunes.h"
#import "SharedSyncController.h"

@interface TabletSyncViewController ()
@property (nonatomic, weak) IBOutlet UIButton *resetBluetoothButton;
@property (weak, nonatomic) IBOutlet UIButton *packageDataButton;
@property (weak, nonatomic) IBOutlet UIButton *importFromiTunesButton;
@end

@implementation TabletSyncViewController {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSString *deviceName;
    GKSession *currentSession;
    SharedSyncController *syncController;
    
    XFerOption xFerOption;
    SyncType syncType;
    SyncOptions syncOption;
    
    BOOL firstReceipt;
    UIView *sendHeader;
    UILabel *sendLabel1;
    UILabel *sendLabel2;
    UILabel *sendLabel3;
    UIView *receiveHeader;
    UILabel *receiveLabel1;
    UILabel *receiveLabel2;
    UILabel *receiveLabel3;
    UILabel *receiveLabel4;
    NSMutableArray *receivedMatches;
    NSMutableArray *receivedMatchTypes;
    MatchResultsObject *dataFromTransfer;
    id popUp;
    SyncOptionDictionary *syncOptionDictionary;
    SyncTypeDictionary *syncTypeDictionary;
    
    NSFileManager *fileManager;
    NSString *exportFilePath;
    NSString *transferFilePath;
    NSString *transferDataFile;
    
    PopUpPickerViewController *importFileListPicker;
    UIPopoverController *importFileListPopover;
    NSArray *importFileList;
    
    NSArray *receivedPhotoList;
    ImportDataFromiTunes *importPackage;
    
    NSArray *tournamentList;
    NSArray *filteredTournamentList;
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
}

@synthesize sendDataTable = _sendDataTable;
@synthesize connectButton = _connectButton;
@synthesize disconnectButton = _disconnectButton;
@synthesize sendButton = _sendButton;
@synthesize peerLabel = _peerLabel;
@synthesize peerName = _peerName;

GKPeerPickerController *picker;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    NSLog(@"TableSync Unload");
    prefs = nil;
    tournamentName = nil;
    sendHeader = nil;
    receiveHeader = nil;
    _dataManager = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!_dataManager) {
        _dataManager = [[DataManager alloc] init];
    }
    prefs = [NSUserDefaults standardUserDefaults];
    tournamentName = [prefs objectForKey:@"tournament"];
    if (tournamentName) {
        self.title =  [NSString stringWithFormat:@"%@ Synchronization", tournamentName];
    }
    else {
        self.title = @"Synchronization";
    }
    
    importPackage = [[ImportDataFromiTunes alloc] init:_dataManager];
    
    [self SetBigButtonDefaults:_connectButton];
    [self SetBigButtonDefaults:_syncOptionButton];
    [self SetBigButtonDefaults:_syncTypeButton];
    [self SetBigButtonDefaults:_disconnectButton];
    [self SetSmallButtonDefaults:_packageDataButton];
    [self SetSmallButtonDefaults:_importFromiTunesButton];
    [self SetSmallButtonDefaults:_sendButton];
    
    
    // Set the notification to receive information after a bluetooth has been received
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionFailed:) name:@"BluetoothDeviceConnectFailedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bluetoothNotice:) name:@"BluetoothDeviceUpdatedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bluetoothNotice:) name:@"BluetoothDeviceDiscoveredNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bluetoothNotice:) name:@"BluetoothDiscoveryStateChangedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bluetoothNotice:) name:@"BluetoothConnectabilityChangedNotification" object:nil];
    NSLog(@"sync option = %d", syncOption);
    teamDataSync = [prefs objectForKey:@"teamDataSync"];
    matchScheduleSync = [prefs objectForKey:@"matchScheduleSync"];
    matchResultsSync = [prefs objectForKey:@"matchResultsSync"];
    deviceName = [prefs objectForKey:@"deviceName"];
    fileManager = [NSFileManager defaultManager];
    
    firstReceipt = TRUE;
    [_connectButton setHidden:NO];
    [_disconnectButton setHidden:YES];
    [_peerLabel setHidden:YES];
    [_peerName setHidden:YES];
    [_sendButton setHidden:YES];
    
    [_sendDataTable setHidden:NO];
    
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
    
    [self createHeaders];
    
    syncOptionDictionary = [[SyncOptionDictionary alloc] init];
    _syncOptionList = [[syncOptionDictionary getSyncOptions] mutableCopy];
    [_syncOptionButton setTitle:[syncOptionDictionary getSyncOptionString:syncOption] forState:UIControlStateNormal];
    
    syncTypeDictionary = [[SyncTypeDictionary alloc] init];
    _syncTypeList = [[syncTypeDictionary getSyncTypes] mutableCopy];
    [_syncTypeButton setTitle:[syncTypeDictionary getSyncTypeString:syncType] forState:UIControlStateNormal];
    
    [self updateTableData];
}

-(void)createHeaders {
    sendHeader = [[UIView alloc] initWithFrame:CGRectMake(0,0,282,50)];
    sendHeader.backgroundColor = [UIColor lightGrayColor];
    sendHeader.opaque = YES;
    
    sendLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 11, 100, 21)];
    sendLabel1.backgroundColor = [UIColor clearColor];
    [sendHeader addSubview:sendLabel1];
    
    sendLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(130, 11, 80, 21)];
    sendLabel2.backgroundColor = [UIColor clearColor];
    [sendHeader addSubview:sendLabel2];
    
    sendLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(195, 11, 65, 21)];
    sendLabel3.backgroundColor = [UIColor clearColor];
    [sendHeader addSubview:sendLabel3];
    
    receiveHeader = [[UIView alloc] initWithFrame:CGRectMake(0,0,282,50)];
    receiveHeader.backgroundColor = [UIColor orangeColor];
    receiveHeader.opaque = YES;
    
    [self setHeaders];
}

-(void)setHeaders {
    switch (syncType) {
        case SyncMatchResults:
            sendLabel1.text = @"Match";
            sendLabel2.text = @"Type";
            sendLabel3.text = @"Team";
            receiveLabel1.text = @"Match";
            receiveLabel2.text = @"Type";
            receiveLabel3.text = @"Team";
            receiveLabel4.text = @"Imported";
        case SyncMatchList:
            sendLabel1.text = @"Match";
            sendLabel2.text = @"Type";
            sendLabel3.text = @"";
            receiveLabel1.text = @"Match";
            receiveLabel2.text = @"Type";
            receiveLabel3.text = @"";
            break;
        case SyncTeams:
            sendLabel1.text = @"Team Number";
            sendLabel2.text = @"Team Name";
            sendLabel3.text = @"";
            receiveLabel1.text = @"Team Number";
            receiveLabel2.text = @"Team Name";
            receiveLabel3.text = @"Imported";
            break;
        case SyncTournaments:
            sendLabel1.text = @"Tournament";
            sendLabel2.text = @"";
            sendLabel3.text = @"";
            receiveLabel1.text = @"Tournament";
            receiveLabel2.text = @"";
            receiveLabel3.text = @"";
        default:
            break;
    }
    
    UILabel *syncLabel = [[UILabel alloc] initWithFrame:CGRectMake(290, 11, 65, 21)];
	syncLabel.text = @"";
    syncLabel.backgroundColor = [UIColor clearColor];
    [sendHeader addSubview:syncLabel];
}

-(void)updateTableData {
    switch (syncType) {
        case SyncTournaments:
            //filteredTournamentList = [syncController fetchTournamentList];
            break;
        case SyncTeams:
            //filteredTeamList = [syncController fetchTeamList];
            break;
        case SyncMatchList:
            //filteredMatchList = [syncController fetchMatchList];
            break;
        case SyncMatchResults:
            //filteredResultsList = [syncController fetchResultsList];
            break;
        default:
            break;
    }
}

- (IBAction)packageDataForiTunes:(id)sender {
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

-(BOOL)createExportPaths {
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
        UIAlertView *prompt  = [[UIAlertView alloc] initWithTitle:@"Transfer Alert"
                                                          message:@"Unable to Save Transfer Data"
                                                         delegate:nil
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
        [prompt setAlertViewStyle:UIAlertViewStyleDefault];
        [prompt show];
    }
    return success;
}

-(void) serializeDataForTransfer:(NSString *)fileName {
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

-(void)importiTunesSelected:(NSString *)importFile {
    NSLog(@"file selected = %@", importFile);
    if ([importFile.pathExtension compare:@"pho" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        NSLog(@"Photo package");
        receivedPhotoList = [importPackage importDataPhoto:importFile];
        receiveLabel1.text = @"Photo";
        receiveLabel2.text = @"";
        receiveLabel3.text = @"Thumbnail";
    }
    else {
        if ([importFile.pathExtension compare:@"mrd" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            receivedResultsList = [importPackage importData:importFile];
        }
        else if ([importFile.pathExtension compare:@"tmd" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            receivedTeamList = [importPackage importData:importFile];
        }
        else if ([importFile.pathExtension compare:@"msd" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            receivedMatchList = [importPackage importData:importFile];
        }
    }
    [_sendDataTable reloadData];
}

- (IBAction)popUpChanged:(id)sender {
    UIButton * PressedButton = (UIButton*)sender;
    if (PressedButton == _syncOptionButton) {
        popUp = _syncOptionButton;
        if (_syncOptionPicker == nil) {
            _syncOptionPicker = [[PopUpPickerViewController alloc]
                                 initWithStyle:UITableViewStylePlain];
            _syncOptionPicker.delegate = self;
        }
        _syncOptionPicker.pickerChoices = _syncOptionList;
        self.syncOptionPopover = [[UIPopoverController alloc]
                                  initWithContentViewController:_syncOptionPicker];
        [self.syncOptionPopover presentPopoverFromRect:PressedButton.bounds inView:PressedButton
                              permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else if (PressedButton == _syncTypeButton) {
        popUp = _syncTypeButton;
        if (_syncTypePicker == nil) {
            _syncTypePicker = [[PopUpPickerViewController alloc]
                               initWithStyle:UITableViewStylePlain];
            _syncTypePicker.delegate = self;
        }
        _syncTypePicker.pickerChoices = _syncTypeList;
        self.syncPickerPopover = [[UIPopoverController alloc]
                                  initWithContentViewController:_syncTypePicker];
        [self.syncPickerPopover presentPopoverFromRect:PressedButton.bounds inView:PressedButton
                              permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else if (PressedButton == _importFromiTunesButton) {
        popUp = _importFromiTunesButton;
        if (importFileListPicker == nil) {
            importFileListPicker = [[PopUpPickerViewController alloc]
                                    initWithStyle:UITableViewStylePlain];
            importFileListPicker.delegate = self;
        }
        importFileList = [importPackage getImportFileList];
        importFileListPicker.pickerChoices = [importFileList mutableCopy];
        importFileListPopover = [[UIPopoverController alloc]
                                 initWithContentViewController:importFileListPicker];
        [importFileListPopover presentPopoverFromRect:PressedButton.bounds inView:PressedButton
                             permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (void)pickerSelected:(NSString *)newPick {
    if (popUp == _syncOptionButton) {
        [_syncOptionPopover dismissPopoverAnimated:YES];
        _syncOptionPopover = nil;
        [self changeSyncOption:newPick];
    }
    else if (popUp == _syncTypeButton) {
        [_syncPickerPopover dismissPopoverAnimated:YES];
        _syncPickerPopover = nil;
        [self changeSyncType:newPick];
    }
    else if (popUp == _importFromiTunesButton) {
        [importFileListPopover dismissPopoverAnimated:YES];
        importFileListPicker = nil;
        importFileListPopover = nil;
        [self importiTunesSelected:newPick];
    }
}

-(void)changeSyncOption:(NSString *)newSyncOption {
    for (int i = 0 ; i < [_syncOptionList count] ; i++) {
        if ([newSyncOption isEqualToString:[_syncOptionList objectAtIndex:i]]) {
            [_syncOptionButton setTitle:newSyncOption forState:UIControlStateNormal];
            syncOption = i;
            break;
        }
    }
    [self updateTableData];
}

-(void)changeSyncType:(NSString *)newSyncType {
    for (int i = 0 ; i < [_syncTypeList count] ; i++) {
        if ([newSyncType isEqualToString:[_syncTypeList objectAtIndex:i]]) {
            [_syncTypeButton setTitle:newSyncType forState:UIControlStateNormal];
            syncType = i;
            break;
        }
    }
    [self setHeaders];
    [self updateTableData];
}

- (void) viewWillDisappear:(BOOL)animated
{
    //    NSLog(@"viewWillDisappear");
    NSError *error;
    if (![_dataManager.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

-(IBAction) btnConnect:(id) sender {
    [self shutdownBluetooth];
    picker = [[GKPeerPickerController alloc] init];
    picker.delegate = self;
    picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
    [_connectButton setHidden:YES];
    [_disconnectButton setHidden:NO];
    [_sendButton setHidden:NO];
    [picker show];
}

-(IBAction) btnDisconnect:(id) sender {
    [self shutdownBluetooth];
    [_connectButton setHidden:NO];
    [_disconnectButton setHidden:YES];
    [_sendButton setHidden:YES];
}

-(IBAction) createDataPackage:(id) sender {
    NSDictionary *syncDict = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:syncType]] forKeys:@[@"syncType"]];
    NSData *myData = [NSKeyedArchiver archivedDataWithRootObject:syncDict];
    NSLog(@"sync dict = %@", syncDict);
    [self mySendDataToPeers:myData];
    
    switch (syncType) {
        case SyncTournaments: {
            NSData *myData = [tournamentDataPackage packageTournamentsForXFer:filteredTournamentList];
            [self mySendDataToPeers:myData];
        }
            break;
        case SyncTeams:
            for (int i=0; i<[filteredTeamList count]; i++) {
                TeamData *team = [filteredTeamList objectAtIndex:i];
                NSData *myData = [teamDataPackage packageTeamForXFer:team];
                [self mySendDataToPeers:myData];
                //       NSLog(@"Team = %@, saved = %@", team.number, team.saved);
            }
            break;
        case SyncMatchList:
            for (int i=0; i<[filteredMatchList count]; i++) {
                MatchData *match = [filteredMatchList objectAtIndex:i];
                NSData *myData = [matchDataPackage packageMatchForXFer:match];
                [self mySendDataToPeers:myData];
                NSLog(@"Match = %@, saved = %@", match.number, match.saved);
            }
            break;
        case SyncMatchResults:
            for (int i=0; i<[filteredResultsList count]; i++) {
                TeamScore *score = [filteredResultsList objectAtIndex:i];
                NSData *myData = [matchResultsPackage packageScoreForXFer:score];
                [self mySendDataToPeers:myData];
                //  NSLog(@"Match = %@, Type = %@, Team = %@", score.match.number, score.match.matchType, score.team.number);
            }
            break;
            
        default:
            break;
    }
}

-(void)connectionFailed:(NSNotification *)notification {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"BOOM!"
                                                    message:@"Connection Failed."
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [self shutdownBluetooth];
    [alert show];
    [_connectButton setHidden:NO];
    [_disconnectButton setHidden:YES];
    [_sendButton setHidden:YES];
    picker.delegate = nil;
    [picker dismiss];
}

-(void)bluetoothNotice:(NSNotification *)notification {
    NSLog(@"%@ %@", notification.name, [notification userInfo]);
}

- (IBAction)resetBluetooth:(id)sender {
    [self shutdownBluetooth];
}

- (void)shutdownBluetooth {
    if (!currentSession) return;
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
    [_peerLabel setHidden:NO];
    [_peerName setHidden:NO];
    _peerName.text = [session displayNameForPeer:peerID];
    [_sendDataTable setHidden:NO];
    firstReceipt = TRUE;
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
    [_connectButton setHidden:NO];
    [_sendButton setHidden:YES];
    [_disconnectButton setHidden:YES];
    [_peerLabel setHidden:YES];
    [_peerName setHidden:YES];
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
            [_connectButton setHidden:NO];
            [_disconnectButton setHidden:YES];
            [_sendButton setHidden:YES];
            [_peerLabel setHidden:YES];
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

- (void) mySendDataToPeers:(NSData *) data
{
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

- (void) receiveData:(NSData *)data
            fromPeer:(NSString *)peer
           inSession:(GKSession *)session
             context:(void *)context {
    
    if (firstReceipt) {
        NSDictionary *myType = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSLog(@"myType = %@", myType);
        NSString *aarg = [syncTypeDictionary getSyncTypeString:[[myType valueForKey:@"syncType"] intValue]];
        NSLog(@"sync type = %@", aarg);
        [self changeSyncType:[syncTypeDictionary getSyncTypeString:[[myType valueForKey:@"syncType"] intValue]]];
        firstReceipt = FALSE;
        return;
    }
    switch (syncType) {
        case SyncTournaments:
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
            if (receivedMatchList == nil) {
                receivedMatchList = [NSMutableArray array];
            }
            NSDictionary *scoreReceived = [matchResultsPackage unpackageScoreForXFer:data];
            if (scoreReceived) [receivedResultsList addObject:scoreReceived];
        }
            break;
        default:
            break;
    }
    [_sendDataTable reloadData];
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return sendHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    /*
     if (tableView == _sendDataTable) {
     if (_sendDataTable.hidden) return 0;
     */
    if (syncType == SyncTeams) return [filteredTeamList count];
    if (syncType == SyncTournaments) return [filteredTournamentList count];
    if (syncType == SyncMatchList) return [filteredMatchList count];
    if (syncType == SyncMatchResults) return [filteredResultsList count];
    /*
     }
     else {
     if (_sendDataTable.hidden) return 0;
     if (syncType == SyncTournaments) return [receivedTournamentList count];
     if (syncType == SyncTeams) return [receivedTeamList count];
     if (syncType == SyncMatchList) return [receivedMatchList count];
     if (syncType == SyncMatchResults) return [receivedResultsList count];
     }
     */
    return 0;
}

- (void)configureTournamentCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSArray *tournament = [filteredTournamentList objectAtIndex:indexPath.row];
    // Configure the cell...
    // Set a background for the cell
    
	UILabel *label1 = (UILabel *)[cell viewWithTag:10];
	label1.text = tournament[0];
    
	UILabel *label2 = (UILabel *)[cell viewWithTag:20];
    label2.text = tournament[1];
    
	UILabel *label3 = (UILabel *)[cell viewWithTag:30];
    label3.text = @"";
    
	UILabel *label4 = (UILabel *)[cell viewWithTag:40];
    label4.text = @"";
}

- (void)configureTeamCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    TeamData *team = [filteredTeamList objectAtIndex:indexPath.row];
    // Configure the cell...
    // Set a background for the cell
    
	UILabel *label1 = (UILabel *)[cell viewWithTag:10];
	label1.text = [NSString stringWithFormat:@"%d", [team.number intValue]];
    
	UILabel *label2 = (UILabel *)[cell viewWithTag:20];
    label2.text = team.name;
    
	UILabel *label3 = (UILabel *)[cell viewWithTag:30];
    label3.text = @"";
    
	UILabel *label4 = (UILabel *)[cell viewWithTag:40];
    label4.text = @"";
}

- (void)configureMatchListCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    MatchData *match = [filteredMatchList objectAtIndex:indexPath.row];
    // Configure the cell...
    // Set a background for the cell
    
	UILabel *label1 = (UILabel *)[cell viewWithTag:10];
	label1.text = [NSString stringWithFormat:@"%d", [match.number intValue]];
    
	UILabel *label2 = (UILabel *)[cell viewWithTag:20];
    label2.text = match.matchType;
    
	UILabel *label3 = (UILabel *)[cell viewWithTag:30];
    label3.text = @"";
    
	UILabel *label4 = (UILabel *)[cell viewWithTag:40];
    label4.text = @"";
}

- (void)configureResultsCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    TeamScore *score = [filteredResultsList objectAtIndex:indexPath.row];
    // Configure the cell...
    // Set a background for the cell
    
	UILabel *label1 = (UILabel *)[cell viewWithTag:10];
	label1.text = [NSString stringWithFormat:@"%d", [score.match.number intValue]];
    
	UILabel *label2 = (UILabel *)[cell viewWithTag:20];
    label2.text = score.match.matchType;
    
	UILabel *label3 = (UILabel *)[cell viewWithTag:30];
    label3.text = [NSString stringWithFormat:@"%d", [score.team.number intValue]];
    
	UILabel *label4 = (UILabel *)[cell viewWithTag:40];
    label4.text = @"";
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    switch (syncType) {
        case SyncTournaments:
            [self configureTournamentCell:cell atIndexPath:indexPath];
            break;
        case SyncTeams:
            [self configureTeamCell:cell atIndexPath:indexPath];
            break;
        case SyncMatchList:
            [self configureMatchListCell:cell atIndexPath:indexPath];
            break;
        case SyncMatchResults:
            [self configureResultsCell:cell atIndexPath:indexPath];
            break;
            
        default:
            break;
    }
}

- (void)configureReceivedTournamentCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSArray *tournament = [receivedTournamentList objectAtIndex:indexPath.row];
    
	UILabel *label1 = (UILabel *)[cell viewWithTag:10];
	label1.text = tournament[0];
    
	UILabel *label2 = (UILabel *)[cell viewWithTag:20];
    label2.text = tournament[1];
    
	UILabel *label3 = (UILabel *)[cell viewWithTag:30];
    label3.text = @"";
    
	UILabel *label4 = (UILabel *)[cell viewWithTag:40];
    label4.text = @"";
}

- (void)configureReceivedTeamCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *team = [receivedTeamList objectAtIndex:indexPath.row];
    
	UILabel *label1 = (UILabel *)[cell viewWithTag:10];
	label1.text = [NSString stringWithFormat:@"%d", [[team objectForKey:@"team"] intValue]];
    
	UILabel *label2 = (UILabel *)[cell viewWithTag:20];
    label2.text = [team objectForKey:@"name"];
    
	UILabel *label3 = (UILabel *)[cell viewWithTag:30];
    label3.text = [team objectForKey:@"transfer"];
    
	UILabel *label4 = (UILabel *)[cell viewWithTag:40];
    label4.text = @"";
}

- (void)configureReceivedMatchListCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *match = [receivedMatchList objectAtIndex:indexPath.row];
    
	UILabel *label1 = (UILabel *)[cell viewWithTag:10];
	label1.text = [NSString stringWithFormat:@"%d", [[match objectForKey:@"match"] intValue]];
    
	UILabel *label2 = (UILabel *)[cell viewWithTag:20];
    label2.text = [match objectForKey:@"type"];
    
	UILabel *label3 = (UILabel *)[cell viewWithTag:30];
    label3.text = @"";
    
	UILabel *label4 = (UILabel *)[cell viewWithTag:40];
    label4.text = @"";
}

- (void)configureReceivedResultsCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *score = [receivedResultsList objectAtIndex:indexPath.row];
    // Configure the cell...
    // Set a background for the cell
    
	UILabel *label1 = (UILabel *)[cell viewWithTag:10];
	label1.text = [NSString stringWithFormat:@"%d", [[score objectForKey:@"match"] intValue]];
    
	UILabel *label2 = (UILabel *)[cell viewWithTag:20];
    label2.text = [score objectForKey:@"type"];
    
	UILabel *label3 = (UILabel *)[cell viewWithTag:30];
    label3.text = [NSString stringWithFormat:@"%d", [[score objectForKey:@"team"] intValue]];
    
	UILabel *label4 = (UILabel *)[cell viewWithTag:40];
    label4.text = [score objectForKey:@"transfer"];
}

- (void)configureReceivedCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    switch (syncType) {
        case SyncTournaments:
            [self configureReceivedTournamentCell:cell atIndexPath:indexPath];
            break;
        case SyncTeams:
            [self configureReceivedTeamCell:cell atIndexPath:indexPath];
            break;
        case SyncMatchList:
            [self configureReceivedMatchListCell:cell atIndexPath:indexPath];
            break;
        case SyncMatchResults:
            [self configureReceivedResultsCell:cell atIndexPath:indexPath];
            break;
        default:
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _sendDataTable) {
        UITableViewCell *cell = [tableView
                                 dequeueReusableCellWithIdentifier:@"SendData"];
        // Set up the cell...
        [self configureCell:cell atIndexPath:indexPath];
        return cell;
    }
    else {
        UITableViewCell *cell = [tableView
                                 dequeueReusableCellWithIdentifier:@"ReceiveData"];
        [self configureReceivedCell:cell atIndexPath:indexPath];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)SetBigButtonDefaults:(UIButton *)currentButton {
    currentButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:20.0];
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

-(void)SetSmallButtonDefaults:(UIButton *)currentButton {
    currentButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
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

/**
 Returns the path to the application's Library directory.
 */
- (NSString *)applicationLibraryDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
}

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

@end