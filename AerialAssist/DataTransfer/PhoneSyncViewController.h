//
//  PhoneSyncViewController.h
//  AerialAssist
//
//  Created by FRC on 2/20/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@class DataManager;

@interface PhoneSyncViewController : UIViewController <GKPeerPickerControllerDelegate, GKSessionDelegate, UIAlertViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) DataManager *dataManager;

@end
