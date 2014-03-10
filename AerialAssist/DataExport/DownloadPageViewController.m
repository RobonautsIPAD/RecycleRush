//
//  DownloadPageViewController.m
// Robonauts Scouting
//
//  Created by Kris Pettinger on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DownloadPageViewController.h"
#import "TabletSyncViewController.h"
#import "TeamData.h"
#import "TeamDataInterfaces.h"
#import "MatchData.h"
#import "TeamScore.h"
#import "DataManager.h"
#import "TournamentData.h"
#import "ExportTeamData.h"
#import "ExportScoreData.h"
#import "ExportMatchData.h"

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
    NSString *exportPath;
    NSMutableArray *syncList;
    id popUp;
    PopUpPickerViewController *optionPicker;
    UIPopoverController *optionPopover;
    NSMutableArray *emailOptionList;
    NSMutableArray *exportOptionList;
    NSMutableArray *photoOptionList;
}
@synthesize dataManager = _dataManager;

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

- (void)viewDidUnload
{
    [super viewDidUnload];
    _dataManager = nil;
    prefs = nil;
    tournamentName = nil;
    exportPath = nil;
    syncList = nil;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    NSLog(@"Download Page");
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
    
    exportPath = [self applicationDocumentsDirectory];
    emailOptionList = [[NSMutableArray alloc] initWithObjects:@"Team", @"Match", nil];
    exportOptionList = [[NSMutableArray alloc] initWithObjects:@"Practice", @"Competition", nil];
    photoOptionList = [[NSMutableArray alloc] initWithObjects:@"iTunes", @"Computer", nil];

    // Display the Robotnauts Banner
    [_mainLogo setImage:[UIImage imageNamed:@"robonauts app banner.jpg"]];
    // Set Font and Text for Export Buttons
    [_emailDataButton setTitle:@"Email Data" forState:UIControlStateNormal];
    _emailDataButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:24.0];
    [_transferPhotosButton setTitle:@"Transfer Photos" forState:UIControlStateNormal];
    _transferPhotosButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:24.0];
    [_syncButton setTitle:@"Sync Data" forState:UIControlStateNormal];
    _syncButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:24.0];
    [_firstImportButton setTitle:@"Import - US FIRST" forState:UIControlStateNormal];
    _firstImportButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:24.0];
    [_scoutingSheetButton setTitle:@"Spreadsheet Data" forState:UIControlStateNormal];
    _scoutingSheetButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:24.0];
    // Display the Label for the Picture
    _pictureCaption.font = [UIFont fontWithName:@"Nasalization" size:24.0];
    _pictureCaption.text = @"Just Hangin' Out";
    [super viewDidLoad];
}

