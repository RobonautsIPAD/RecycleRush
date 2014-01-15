//
//  SyncViewController.m
// Robonauts Scouting
//
//  Created by FRC on 3/13/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "TabletSyncViewController.h"
#import "DataManager.h"
#import "TournamentData.h"
#import "MatchData.h"
#import "TeamData.h"
#import "TeamScore.h"
#import "SyncOptionDictionary.h"
#import "SyncTypeDictionary.h"
#import "MatchResultsObject.h"

@interface TabletSyncViewController ()

@end

@implementation TabletSyncViewController {
    UIView *sendHeader;
    UILabel *sendLabel1;
    UILabel *sendLabel2;
    UILabel *sendLabel3;
    UIView *receiveHeader;
    UILabel *receiveLabel1;
    UILabel *receiveLabel2;
    UILabel *receiveLabel3;
    NSMutableArray *receivedMatches;
    NSMutableArray *receivedMatchTypes;
    NSMutableArray *receivedTeams;
    MatchResultsObject *dataFromTransfer;
    id popUp;
    SyncOptionDictionary *syncOptionDictionary;
    SyncTypeDictionary *syncTypeDictionary;
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSNumber *teamDataSync;
}

@synthesize dataManager = _dataManager;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize currentSession = _currentSession;
@synthesize syncOption = _syncOption;
@synthesize syncType = _syncType;
@synthesize blueToothType = _blueToothType;
@synthesize sendDataTable = _sendDataTable;
@synthesize receiveDataTable = _receiveDataTable;
@synthesize connectButton = _connectButton;
@synthesize disconnectButton = _disconnectButton;
@synthesize peerLabel = _peerLabel;
@synthesize peerName = _peerName;
@synthesize alertPrompt = _alertPrompt;
@synthesize alertPromptPopover = _alertPromptPopover;

GKPeerPickerController *picker;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    NSLog(@"TableSync Unload");
    prefs = nil;
    tournamentName = nil;
    sendHeader = nil;
    receiveHeader = nil;
    _fetchedResultsController = nil;
    _dataManager = nil;
}

- (void)viewDidLoad
{
    //    if ([[prefs objectForKey:@"bluetooth"] isEqualToString:@"Scouter"]) {

    [super viewDidLoad];
    NSError *error = nil;
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
    if (![[self fetchedResultsController] performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         abort() causes the application to generate a crash log and terminate.
         You should not use this function in a shipping application,
         although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    [_connectButton setHidden:NO];
    [_disconnectButton setHidden:YES];
    [_peerLabel setHidden:YES];
    [_peerName setHidden:YES];
    [_sendDataTable setHidden:YES];
    [_receiveDataTable setHidden:YES];
    
    [self createHeaders];

    syncOptionDictionary = [[SyncOptionDictionary alloc] init];
    _syncOptionList = [[syncOptionDictionary getSyncOptions] mutableCopy];
    [_syncOptionButton setTitle:[syncOptionDictionary getSyncOptionString:_syncOption] forState:UIControlStateNormal];

    syncTypeDictionary = [[SyncTypeDictionary alloc] init];
    _syncTypeList = [[syncTypeDictionary getSyncTypes] mutableCopy];
    [_syncTypeButton setTitle:[syncTypeDictionary getSyncTypeString:_syncType] forState:UIControlStateNormal];
}

-(void)createHeaders {
    sendHeader = [[UIView alloc] initWithFrame:CGRectMake(0,0,282,50)];
    sendHeader.backgroundColor = [UIColor lightGrayColor];
    sendHeader.opaque = YES;

    sendLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(9, 11, 55, 21)];
    sendLabel1.backgroundColor = [UIColor clearColor];
    [sendHeader addSubview:sendLabel1];

    sendLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(85, 11, 65, 21)];
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
    if (_syncType == SyncMatchList || _syncType == SyncMatchResults) {
        sendLabel1.text = @"Match";
        sendLabel2.text = @"Type";
        sendLabel3.text = @"Team";
    }
    else if (_syncType == SyncTeams) {
        sendLabel1.text = @"Team Number";
        sendLabel2.text = @"Team Name";
        sendLabel3.text = @"";
    }
    else if (_syncType == SyncTournaments) {
        sendLabel1.text = @"Tournament";
        sendLabel2.text = @"";
        sendLabel3.text = @"";
    }
    
   
    UILabel *syncLabel = [[UILabel alloc] initWithFrame:CGRectMake(290, 11, 65, 21)];
	syncLabel.text = @"Synced";
    syncLabel.backgroundColor = [UIColor clearColor];
    [sendHeader addSubview:syncLabel];
}

