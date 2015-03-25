//
//  PhoneSyncViewController.h
//  RecycleRush
//
//  Created by FRC on 2/20/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

@class DataManager;
@class ConnectionUtility;

@interface PhoneSyncViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>
@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) ConnectionUtility *connectionUtility;
-(void)updateClientStatus:(NSNotification *)notification;
-(void)updateServerStatus:(NSNotification *)notification;
-(void)dataReceived:(NSNotification *)notification;
-(void)startReceiving:(NSNotification *)notification;
@end
