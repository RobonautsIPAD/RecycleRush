//
//  PitScoutingDataSheet.m
//  RecycleRush
//
//  Created by FRC on 1/24/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import "PitScoutingDataSheet.h"
#import "DataManager.h"
#import "FileIOMethods.h" 
#import "TeamData.h"
@interface PitScoutingDataSheet ()
@property (weak, nonatomic) IBOutlet UIButton *toteIntakeButton;
@property (weak, nonatomic) IBOutlet UIButton *canIntakeButton;
@property (weak, nonatomic) IBOutlet UIButton *liftTypeButton;
@property (weak, nonatomic) IBOutlet UIButton *noodlerOptionButton;
@property (weak, nonatomic) IBOutlet UILabel *trackerOptionButton;
@property (weak, nonatomic) IBOutlet UILabel *cimsSideButton;
@property (weak, nonatomic) IBOutlet UILabel *driveTypeButton;
@property (weak, nonatomic) IBOutlet UILabel *wheelTypeButton;
@property (weak, nonatomic) IBOutlet UILabel *numberOfWheelsButton;
@property (weak, nonatomic) IBOutlet UIButton *noodlerOption;









@end

@implementation PitScoutingDataSheet {
    id popUp;
    
    
    
    
    
    NSArray *intakeTypeList;
    NSArray *canIntakeList;
    NSArray *liftTypeList;
    NSArray *driveTypeList;
    NSArray *wheelTypeList;
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
	// Do any additional setup after loading the view.








}

/*
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
        NSError *error;
        _team.saved = [NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()];
        if (![_dataManager.managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        dataChange = NO;
    }
}

*/


- (IBAction)toteIntakeSelection:(id)sender {
    NSLog(@"toteIntakeButton");
    popUp= sender;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Tote Intake" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    if (!intakeTypeList) intakeTypeList = [FileIOMethods initializePopUpList:@"IntakeType"];
    for (NSString *intakeType in intakeTypeList) {
        [actionSheet addButtonWithTitle:intakeType];
    }
    [actionSheet addButtonWithTitle:@"Cancel"];
    [actionSheet setCancelButtonIndex:[intakeTypeList count]];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}
- (IBAction)canIntakeSelection:(id)sender {
    NSLog(@"canIntakeButton");
    popUp= sender;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Can Intake" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    if (!canIntakeList) canIntakeList = [FileIOMethods initializePopUpList:@"CanIntake"];
    NSLog(@"%@", canIntakeList);
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

- (IBAction)NoodlerOption:(id)sender {
    NSLog(@"NoodlerOptionButton");
    popUp= sender;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Noodler Option " delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    if (!triStateList) triStateList = [FileIOMethods initializePopUpList:@"TriState"];
    for (NSString *noodlerOption in triStateList) {
        [actionSheet addButtonWithTitle:noodlerOption];
    }
    [actionSheet addButtonWithTitle:@"Cancel"];
    [actionSheet setCancelButtonIndex:[triStateList count]];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}




- (IBAction)TrackerOption:(id)sender {
    NSLog(@"TrackerOptionButton");
    popUp= sender;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Tracker Option " delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    if (!triStateList) triStateList = [FileIOMethods initializePopUpList:@"Tracker Option"];
    for (NSString *trackerOption in triStateList) {
        [actionSheet addButtonWithTitle:trackerOption];
    }
    [actionSheet addButtonWithTitle:@"Cancel"];
    [actionSheet setCancelButtonIndex:[triStateList count]];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}




- (IBAction)DriveTypeSelection:(id)sender {
    NSLog(@"DriveTypeButton");
    popUp= sender;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Drive Type " delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    if (!driveTypeList) driveTypeList = [FileIOMethods initializePopUpList:@"Drive Type Selection"];
    for (NSString *driveType in driveTypeList) {
        [actionSheet addButtonWithTitle:driveType];
    }
    [actionSheet addButtonWithTitle:@"Cancel"];
    [actionSheet setCancelButtonIndex:[driveTypeList count]];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}














/*
- (IBAction)toteIntakeSelection:(id)sender {
        NSLog(@"noodlerOptionButton");
        popUp= sender;
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Noodler Option" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        if (!intakeList) intakeList = [FileIOMethods initializePopUpList:@"NoodlerOption"];
        for (NSString *intake in intakeList) {
            [actionSheet addButtonWithTitle:intake];
        }
        [actionSheet addButtonWithTitle:@"Cancel"];
        [actionSheet setCancelButtonIndex:[noodlerList count]];
        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
        [actionSheet showInView:self.view];
}

*/

/*
    - (IBAction)trackerOptionSelection:(id)sender {
        NSLog(@"trackerOptionButton");
        popUp= sender;
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Tracker Option" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        if (!trackerOptionList) trackerOptionList = [FileIOMethods initializePopUpList:@"TrackerOption"];
        for (NSString *trackerOption in trackerOptionList) {
            [actionSheet addButtonWithTitle:trackerOption];
        }
        [actionSheet addButtonWithTitle:@"Cancel"];
        [actionSheet setCancelButtonIndex:[trackerOptionList count]];
        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
        [actionSheet showInView:self.view];
    }

    */





- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
