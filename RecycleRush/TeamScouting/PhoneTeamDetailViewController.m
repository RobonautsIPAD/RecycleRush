//
//  PhoneTeamDetailViewController.m
//  RecycleRush
//
//  Created by FRC on 3/28/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import "PhoneTeamDetailViewController.h"
#import "DataManager.h"
#import "FileIOMethods.h"
#import "TeamData.h"

@interface PhoneTeamDetailViewController ()
@property (weak, nonatomic) IBOutlet UIButton *toteIntakeButton;
@property (weak, nonatomic) IBOutlet UIButton *canIntakeButton;
@property (weak, nonatomic) IBOutlet UIButton *liftTypeButton;
@property (weak, nonatomic) IBOutlet UIButton *stackingMech;
@property (weak, nonatomic) IBOutlet UIButton *driveTypeButton;
@property (weak, nonatomic) IBOutlet UITextField *cimsSide;
@property (weak, nonatomic) IBOutlet UITextField *wheelType;
@property (weak, nonatomic) IBOutlet UITextField *numberOfWheels;
@property (weak, nonatomic) IBOutlet UITextField *maxHeight;
@property (weak, nonatomic) IBOutlet UITextField *wheelDiameter;
@property (weak, nonatomic) IBOutlet UITextField *maxToteStack;
@property (weak, nonatomic) IBOutlet UITextField *maxCanStack;
@property (weak, nonatomic) IBOutlet UITextField *weight;
@property (weak, nonatomic) IBOutlet UITextField *width;
@property (weak, nonatomic) IBOutlet UITextField *length;
@property (weak, nonatomic) IBOutlet UIButton *programmingButton;
@end

@implementation PhoneTeamDetailViewController {
    id popUp;
    NSUserDefaults *prefs;
    NSString *deviceName;
    BOOL dataChange;
    
    NSArray *toteIntakeList;
    NSArray *canIntakeList;
    NSArray *liftTypeList;
    NSArray *driveTypeList;
    NSArray *wheelTypeList;
    NSArray *stackingMechList;
    NSArray *programmingLanguageList;
    NSArray *triStateList;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    prefs = [NSUserDefaults standardUserDefaults];
    deviceName = [prefs objectForKey:@"deviceName"];
    self.title = [NSString stringWithFormat:@"%d - %@", [_team.number intValue], _team.name];
    NSLog(@"%@", _team);
    [self showTeam];
}

-(void)setDataChange {
    //  A change to one of the database fields has been detected. Set the time tag for the
    //  saved filed and set the device name into the field to indicated who made the change.
    _team.saved = [NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()];
    _team.savedBy = deviceName;
    // NSLog(@"Saved by:%@\tTime = %@", _team.savedBy, _team.saved);
    dataChange = TRUE;
}

-(void)checkDataStatus {
    // Check to see if a data change has been made. If so, save the database.
    // At some point, we really need to decide on real error handling.
    if (dataChange) {
        _team.saved = [NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()];
        if (![_dataManager saveContext]) {
            UIAlertView *prompt  = [[UIAlertView alloc] initWithTitle:@"Horrible Problem"
                                                              message:@"Unable to save data"
                                                             delegate:nil
                                                    cancelButtonTitle:@"Ok"
                                                    otherButtonTitles:nil];
            [prompt setAlertViewStyle:UIAlertViewStyleDefault];
            [prompt show];
        }
        dataChange = NO;
    }
}

-(void)showTeam {
    //  Set the display fields for the currently selected team.
    _maxHeight.text = [NSString stringWithFormat:@"%.1f", [_team.maxHeight floatValue]];
    _wheelType.text = _team.wheelType;
    _numberOfWheels.text = [NSString stringWithFormat:@"%d", [_team.nwheels intValue]];
    _wheelDiameter.text = [NSString stringWithFormat:@"%.1f", [_team.wheelDiameter floatValue]];
    _cimsSide.text = [NSString stringWithFormat:@"%.0f", [_team.cims floatValue]];
    _maxToteStack.text = [NSString stringWithFormat:@"%d", [_team.maxToteStack intValue]];
    _maxCanStack.text = [NSString stringWithFormat:@"%d", [_team.maxCanHeight intValue]];
    _weight.text = [NSString stringWithFormat:@"%.1f", [_team.weight floatValue]];
    _length.text = [NSString stringWithFormat:@"%.1f", [_team.length floatValue]];
    _width.text = [NSString stringWithFormat:@"%.1f", [_team.width floatValue]];
    
    [_driveTypeButton setTitle:_team.driveTrainType forState:UIControlStateNormal];
    [_toteIntakeButton setTitle:_team.toteIntake forState:UIControlStateNormal];
    [_canIntakeButton setTitle:_team.canIntake forState:UIControlStateNormal];
    [_liftTypeButton setTitle:_team.liftType forState:UIControlStateNormal];
    [_stackingMech setTitle:_team.stackMechanism forState:UIControlStateNormal];
    [_programmingButton setTitle:_team.language forState:UIControlStateNormal];
    dataChange = NO;
}

- (IBAction)toteIntakeSelection:(id)sender {
    NSLog(@"toteIntakeButton");
    popUp= sender;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Tote Intake" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    if (!toteIntakeList) toteIntakeList = [FileIOMethods initializePopUpList:@"ToteIntakeType"];
    for (NSString *intakeType in toteIntakeList) {
        [actionSheet addButtonWithTitle:intakeType];
    }
    [actionSheet addButtonWithTitle:@"Cancel"];
    [actionSheet setCancelButtonIndex:[toteIntakeList count]];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}

