//
//  DownloadPageViewController.m
// Robonauts Scouting
//
//  Created by Kris Pettinger on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DownloadPageViewController.h"
#import "DataManager.h"
#import "FileIOMethods.h"
#import "MainLogo.h"
#import "TournamentData.h"
#import "ExportTeamData.h"
#import "ExportScoreData.h"
#import "ExportMatchData.h"
#import "PhotoUtilities.h"
#import "MatchPhotoUtilities.h"
#import "TabletSyncViewController.h"

@interface DownloadPageViewController ()
@property (nonatomic, weak) IBOutlet UIImageView *mainLogo;
@property (nonatomic, weak) IBOutlet UIImageView *splashPicture;
@property (nonatomic, weak) IBOutlet UILabel *pictureCaption;
@property (nonatomic, weak) IBOutlet UIButton *emailDataButton;
@property (nonatomic, weak) IBOutlet UIButton *transferPhotosButton;
@property (nonatomic, weak) IBOutlet UIButton *syncButton;
@property (nonatomic, weak) IBOutlet UIButton *firstImportButton;
@property (nonatomic, weak) IBOutlet UIButton *scoutingSheetButton;
@end

@implementation DownloadPageViewController {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSString *appName;
    NSString *gameName;
    NSFileManager *fileManager;
    NSString *exportPath;
    NSString *mitchPath;
    id popUp;
    PopUpPickerViewController *optionPicker;
    UIPopoverController *optionPopover;

    NSMutableArray *emailOptionList;
    NSMutableArray *exportOptionList;
    NSMutableArray *photoOptionList;
    NSMutableArray *spreadsheetOptionList;
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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    //NSLog(@"Download Page");
    if (!_dataManager) {
        _dataManager = [DataManager new];
    }

    prefs = [NSUserDefaults standardUserDefaults];
    tournamentName = [prefs objectForKey:@"tournament"];
    appName = [prefs objectForKey:@"appName"];
    gameName = [prefs objectForKey:@"gameName"];
    if (tournamentName) {
        self.title =  [NSString stringWithFormat:@"%@ Data Transfer", tournamentName];
    }
    else {
        self.title = @"Data Transfer";
    }
    
    fileManager = [NSFileManager defaultManager];
    exportPath = [[FileIOMethods applicationDocumentsDirectory] stringByAppendingPathComponent:@"Outbox"];
    NSError *error;
    if (![fileManager createDirectoryAtPath:exportPath withIntermediateDirectories:YES attributes:nil error:&error]) {
        UIAlertView *prompt  = [[UIAlertView alloc] initWithTitle:@"Email Data Alert"
                                                          message:@"Unable to Save Email Data"
                                                         delegate:nil
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
        [prompt setAlertViewStyle:UIAlertViewStyleDefault];
        [prompt show];
    }
   
    emailOptionList = [[NSMutableArray alloc] initWithObjects:@"Team", @"Match List", @"Spreadsheet", @"Mitch Data", nil];
    exportOptionList = [[NSMutableArray alloc] initWithObjects:@"Practice", @"Competition", nil];
    photoOptionList = [[NSMutableArray alloc] initWithObjects:@"Team Photos", @"Match Photos", nil];
    spreadsheetOptionList = [[NSMutableArray alloc] initWithObjects:@"Scouting Spreadsheet", @"Mitch Data", nil];

    // Set Font and Text for Export Buttons
    [_emailDataButton setTitle:@"Email Data" forState:UIControlStateNormal];
    [self setBigButtonDefaults:_emailDataButton];
    _emailDataButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:24.0];
    [_transferPhotosButton setTitle:@"Transfer Photos" forState:UIControlStateNormal];
    [self setBigButtonDefaults:_transferPhotosButton];
    _transferPhotosButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:24.0];
    [_syncButton setTitle:@"Bluetooth Transfer" forState:UIControlStateNormal];
    [self setBigButtonDefaults:_syncButton];
    _syncButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:24.0];
    [_firstImportButton setTitle:@"Import - US FIRST" forState:UIControlStateNormal];
    [self setBigButtonDefaults:_firstImportButton];
    _firstImportButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:24.0];
    [_scoutingSheetButton setTitle:@"Spreadsheet Data" forState:UIControlStateNormal];
    [self setBigButtonDefaults:_scoutingSheetButton];
    _scoutingSheetButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:24.0];
    // Display the Label for the Picture
    _pictureCaption.font = [UIFont fontWithName:@"Nasalization" size:24.0];
    _pictureCaption.text = @"Just Hangin' Out";
    [super viewDidLoad];

}

