//
//  ImportDataViewController.h
// Robonauts Scouting
//
//  Created by FRC on 4/2/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataManager;

@interface ImportDataViewController : UIViewController
@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, weak) IBOutlet UIButton *importUSFirstButton;
@property (nonatomic, weak) IBOutlet UIButton *importMatchList;

@end
