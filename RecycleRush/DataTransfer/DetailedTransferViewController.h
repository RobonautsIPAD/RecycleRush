//
//  DetailedTransferViewController.h
//  RecycleRush
//
//  Created by FRC on 4/13/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopUpPickerViewController.h"

@class DataManager;
@class ConnectionUtility;

@interface DetailedTransferViewController : UIViewController <UITextFieldDelegate, PopUpPickerDelegate>
@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) ConnectionUtility *connectionUtility;
-(void)dataReceived:(NSNotification *)notification;

@end
