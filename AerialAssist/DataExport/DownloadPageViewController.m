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
#import "MatchData.h"
#import "TeamScore.h"
#import "DataManager.h"
#import "TournamentData.h"
#import "ExportTeamData.h"
#import "ExportScoreData.h"
#import "ExportMatchData.h"

@implementation DownloadPageViewController {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSString *appName;
    NSString *gameName;
    NSString *exportPath;
    NSMutableArray *syncList;
}
@synthesize dataManager = _dataManager;
@synthesize exportTeamData = _exportTeamData;
@synthesize exportMatchData = _exportMatchData;
@synthesize mainLogo = _mainLogo;
@synthesize splashPicture = _splashPicture;
@synthesize pictureCaption = _pictureCaption;
@synthesize syncButton = _syncButton;
@synthesize ftpButton = _ftpButton;

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
        self.title =  [NSString stringWithFormat:@"%@ Download Page", tournamentName];
    }
    else {
        self.title = @"Download Page";
    }

    // Display the Robotnauts Banner
    [_mainLogo setImage:[UIImage imageNamed:@"robonauts app banner.jpg"]];
    // Set Font and Text for Export Buttons
    [_exportTeamData setTitle:@"Export Team Data" forState:UIControlStateNormal];
    _exportTeamData.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:24.0];
    [_exportMatchData setTitle:@"Export Match Data" forState:UIControlStateNormal];
    _exportMatchData.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:24.0];
    exportPath = [self applicationDocumentsDirectory];
    [_syncButton setTitle:@"Sync Data" forState:UIControlStateNormal];
    _syncButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:24.0];
    [_iPadExportButton setTitle:@"Export to iDevice" forState:UIControlStateNormal];
    _iPadExportButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:24.0];
    [_ftpButton setTitle:@"FTP" forState:UIControlStateNormal];
    _ftpButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:24.0];
    // Display the Label for the Picture
    _pictureCaption.font = [UIFont fontWithName:@"Nasalization" size:24.0];
    _pictureCaption.text = @"Just Hangin' Out";
    [super viewDidLoad];
}

- (IBAction)exportTapped:(id)sender {
    
    if (sender == _exportTeamData) {
        [self emailTeamData];
    }
    else {
        [self emailMatchData];
    }
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
        [self buildEmail:fileList attach:attachList subject:emailSubject];
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
    
    [self buildEmail:fileList attach:attachList subject:emailSubject];
}

-(NSString *)buildDanielleMatchCSVOutput:(MatchData *)match forTeam:(TeamScore *)teamScore {
    NSString *csvDataString;
    
    if (teamScore) {
        csvDataString = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@",
                         teamScore.team.number,
                         match.number,
                         teamScore.autonMissed,
//                         teamScore.autonLow,
//                         teamScore.autonMid,
//                         teamScore.autonHigh,
                         teamScore.totalAutonShots,
                         teamScore.teleOpMissed,
                         teamScore.teleOpLow,
//                         teamScore.teleOpMid,
                         teamScore.teleOpHigh,
//                         teamScore.pyramid,
                         teamScore.totalTeleOpShots,
//                         teamScore.passes,
//                         teamScore.blocks,
                         teamScore.wallPickUp,
                         teamScore.floorPickUp,
//                         teamScore.climbAttempt,
//                         ([teamScore.climbLevel intValue] == 0) ? @"N" : @"Y",      // Climb Success
//                         teamScore.climbTimer,
//                         teamScore.climbLevel,
                         teamScore.driverRating,
//                         teamScore.defenseRating,
                         ([teamScore.team.minHeight floatValue] < 28.5) ? @"Y" : @"N",      // drive under pyramid
                         teamScore.team.maxHeight,
                         (teamScore.notes == nil) ? @"," : [NSString stringWithFormat:@",\"%@\"", teamScore.notes]];
    }
    else {
        csvDataString = @"0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,,";
        // NSLog(@"csvDataString = %@", csvDataString);
    }
    return csvDataString;
}

-(NSString *)buildMatchCSVOutput:(TeamScore *)teamScore {
    // NSLog(@"buildMatchCSV");
    NSString *csvDataString;

    if (teamScore) {
        csvDataString = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@%@%@\n",
                teamScore.alliance,
                teamScore.team.number,
                teamScore.saved,
                teamScore.driverRating,
//                teamScore.defenseRating,
//                teamScore.autonHigh,
//                teamScore.autonMid,
//                teamScore.autonLow,
                teamScore.autonMissed,
                teamScore.autonShotsMade,
                teamScore.totalAutonShots,
                teamScore.teleOpHigh,
//                teamScore.teleOpMid,
                teamScore.teleOpLow,
                teamScore.teleOpMissed,
                teamScore.teleOpShots,
                teamScore.totalTeleOpShots,
 //               teamScore.climbAttempt,
 //               teamScore.climbLevel,
 //               teamScore.climbTimer,
 //               teamScore.pyramid,
 //               teamScore.passes,
 //               teamScore.blocks,
                teamScore.floorPickUp,
                teamScore.wallPickUp,
                teamScore.wallPickUp1,
                teamScore.wallPickUp2,
                teamScore.wallPickUp3,
                teamScore.wallPickUp4,
//                (teamScore.fieldDrawing == nil) ? @"," : [NSString stringWithFormat:@",\"%@\"", teamScore.fieldDrawing],
                (teamScore.notes == nil) ? @"," : [NSString stringWithFormat:@",\"%@\"", teamScore.notes]];
        
        // NSLog(@"csvDataString = %@", csvDataString);
    }
    else {
        csvDataString = @"0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,,\n";        
        // NSLog(@"csvDataString = %@", csvDataString);
    }
    return csvDataString;                   
}

-(void)buildEmail:(NSArray *)filePaths attach:(NSArray *)emailFiles subject:(NSString *)emailSubject {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        NSArray *array = [[NSArray alloc] initWithObjects:@"kpettinger@comcast.net", @"BESTRobonauts@gmail.com",nil];
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

- (void)pickerSelected:(NSString *)newPick {
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
            _exportTeamData.frame = CGRectMake(325, 125, 400, 68);
            _exportMatchData.frame = CGRectMake(325, 225, 400, 68);
            _syncButton.frame = CGRectMake(325, 325, 400, 68);
            _iPadExportButton.frame = CGRectMake(325, 425, 400, 68);
            _ftpButton.frame = CGRectMake(325, 525, 400, 68);
            _splashPicture.frame = CGRectMake(293, 563, 468, 330);
            _pictureCaption.frame = CGRectMake(293, 901, 468, 39);
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            _mainLogo.frame = CGRectMake(0, -60, 1024, 255);
            [_mainLogo setImage:[UIImage imageNamed:@"robonauts app banner original.jpg"]];
            _exportTeamData.frame = CGRectMake(550, 225, 400, 68);
            _exportMatchData.frame = CGRectMake(550, 325, 400, 68);
            _syncButton.frame = CGRectMake(550, 425, 400, 68);
            _iPadExportButton.frame = CGRectMake(550, 525, 400, 68);
            _ftpButton.frame = CGRectMake(550, 625, 400, 68);
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
