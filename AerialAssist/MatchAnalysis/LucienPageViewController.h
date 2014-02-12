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
@property (nonatomic, strong) PopUpPickerViewController *averagePicker;
@property (nonatomic, strong) NSMutableArray *averageList;
@property (nonatomic, strong) UIPopoverController *averagePickerPopover;
@property (nonatomic, strong) PopUpPickerViewController *heightPicker;
@property (nonatomic, strong) NSMutableArray *heightList;
@property (nonatomic, strong) UIPopoverController *heightPickerPopover;

@property (nonatomic, weak) IBOutlet UIButton *autonAverage;
@property (nonatomic, weak) IBOutlet UITextField *autonNormal;
@property (nonatomic, weak) IBOutlet UITextField *autonFactor;

@property (nonatomic, weak) IBOutlet UIButton *teleOpAverage;
@property (nonatomic, weak) IBOutlet UITextField *teleOpNormal;
@property (nonatomic, weak) IBOutlet UITextField *teleOpFactor;

@property (nonatomic, weak) IBOutlet UIButton *climbAverage;
@property (nonatomic, weak) IBOutlet UITextField *climbNormal;
@property (nonatomic, weak) IBOutlet UITextField *climbFactor;

@property (nonatomic, weak) IBOutlet UIButton *driverAverage;
@property (nonatomic, weak) IBOutlet UITextField *driverNormal;
@property (nonatomic, weak) IBOutlet UITextField *driverFactor;

@property (nonatomic, weak) IBOutlet UIButton *speedAverage;
@property (nonatomic, weak) IBOutlet UITextField *speedNormal;
@property (nonatomic, weak) IBOutlet UITextField *speedFactor;

@property (nonatomic, weak) IBOutlet UIButton *defenseAverage;
@property (nonatomic, weak) IBOutlet UITextField *defenseNormal;
@property (weak, nonatomic) IBOutlet UITextField *defenseFactor;

@property (nonatomic, weak) IBOutlet UITextField *height1Normal;
@property (nonatomic, weak) IBOutlet UIButton *height1Average;
@property (nonatomic, weak) IBOutlet UITextField *height1Factor;

@property (nonatomic, weak) IBOutlet UITextField *height2Normal;
@property (nonatomic, weak) IBOutlet UIButton *height2Average;
@property (nonatomic, weak) IBOutlet UITextField *height2Factor;

@property (nonatomic, weak) IBOutlet UIButton *calculateButton;

-(IBAction)selectParameter:(id)sender;
- (IBAction)selectAverage:(id)sender;
- (IBAction)selectHeight:(id)sender;

-(float)calculateNumbers:(NSMutableArray *)list forAverage:(NSNumber *)average forNormal:(NSNumber *)normal forFactor:(NSNumber *)factor;

-(void)SetBigButtonDefaults:(UIButton *)currentButton;
-(void)SetSmallButtonDefaults:(UIButton *)currentButton;

- (NSString *)applicationDocumentsDirectory;
-(void)setDisplayData;

@end
