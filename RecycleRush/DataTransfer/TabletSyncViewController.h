//
//  TabletSyncViewController.h
//  RecycleRush
//
//  Created by FRC on 1/20/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopUpPickerViewController.h"

@class DataManager;
@class ConnectionUtility;

@interface TabletSyncViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, PopUpPickerDelegate>
@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) ConnectionUtility *connectionUtility;
-(void)updateClientStatus:(NSNotification *)notification;
-(void)updateServerStatus:(NSNotification *)notification;
-(void)dataReceived:(NSNotification *)notification;

@end
