//
//  PadSyncViewController.h
//  AerialAssist
//
//  Created by Kylor Wang on 4/17/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "PopUpPickerViewController.h"
#import "SyncMethods.h"

@class DataManager;

@interface PadSyncViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, PopUpPickerDelegate>

@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, assign) SyncType syncType;
@property (nonatomic, assign) SyncOptions syncOption;

@end