- (IBAction)canIntakeSelection:(id)sender {
    NSLog(@"canIntakeButton");
    popUp= sender;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Can Intake" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    if (!canIntakeList) canIntakeList = [FileIOMethods initializePopUpList:@"CanIntake"];
    //NSLog(@"%@", canIntakeList);
    for (NSString *canIntake in canIntakeList) {
        [actionSheet addButtonWithTitle:canIntake];
    }
    [actionSheet addButtonWithTitle:@"Cancel"];
    [actionSheet setCancelButtonIndex:[canIntakeList count]];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}

- (IBAction)liftTypeSelection:(id)sender {
    NSLog(@"liftTypeButton");
    popUp= sender;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Lift Type" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    if (!liftTypeList) liftTypeList = [FileIOMethods initializePopUpList:@"LiftType"];
    for (NSString *liftType in liftTypeList) {
        [actionSheet addButtonWithTitle:liftType];
    }
    [actionSheet addButtonWithTitle:@"Cancel"];
    [actionSheet setCancelButtonIndex:[liftTypeList count]];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}

- (IBAction)stackingOptionSelected:(id)sender {
    popUp= sender;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Stacking Mech" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    if (!stackingMechList) stackingMechList = [FileIOMethods initializePopUpList:@"StackingMech"];
    for (NSString *stackType in stackingMechList) {
        [actionSheet addButtonWithTitle:stackType];
    }
    [actionSheet addButtonWithTitle:@"Cancel"];
    [actionSheet setCancelButtonIndex:[stackingMechList count]];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}

- (IBAction)driveTypeSelection:(id)sender {
    NSLog(@"DriveTypeButton");
    popUp= sender;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Drive Type " delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    if (!driveTypeList) driveTypeList = [FileIOMethods initializePopUpList:@"DriveType"];
    for (NSString *driveType in driveTypeList) {
        [actionSheet addButtonWithTitle:driveType];
    }
    [actionSheet addButtonWithTitle:@"Cancel"];
    [actionSheet setCancelButtonIndex:[driveTypeList count]];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}

- (IBAction)programmingSelection:(id)sender {
    popUp= sender;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Programming" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    if (!programmingLanguageList) programmingLanguageList = [FileIOMethods initializePopUpList:@"ProgrammingLanguage"];
    for (NSString *programType in programmingLanguageList) {
        [actionSheet addButtonWithTitle:programType];
    }
    [actionSheet addButtonWithTitle:@"Cancel"];
    [actionSheet setCancelButtonIndex:[programmingLanguageList count]];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (popUp == _toteIntakeButton) {
        if (buttonIndex >= [toteIntakeList count]) return;
        NSString *selection = [toteIntakeList objectAtIndex:buttonIndex];
        _team.toteIntake = selection;
        [_toteIntakeButton setTitle:selection forState:UIControlStateNormal];
    }
    else if (popUp == _canIntakeButton) {
        if (buttonIndex >= [canIntakeList count]) return;
        NSString *selection = [canIntakeList objectAtIndex:buttonIndex];
        _team.canIntake = selection;
        [_canIntakeButton setTitle:selection forState:UIControlStateNormal];
    }
    else if (popUp == _liftTypeButton) {
        if (buttonIndex >= [liftTypeList count]) return;
        NSString *selection = [liftTypeList objectAtIndex:buttonIndex];
        _team.liftType = selection;
        [_liftTypeButton setTitle:selection forState:UIControlStateNormal];
    }
    else if (popUp == _stackingMech) {
        if (buttonIndex >= [stackingMechList count]) return;
        NSString *selection = [stackingMechList objectAtIndex:buttonIndex];
        _team.stackMechanism = selection;
        [_stackingMech setTitle:selection forState:UIControlStateNormal];
    }
    else if (popUp == _driveTypeButton) {
        if (buttonIndex >= [driveTypeList count]) return;
        NSString *selection = [driveTypeList objectAtIndex:buttonIndex];
        _team.driveTrainType = selection;
        [_driveTypeButton setTitle:selection forState:UIControlStateNormal];
    }
    else if (popUp == _programmingButton) {
        if (buttonIndex >= [programmingLanguageList count]) return;
        NSString *selection = [programmingLanguageList objectAtIndex:buttonIndex];
        _team.language = selection;
        [_programmingButton setTitle:selection forState:UIControlStateNormal];
    }
    [self setDataChange];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self setDataChange];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Limit these text fields to numbers only.
    if (textField == _wheelType)  return YES;
    
    NSString *resultingString = [textField.text stringByReplacingCharactersInRange: range withString: string];
    
    // This allows backspace
    if ([resultingString length] == 0) {
        return true;
    }
    if (textField == _maxCanStack || textField == _numberOfWheels || textField == _maxToteStack) {
        NSInteger holder;
        NSScanner *scan = [NSScanner scannerWithString: resultingString];
        
        return [scan scanInteger: &holder] && [scan isAtEnd];
    }
    else {
        float holder;
        NSScanner *scan = [NSScanner scannerWithString: resultingString];
        
        return [scan scanFloat: &holder] && [scan isAtEnd];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