-(IBAction)syncChanged:(id)sender {
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
}

-(void)changeSyncOption:(NSString *)newSyncOption {
    for (int i = 0 ; i < [_syncOptionList count] ; i++) {
        if ([newSyncOption isEqualToString:[_syncOptionList objectAtIndex:i]]) {
            [_syncOptionButton setTitle:newSyncOption forState:UIControlStateNormal];
            _syncOption = i-1;
            break;
        }
    }
}

-(void)changeSyncType:(NSString *)newSyncType {
    for (int i = 0 ; i < [_syncTypeList count] ; i++) {
        if ([newSyncType isEqualToString:[_syncTypeList objectAtIndex:i]]) {
            [_syncTypeButton setTitle:newSyncType forState:UIControlStateNormal];
            _syncType = i-1;
            break;
        }
    }
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
    picker = [[GKPeerPickerController alloc] init];
    picker.delegate = self;
    picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
    [_connectButton setHidden:YES];
    [_disconnectButton setHidden:NO];
    [picker show];
}

-(IBAction) btnDisconnect:(id) sender {
    [self.currentSession disconnectFromAllPeers];
    _currentSession = nil;
    
    [_connectButton setHidden:NO];
    [_disconnectButton setHidden:YES];
}

- (void)peerPickerController:(GKPeerPickerController *)picker
              didConnectPeer:(NSString *)peerID
                   toSession:(GKSession *) session {
    self.currentSession = session;
    session.delegate = self;
    [session setDataReceiveHandler:self withContext:nil];
    [_peerLabel setHidden:NO];
    [_peerName setHidden:NO];
    _peerName.text = [session displayNameForPeer:peerID];
    [_sendDataTable setHidden:NO];
    [_receiveDataTable setHidden:NO];
    picker.delegate = nil;
    
    [picker dismiss];

}

- (void)session:(GKSession *)sessionpeer
           peer:(NSString *)peerID
 didChangeState:(GKPeerConnectionState)state {
    switch (state)
    {
        case GKPeerStateConnected:
            NSLog(@"connected");
            [_sendDataTable setHidden:NO];
            [_receiveDataTable setHidden:NO];
            break;
        case GKPeerStateDisconnected:
            NSLog(@"disconnected");
            _currentSession = nil;
            [_connectButton setHidden:NO];
            [_disconnectButton setHidden:YES];
            [_peerLabel setHidden:YES];
            [_peerName setHidden:YES];
            break;
        case GKPeerStateAvailable:
        case GKPeerStateConnecting:
        case GKPeerStateUnavailable:
            break;
    }
}

- (void) mySendDataToPeers:(NSData *) data
{
    if (_currentSession)
        [self.currentSession sendDataToAllPeers:data
                                   withDataMode:GKSendDataReliable
                                          error:nil];
}

- (void) receiveData:(NSData *)data
            fromPeer:(NSString *)peer
           inSession:(GKSession *)session
             context:(void *)context {
    
    dataFromTransfer = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    //---convert the NSData to NSString---
    if (receivedMatches == nil) {
        receivedMatches = [NSMutableArray array];
    }
    if (receivedMatchTypes == nil) {
        receivedMatchTypes = [NSMutableArray array];
    }
    if (receivedTeams == nil) {
        receivedTeams = [NSMutableArray array];
    }
    if ([self addMatchScore:dataFromTransfer]) {
        [receivedMatches addObject:dataFromTransfer.match];
        [receivedMatchTypes addObject:dataFromTransfer.matchType];
        [receivedTeams addObject:dataFromTransfer.team];
        [_receiveDataTable reloadData];
    }
    else {
        NSString* str = [NSString stringWithFormat:@"Match %@, Team %@ Already Synced", dataFromTransfer.match, dataFromTransfer.team];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sync Again?"
                                                        message:str
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
        [alert show];
    }
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error {
    NSLog(@"error = %@", error);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"alert");
    if (buttonIndex == 1) { // Yes
        NSLog(@"Resync Match");
        if ([self addMatchScore:dataFromTransfer]) {
            [receivedMatches addObject:dataFromTransfer.match];
            [receivedMatchTypes addObject:dataFromTransfer.matchType];
            [receivedTeams addObject:dataFromTransfer.team];
            [_receiveDataTable reloadData];
        }        
    }
}

