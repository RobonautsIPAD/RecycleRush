//
//  SharedSyncController.h
//  AerialAssist
//
//  Created by FRC on 4/14/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@class DataManager;

@interface SharedSyncController : NSObject <UITableViewDelegate, UITableViewDataSource, GKSessionDelegate, GKPeerPickerControllerDelegate>

@property (nonatomic, weak) UIButton *xFerOptionButton;
@property (nonatomic, weak) UIButton *syncTypeButton;
@property (nonatomic, weak) UIButton *syncOptionButton;
@property (nonatomic, weak) UIButton *connectButton;
@property (nonatomic, weak) UIButton *disconnectButton;
@property (nonatomic, weak) UILabel *peerName;
@property (nonatomic, weak) UIButton *sendButton;
@property (nonatomic, weak) UITableView *syncDataTable;
@property (nonatomic, weak) UIButton *packageDataButton;
@property (nonatomic, weak) UIButton *importFromiTunesButton;
@property (nonatomic, strong) DataManager *dataManager;

-(id)initWithDataManager:(DataManager *)initManager;

-(void)connectionFailed:(NSNotification *)notification;
-(void)bluetoothNotice:(NSNotification *)notification;

-(void)setXFerOption:(XFerOption)optionChoice;
-(void)setSyncType:(SyncType)typeChoice;
-(void)setSyncOption:(SyncOptions)optionChoice;

-(void)updateTableData;

-(void)btnConnect;
-(void)btnDisconnect;
-(void)btnSend;

-(NSArray *)getImportFileList;
-(void)importiTunesSelected:(NSString *)importFile;

@end
