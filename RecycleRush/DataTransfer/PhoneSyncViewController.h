//
//  PhoneSyncViewController.h
//  RecycleRush
//
//  Created by FRC on 2/20/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

@class DataManager;
@class ConnectionUtility;

@interface PhoneSyncViewController : UIViewController <UIActionSheetDelegate>
@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) ConnectionUtility *connectionUtility;
@end
