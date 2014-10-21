//
//  PhoneExportViewController.h
//  AerialAssist
//
//  Created by FRC on 2/14/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@class DataManager;

@interface PhoneExportViewController : UIViewController <MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) DataManager *dataManager;

@end
