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

@interface TabletSyncViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, PopUpPickerDelegate>
@property (nonatomic, strong) DataManager *dataManager;
-(void)updateClientStatus:(NSNotification *)notification;
-(void)updateServerStatus:(NSNotification *)notification;

@end
