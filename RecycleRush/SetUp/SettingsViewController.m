//
//  TournamentViewController.m
// Robonauts Scouting
//
//  Created by FRC on 2/15/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "SettingsViewController.h"
#import "DataManager.h"
#import "FileIOMethods.h"
#import "TournamentUtilities.h"
#import "PopUpPickerViewController.h"
#import "AlertPromptViewController.h"
#import "MainLogo.h"

@interface SettingsViewController ()
@property (nonatomic, weak) IBOutlet UIImageView *mainLogo;
@property (nonatomic, weak) IBOutlet UIImageView *splashPicture;
@property (nonatomic, weak) IBOutlet UILabel *pictureCaption;
@property (nonatomic, weak) IBOutlet UITextField *adminText;
@property (nonatomic, weak) IBOutlet UITextField *overrideText;
@property (nonatomic, weak) IBOutlet UILabel *tournamentLabel;
@property (nonatomic, weak) IBOutlet UILabel *allianceLabel;
@property (nonatomic, weak) IBOutlet UILabel *adminLabel;
@property (nonatomic, weak) IBOutlet UILabel *overideLabel;
@property (nonatomic, weak) IBOutlet UILabel *modeLabel;
@property (nonatomic, weak) IBOutlet UILabel *bluetoothLabel;
// Tournament Picker
@property (nonatomic, weak) IBOutlet UIButton *tournamentButton;
// Alliance Picker
@property (nonatomic, weak) IBOutlet UIButton *allianceButton;
@property (nonatomic, strong) NSMutableArray *allianceList;
@property (nonatomic, strong) PopUpPickerViewController *alliancePicker;
@property (nonatomic, strong) UIPopoverController *alliancePickerPopover;
@property (nonatomic, weak) IBOutlet UISegmentedControl *modeSegment;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *homeButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *bluetoothMode;
@end

@implementation SettingsViewController {
    id popUp;
    OverrideMode overrideMode;
    NSUserDefaults *prefs;
    NSArray *tournamentList;
    PopUpPickerViewController *tournamentPicker;
    UIPopoverController *tournamentPickerPopover;
}
@synthesize splashPicture = _splashPicture;
@synthesize pictureCaption = _pictureCaption;

// Alliance Picker
@synthesize allianceButton = _allianceButton;
@synthesize alliancePicker = _alliancePicker;
@synthesize allianceList = _allianceList;
@synthesize alliancePickerPopover = _alliancePickerPopover;

// Mode Selection
@synthesize modeSegment = _modeSegment;

// User access control
@synthesize adminText = _adminText;
@synthesize overrideText = _overrideText;
@synthesize alertPrompt = _alertPrompt;
@synthesize alertPromptPopover = _alertPromptPopover;

//labels
@synthesize allianceLabel = _allianceLabel;
@synthesize adminLabel = _adminLabel;
@synthesize overideLabel = _overideLabel;
@synthesize modeLabel = _modeLabel;

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
    if (!_dataManager) {
        _dataManager = [DataManager new];
    }
    
    //    NSLog(@"Set-Up Page");
    // Display the Label for the Picture
    _pictureCaption.font = [UIFont fontWithName:@"Nasalization" size:24.0];
    _pictureCaption.text = @"Just Hangin' Out";
    self.title = @"iPad Set-Up Page";

    prefs = [NSUserDefaults standardUserDefaults];

   // Set Font and Text for Tournament Set-Up Button
    [_tournamentButton setTitle:[prefs objectForKey:@"tournament"] forState:UIControlStateNormal];
    _tournamentButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:18.0];

    TournamentUtilities *tournamentUtilities = [[TournamentUtilities alloc] init:_dataManager];
    tournamentList = [tournamentUtilities getTournamentList];
    
    //NSLog(@"Tournament List = %@", tournamentList);
    
    // Alliance Selection
    [_allianceButton setTitle:[prefs objectForKey:@"alliance"] forState:UIControlStateNormal];
    _allianceButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:18.0];
    _allianceList = [[NSMutableArray alloc] initWithObjects:@"Red 1", @"Red 2", @"Red 3", @"Blue 1", @"Blue 2", @"Blue 3", nil];

    // Set Mode segment
    if ([[prefs objectForKey:@"mode"] isEqualToString:@"Meeting"]) {
        _modeSegment.selectedSegmentIndex = 0;
    }
    else if ([[prefs objectForKey:@"mode"] isEqualToString:@"Tournament"]) {
        _modeSegment.selectedSegmentIndex = 1;
    }
    else if ([[prefs objectForKey:@"mode"] isEqualToString:@"Analysis"]) {
        _modeSegment.selectedSegmentIndex = 2;
    }
    // Set Bluetooth segment
    NSNumber *bluetoothMode = [prefs objectForKey:@"bluetooth"];
    if ([bluetoothMode intValue] == Scouter) {
        _bluetoothMode.selectedSegmentIndex = 0;
    }
    else {
        _bluetoothMode.selectedSegmentIndex = 1;
    }
}

