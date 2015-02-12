//
//  PitScoutingDataSheet.h
//  RecycleRush
//
//  Created by FRC on 1/24/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DataManager;
@interface PitScoutingDataSheet : UIViewController <UIActionSheetDelegate, UITextFieldDelegate>

@property (nonatomic, strong) DataManager *dataManager;
@end
