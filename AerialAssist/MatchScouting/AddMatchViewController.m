//
//  AddMatchViewController.m
// Robonauts Scouting
//
//  Created by FRC on 2/25/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "AddMatchViewController.h"
#import "PopUpPickerViewController.h"
#import "FileIOMethods.h"
#import "DataManager.h"
#import "MatchUtilities.h"
#import "EnumerationDictionary.h"

@interface AddMatchViewController ()
    @property (weak, nonatomic) IBOutlet UIButton *matchTypeButton;
    @property (nonatomic, strong) IBOutlet UITextField *matchNumber;
    @property (nonatomic, strong) IBOutlet UITextField *red1;
    @property (nonatomic, strong) IBOutlet UITextField *red2;
    @property (nonatomic, strong) IBOutlet UITextField *red3;
    @property (nonatomic, strong) IBOutlet UITextField *blue1;
    @property (nonatomic, strong) IBOutlet UITextField *blue2;
    @property (nonatomic, strong) IBOutlet UITextField *blue3;
    @property (nonatomic, strong) IBOutlet UITextField *red4;
    @property (nonatomic, strong) IBOutlet UITextField *blue4;
@end

@implementation AddMatchViewController {
    NSMutableArray *newMatch;
    MatchUtilities *matchUtilities;
    PopUpPickerViewController *matchTypePicker;
    UIPopoverController *matchTypePickerPopover;
    NSArray *matchTypeList;
    id popUp;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

- (void)viewDidLoad
{
    [super viewDidLoad];
    matchUtilities = [[MatchUtilities alloc] init:_dataManager];
    NSLog(@"Add blue 4 and red 4 for elim matches");
    newMatch = [[NSMutableArray alloc] initWithObjects:@"", @"", @"", @"Red 2", @"Red 3", @"Blue 1", @"Blue 2", @"Blue 3", nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (IBAction)cancelVC:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}

-(NSMutableArray *) buildTeamList:(NSString *)alliance forTextBox:(UITextField *)teamTextField forTeamList:(NSMutableArray *)teamList {
    // Return a thing with the alliance station in the first slot
    // and the team number in the second slot
    if (!alliance || [alliance isEqualToString:@""]) return teamList;
    if (!teamTextField.text || [teamTextField.text isEqualToString:@""]) return teamList;
    NSNumber *teamNumber = [NSNumber numberWithInt:[teamTextField.text intValue]];
    NSDictionary *teamInfo = [NSDictionary dictionaryWithObject:teamNumber forKey:alliance];
    [teamList addObject:teamInfo];
    return teamList;
}

- (IBAction)addAction:(id)sender {
    NSNumber *matchNumber = [NSNumber numberWithInt:[_matchNumber.text intValue]];
    NSLog(@"add check to make sure there is a match number and type");
    NSLog(@"do something about create new match that returns an exising one if it exists");
    NSMutableArray *teamList = [[NSMutableArray alloc] init];
    teamList = [self buildTeamList:@"Red 1" forTextBox:_red1 forTeamList:teamList];
    teamList = [self buildTeamList:@"Red 2" forTextBox:_red2 forTeamList:teamList];
    teamList = [self buildTeamList:@"Red 3" forTextBox:_red3 forTeamList:teamList];
    teamList = [self buildTeamList:@"Blue 1" forTextBox:_blue1 forTeamList:teamList];
    teamList = [self buildTeamList:@"Blue 2" forTextBox:_blue2 forTeamList:teamList];
    teamList = [self buildTeamList:@"Blue 3" forTextBox:_blue3 forTeamList:teamList];

    if ([_matchTypeButton.titleLabel.text isEqualToString:@"Elimination"]) {
        teamList = [self buildTeamList:@"Red 4" forTextBox:_red4 forTeamList:teamList];
        teamList = [self buildTeamList:@"Blue 4" forTextBox:_blue4 forTeamList:teamList];
    }
    NSString *errMsg = [matchUtilities addMatch:matchNumber forMatchType:_matchTypeButton.titleLabel.text forTeams:teamList forTournament:_tournamentName];
    [self dismissViewControllerAnimated:YES completion:Nil];
}

- (IBAction)matchTypeSelectionChanged:(id)sender {
    UIButton *PressedButton = (UIButton*)sender;
    popUp = PressedButton;
    if (!matchTypeList) matchTypeList = [FileIOMethods initializePopUpList:@"MatchType"];
        if (matchTypePicker == nil) {
            matchTypePicker = [[PopUpPickerViewController alloc]
                            initWithStyle:UITableViewStylePlain];
            matchTypePicker.delegate = self;
            matchTypePicker.pickerChoices = matchTypeList;
        }
        if (!matchTypePickerPopover) {
            matchTypePickerPopover = [[UIPopoverController alloc]
                                   initWithContentViewController:matchTypePicker];
        }
        [matchTypePickerPopover presentPopoverFromRect:PressedButton.bounds inView:PressedButton
                           permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

-(void)pickerSelected:(NSString *)newPick {
    // The user has made a selection on one of the pop-ups. Dismiss the pop-up
    //  and call the correct method to change the right field.
    NSLog(@"new pick = %@", newPick);
    if (popUp == _matchTypeButton) {
        [matchTypePickerPopover dismissPopoverAnimated:YES];
    }
    [popUp setTitle:newPick forState:UIControlStateNormal];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *resultingString = [textField.text stringByReplacingCharactersInRange: range withString: string];
    
    // This allows backspace
    if ([resultingString length] == 0) {
        return true;
    }
    
    NSInteger holder;
    NSScanner *scan = [NSScanner scannerWithString: resultingString];
    
    return [scan scanInteger: &holder] && [scan isAtEnd];
}

#pragma mark -
#pragma mark Text

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    //    NSLog(@"team should end editing");
    if (textField == _matchNumber) {
        [newMatch replaceObjectAtIndex:0
                            withObject:_matchNumber.text];
	}
	else if (textField == _red1) {
        [newMatch replaceObjectAtIndex:2
                            withObject:_red1.text];	}
	else if (textField == _red2) {
        [newMatch replaceObjectAtIndex:3
                            withObject:_red2.text];	}
	else if (textField == _red3) {
        [newMatch replaceObjectAtIndex:4
                            withObject:_red3.text];	}
	else if (textField == _blue1) {
        [newMatch replaceObjectAtIndex:5
                            withObject:_blue1.text];	}
	else if (textField == _blue2) {
        [newMatch replaceObjectAtIndex:6
                            withObject:_blue2.text];	}
	else if (textField == _blue3) {
        [newMatch replaceObjectAtIndex:7
                            withObject:_blue3.text];	}
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Row at index %i selected", indexPath.row);
}
@end
