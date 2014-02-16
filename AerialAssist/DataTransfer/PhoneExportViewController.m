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

@interface PhoneExportViewController ()
@property (nonatomic, weak) IBOutlet UIButton *exportTeamData;
@property (nonatomic, weak) IBOutlet UIButton *exportMatchData;
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
        NSLog(@"Team Button");
        ExportTeamData *teamCSVExport = [[ExportTeamData alloc] initWithDataManager:_dataManager];
        csvString = [teamCSVExport teamDataCSVExport];
        if (csvString) {
            NSString *filePath = [exportPath stringByAppendingPathComponent: @"TeamData.csv"];
            NSLog(@"export data file = %@", filePath);
            NSLog(@"csvString = %@", csvString);
            [csvString writeToFile:filePath
                        atomically:YES
                          encoding:NSUTF8StringEncoding
                             error:nil];
            NSString *emailSubject = @"Team Data CSV File";
            [self buildEmail:filePath attach:@"TeamData.csv" subject:emailSubject];
         }
    }
    else {
        NSLog(@"Match Button");
    }
}


 -(void)buildEmail:(NSString *)filePath attach:(NSString *)emailFile subject:(NSString *)emailSubject {
     if ([MFMailComposeViewController canSendMail]) {
         MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
         NSArray *array = [[NSArray alloc] initWithObjects:@"kpettinger@comcast.net", @"BESTRobonauts@gmail.com",nil];
         [mailViewController setSubject:emailSubject];
         [mailViewController setToRecipients:array];
         [mailViewController setMessageBody:[NSString stringWithFormat:@"Downloaded Data from %@", gameName] isHTML:NO];
         [mailViewController setMailComposeDelegate:self];
 
         NSData *exportData = [[NSData alloc] initWithContentsOfFile:filePath];
         if (exportData) {
             [mailViewController addAttachmentData:exportData mimeType:[NSString stringWithFormat:@"application/%@", appName] fileName:emailFile];
         }
         else {
             NSLog(@"Error encoding data for email");
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
