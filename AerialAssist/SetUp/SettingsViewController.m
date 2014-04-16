//
//  TournamentViewController.m
// Robonauts Scouting
//
//  Created by FRC on 2/15/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "SettingsViewController.h"
#import "DataManager.h"
#import "TournamentData.h"
#import "PopUpPickerViewController.h"
#import "AlertPromptViewController.h"

@interface SettingsViewController ()
@end

@implementation SettingsViewController {
    id popUp;
    OverrideMode overrideMode;
    NSUserDefaults *prefs;
}
@synthesize dataManager = _dataManager;
@synthesize mainLogo = _mainLogo;
@synthesize splashPicture = _splashPicture;
@synthesize pictureCaption = _pictureCaption;

// Tournament Picking
@synthesize tournamentData = _tournamentData;
@synthesize tournamentLabel = _tournamentLabel;
@synthesize tournamentButton = _tournamentButton;
@synthesize tournamentPicker = _tournamentPicker;
@synthesize tournamentList = _tournamentList;
@synthesize tournamentPickerPopover = _tournamentPickerPopover;

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

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    _dataManager = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!_dataManager) {
        _dataManager = [DataManager new];
    }
    
    //    NSLog(@"Set-Up Page");
    // Display the Robotnauts Banner
    [_mainLogo setImage:[UIImage imageNamed:@"robonauts app banner.jpg"]];
    // Display the Label for the Picture
    _pictureCaption.font = [UIFont fontWithName:@"Nasalization" size:24.0];
    _pictureCaption.text = @"Just Hangin' Out";
    self.title = @"iPad Set-Up Page";

    prefs = [NSUserDefaults standardUserDefaults];

   // Set Font and Text for Tournament Set-Up Button
    [_tournamentButton setTitle:[prefs objectForKey:@"tournament"] forState:UIControlStateNormal];
    _tournamentButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:18.0];

    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TournamentData" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *tournamentSort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:tournamentSort]];
    _tournamentData = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!_tournamentData) {
        NSLog(@"Karma disruption error");
        _tournamentList = nil;
    }
    else {
        TournamentData *t;
        self.tournamentList = [NSMutableArray array];
        for (int i=0; i < [_tournamentData count]; i++) {
            t = [_tournamentData objectAtIndex:i];
            NSLog(@"Tournament %@ exists", t.name);
            [_tournamentList addObject:t.name];
        }
    }
    NSLog(@"Tournament List = %@", _tournamentList);
    
    // Alliance Selection
    [_allianceButton setTitle:[prefs objectForKey:@"alliance"] forState:UIControlStateNormal];
    _allianceButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:18.0];
    _allianceList = [[NSMutableArray alloc] initWithObjects:@"Red 1", @"Red 2", @"Red 3", @"Blue 1", @"Blue 2", @"Blue 3", nil];

    // Set Mode segment
    if ([[prefs objectForKey:@"mode"] isEqualToString:@"Test"]) {
        _modeSegment.selectedSegmentIndex = 0;
    }
    else {
        _modeSegment.selectedSegmentIndex = 1;
    }
}

-(IBAction)TournamentSelectionChanged:(id)sender {
    //    NSLog(@"TournamentSelectionChanged");
    if (_tournamentPicker == nil) {
        self.tournamentPicker = [[PopUpPickerViewController alloc]
                               initWithStyle:UITableViewStylePlain];
        _tournamentPicker.delegate = self;
        _tournamentPicker.pickerChoices = _tournamentList;
        self.tournamentPickerPopover = [[UIPopoverController alloc]
                                      initWithContentViewController:_tournamentPicker];
    }
    _tournamentPicker.pickerChoices = _tournamentList;
    popUp = sender;
    [self.tournamentPickerPopover presentPopoverFromRect:_tournamentButton.bounds inView:_tournamentButton
                              permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

-(void)pickerSelected:(NSString *)newPick {
    NSLog(@"Picker = %@", newPick);
    if (popUp == _tournamentButton) {
        [self tournamentSelected:newPick];
    }
    else if (popUp == _allianceButton) {
        [self allianceSelected:newPick];
    }
}

-(void)tournamentSelected:(NSString *)newTournament {
    [self.tournamentPickerPopover dismissPopoverAnimated:YES];
    for (int i = 0 ; i < [_tournamentList count] ; i++) {
        if ([newTournament isEqualToString:[_tournamentList objectAtIndex:i]]) {
            [prefs setObject:newTournament forKey:@"tournament"];
            [_tournamentButton setTitle:newTournament forState:UIControlStateNormal];
            break;
        }
    }
    NSError *error;
    NSString *storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"dataMarker.csv"];
    [[NSFileManager defaultManager] removeItemAtPath: storePath error: &error];
    storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"dataMarkerMason.csv"];
    [[NSFileManager defaultManager] removeItemAtPath: storePath error: &error];

}


