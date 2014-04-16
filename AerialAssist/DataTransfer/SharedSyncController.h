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

@property (nonatomic, strong) DataManager *dataManager;

-(id)initWithDataManager:(DataManager *)initManager andTableView:(UITableView *)tableView;

-(void)connectionFailed:(NSNotification *)notification;
-(void)bluetoothNotice:(NSNotification *)notification;
-(void)shutdownBluetooth;

-(void)setXFerOption:(XFerOption)optionChoice;
-(void)setSyncType:(SyncType)typeChoice;
-(void)setSyncOption:(SyncOptions)optionChoice;

-(void)updateTableData;

-(NSMutableArray *)fetchTournamentList;
-(NSArray *)fetchTeamList;
-(NSArray *)fetchMatchList;
-(NSArray *)fetchResultsList;

-(void)sendData;

@end
