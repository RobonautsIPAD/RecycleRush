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

@property (weak, nonatomic) IBOutlet UIButton *liftButton;
@property (weak, nonatomic) IBOutlet UIButton *canIntakeButton;
@property (weak, nonatomic) IBOutlet UIButton *liftTypeButton;
@property (weak, nonatomic) IBOutlet UIButton *noodlerOptionButton;









@end

@implementation PitScoutingDataSheet {
    id popUp;
    
    
    
    
    
    NSArray *intakeList;
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
    if (!intakeList) intakeList = [FileIOMethods initializePopUpList:@"IntakeType"];
    for (NSString *intake in intakeList) {
        [actionSheet addButtonWithTitle:intake];
    }
    [actionSheet addButtonWithTitle:@"Cancel"];
    [actionSheet setCancelButtonIndex:[intakeList count]];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}
- (IBAction)canIntakeSelection:(id)sender {
    NSLog(@"canIntakeButton");
    popUp= sender;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Can Intake" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    if (!intakeList) intakeList = [FileIOMethods initializePopUpList:@"IntakeType"];
    for (NSString *intake in intakeList) {
        [actionSheet addButtonWithTitle:intake];
    }
    [actionSheet addButtonWithTitle:@"Cancel"];
    [actionSheet setCancelButtonIndex:[intakeList count]];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}

- (IBAction)liftTyoeSelection:(id)sender {
    NSLog(@"liftTypeButton");
    popUp= sender;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Lift Type" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    if (!intakeList) intakeList = [FileIOMethods initializePopUpList:@"Lift Type"];
    for (NSString *intake in intakeList) {
        [actionSheet addButtonWithTitle:intake];
    }
    [actionSheet addButtonWithTitle:@"Cancel"];
    [actionSheet setCancelButtonIndex:[intakeList count]];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}




-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) return;
    if (popUp== _toteIntakeButton) {
        NSString *newIntake = [intakeList objectAtIndex:(buttonIndex)];
        [_toteIntakeButton setTitle:newIntake forState:UIControlStateNormal];
    }
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

    
    - (IBAction)trackerOptionSelection:(id)sender {
        NSLog(@"toteIntakeButton");
        popUp= sender;
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Tote Intake" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        if (!intakeList) intakeList = [FileIOMethods initializePopUpList:@"IntakeType"];
        for (NSString *intake in intakeList) {
            [actionSheet addButtonWithTitle:intake];
        }
        [actionSheet addButtonWithTitle:@"Cancel"];
        [actionSheet setCancelButtonIndex:[intakeList count]];
        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
        [actionSheet showInView:self.view];
    }

    





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
