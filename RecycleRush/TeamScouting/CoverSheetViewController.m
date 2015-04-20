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
#import "Regional.h"
#import "TeamAccessors.h"
#import "PhotoUtilities.h"
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
    NSUInteger currentTeamIndex;
    NSMutableArray *regionalLabels;
    PhotoUtilities *photoUtilities;
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
        currentTeamIndex = 0;
    }
    photoUtilities = [[PhotoUtilities alloc] init:_dataManager];
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
    regionalLabels = [[NSMutableArray alloc] init];
    CGFloat yAnchor = 5.0;
    CGFloat yInterval = 25.0;
    for (int i=0; i<5; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20,yAnchor+yInterval*i,700,21)];
        label.textColor = [UIColor blackColor];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:17.0];
        [regionalLabels addObject:label];
        [_robotHistoryView addSubview:label];
    }
    [self showTeam];
    [_event1Label setHidden:TRUE];
    [_event2Label setHidden:TRUE];
    [_event3Label setHidden:TRUE];
    [_event4Label setHidden:TRUE];
    [_event5Label setHidden:TRUE];
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gotoNextTeam:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeLeft.numberOfTouchesRequired = 1;
    swipeLeft.delegate = self;
    [self.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gotoPrevTeam:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    swipeRight.numberOfTouchesRequired = 1;
    swipeRight.delegate = self;
    [self.view addGestureRecognizer:swipeRight];
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
    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"eventNumber" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:numberDescriptor, nil];
    NSArray *regionals = [[currentTeam.regional allObjects] sortedArrayUsingDescriptors:sortDescriptors];
    [[regionalLabels objectAtIndex:0] setHidden:TRUE];
    [[regionalLabels objectAtIndex:1] setHidden:TRUE];
    [[regionalLabels objectAtIndex:2] setHidden:TRUE];
    [[regionalLabels objectAtIndex:3] setHidden:TRUE];
    [[regionalLabels objectAtIndex:4] setHidden:TRUE];
    int i = 0;
    for (Regional *regional in regionals) {
        NSString *event = [NSString stringWithFormat:@"%@ Regional:%@, %@, Avg. Score:%.1f", regional.eventName, regional.finishPosition, regional.alliance, [regional.averageScore floatValue]];
        UILabel *label = [regionalLabels objectAtIndex:i];
        label.text = event;
        [label setHidden:FALSE];
        i++;
        NSLog(@"regional event = %@", regional.eventName);
    }
    [self getPhoto];
    dataChange = NO;
}

-(void)getPhoto {
    _robotPhotoImageView.image = nil;
    _robotPhotoImageView.userInteractionEnabled = NO;
    _robotPhotoImageView.contentMode = UIViewContentModeScaleAspectFit;
    if (!currentTeam.primePhoto) return;
    [_robotPhotoImageView setImage:[UIImage imageWithContentsOfFile:[photoUtilities getFullImagePath:currentTeam.primePhoto]]];
}

- (IBAction)teamNumberChanged:(id)sender {
    // The user has typed a new team number in the field. Access that team and display it.
    // NSLog(@"teamNumberChanged");
    [self checkDataStatus];
    if ([_teamNumberField.text isEqualToString:@""]) {
        _teamNumberField.text = [NSString stringWithFormat:@"%@", currentTeam.number];
        return;
    }
    int desiredTeam = [_teamNumberField.text intValue];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"number = %@", [NSNumber numberWithInt:desiredTeam]];
    NSArray *team = [_teamList filteredArrayUsingPredicate:pred];
    if (team && [team count]) {
        TeamData *newTeam = [team objectAtIndex:0];
        NSUInteger newIndex = [_teamList indexOfObject:newTeam];
        if (newIndex == NSNotFound) {
            newIndex = currentTeamIndex;
        }
        else {
            currentTeamIndex = [_teamList indexOfObject:newTeam];
        }
        currentTeam = [_teamList objectAtIndex:currentTeamIndex];
        [self showTeam];
    }
}

-(void)gotoNextTeam:(UISwipeGestureRecognizer *)gestureRecognizer {
    if (currentTeamIndex < ([_teamList count]-1)) currentTeamIndex++;
    else currentTeamIndex = 0;
    currentTeam = [_teamList objectAtIndex:currentTeamIndex];
    [self showTeam];
}

-(void)gotoPrevTeam:(UISwipeGestureRecognizer *)gestureRecognizer {
    if (currentTeamIndex == 0) currentTeamIndex = [_teamList count] - 1;
    else currentTeamIndex--;
    currentTeam = [_teamList objectAtIndex:currentTeamIndex];
    [self showTeam];
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
		currentTeam.coverCanDomTime = [NSNumber numberWithInt:[_canDomTimeField.text intValue]];
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
