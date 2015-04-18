//
//  CoverSheetViewController.m
//  RecycleRush
//
//  Created by FRC on 4/18/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import "CoverSheetViewController.h"
#import <QuartzCore/CALayer.h>
#import "DataManager.h"
#import "TeamData.h"
#import "TeamAccessors.h"
#import "LNNumberpad.h"

@interface CoverSheetViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *teamLabel;
@property (weak, nonatomic) IBOutlet UITextField *teamNumberField;
@property (weak, nonatomic) IBOutlet UILabel *teamNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *robotPhotoImageView;
@property (weak, nonatomic) IBOutlet UIView *robotInfoView;
@property (weak, nonatomic) IBOutlet UIView *robotHistoryView;
@property (weak, nonatomic) IBOutlet UITextField *oprField;
@property (weak, nonatomic) IBOutlet UITextField *canDomField;
@property (weak, nonatomic) IBOutlet UITextField *ccwmField;
@property (weak, nonatomic) IBOutlet UITextField *canDomTimeField;
@property (weak, nonatomic) IBOutlet UITextField *scoreField;
@property (weak, nonatomic) IBOutlet UILabel *event1Label;
@property (weak, nonatomic) IBOutlet UILabel *event2Label;
@property (weak, nonatomic) IBOutlet UILabel *event3Label;
@property (weak, nonatomic) IBOutlet UILabel *event4Label;
@property (weak, nonatomic) IBOutlet UILabel *event5Label;
@property (weak, nonatomic) IBOutlet UITextField *notesField;

@end

@implementation CoverSheetViewController {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSString *deviceName;
    TeamData *currentTeam;
    BOOL dataChange;
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
    // Check to make sure the data manager has been initialized
    if (!_dataManager) {
        UIAlertView *prompt  = [[UIAlertView alloc] initWithTitle:@"Horrible Problem"
                                                          message:@"Initialization Problem"
                                                         delegate:nil
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
        [prompt setAlertViewStyle:UIAlertViewStyleDefault];
        [prompt show];
    }
    // Get the preferences needed for this VC
    prefs = [NSUserDefaults standardUserDefaults];
    deviceName = [prefs objectForKey:@"deviceName"];
    tournamentName = [prefs objectForKey:@"tournament"];
    if (tournamentName) {
        self.title =  [NSString stringWithFormat:@"%@ Cover Sheets", tournamentName];
    }
    else {
        self.title = @"Cover Sheets";
    }
    if (!_teamList) {
        _teamList = [TeamAccessors getTeamDataForTournament:tournamentName fromDataManager:_dataManager];
    }
    if (_teamList && [_teamList count]) {
        currentTeam = [_teamList objectAtIndex:0];
    }
    [self showTeam];
    _robotInfoView.layer.borderColor = [UIColor blackColor].CGColor;
    _robotInfoView.layer.borderWidth = 2.0f;
    _robotHistoryView.layer.borderColor = [UIColor blackColor].CGColor;
    _robotHistoryView.layer.borderWidth = 1.0f;
    _robotHistoryView.layer.cornerRadius = 10.0f;
    _teamNumberField.inputView  = [LNNumberpad defaultLNNumberpad];
    _oprField.inputView  = [LNNumberpad defaultLNNumberpad];
    _canDomField.inputView  = [LNNumberpad defaultLNNumberpad];
    _ccwmField.inputView  = [LNNumberpad defaultLNNumberpad];
    _scoreField.inputView  = [LNNumberpad defaultLNNumberpad];
}

-(void)setDataChange {
    //  A change to one of the database fields has been detected. Set the time tag for the
    //  saved filed and set the device name into the field to indicated who made the change.
    currentTeam.saved = [NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()];
    currentTeam.savedBy = deviceName;
    // NSLog(@"Saved by:%@\tTime = %@", _team.savedBy, _team.saved);
    dataChange = TRUE;
}

-(void)checkDataStatus {
    // Check to see if a data change has been made. If so, save the database.
    // At some point, we really need to decide on real error handling.
    if (dataChange) {
        currentTeam.saved = [NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()];
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
    _teamNumberField.text = [NSString stringWithFormat:@"%@", currentTeam.number];
    _teamNameLabel.text = currentTeam.name;
    _oprField.text = [NSString stringWithFormat:@"%.1f", [currentTeam.coverOPR floatValue]];
    _scoreField.text = [NSString stringWithFormat:@"%.1f", [currentTeam.coverAverageScore floatValue]];
    _ccwmField.text = [NSString stringWithFormat:@"%.1f", [currentTeam.coverCCWM floatValue]];
    _notesField.text = currentTeam.coverNotes;
    dataChange = NO;
}

- (IBAction)teamNumberChanged:(id)sender {

 /*   // The user has typed a new team number in the field. Access that team and display it.
    // NSLog(@"teamNumberChanged");
    [self checkDataStatus];
    if ([_numberText.text isEqualToString:@""]) {
        _numberText.text = [NSString stringWithFormat:@"%d", [_team.number intValue]];
        return;
    }
    
    int currentTeam = [_numberText.text intValue];
    BOOL found = FALSE;
    for(int x = 0; x < [self getNumberOfTeams]; x++){
        NSIndexPath *teamIndex = [NSIndexPath indexPathForRow:x inSection:0];
        TeamData* team = [_fetchedResultsController objectAtIndexPath: teamIndex];
        if([team.number intValue] == currentTeam) {
            _teamIndex = teamIndex;
            _team = team;
            [self showTeam];
            found = TRUE;
            break;
        }
    }
    if (!found) _numberText.text = [NSString stringWithFormat:@"%d", [_team.number intValue]];*/
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    //    NSLog(@"team should end editing");
    if (textField == _oprField) {
		currentTeam.coverOPR = [NSNumber numberWithFloat:[_oprField.text floatValue]];
	}
	else if (textField == _canDomField) {
		currentTeam.coverCanDomCans = [NSNumber numberWithInt:[_canDomField.text intValue]];
	}
	else if (textField == _ccwmField) {
		currentTeam.coverCCWM = [NSNumber numberWithFloat:[_ccwmField.text floatValue]];
	}
	else if (textField == _canDomTimeField) {
		currentTeam.coverCanDomTime = _canDomTimeField.text;
	}
	else if (textField == _scoreField) {
		currentTeam.coverAverageScore = [NSNumber numberWithFloat:[_scoreField.text floatValue]];
	}
	return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField != _teamNumberField) {
        [self setDataChange];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Limit these text fields to numbers only.
    if (textField == _canDomTimeField || textField == _notesField)  return YES;
    
    NSString *resultingString = [textField.text stringByReplacingCharactersInRange: range withString: string];
    
    // This allows backspace
    if ([resultingString length] == 0) {
        return true;
    }
    if (textField == _canDomField) {
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

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
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
