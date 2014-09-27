//
//  PhoneExportViewController.m
//  AerialAssist
//
//  Created by FRC on 2/14/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "PhoneExportViewController.h"
#import "DataManager.h"
#import "ExportTeamData.h"
#import "ExportScoreData.h"
#import "ExportMatchData.h"
#import "TeamDataInterfaces.h"

@interface PhoneExportViewController ()
@property (nonatomic, weak) IBOutlet UIButton *exportTeamData;
@property (nonatomic, weak) IBOutlet UIButton *exportMatchData;
@property (nonatomic, weak) IBOutlet UIButton *exportSpreadsheetData;
@end

@implementation PhoneExportViewController {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSString *gameName;
    NSString *appName;
    NSString *exportPath;
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

    exportPath = [self applicationDocumentsDirectory];
}

- (IBAction)buttonPress:(id)sender {
    NSString *csvString;
    if (sender == _exportTeamData) {
        csvString = [[[ExportTeamData alloc] init] teamDataCSVExport:tournamentName fromContext:_dataManager.managedObjectContext];
        if (csvString) {
            NSString *filePath = [exportPath stringByAppendingPathComponent: @"TeamData.csv"];
            [csvString writeToFile:filePath
                        atomically:YES
                          encoding:NSUTF8StringEncoding
                             error:nil];
            NSString *emailSubject = @"Team Data CSV File";
            NSArray *fileList = [[NSArray alloc] initWithObjects:filePath, nil];
            NSArray *attachList = [[NSArray alloc] initWithObjects:@"TeamData.csv", nil];
            NSArray *recipients = [[NSArray alloc] initWithObjects:@"kpettinger@comcast.net", @"BESTRobonauts@gmail.com",nil];
            [self buildEmail:fileList attach:attachList subject:emailSubject toRecipients:recipients];
         }
    }
    else if (sender == _exportMatchData) {
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
        NSArray *recipients = [[NSArray alloc] initWithObjects:@"kpettinger@comcast.net", @"BESTRobonauts@gmail.com",nil];

        [self buildEmail:fileList attach:attachList subject:emailSubject toRecipients:recipients];
   }
    else if (sender == _exportSpreadsheetData) {
        [self createScoutingSpreadsheet:@""];
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
    NSArray *recipients = [[NSArray alloc] initWithObjects:@"kpettinger@comcast.net", @"BESTRobonauts@gmail.com",nil];
    [self buildEmail:fileList attach:attachList subject:emailSubject toRecipients:recipients];
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

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
