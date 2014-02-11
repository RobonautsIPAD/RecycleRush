//
//  SyncViewController.h
// Robonauts Scouting
//
//  Created by FRC on 3/13/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "AlertPromptViewController.h"
#import "PopUpPickerViewController.h"

@class DataManager;
@class MatchResultsObject;
@class TeamScore;

@interface TabletSyncViewController : UIViewController <GKPeerPickerControllerDelegate, GKSessionDelegate, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, PopUpPickerDelegate>
@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, assign) SyncType syncType;
@property (nonatomic, assign) SyncOptions syncOption;
@property (nonatomic, assign) BlueToothType blueToothType;
@property (nonatomic, retain) GKSession *currentSession;
@property (nonatomic, weak) IBOutlet UITableView *sendDataTable;
@property (nonatomic, weak) IBOutlet UITableView *receiveDataTable;
@property (nonatomic, weak) IBOutlet UIButton *connectButton;
@property (nonatomic, weak) IBOutlet UIButton *disconnectButton;
@property (nonatomic, weak) IBOutlet UIButton *sendButton;
@property (nonatomic, weak) IBOutlet UILabel *peerLabel;
@property (nonatomic, weak) IBOutlet UILabel *peerName;

@property (nonatomic, weak) IBOutlet UIButton *syncTypeButton;
@property (nonatomic, strong) PopUpPickerViewController *syncTypePicker;
@property (nonatomic, strong) UIPopoverController *syncPickerPopover;
@property (nonatomic, strong) NSMutableArray *syncTypeList;
-(void)changeSyncType:(NSString *)newSyncType;

@property (nonatomic, weak) IBOutlet UIButton *syncOptionButton;
@property (nonatomic, strong) PopUpPickerViewController *syncOptionPicker;
@property (nonatomic, strong) UIPopoverController *syncOptionPopover;
@property (nonatomic, strong) NSMutableArray *syncOptionList;
-(void)changeSyncOption:(NSString *)newSyncOption;

-(IBAction)syncChanged:(id)sender;
-(void)setHeaders;
-(void)createHeaders;
-(void)createTeamList;
-(void)createTournamentList;

@property (nonatomic, retain) AlertPromptViewController *alertPrompt;
@property (nonatomic, retain) UIPopoverController *alertPromptPopover;

-(IBAction) btnConnect:(id) sender;
-(IBAction) btnDisconnect:(id) sender;
-(void)connectionFailed:(NSNotification *)notification;

-(IBAction) createDataPackage:(id) sender;

-(BOOL)addMatchScore:(MatchResultsObject *) xferData;
-(void)unpackXferData:(MatchResultsObject *)xferData forScore:(TeamScore *)score;

@end
