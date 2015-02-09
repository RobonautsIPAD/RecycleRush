//
//  MainMatchAnalysisViewController.h
// Robonauts Scouting
//
//  Created by FRC on 3/21/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopUpPickerViewController.h"

@class DataManager;

@interface MainMatchAnalysisViewController : UIViewController <NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, PopUpPickerDelegate>

@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSNumber *teamNumber;
@property (nonatomic, strong) NSNumber *initialMatchNumber;
@property (nonatomic, strong) NSNumber *initialMatchType;

@end
