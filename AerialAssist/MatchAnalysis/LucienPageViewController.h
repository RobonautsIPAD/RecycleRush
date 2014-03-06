//
//  LucienPageViewController.h
// Robonauts Scouting
//
//  Created by FRC on 4/21/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopUpPickerViewController.h"

@class DataManager;
@class PopUpPickerViewController;

@interface LucienPageViewController : UIViewController <UITextFieldDelegate, PopUpPickerDelegate>
@property (nonatomic, weak) IBOutlet UIImageView *mainLogo;
@property (nonatomic, weak) IBOutlet UILabel *labelText;

@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) PopUpPickerViewController *heightPicker;
@property (nonatomic, strong) NSMutableArray *heightList;
@property (nonatomic, strong) UIPopoverController *heightPickerPopover;

@property (nonatomic, weak) IBOutlet UIButton *calculateButton;

-(IBAction)selectParameter:(id)sender;
- (IBAction)selectAverage:(id)sender;
- (IBAction)selectHeight:(id)sender;

-(void)SetBigButtonDefaults:(UIButton *)currentButton;
-(void)SetSmallButtonDefaults:(UIButton *)currentButton;

-(void)setDisplayData;

@end
