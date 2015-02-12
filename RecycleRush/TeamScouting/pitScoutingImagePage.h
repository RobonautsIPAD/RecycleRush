//
//  pitScoutingImagePage.h
//  RecycleRush
//
//  Created by FRC on 1/24/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DataManager;
@class TeamData;
@interface pitScoutingImagePage : UIViewController <UINavigationControllerDelegate, UIActionSheetDelegate,  UIImagePickerControllerDelegate, UITextFieldDelegate>
@property (nonatomic, strong) DataManager *dataManager;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSIndexPath *teamIndex;
@property (nonatomic, strong) TeamData *team;

@end
