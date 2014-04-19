//
//  PadSyncViewController.h
//  AerialAssist
//
//  Created by Kylor Wang on 4/17/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "PopUpPickerViewController.h"

@class DataManager;

@interface PadSyncViewController : UIViewController <UIActionSheetDelegate, PopUpPickerDelegate>

@property (nonatomic, strong) DataManager *dataManager;

@end
