//
//  PitScoutingDataSheet.h
//  RecycleRush
//
//  Created by FRC on 1/24/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DataManager;
@class TeamData;
@interface PitScoutingDataSheet : UIViewController <UITextFieldDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) TeamData *team;



@end
