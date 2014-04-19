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

@interface TabletSyncViewController : UIViewController <GKPeerPickerControllerDelegate, GKSessionDelegate, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, PopUpPickerDelegate>

@property (nonatomic, strong) DataManager *dataManager;

@property (nonatomic, weak) IBOutlet UITableView *sendDataTable;
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

-(void)setHeaders;
-(void)createHeaders;

-(IBAction) btnConnect:(id) sender;
-(IBAction) btnDisconnect:(id) sender;
-(void)connectionFailed:(NSNotification *)notification;
-(void)bluetoothNotice:(NSNotification *)notification;

-(IBAction) createDataPackage:(id) sender;

@end