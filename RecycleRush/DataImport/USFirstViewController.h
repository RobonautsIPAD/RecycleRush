//
//  USFirstViewController.h
//  RecycleRush
//
//  Created by Kylor Wang on 4/2/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DataManager;

@interface USFirstViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>

@property (nonatomic, strong) DataManager *dataManager;

@end