-(IBAction)tournamentSelectionChanged:(id)sender {
    //    NSLog(@"TournamentSelectionChanged");
    if (tournamentPicker == nil) {
        tournamentPicker = [[PopUpPickerViewController alloc]
                            initWithStyle:UITableViewStylePlain];
        tournamentPicker.delegate = self;
        tournamentPicker.pickerChoices = tournamentList;
        tournamentPickerPopover = [[UIPopoverController alloc]
                                   initWithContentViewController:tournamentPicker];
    }
    popUp = sender;
    [tournamentPickerPopover presentPopoverFromRect:_tournamentButton.bounds inView:_tournamentButton
                           permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

-(void)pickerSelected:(NSString *)newPick {
    if (popUp == _tournamentButton) {
        [self tournamentSelected:newPick];
    }
    else if (popUp == _allianceButton) {
        [self allianceSelected:newPick];
    }
}

-(void)tournamentSelected:(NSString *)newTournament {
    [tournamentPickerPopover dismissPopoverAnimated:YES];
    NSUInteger index = [tournamentList indexOfObject:newTournament];
    if (index == NSNotFound) return;
    [prefs setObject:newTournament forKey:@"tournament"];
    [_tournamentButton setTitle:newTournament forState:UIControlStateNormal];
    // Reset all sync timers
    [prefs setObject:[NSNumber numberWithFloat:0] forKey:@"teamDataSync"];
    [prefs setObject:[NSNumber numberWithFloat:0] forKey:@"matchScheduleSync"];
    [prefs setObject:[NSNumber numberWithFloat:0] forKey:@"matchResultsSync"];
    [prefs setObject:[NSNumber numberWithFloat:0] forKey:@"scoutingBundleSync"];
    [prefs setObject:[NSNumber numberWithFloat:0] forKey:@"spreadsheetSync"];
}


-(IBAction)allianceSelectionChanged:(id)sender {
    //    NSLog(@"AllianceSelectionChanged");
    popUp = sender;
    if ([[prefs objectForKey:@"mode"] isEqualToString:@"Meeting"]) {
        [self allianceSelectionPopUp];
    }
    else {
        overrideMode = OverrideAllianceSelection;
        [self checkAdminCode:_allianceButton];
    }
}

-(void)allianceSelectionPopUp {
    if (_alliancePicker == nil) {
        self.alliancePicker = [[PopUpPickerViewController alloc]
                               initWithStyle:UITableViewStylePlain];
        _alliancePicker.delegate = self;
        _alliancePicker.pickerChoices = _allianceList;
        self.alliancePickerPopover = [[UIPopoverController alloc]
                                      initWithContentViewController:_alliancePicker];
    }
    _alliancePicker.pickerChoices = _allianceList;
    [self.alliancePickerPopover presentPopoverFromRect:_allianceButton.bounds inView:_allianceButton
                              permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

-(void)allianceSelected:(NSString *)newAlliance {
    [self.alliancePickerPopover dismissPopoverAnimated:YES];
    NSString *currentAlliance = _allianceButton.titleLabel.text;
    NSUInteger allianceIndex = [_allianceList indexOfObject:newAlliance];
    if (allianceIndex == NSNotFound) newAlliance = currentAlliance;
    [prefs setObject:newAlliance forKey:@"alliance"];
    [_allianceButton setTitle:newAlliance forState:UIControlStateNormal];
}

-(void)checkAdminCode:(UIButton *)button {
   // NSLog(@"Check override");
    if (_alertPrompt == nil) {
        self.alertPrompt = [[AlertPromptViewController alloc] initWithNibName:nil bundle:nil];
        _alertPrompt.delegate = self;
        _alertPrompt.titleText = @"Enter Admin Code";
        _alertPrompt.msgText = @"Do NOT change unless you are sure";
        self.alertPromptPopover = [[UIPopoverController alloc]
                                   initWithContentViewController:_alertPrompt];
    }
    [self.alertPromptPopover presentPopoverFromRect:button.bounds inView:button permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    
    return;
}

-(void)passCodeResult:(NSString *)passCodeAttempt {
    [self.alertPromptPopover dismissPopoverAnimated:YES];
    switch (overrideMode) {
        case OverrideAllianceSelection:
            if ([passCodeAttempt isEqualToString:[prefs objectForKey:@"adminCode"]]) {
                [self allianceSelectionPopUp];
            }
            break;
                        
        default:
            break;
    } 
    overrideMode = NoOverride;
}

-(IBAction)modeSelectionChanged:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSInteger current = segmentedControl.selectedSegmentIndex;
    
    if (current == 0) {
        [prefs setObject:@"Meeting" forKey:@"mode"];
    }
    else if (current == 1) {
        NSString *currentAlliance = _allianceButton.titleLabel.text;
        NSUInteger allianceIndex = [_allianceList indexOfObject:currentAlliance];
        if (allianceIndex == NSNotFound) {
            UIAlertView *prompt  = [[UIAlertView alloc] initWithTitle:@"Alliance Required"
                                                              message:@"A valid default alliance must be set"
                                                             delegate:nil
                                                    cancelButtonTitle:@"Ok"
                                                    otherButtonTitles:nil];
            [prompt show];
        }
        else {
            [prefs setObject:@"Tournament" forKey:@"mode"];
        }
    }
    else {
        [prefs setObject:@"Analysis" forKey:@"mode"];
    }
}

- (IBAction)bluetoothRoleChanged:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSInteger current = segmentedControl.selectedSegmentIndex;

    if (current == 0) {
        [prefs setObject:[NSNumber numberWithInt:Scouter] forKey:@"bluetooth"];
    }
    else {
        [prefs setObject:[NSNumber numberWithInt:Master] forKey:@"bluetooth"];
    }
}

- (IBAction)cleanPrefsAction:(id)sender {
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *prefsPath = [[FileIOMethods applicationLibraryDirectory] stringByAppendingPathComponent: @"Preferences"];
    NSString *prefsFile = [prefsPath stringByAppendingPathComponent: @"dataMarker.csv"];
   [fileManager removeItemAtPath: prefsFile error: &error];
    prefsFile = [prefsPath stringByAppendingPathComponent: @"lucienPagePreferences.plist"];
    [fileManager removeItemAtPath: prefsFile error: &error];
    prefsPath = [[FileIOMethods applicationDocumentsDirectory] stringByAppendingPathComponent: @"dataMarkerMason.csv"];
    [fileManager removeItemAtPath: prefsPath error: &error];

}

-(void) viewWillDisappear:(BOOL)animated {
    [prefs synchronize];
}

-(void)viewWillLayoutSubviews {
    _mainLogo = [MainLogo rotate:self.view forImageView:_mainLogo forOrientation:self.interfaceOrientation];
}
- (IBAction)goHome:(id)sender {
    UINavigationController * navigationController = self.navigationController;
    [navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