-(BOOL)addMatchScore:(MatchResultsObject *) xferData {
    // Fetch score record
    // Copy the data into the right places
    // Put the match drawing in the correct directory
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"TeamScore" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"match.number == %@ AND match.matchType CONTAINS %@ and tournament.name CONTAINS %@ and team.number == %@", xferData.match, xferData.matchType, xferData.tournament, xferData.team];
    [fetchRequest setPredicate:predicate];
    
    NSArray *scoreData = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!scoreData) {
        NSLog(@"Karma disruption error");
        return FALSE;
    }
    else {
        if([scoreData count] > 0) {  // Match Exists
            TeamScore *score = [scoreData objectAtIndex:0];
 /*           if ([score.saved intValue]) {
                // Match already saved on this device
                return FALSE;
            }*/
            [self unpackXferData:xferData forScore:score];
            return TRUE;
        }
        else {
            return FALSE;
        }
    }
}

-(void)unpackXferData:(MatchResultsObject *)xferData forScore:(TeamScore *)score {
    score.alliance = xferData.alliance;
    score.autonHigh = xferData.autonHigh;
    score.autonLow = xferData.autonLow;
    score.autonMid = xferData.autonMid;
    score.autonMissed = xferData.autonMissed;
    score.autonShotsMade = xferData.autonShotsMade;
    score.blocks = xferData.blocks;
    score.climbAttempt = xferData.climbAttempt;
    score.climbLevel = xferData.climbLevel;
    score.climbTimer = xferData.climbTimer;
    score.defenseRating = xferData.defenseRating;
    score.driverRating = xferData.driverRating;
//    score.fieldDrawing = xferData.fieldDrawing;
    score.floorPickUp = xferData.floorPickUp;
    score.notes = xferData.notes;
    score.otherRating = xferData.otherRating;
    score.passes = xferData.passes;
    score.pyramid = xferData.pyramid;
    score.robotSpeed = xferData.robotSpeed;
    score.teleOpHigh = xferData.teleOpHigh;
    score.teleOpLow = xferData.teleOpLow;
    score.teleOpMid = score.teleOpMid;
    score.teleOpMissed = xferData.teleOpMissed;
    score.teleOpShots = xferData.teleOpShots;
    score.totalAutonShots = xferData.totalAutonShots;
    score.totalTeleOpShots = xferData.totalTeleOpShots;
    score.wallPickUp = xferData.wallPickUp;
    score.wallPickUp1 = xferData.wallPickUp1;
    score.wallPickUp2 = xferData.wallPickUp2;
    score.wallPickUp3 = xferData.wallPickUp3;
    score.wallPickUp4 = xferData.wallPickUp4;
    score.allianceSection = xferData.allianceSection;
    score.sc1 = xferData.sc1;
    score.sc2 = xferData.sc2;
    score.sc3 = xferData.sc3;
    score.sc4 = xferData.sc4;
    score.sc5 = xferData.sc5;
    score.sc6 = xferData.sc6;
    score.sc7 = xferData.sc7;
    score.sc8 = xferData.sc8;
    score.sc9 = xferData.sc9;
    // For now, set saved to zero so that we know that this iPad didn't do the scouting
    // score.saved = [NSNumber numberWithInt:0];
    // Set synced to one so that we know it has been received
    score.synced = [NSNumber numberWithInt:1];
    
    // Save the picture
    NSString *baseDrawingPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",xferData.drawingPath]];

    // Check if robot directory exists, if not, create it
    if (![[NSFileManager defaultManager] fileExistsAtPath:baseDrawingPath isDirectory:NO]) {
        if (![[NSFileManager defaultManager]createDirectoryAtPath:baseDrawingPath
                                      withIntermediateDirectories: YES
                                                       attributes: nil
                                                            error: NULL]) {
            NSLog(@"Dreadful error creating directory to save field drawings");
            return;
        }
    }
/*    baseDrawingPath = [baseDrawingPath stringByAppendingPathComponent:score.fieldDrawing];
    NSLog(@"score = %@", score);
    NSLog(@"base path = %@", baseDrawingPath);
    UIImage *imge = [UIImage imageWithData:xferData.fieldDrawingImage];
    [UIImagePNGRepresentation(imge) writeToFile:baseDrawingPath atomically:YES];
    NSError *error;
    if (![_dataManager.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }*/
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == _receiveDataTable) {
        return receiveHeader;
    }
    else return sendHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == _receiveDataTable) {
    }
    return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == _receiveDataTable) {
    }
    if (tableView == _sendDataTable) {
        NSInteger count = [[_fetchedResultsController sections] count];
        if (count == 0) {
            count = 1;
        }
        return count;
    }
    else {
        if ([receivedMatches count]) return 1;
        else return 0;
    }
}
        
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (tableView == _sendDataTable) {
        id <NSFetchedResultsSectionInfo> sectionInfo =
        [[_fetchedResultsController sections] objectAtIndex:section];
    
        return [sectionInfo numberOfObjects];
    }
    else {
        return [receivedMatches count];
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    TeamScore *info = [_fetchedResultsController objectAtIndexPath:indexPath];
    // Configure the cell...
    // Set a background for the cell
    
	UILabel *numberLabel = (UILabel *)[cell viewWithTag:10];
	numberLabel.text = [NSString stringWithFormat:@"%d", [info.match.number intValue]];
    
	UILabel *matchTypeLabel = (UILabel *)[cell viewWithTag:20];
    matchTypeLabel.text = info.match.matchType;
    
	UILabel *teamLabel = (UILabel *)[cell viewWithTag:30];
    teamLabel.text = [NSString stringWithFormat:@"%d", [info.team.number intValue]];

	UILabel *syncLabel = (UILabel *)[cell viewWithTag:40];
    syncLabel.text = ([info.synced intValue] == 0) ? @"N" : @"Y";
}