- (void)viewDidAppear:(BOOL)animated {
    _mainLogo = [MainLogo rotate:self.view forImageView:_mainLogo forOrientation:self.interfaceOrientation];
}

- (IBAction)exportTapped:(id)sender {
    popUp = sender;
    UIButton * pressedButton = (UIButton*)sender;
    optionPicker = [[PopUpPickerViewController alloc]
                          initWithStyle:UITableViewStylePlain];
    optionPicker.delegate = self;
   
    if (sender == _transferPhotosButton) {
        optionPicker.pickerChoices = photoOptionList;
    }
    else if (sender == _scoutingSheetButton) {
        optionPicker.pickerChoices = spreadsheetOptionList;
    }
    else if (sender == _emailDataButton) {
        optionPicker.pickerChoices = emailOptionList;
    }
    else if (sender == _scoutingSheetButton) {
        optionPicker.pickerChoices = spreadsheetOptionList;
    }
    optionPopover = [[UIPopoverController alloc]
                               initWithContentViewController:optionPicker];
    [optionPopover presentPopoverFromRect:pressedButton.bounds inView:pressedButton
                       permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

-(void)createScoutingSpreadsheet {
    NSString *filePath = [exportPath stringByAppendingPathComponent: @"ScoutingSpreadsheet.csv"];
    BOOL success = [[[ExportScoreData alloc] init:_dataManager] spreadsheetCSVExport:tournamentName toFile:filePath];
    if (!success) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Create Scouting Spreadsheet"
                                                        message:@"No matches were found"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

-(void)createMitchData {
    mitchPath = [exportPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Mitch_%0.f", CFAbsoluteTimeGetCurrent()]];
    NSError *error;
    if (![fileManager createDirectoryAtPath:mitchPath withIntermediateDirectories:YES attributes:nil error:&error]) {
        UIAlertView *prompt  = [[UIAlertView alloc] initWithTitle:@"Scouting Bundle Data Alert"
                                                          message:@"Unable to Scouting Bundle Data"
                                                         delegate:nil
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
        [prompt setAlertViewStyle:UIAlertViewStyleDefault];
        [prompt show];
    }
    // Team data
    NSString *csvString;
    // Match Schedule
    csvString = [[[ExportMatchData alloc] init:_dataManager] matchDataCSVExport:tournamentName];
    if (csvString) {
        NSString *filePath = [mitchPath stringByAppendingPathComponent: @"MatchScheduleBundle.csv"];
        [csvString writeToFile:filePath
                    atomically:YES
                      encoding:NSUTF8StringEncoding
                         error:nil];
    }
    // Score data
    NSString *filePath = [mitchPath stringByAppendingPathComponent: @"MatchResultsBundle.csv"];
    BOOL success = [[[ExportScoreData alloc] init:_dataManager] scoreBundleCSVExport:tournamentName toFile:filePath];
    if (!success) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Create Mitch Data"
                                                        message:@"No matches were found"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    csvString = [[[ExportTeamData alloc] init:_dataManager] teamBundleCSVExport:tournamentName];
    if (csvString) {
        NSString *filePath = [mitchPath stringByAppendingPathComponent: @"TeamBundle.csv"];
        [csvString writeToFile:filePath
                    atomically:YES
                      encoding:NSUTF8StringEncoding
                         error:nil];
    }
}

-(void)emailTeamData {
    NSString *csvString;
    csvString = [[[ExportTeamData alloc] init:_dataManager] teamDataCSVExport:tournamentName];
    if (csvString) {
        NSString *filePath = [exportPath stringByAppendingPathComponent: @"TeamData.csv"];
        [csvString writeToFile:filePath
                    atomically:YES
                      encoding:NSUTF8StringEncoding
                         error:nil];
        NSString *emailSubject = @"Team Data CSV File";
        NSArray *fileList = [[NSArray alloc] initWithObjects:filePath, nil];
        NSArray *attachList = [[NSArray alloc] initWithObjects:@"TeamData.csv", nil];
        NSArray *array = [[NSArray alloc] initWithObjects:@"kpettinger@comcast.net", @"BESTRobonauts@gmail.com",nil];
        [self buildEmail:fileList attach:attachList subject:emailSubject toRecipients:array];
    }
}

-(void)emailMatchData {
    NSString *csvString;
    csvString = [[[ExportMatchData alloc] init:_dataManager] matchDataCSVExport:tournamentName];
    if (csvString) {
        NSString *filePath = [exportPath stringByAppendingPathComponent: @"MatchData.csv"];
        [csvString writeToFile:filePath
                    atomically:YES
                      encoding:NSUTF8StringEncoding
                         error:nil];
        NSString *emailSubject = @"Match Schedule CSV File";
        NSArray *fileList = [[NSArray alloc] initWithObjects:filePath, nil];
        NSArray *attachList = [[NSArray alloc] initWithObjects:@"MatchData.csv", nil];
        NSArray *array = [[NSArray alloc] initWithObjects:@"kpettinger@comcast.net", @"BESTRobonauts@gmail.com",nil];
        [self buildEmail:fileList attach:attachList subject:emailSubject toRecipients:array];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email Match Data"
                                                        message:@"No matches were found"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

-(void)emailScoutingSpreadsheet:(NSString *)choice {
    NSString *filePath = [exportPath stringByAppendingPathComponent: @"ScoutingSpreadsheet.csv"];
    BOOL success = [[[ExportScoreData alloc] init:_dataManager] spreadsheetCSVExport:tournamentName toFile:filePath];
    if (!success) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email Scouting Spreadsheet"
                                                        message:@"No matches were found"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)pickerSelected:(NSString *)newPick {
    [optionPopover dismissPopoverAnimated:YES];
    optionPicker = nil;
    optionPopover = nil;
    if (popUp == _emailDataButton) {
        if ([newPick isEqualToString:@"Team"]) {
            [self emailTeamData];
        }
        else if ([newPick isEqualToString:@"Match List"]) {
            [self emailMatchData];
        }
        else if ([newPick isEqualToString:@"Spreadsheet"]) {
            [self emailScoutingSpreadsheet:@"Competition"];
        }
    }
    else if (popUp == _scoutingSheetButton) {
        if ([newPick isEqualToString:@"Scouting Spreadsheet"]) {
            [self createScoutingSpreadsheet];
        }
        else {
            [self createMitchData];
        }
    }
    else if (popUp == _transferPhotosButton) {
        if ([newPick isEqualToString:@"Team Photos"]) {
            [[[PhotoUtilities alloc] init:_dataManager] exportTournamentPhotos:tournamentName];
        }
        else {
            [[[MatchPhotoUtilities alloc] init:_dataManager] exportMatchPhotos];
        }

    }
}

-(void)buildEmail:(NSArray *)filePaths attach:(NSArray *)emailFiles subject:(NSString *)emailSubject toRecipients:array {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        [mailViewController setSubject:emailSubject];
        [mailViewController setToRecipients:array];
        [mailViewController setMessageBody:[NSString stringWithFormat:@"Downloaded Data from %@", gameName] isHTML:NO];
        [mailViewController setMailComposeDelegate:self];
        
        for (int i=0; i<[filePaths count]; i++) {
            NSData *exportData = [[NSData alloc] initWithContentsOfFile:[filePaths objectAtIndex:i]];
            if (exportData) {
                [mailViewController addAttachmentData:exportData mimeType:[NSString stringWithFormat:@"application/%@", appName] fileName:[emailFiles objectAtIndex:i]];
            }
            else {
                NSLog(@"Error encoding data for email");
            }
        }
        [self presentViewController:mailViewController animated:YES completion:nil];
    }
    else {
        NSLog(@"Device is unable to send email in its current state.");
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller
         didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:Nil];
}

- (IBAction)exportFullMatchData:(id)sender {
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setDataManager:_dataManager];
    if ([segue.identifier isEqualToString:@"DataTransfer"]) {
        [segue.destinationViewController setConnectionUtility:_connectionUtility];
    }
}

-(void)setBigButtonDefaults:(UIButton *)currentButton {
    [currentButton setTitleColor:[UIColor colorWithRed:(0.0/255) green:(0.0/255) blue:(120.0/255) alpha:1.0 ]forState: UIControlStateNormal];
    currentButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:18.0];
}

-(void)viewWillLayoutSubviews {
    _mainLogo = [MainLogo rotate:self.view forImageView:_mainLogo forOrientation:self.interfaceOrientation];
}

@end
