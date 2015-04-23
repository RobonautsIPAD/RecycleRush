//
//  SpreadsheetViewController.h
//  RecycleRush
//
//  Created by FRC on 4/13/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMSpreadsheetView.h"

@class DataManager;

@interface SpreadsheetViewController : UIViewController <MMSpreadsheetViewDataSource, MMSpreadsheetViewDelegate>
@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) NSArray *dataRows;

@end