- (void)configureReceivedCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    // Set a background for the cell
    
	UILabel *numberLabel = (UILabel *)[cell viewWithTag:10];
	numberLabel.text = [NSString stringWithFormat:@"%d", [[receivedMatches objectAtIndex:indexPath.row] intValue]];

	UILabel *matchTypeLabel = (UILabel *)[cell viewWithTag:20];
    matchTypeLabel.text = [receivedMatchTypes objectAtIndex:indexPath.row];
    
	UILabel *teamLabel = (UILabel *)[cell viewWithTag:30];
    teamLabel.text = [NSString stringWithFormat:@"%d", [[receivedTeams objectAtIndex:indexPath.row] intValue]];
    
	UILabel *syncLabel = (UILabel *)[cell viewWithTag:40];
    syncLabel.text = @"";   //([info.synced intValue] == 0) ? @"N" : @"Y";
 
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
    if (tableView == _receiveDataTable) return;
    
    MatchResultsObject *transferObject = [[MatchResultsObject alloc] initWithScore:[_fetchedResultsController objectAtIndexPath:indexPath]];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:transferObject];
    [self mySendDataToPeers:data];
    TeamScore *info = [_fetchedResultsController objectAtIndexPath:indexPath];
    info.synced = [NSNumber numberWithInt:1];
    NSString* str = @"Sending";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Data sending"
                                                    message:str
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];

/*
    NSLog(@"Temp =====================================================");
    TeamScore *info = [_fetchedResultsController objectAtIndexPath:indexPath];
    if (receivedMatches == nil) {
        receivedMatches = [NSMutableArray array];
    }
    if (receivedMatchTypes == nil) {
        receivedMatchTypes = [NSMutableArray array];
    }
    if (receivedTeams == nil) {
        receivedTeams = [NSMutableArray array];
    }
    [receivedMatches addObject:info.match.number];
    [receivedMatchTypes addObject:info.match.matchType];
    [receivedTeams addObject:info.team.number];
    [_receiveDataTable reloadData];
 */

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];

}

- (NSFetchedResultsController *)fetchedResultsController {
    // Set up the fetched results controller if needed.
    if (_fetchedResultsController == nil) {
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"TeamScore" inManagedObjectContext:_dataManager.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Edit the sort key as appropriate.
        NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"match.matchTypeSection" ascending:YES];
        NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"match.number" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:typeDescriptor, numberDescriptor, nil];
        NSLog(@"Fix this");
 //       NSPredicate *pred = [NSPredicate predicateWithFormat:@"ANY tournament = %@", settings.tournament];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"(ANY tournamentName = %@) AND (saved == 1)", tournamentName];
        [fetchRequest setPredicate:pred];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController =
        [[NSFetchedResultsController alloc]
         initWithFetchRequest:fetchRequest
         managedObjectContext:_dataManager.managedObjectContext
         sectionNameKeyPath:nil
         cacheName:@"Root"];
        aFetchedResultsController.delegate = self;
        self.fetchedResultsController = aFetchedResultsController;
    }
	
	return _fetchedResultsController;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
