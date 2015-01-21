//
//  TabletSyncViewController.h
//  RecycleRush
//
//  Created by FRC on 1/20/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataManager;

@interface TabletSyncViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) DataManager *dataManager;
-(void)updateClientStatus:(NSNotification *)notification;
-(void)updateServerStatus:(NSNotification *)notification;

@end
