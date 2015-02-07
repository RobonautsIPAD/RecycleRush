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
@interface PitScoutingDataSheet ()
@property (weak, nonatomic) IBOutlet UIButton *toteIntakeButton;
@property (weak, nonatomic) IBOutlet UIButton *liftButton;
@property (weak, nonatomic) IBOutlet UIButton *canIntakeButton;


@end

@implementation PitScoutingDataSheet {
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

- (IBAction)intakeSelection:(id)sender {
    NSLog(@"toteIntakeButton");
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

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) return;
    NSString *newIntake = [intakeList objectAtIndex:(buttonIndex)];
    [_toteIntakeButton setTitle:newIntake forState:UIControlStateNormal];
   
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
