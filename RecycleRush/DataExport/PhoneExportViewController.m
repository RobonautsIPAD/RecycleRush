//
//  PhoneExportViewController.m
//  RecycleRush
//
//  Created by FRC on 2/14/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "PhoneExportViewController.h"
#import "DataManager.h"
#import "ExportTeamData.h"
#import "ExportScoreData.h"
#import "ExportMatchData.h"
#import "FileIOMethods.h"

@interface PhoneExportViewController ()
@property (weak, nonatomic) IBOutlet UIButton *emailMatchButton;
@property (weak, nonatomic) IBOutlet UIButton *emailTeamButton;
@property (weak, nonatomic) IBOutlet UIButton *emailSpreadsheetButton;
@property (weak, nonatomic) IBOutlet UIButton *createSpreadsheetButton;
@property (weak, nonatomic) IBOutlet UIButton *createMitchButton;
@end

@implementation PhoneExportViewController {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSString *gameName;
    NSString *appName;
    NSFileManager *fileManager;
    NSString *exportPath;
    NSString *mitchPath;
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
    if (!_dataManager) {
        _dataManager = [[DataManager alloc] init];
    }
    prefs = [NSUserDefaults standardUserDefaults];
    appName = [prefs objectForKey:@"appName"];
    gameName = [prefs objectForKey:@"gameName"];
    tournamentName = [prefs objectForKey:@"tournament"];
    
    if (tournamentName) {
        self.title =  [NSString stringWithFormat:@"%@ Export", tournamentName];
    }
    else {
        self.title = @"Export";
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
}

-(IBAction)buttonPress:(id)sender {
    if (sender == _emailTeamButton) {
        [self emailTeamData];
    } else if (sender == _emailMatchButton) {
        [self emailMatchData];
    } else if (sender == _emailSpreadsheetButton) {
        [self emailScoutingSpreadsheet:@"Competition"];
    } else if (sender == _createSpreadsheetButton) {
        [self createScoutingSpreadsheet];
    } else if (sender == _createMitchButton) {
        [self createMitchData];
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
    csvString = [[[ExportTeamData alloc] init:_dataManager] teamBundleCSVExport:tournamentName];
    if (csvString) {
        NSString *filePath = [mitchPath stringByAppendingPathComponent: @"TeamBundle.csv"];
        [csvString writeToFile:filePath
                    atomically:YES
                      encoding:NSUTF8StringEncoding
                         error:nil];
    }
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
    csvString = [[[ExportScoreData alloc] init:_dataManager] scoreBundleCSVExport:tournamentName];
    if (csvString) {
        NSString *filePath = [mitchPath stringByAppendingPathComponent: @"MatchResultsBundle.csv"];
        [csvString writeToFile:filePath
                    atomically:YES
                      encoding:NSUTF8StringEncoding
                         error:nil];
    }
    
}

-(void)buildEmail:(NSArray *)filePaths attach:(NSArray *)emailFiles subject:(NSString *)emailSubject toRecipients:recipients {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        [mailViewController setSubject:emailSubject];
        [mailViewController setToRecipients:recipients];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