-(IBAction)allianceSelectionChanged:(id)sender {
    //    NSLog(@"AllianceSelectionChanged");
    popUp = sender;
    if ([[prefs objectForKey:@"mode"] isEqualToString:@"Test"]) {
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
    for (int i = 0 ; i < [_allianceList count] ; i++) {
        if ([newAlliance isEqualToString:[_allianceList objectAtIndex:i]]) {
            [prefs setObject:newAlliance forKey:@"alliance"];
            [_allianceButton setTitle:newAlliance forState:UIControlStateNormal];
            break;
        }
    }
}

-(void)checkAdminCode:(UIButton *)button {
   // NSLog(@"Check override");
    if (_alertPrompt == nil) {
        self.alertPrompt = [[AlertPromptViewController alloc] initWithNibName:nil bundle:nil];
        _alertPrompt.delegate = self;
        _alertPrompt.titleText = @"Enter Admin Code";
        _alertPrompt.msgText = @"Danielle will kill you.";
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
    int current;
    current = segmentedControl.selectedSegmentIndex;
    
    if (current == 0) {
        [prefs setObject:@"Test" forKey:@"mode"];
    }
    else {
        [prefs setObject:@"Tournament" forKey:@"mode"];
    }
}

-(void) viewWillDisappear:(BOOL)animated
{
    //    NSLog(@"viewWillDisappear");
    NSError *error;
    if (![_dataManager.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

/*

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            _mainLogo.frame = CGRectMake(-20, 0, 285, 960);
            [_mainLogo setImage:[UIImage imageNamed:@"robonauts app banner.jpg"]];
            _tournamentLabel.frame = CGRectMake(340, 85, 144, 21);
            _tournamentButton.frame = CGRectMake(530, 73, 208, 44);
//            matchSetUpButton.frame = CGRectMake(325, 225, 400, 68);
//            importDataButton.frame = CGRectMake(325, 325, 400, 68);
//            exportDataButton.frame = CGRectMake(325, 425, 400, 68);
            _splashPicture.frame = CGRectMake(293, 563, 468, 330);
            _pictureCaption.frame = CGRectMake(293, 901, 468, 39);
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            _mainLogo.frame = CGRectMake(0, -60, 1024, 255);
            [_mainLogo setImage:[UIImage imageNamed:@"robonauts app banner original.jpg"]];
            _tournamentLabel.frame = CGRectMake(540, 255, 144, 21);
            _tournamentButton.frame = CGRectMake(730, 243, 208, 44);
//            matchSetUpButton.frame = CGRectMake(550, 325, 400, 68);
//            importDataButton.frame = CGRectMake(550, 425, 400, 68);
//            exportDataButton.frame = CGRectMake(550, 525, 400, 68);
            _splashPicture.frame = CGRectMake(50, 243, 468, 330);
            _pictureCaption.frame = CGRectMake(50, 581, 468, 39);
            break;
        default:
            break;
    }
    // Return YES for supported orientations 
	return YES;
}

*/
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    switch(toInterfaceOrientation){
        case UIInterfaceOrientationLandscapeRight:
        case UIInterfaceOrientationLandscapeLeft:
            _mainLogo.frame = CGRectMake(0, -50, 1024, 255);
            [_mainLogo setImage:[UIImage imageNamed:@"robonauts app banner original.jpg"]];
             _splashPicture.frame = CGRectMake(50, 233, 468, 330);
            _pictureCaption.frame = CGRectMake(50, 571, 468, 39);
            _tournamentButton.frame = CGRectMake(770, 230, 208, 44);
            _allianceButton.frame = CGRectMake(770, 305, 208, 44);
            _adminText.frame = CGRectMake(770, 380, 208, 30);
            _overrideText.frame = CGRectMake(770, 440, 208, 30);
            _modeSegment.frame = CGRectMake(770, 500, 208, 30);
            _tournamentLabel.frame = CGRectMake(580, 240, 144, 21);
            _allianceLabel.frame = CGRectMake(580, 315, 144, 21);
            _adminLabel.frame = CGRectMake(580, 385, 144, 21);
            _overideLabel.frame = CGRectMake(580, 440, 173, 29);
            _modeLabel.frame = CGRectMake(580, 500, 173, 29);
            _bluetoothLabel.frame = CGRectMake(580, 560, 173, 29);
            break;
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            _mainLogo.frame = CGRectMake(0, 0, 285, 960);
            [_mainLogo setImage:[UIImage imageNamed:@"robonauts app banner.jpg"]];
            _splashPicture.frame = CGRectMake(293, 563, 468, 330);
            _pictureCaption.frame = CGRectMake(293, 901, 468, 39);
            _tournamentButton.frame = CGRectMake(530, 73, 208, 44);
            _allianceButton.frame = CGRectMake(530, 151, 208, 44);
            _adminText.frame = CGRectMake(530, 235, 208, 30);
            _overrideText.frame = CGRectMake(530, 305, 208, 30);
            _modeSegment.frame = CGRectMake(530, 376, 208, 30);
            _tournamentLabel.frame = CGRectMake(340, 85, 144, 21);
            _allianceLabel.frame = CGRectMake(340, 158, 144, 21);
            _adminLabel.frame = CGRectMake(340, 235, 144, 21);
            _overideLabel.frame = CGRectMake(340, 305, 173, 29);
            _modeLabel.frame = CGRectMake(340, 379, 173, 29);
            _bluetoothLabel.frame = CGRectMake(340, 435, 173, 29);
            break;
        default:
            break;
    }
    
}

/**
 Returns the path to the application's Documents directory.
 */
-(NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
