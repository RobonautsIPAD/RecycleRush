//
//  AddMatchViewController.m
// Robonauts Scouting
//
//  Created by FRC on 2/25/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "AddMatchViewController.h"
#import "MainLogo.h"
#import "DataManager.h"
#import "FileIOMethods.h"
#import "MatchData.h"
#import "TeamScore.h"
#import "PopUpPickerViewController.h"
#import "MatchAccessors.h"
#import "MatchUtilities.h"
#import "ScoreAccessors.h"
#import "LNNumberpad.h"

@interface AddMatchViewController ()
    @property (weak, nonatomic) IBOutlet UIImageView *mainLogo;
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
    MatchUtilities *matchUtilities;
    NSUserDefaults *prefs;
    NSString *deviceName;
    PopUpPickerViewController *matchTypePicker;
    UIPopoverController *matchTypePickerPopover;
    NSArray *matchTypeList;
    id popUp;
    BOOL textChanges;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    prefs = [NSUserDefaults standardUserDefaults];
    deviceName = [prefs objectForKey:@"deviceName"];
    matchUtilities = [[MatchUtilities alloc] init:_dataManager];
    [_matchTypeButton setBackgroundImage:[UIImage imageNamed:@"button_robonaut_gold.png"] forState:UIControlStateNormal];
    NSLog(@"Add blue 4 and red 4 for elim matches");
    [_red4 setHidden:YES];
    [_blue4 setHidden:YES];
    
    _matchNumber.inputView  = [LNNumberpad defaultLNNumberpad];
    _red1.inputView  = [LNNumberpad defaultLNNumberpad];
    _red2.inputView  = [LNNumberpad defaultLNNumberpad];
    _red3.inputView  = [LNNumberpad defaultLNNumberpad];
    _blue1.inputView  = [LNNumberpad defaultLNNumberpad];
    _blue2.inputView  = [LNNumberpad defaultLNNumberpad];
    _blue3.inputView  = [LNNumberpad defaultLNNumberpad];
    
    if (_match) {
        self.title =  [NSString stringWithFormat:@"%@ Edit Match", _match.tournamentName];
        [self displayMatch];
      
    }
    else {
        self.title =  [NSString stringWithFormat:@"%@ Add Match", _tournamentName];
    }
    textChanges = FALSE;
    
    [self setBigButtonDefaults:_matchTypeButton];
}

- (IBAction)cancelVC:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}

-(NSMutableArray *)buildTeamList:(NSString *)alliance forTextBox:(UITextField *)teamTextField forTeamList:(NSMutableArray *)teamList {
    NSDictionary *teamDictionary = [matchUtilities teamDictionary:alliance forTeam:teamTextField.text];
    if (teamDictionary) [teamList addObject:teamDictionary];
    return teamList;
}

- (IBAction)addAction:(id)sender {
    NSNumber *matchNumber = [NSNumber numberWithInt:[_matchNumber.text intValue]];
    NSError *error = nil;
    //NSLog(@"add check to make sure there is a match number and type");
    //NSLog(@"do something about create new match that returns an exising one if it exists");
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
    MatchData *newMatch = [matchUtilities addMatch:matchNumber forMatchType:_matchTypeButton.titleLabel.text forTeams:teamList forTournament:_tournamentName error:&error];
    newMatch.saved = [NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()];
    newMatch.savedBy = deviceName;
    [_dataManager saveContext];
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
    if (popUp == _matchTypeButton) {
        [matchTypePickerPopover dismissPopoverAnimated:YES];
    }
    [popUp setTitle:newPick forState:UIControlStateNormal];
}

-(void)setTeamTextField:(UITextField *)textField forScores:(NSArray *)scores forAllianceString:(NSString *)allianceString {
    TeamScore *teamScore = [ScoreAccessors getTeamScore:scores forAllianceString:allianceString forAllianceDictionary:_dataManager.allianceDictionary];
    if (teamScore) {
        textField.text = [NSString stringWithFormat:@"%d", [teamScore.teamNumber intValue]];
        if ([teamScore.results boolValue]) {
            [textField setTextColor:[UIColor redColor]];
            [textField setEnabled:NO];
        }
        else {
            [textField setTextColor:[UIColor blackColor]];
            [textField setEnabled:YES];
        }
    }
    else {
        textField.text = @"";
        [textField setEnabled:YES];
    }
}

-(void)displayMatch {
    _matchNumber.text = [NSString stringWithFormat:@"%@", _match.number];
    NSString *matchTypeString = [MatchAccessors getMatchTypeString:_match.matchType fromDictionary:_dataManager.matchTypeDictionary];
    [_matchTypeButton setTitle:matchTypeString forState:UIControlStateNormal];
    NSArray *scoreList = [_match.score allObjects];
    [self setTeamTextField:_red1 forScores:scoreList forAllianceString:@"Red 1"];
    [self setTeamTextField:_red2 forScores:scoreList forAllianceString:@"Red 2"];
    [self setTeamTextField:_red3 forScores:scoreList forAllianceString:@"Red 3"];
    [self setTeamTextField:_red4 forScores:scoreList forAllianceString:@"Red 4"];
    [self setTeamTextField:_blue1 forScores:scoreList forAllianceString:@"Blue 1"];
    [self setTeamTextField:_blue2 forScores:scoreList forAllianceString:@"Blue 2"];
    [self setTeamTextField:_blue3 forScores:scoreList forAllianceString:@"Blue 3"];
    [self setTeamTextField:_blue4 forScores:scoreList forAllianceString:@"Blue 4"];
    if ([matchTypeString isEqualToString:@"Elimination"]) {
        [_red4 setHidden:NO];
        [_blue4 setHidden:NO];
    }
    else {
        [_red4 setHidden:YES];
        [_blue4 setHidden:YES];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *resultingString = [textField.text stringByReplacingCharactersInRange: range withString: string];
    
    // This allows backspace
    if ([resultingString length] == 0) {
        return true;
    }
    
    NSInteger holder;
    NSScanner *scan = [NSScanner scannerWithString: resultingString];
    
    BOOL isValid = [scan scanInteger: &holder] && [scan isAtEnd];
    if (isValid) textChanges = TRUE;
    return isValid;
}

#pragma mark -
#pragma mark Text

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    //NSLog(@"team should end editing");
    if (!textChanges) return YES;
    textChanges = FALSE;
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"Row at index %li selected", (long)indexPath.row);
}

- (void)viewWillLayoutSubviews {
    _mainLogo = [MainLogo rotate:self.view forImageView:_mainLogo forOrientation:self.interfaceOrientation];
}

-(void)setBigButtonDefaults:(UIButton *)currentButton {
    currentButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:22.0];
    // Round button corners
    CALayer *btnLayer = [currentButton layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:10.0f];
    // Apply a 1 pixel, black border
    [btnLayer setBorderWidth:1.0f];
    [btnLayer setBorderColor:[[UIColor blackColor] CGColor]];
    // Set the button Background Color
    [currentButton setBackgroundColor:[UIColor whiteColor]];
    // Set the button Text Color
    [currentButton setTitleColor:[UIColor colorWithRed:(0.0/255) green:(0.0/255) blue:(120.0/255) alpha:1.0 ]forState: UIControlStateNormal];
}


@end
