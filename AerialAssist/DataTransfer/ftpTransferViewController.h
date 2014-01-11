//
//  ftpTransferViewController.h
// Robonauts Scouting
//
//  Created by FRC on 4/21/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataManager;

@interface ftpTransferViewController : UIViewController <UITextFieldDelegate, NSStreamDelegate>
@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, weak) IBOutlet UIButton *pushDataButton;
@property (nonatomic, weak) IBOutlet UIButton *getDataButton;
@property (nonatomic, weak) IBOutlet UIButton *sendDatabaseButton;
@property (nonatomic, weak) IBOutlet UIButton *picturesButton;
@property (nonatomic, weak) IBOutlet UITextField *urlText;
@property (nonatomic, weak) IBOutlet UITextField *usernameText;
@property (nonatomic, weak) IBOutlet UITextField *passwordText;
@property (nonatomic, strong, readwrite) IBOutlet UILabel *statusLabel;
@property (nonatomic, strong, readwrite) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong, readwrite) IBOutlet UIButton *cancelButton;

- (IBAction)sendAction:(UIView *)sender;
- (IBAction)cancelAction:(id)sender;
- (IBAction)pushData:(id)sender;
- (IBAction)getData:(id)sender;
- (IBAction)pushDatabase:(id)sender;
- (IBAction)pictures:(id)sender;
-(void)timerStart;
- (void)timerFired;
-(void)timerEnd;

- (NSString *)applicationDocumentsDirectory;
- (NSString *)applicationLibraryDirectory;

@end