- (IBAction)exportTapped:(id)sender {
    popUp = sender;
    UIButton * pressedButton = (UIButton*)sender;
    optionPicker = [[PopUpPickerViewController alloc]
                          initWithStyle:UITableViewStylePlain];
    optionPicker.delegate = self;
   
    if (sender == _transferPhotosButton) {
        [[[TeamDataInterfaces alloc] initWithDataManager:_dataManager] exportPhotosiTunes:tournamentName];
        return;
    }

    if (sender == _emailDataButton) {
        optionPicker.pickerChoices = emailOptionList;
    }
     else if (sender == _scoutingSheetButton) {
        optionPicker.pickerChoices = exportOptionList;
    }
    optionPopover = [[UIPopoverController alloc]
                               initWithContentViewController:optionPicker];
    [optionPopover presentPopoverFromRect:pressedButton.bounds inView:pressedButton
                       permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

-(void)emailTeamData {
    NSString *csvString;
    ExportTeamData *teamCSVExport = [[ExportTeamData alloc] initWithDataManager:_dataManager];
    csvString = [teamCSVExport teamDataCSVExport];
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
    NSString *fileListPath = [exportPath stringByAppendingPathComponent: @"MatchData.csv"];
    NSString *fileDataPath = [exportPath stringByAppendingPathComponent: @"ScoreData.csv"];
    // Export Match List
    ExportMatchData *matchCSVExport = [[ExportMatchData alloc] initWithDataManager:_dataManager];
    csvString = [matchCSVExport matchDataCSVExport];
    if (csvString) {
        [csvString writeToFile:fileListPath
                    atomically:YES
                      encoding:NSUTF8StringEncoding
                         error:nil];
    }
    // Export Scores
    ExportScoreData *scoreCSVExport = [[ExportScoreData alloc] initWithDataManager:_dataManager];
    csvString = [scoreCSVExport teamScoreCSVExport];
    if (csvString) {
        [csvString writeToFile:fileDataPath
                    atomically:YES
                      encoding:NSUTF8StringEncoding
                         error:nil];
    }
    NSString *emailSubject = @"Match Data CSV Files";
    NSArray *fileList = [[NSArray alloc] initWithObjects:fileListPath, fileDataPath, nil];
    NSArray *attachList = [[NSArray alloc] initWithObjects:@"MatchList.csv", @"ScoreData.csv", nil];
    
    NSArray *array = [[NSArray alloc] initWithObjects:@"kpettinger@comcast.net", @"BESTRobonauts@gmail.com", @"misnard30@gmail.com", nil];
    [self buildEmail:fileList attach:attachList subject:emailSubject toRecipients:array];
}

- (void)pickerSelected:(NSString *)newPick {
    [optionPopover dismissPopoverAnimated:YES];
    optionPicker = nil;
    optionPopover = nil;
    if (popUp == _emailDataButton) {
        if ([newPick isEqualToString:@"Team"]) {
            [self emailTeamData];
        }
        else {
            [self emailMatchData];
        }
    }
    else if (popUp == _scoutingSheetButton) {
        [self createScoutingSpreadsheet:newPick];
    }
}

-(void)createScoutingSpreadsheet:(NSString *)choice {
    NSString *csvString = [[NSString alloc] init];
    NSString *filePath = [exportPath stringByAppendingPathComponent: @"ScoutingSpreadsheet.csv"];
    
    // Export Scores
    NSArray *teamData = [[[[TeamDataInterfaces alloc] initWithDataManager:_dataManager] getTeamListTournament:tournamentName] mutableCopy];
    ExportScoreData *scoutingSpreadsheet = [[ExportScoreData alloc] initWithDataManager:_dataManager];
    for (int i=0; i<[teamData count]; i++) {
        csvString = [csvString stringByAppendingString:[scoutingSpreadsheet spreadsheetCSVExport:[teamData objectAtIndex:i] forMatches:choice]];
    }
    NSLog(@"%@", csvString);
    if (csvString) {
        [csvString writeToFile:filePath
                    atomically:YES
                      encoding:NSUTF8StringEncoding
                         error:nil];
    }
    NSString *emailSubject = @"Match Data CSV Files";
    NSArray *fileList = [[NSArray alloc] initWithObjects:filePath, nil];
    NSArray *attachList = [[NSArray alloc] initWithObjects:@"ScoutingData.csv", nil];
    NSArray *array = [[NSArray alloc] initWithObjects:@"kpettinger@comcast.net", @"BESTRobonauts@gmail.com",nil];
    [self buildEmail:fileList attach:attachList subject:emailSubject toRecipients:array];
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

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setDataManager:_dataManager];
    if ([segue.identifier isEqualToString:@"Sync"]) {
        [segue.destinationViewController setSyncOption:SyncAllSavedSince];
        [segue.destinationViewController setSyncType:SyncTeams];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            _mainLogo.frame = CGRectMake(-20, 0, 285, 960);
            [_mainLogo setImage:[UIImage imageNamed:@"robonauts app banner.jpg"]];
            _emailDataButton.frame = CGRectMake(325, 125, 400, 68);
            _transferPhotosButton.frame = CGRectMake(325, 225, 400, 68);
            _syncButton.frame = CGRectMake(325, 325, 400, 68);
            _firstImportButton.frame = CGRectMake(325, 425, 400, 68);
            _scoutingSheetButton.frame = CGRectMake(325, 525, 400, 68);
            _splashPicture.frame = CGRectMake(293, 563, 468, 330);
            _pictureCaption.frame = CGRectMake(293, 901, 468, 39);
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            _mainLogo.frame = CGRectMake(0, -60, 1024, 255);
            [_mainLogo setImage:[UIImage imageNamed:@"robonauts app banner original.jpg"]];
            _emailDataButton.frame = CGRectMake(550, 225, 400, 68);
            _transferPhotosButton.frame = CGRectMake(550, 325, 400, 68);
            _syncButton.frame = CGRectMake(550, 425, 400, 68);
            _firstImportButton.frame = CGRectMake(550, 525, 400, 68);
            _scoutingSheetButton.frame = CGRectMake(550, 625, 400, 68);
            _splashPicture.frame = CGRectMake(50, 243, 468, 330);
            _pictureCaption.frame = CGRectMake(50, 581, 468, 39);
            break;
        default:
            break;
    }
    // Return YES for supported orientations
	return YES;
}

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

@end
