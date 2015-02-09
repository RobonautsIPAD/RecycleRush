//
//  LucienPageViewController.m
// Robonauts Scouting
//
//  Created by FRC on 4/21/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <QuartzCore/CALayer.h>
#import "LucienPageViewController.h"
#import "DataManager.h"
#import "FileIOMethods.h"
#import "TeamAccessors.h"
#import "MatchAccessors.h"
#import "ScoreAccessors.h"
#import "TournamentData.h"
#import "TeamData.h"
#import "TeamScore.h"
#import "MatchData.h"
#import "PopUpPickerViewController.h"
#import "LucienTableViewController.h"

@interface LucienPageViewController ()
@property (nonatomic, weak) IBOutlet UIButton *parameter1Button;
@property (nonatomic, weak) IBOutlet UIButton *average1Button;
@property (nonatomic, weak) IBOutlet UITextField *normal1Text;
@property (nonatomic, weak) IBOutlet UITextField *factor1Text;

@property (nonatomic, weak) IBOutlet UIButton *parameter2Button;
@property (nonatomic, weak) IBOutlet UIButton *average2Button;
@property (nonatomic, weak) IBOutlet UITextField *normal2Text;
@property (nonatomic, weak) IBOutlet UITextField *factor2Text;

@property (nonatomic, weak) IBOutlet UIButton *parameter3Button;
@property (nonatomic, weak) IBOutlet UIButton *average3Button;
@property (nonatomic, weak) IBOutlet UITextField *normal3Text;
@property (nonatomic, weak) IBOutlet UITextField *factor3Text;

@property (nonatomic, weak) IBOutlet UIButton *parameter4Button;
@property (nonatomic, weak) IBOutlet UIButton *average4Button;
@property (nonatomic, weak) IBOutlet UITextField *normal4Text;
@property (nonatomic, weak) IBOutlet UITextField *factor4Text;

@property (nonatomic, weak) IBOutlet UIButton *parameter5Button;
@property (nonatomic, weak) IBOutlet UIButton *average5Button;
@property (nonatomic, weak) IBOutlet UITextField *normal5Text;
@property (nonatomic, weak) IBOutlet UITextField *factor5Text;

@property (nonatomic, weak) IBOutlet UIButton *parameter6Button;
@property (nonatomic, weak) IBOutlet UIButton *average6Button;
@property (nonatomic, weak) IBOutlet UITextField *normal6Text;
@property (nonatomic, weak) IBOutlet UITextField *factor6Text;

@property (nonatomic, weak) IBOutlet UIButton *parameter7Button;
@property (nonatomic, weak) IBOutlet UIButton *average7Button;
@property (nonatomic, weak) IBOutlet UITextField *normal7Text;
@property (nonatomic, weak) IBOutlet UITextField *factor7Text;

@property (nonatomic, weak) IBOutlet UIButton *parameter8Button;
@property (nonatomic, weak) IBOutlet UIButton *average8Button;
@property (nonatomic, weak) IBOutlet UITextField *normal8Text;
@property (nonatomic, weak) IBOutlet UITextField *factor8Text;
@property (weak, nonatomic) IBOutlet UIButton *exportButton;
@end

@implementation LucienPageViewController {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSString *appName;
    NSString *gameName;
    
    NSString *settingsFile;
    BOOL dataChange;
    NSFileManager *fileManager;
    NSString *storePath;
    NSString *exportPath;
    NSDictionary *matchTypeDictionary;

    NSMutableDictionary *parameterDictionary;
    NSArray *databaseList;
    NSMutableArray *lucienList;

    id popUp;
    BOOL parameterSelected;
    BOOL averageSelected;
    
    PopUpPickerViewController *parameterPicker;
    UIPopoverController *parameterPickerPopover;
    NSMutableArray *parameterList;
    PopUpPickerViewController *averagePicker;
    NSMutableArray *averageList;
    UIPopoverController *averagePickerPopover;
    NSMutableArray *booleanList;
}

@synthesize mainLogo = _mainLogo;
@synthesize labelText = _labelText;

@synthesize dataManager = _dataManager;
@synthesize heightPicker = _heightPicker;
@synthesize heightList = _heightList;
@synthesize heightPickerPopover = _heightPickerPopover;
@synthesize calculateButton = _calculateButton;

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
    
    // Display the Robotnauts Banner
    [_mainLogo setImage:[UIImage imageNamed:@"robonauts app banner original.jpg"]];
    // Display the Label for the Picture
    _labelText.font = [UIFont fontWithName:@"Nasalization" size:24.0];
    _labelText.text = @"Just Hangin' Out";
    
    prefs = [NSUserDefaults standardUserDefaults];
    tournamentName = [prefs objectForKey:@"tournament"];
    if (tournamentName) {
        self.title =  [NSString stringWithFormat:@"%@ Lucien Page", tournamentName];
    }
    else {
        self.title = @"Lucien Page";
    }
    appName = [prefs objectForKey:@"appName"];
    gameName = [prefs objectForKey:@"gameName"];

    [self initializePreferences];
    exportPath = [FileIOMethods applicationDocumentsDirectory];
    matchTypeDictionary = _dataManager.matchTypeDictionary;

    dataChange = NO;
    parameterSelected = FALSE;
    averageSelected = FALSE;
    
    [self createParameterList];

    averageList = [[NSMutableArray alloc] initWithObjects:
                    @"All", @"Top One", @"Top 2", @"Top 3", @"Top 4", @"Top 5", @"Top 6", @"Top 7", @"Top 8", @"Top 9", @"Top 10", @"Top 11", nil];
    booleanList = [[NSMutableArray alloc] initWithObjects:@"True", @"False", nil];

    // Set Font and Text for Calculate Button
    [_calculateButton setTitle:@"Calculate Lucien Number" forState:UIControlStateNormal];
    _calculateButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:24.0];
    
    // Set defaults for the selection buttons
    [self SetBigButtonDefaults:_parameter1Button];
    [self SetBigButtonDefaults:_parameter2Button];
    [self SetBigButtonDefaults:_parameter3Button];
    [self SetBigButtonDefaults:_parameter4Button];
    [self SetBigButtonDefaults:_parameter5Button];
    [self SetBigButtonDefaults:_parameter6Button];
    [self SetBigButtonDefaults:_parameter7Button];
    [self SetBigButtonDefaults:_parameter8Button];
    [self SetBigButtonDefaults:_average1Button];
    [self SetBigButtonDefaults:_average2Button];
    [self SetBigButtonDefaults:_average3Button];
    [self SetBigButtonDefaults:_average4Button];
    [self SetBigButtonDefaults:_average5Button];
    [self SetBigButtonDefaults:_average6Button];
    [self SetBigButtonDefaults:_average7Button];
    [self SetBigButtonDefaults:_average8Button];
    [self setDisplayData];
}

-(void)setDisplayData {
    NSMutableDictionary *row = [self getRowDictionary:@"1"];
    [self setDisplayRow:row forParameter:_parameter1Button
                            forAverage:_average1Button
                            forNormal:_normal1Text
                            forFactor:_factor1Text];
    row = [self getRowDictionary:@"2"];
    [self setDisplayRow:row forParameter:_parameter2Button
                            forAverage:_average2Button
                            forNormal:_normal2Text
                            forFactor:_factor2Text];
    row = [self getRowDictionary:@"3"];
    [self setDisplayRow:row forParameter:_parameter3Button
                            forAverage:_average3Button
                            forNormal:_normal3Text
                            forFactor:_factor3Text];
    row = [self getRowDictionary:@"4"];
    [self setDisplayRow:row forParameter:_parameter4Button
                            forAverage:_average4Button
                            forNormal:_normal4Text
                            forFactor:_factor4Text];
    row = [self getRowDictionary:@"5"];
    [self setDisplayRow:row forParameter:_parameter5Button
                            forAverage:_average5Button
                            forNormal:_normal5Text
                            forFactor:_factor5Text];
    row = [self getRowDictionary:@"6"];
    [self setDisplayRow:row forParameter:_parameter6Button
                            forAverage:_average6Button
                            forNormal:_normal6Text
                            forFactor:_factor6Text];
    row = [self getRowDictionary:@"7"];
    [self setDisplayRow:row forParameter:_parameter7Button
                            forAverage:_average7Button
                            forNormal:_normal7Text
                            forFactor:_factor7Text];
    row = [self getRowDictionary:@"8"];
    [self setDisplayRow:row forParameter:_parameter8Button
                            forAverage:_average8Button
                            forNormal:_normal8Text
                            forFactor:_factor8Text];
}

-(void)setDisplayRow:(NSMutableDictionary *)row forParameter:(UIButton *)parameterButton forAverage:(UIButton *)averageButton forNormal:(UITextField *)normalButton forFactor:(UITextField *)factorButton {
    if (row) {
        [parameterButton setTitle:[row objectForKey:@"name"] forState:UIControlStateNormal];
        [averageButton setTitle:[row objectForKey:@"selection"] forState:UIControlStateNormal];
        normalButton.text = [NSString stringWithFormat:@"%.1f", [[row objectForKey:@"normal"] floatValue]];
        factorButton.text = [NSString stringWithFormat:@"%.1f", [[row objectForKey:@"factor"] floatValue]];
        averageButton.userInteractionEnabled = TRUE;
        normalButton.userInteractionEnabled = TRUE;
        factorButton.userInteractionEnabled = TRUE;
    }
    else {
        [parameterButton setTitle:@"" forState:UIControlStateNormal];
        [averageButton setTitle:@"" forState:UIControlStateNormal];
        normalButton.text = @"";
        factorButton.text = @"";
        averageButton.userInteractionEnabled = FALSE;
        normalButton.userInteractionEnabled = FALSE;
        factorButton.userInteractionEnabled = FALSE;
    }
}

-(NSMutableDictionary *) getRowDictionary:(NSString *)row {
    NSMutableDictionary *result = [parameterDictionary objectForKey:row];
    if (result) return result;
    else return nil;
}

-(IBAction)selectParameter:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (parameterPicker == nil) {
        parameterPicker = [[PopUpPickerViewController alloc]
                              initWithStyle:UITableViewStylePlain];
        parameterPicker.delegate = self;
        parameterPicker.pickerChoices = parameterList;
        parameterPickerPopover = [[UIPopoverController alloc]
                                     initWithContentViewController:parameterPicker];
    }
    popUp = sender;
    parameterSelected = TRUE;
    [parameterPickerPopover presentPopoverFromRect:button.bounds inView:button
                             permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (IBAction)selectAverage:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (averagePicker == nil) {
        averagePicker = [[PopUpPickerViewController alloc]
                                 initWithStyle:UITableViewStylePlain];
        averagePicker.delegate = self;
        averagePicker.pickerChoices = averageList;
        averagePickerPopover = [[UIPopoverController alloc]
                                        initWithContentViewController:averagePicker];
    }
    popUp = sender;
    averageSelected = TRUE;
    [averagePickerPopover presentPopoverFromRect:button.bounds inView:button
                                permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (IBAction)selectHeight:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (_heightPicker == nil) {
        self.heightPicker = [[PopUpPickerViewController alloc]
                              initWithStyle:UITableViewStylePlain];
        _heightPicker.delegate = self;
        _heightPicker.pickerChoices = _heightList;
        self.heightPickerPopover = [[UIPopoverController alloc]
                                     initWithContentViewController:_heightPicker];
    }
    _heightPicker.pickerChoices = _heightList;
    popUp = sender;
    [self.heightPickerPopover presentPopoverFromRect:button.bounds inView:button
                             permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)pickerSelected:(NSString *)newPick {
    dataChange = YES;
    if (parameterSelected) {
        [self changeParameter:popUp forChoice:newPick];
        parameterSelected = FALSE;
    }
    else if (averageSelected) {
        [self changeAverage:popUp forChoice:newPick];
        averageSelected = FALSE;
    }
}

-(void)changeParameter:(id)selection forChoice:(NSString *)newPick {
    NSString *validChoice;
    [parameterPickerPopover dismissPopoverAnimated:YES];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", newPick];
    NSArray *choices = [parameterList filteredArrayUsingPredicate: predicate];
    if ([choices count] && ![[choices objectAtIndex:0] isEqualToString:@"Clear"]) {
        validChoice = [choices objectAtIndex:0];
    }
    else {
        validChoice = @"";
    }
    [popUp setTitle:validChoice forState:UIControlStateNormal];
    NSString *dictionaryId;
    if (popUp == _parameter1Button)         dictionaryId = @"1";
    else if (popUp == _parameter2Button)    dictionaryId = @"2";
    else if (popUp == _parameter3Button)    dictionaryId = @"3";
    else if (popUp == _parameter4Button)    dictionaryId = @"4";
    else if (popUp == _parameter5Button)    dictionaryId = @"5";
    else if (popUp == _parameter6Button)    dictionaryId = @"6";
    else if (popUp == _parameter7Button)    dictionaryId = @"7";
    else if (popUp == _parameter8Button)    dictionaryId = @"8";
    
    [self setParameterEntry:validChoice forKey:@"name" forDictionaryId:dictionaryId];
}

-(void)changeAverage:(id)selection forChoice:(NSString *)newPick {
    NSString *validChoice;
    [averagePickerPopover dismissPopoverAnimated:YES];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", newPick];
    NSArray *choices = [averageList filteredArrayUsingPredicate: predicate];
    if ([choices count]) {
        validChoice = [choices objectAtIndex:0];
    }
    else {
        validChoice = @"";
    }
    [popUp setTitle:validChoice forState:UIControlStateNormal];
    NSString *dictionaryId;
    if (popUp == _average1Button)         dictionaryId = @"1";
    else if (popUp == _average2Button)    dictionaryId = @"2";
    else if (popUp == _average3Button)    dictionaryId = @"3";
    else if (popUp == _average4Button)    dictionaryId = @"4";
    else if (popUp == _average5Button)    dictionaryId = @"5";
    else if (popUp == _average6Button)    dictionaryId = @"6";
    else if (popUp == _average7Button)    dictionaryId = @"7";
    else if (popUp == _average8Button)    dictionaryId = @"8";
    
    [self setRowEntry:validChoice forKey:@"selection" forDictionaryId:dictionaryId];
}

-(void)setRowEntry:validChoice forKey:(NSString *)key forDictionaryId:(NSString *)line {
   
    NSMutableDictionary *row = [self getRowDictionary:line];
    
    if ([row objectForKey:key]) {
        [row setObject:validChoice forKey:key];
    }
 }

-(void) setParameterEntry:(NSString *)validChoice forKey:(NSString *)key forDictionaryId:(NSString *)line {
    NSMutableDictionary *row = [self getRowDictionary:line];
    if ([validChoice isEqualToString:@""]) {
        [parameterDictionary removeObjectForKey:line];
        [self setDisplayData];
    }
    else {
        if (row) {
            [row setObject:validChoice forKey:key];
        }
        else {
            NSMutableDictionary *defaultParameterDictionary = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:validChoice, @"", [NSNumber numberWithFloat:1.0], [NSNumber numberWithFloat:1.0], nil] forKeys:[NSArray arrayWithObjects:@"name", @"selection", @"normal", @"factor", nil]];
            NSLog(@"para dict = %@", parameterDictionary);
            [parameterDictionary setObject:defaultParameterDictionary forKey:line];
            [self setDisplayData];
        }
    }
}

-(void)createParameterList {
    if (!parameterList) {
        parameterList = [[NSMutableArray alloc] init];
    }
    else {
        [parameterList removeAllObjects];
    }

    for (int i=0; i<[databaseList count]; i++) {
        [parameterList addObject:[[databaseList objectAtIndex:i] objectForKey:@"name"]];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    dataChange = YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    //    NSLog(@"team should end editing");
    if (textField == _normal1Text) {
        [self setRowEntry:[NSNumber numberWithFloat:[textField.text floatValue]] forKey:@"normal" forDictionaryId:@"1"];
	}
	else if (textField == _normal2Text) {
        [self setRowEntry:[NSNumber numberWithFloat:[textField.text floatValue]] forKey:@"normal" forDictionaryId:@"2"];
	}
	else if (textField == _normal3Text) {
        [self setRowEntry:[NSNumber numberWithFloat:[textField.text floatValue]] forKey:@"normal" forDictionaryId:@"3"];
	}
	else if (textField == _normal4Text) {
        [self setRowEntry:[NSNumber numberWithFloat:[textField.text floatValue]] forKey:@"normal" forDictionaryId:@"4"];
	}
	else if (textField == _normal5Text) {
        [self setRowEntry:[NSNumber numberWithFloat:[textField.text floatValue]] forKey:@"normal" forDictionaryId:@"5"];
	}
	else if (textField == _normal6Text) {
        [self setRowEntry:[NSNumber numberWithFloat:[textField.text floatValue]] forKey:@"normal" forDictionaryId:@"6"];
	}
	else if (textField == _normal7Text) {
        [self setRowEntry:[NSNumber numberWithFloat:[textField.text floatValue]] forKey:@"normal" forDictionaryId:@"7"];
	}
	else if (textField == _normal8Text) {
        [self setRowEntry:[NSNumber numberWithFloat:[textField.text floatValue]] forKey:@"normal" forDictionaryId:@"8"];
	}
	else if (textField == _factor1Text) {
        [self setRowEntry:[NSNumber numberWithFloat:[textField.text floatValue]] forKey:@"factor" forDictionaryId:@"1"];
	}
	else if (textField == _factor2Text) {
        [self setRowEntry:[NSNumber numberWithFloat:[textField.text floatValue]] forKey:@"factor" forDictionaryId:@"2"];
	}
	else if (textField == _factor3Text) {
        [self setRowEntry:[NSNumber numberWithFloat:[textField.text floatValue]] forKey:@"factor" forDictionaryId:@"3"];
	}
	else if (textField == _factor4Text) {
        [self setRowEntry:[NSNumber numberWithFloat:[textField.text floatValue]] forKey:@"factor" forDictionaryId:@"4"];
	}
	else if (textField == _factor5Text) {
        [self setRowEntry:[NSNumber numberWithFloat:[textField.text floatValue]] forKey:@"factor" forDictionaryId:@"5"];
	}
	else if (textField == _factor6Text) {
        [self setRowEntry:[NSNumber numberWithFloat:[textField.text floatValue]] forKey:@"factor" forDictionaryId:@"6"];
	}
	else if (textField == _factor7Text) {
        [self setRowEntry:[NSNumber numberWithFloat:[textField.text floatValue]] forKey:@"factor" forDictionaryId:@"7"];
	}
	else if (textField == _factor8Text) {
        [self setRowEntry:[NSNumber numberWithFloat:[textField.text floatValue]] forKey:@"factor" forDictionaryId:@"8"];
	}
    
	return YES;
}

- (IBAction)exportLucienNumbers:(id)sender {
    [self saveSelections];
    [self calculateLucienNumbers];

    NSString *filePath = [exportPath stringByAppendingPathComponent: @"LucienData.csv"];
    NSString *csvString = @"Team, Lucien Number";
    
    for (int i = 1; i<[parameterDictionary count]+1; i++) {
        NSDictionary *row = [parameterDictionary objectForKey:[NSString stringWithFormat:@"%d",i]];
        NSString *header = [row objectForKey:@"name"];
        csvString = [csvString stringByAppendingFormat:@", %@", header];
    }
    for (int j=0; j<[lucienList count]; j++) {
        NSDictionary *info = [lucienList objectAtIndex:j];
        csvString = [csvString stringByAppendingFormat:@"\n%@, %@", [info objectForKey:@"team"], [NSString stringWithFormat:@"%.1f", [[info objectForKey:@"lucien"] floatValue]]];
        for (int i=1; i<=[parameterDictionary count]+1; i++) {
            NSString *key = [NSString stringWithFormat:@"%d", i];
            NSNumber *value = [info objectForKey:key];
            if (value) {
                csvString = [csvString stringByAppendingString:[NSString stringWithFormat:@", %.1f", [value floatValue]]];
            }
        }
    }
    [csvString writeToFile:filePath
                atomically:YES
                  encoding:NSUTF8StringEncoding
                     error:nil];
    NSString *emailSubject = @"Team Data CSV File";
    NSArray *fileList = [[NSArray alloc] initWithObjects:filePath, nil];
    NSArray *attachList = [[NSArray alloc] initWithObjects:@"LucienData.csv", nil];
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
    [self saveSelections];
    [self calculateLucienNumbers];

    [segue.destinationViewController setLucienNumbers:[[NSArray alloc] initWithArray:lucienList]];
    [segue.destinationViewController setLucienSelections:parameterDictionary];
}

-(void)calculateLucienNumbers {
    lucienList = [[NSMutableArray alloc] init];
    // get team list
    NSArray *teamData = [TeamAccessors getTeamsInTournament:tournamentName fromDataManager:_dataManager];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"results = %@ AND matchType == %@", [NSNumber numberWithBool:YES], [MatchAccessors getMatchTypeFromString:@"Qualification" fromDictionary:matchTypeDictionary]];
    // each team will have a dictionary with team number and a lucien number for each row
    // so a dictionary where key is the team number and there is an dictionary of lucien numbers with the same key as the row
    for (NSNumber *teamNumber in teamData) {
        NSLog(@"Team %@", teamNumber);
        // Get the matches for this team, this tournament and that have recorded results
        NSArray *allMatches = [ScoreAccessors getMatchListForTeam:teamNumber forTournament:tournamentName fromDataManager:_dataManager];
        // = [[team.match allObjects] filteredArrayUsingPredicate:pred];
        NSArray *matches = [allMatches filteredArrayUsingPredicate:pred];
        // For each requested parameter (ie row on this display), calculate its lucien number. Store in a dictionary
        //  using the same key as the parameterDictionary
        NSMutableDictionary *lucienDictionary = [[NSMutableDictionary alloc] init];
        [lucienDictionary setObject:teamNumber forKey:@"team"];
        float total = 0.0;
        TeamData *team = [TeamAccessors getTeam:teamNumber fromDataManager:_dataManager];
        for (int i=0; i<([parameterDictionary count]); i++) {
            NSString *parameterDictionaryKey = [NSString stringWithFormat:@"%d", i+1];
            NSNumber *lucienNumber = [self calculateLucienParameter:parameterDictionaryKey forTeam:team forScores:matches];
            if (lucienNumber) {
                [lucienDictionary setObject:lucienNumber forKey:parameterDictionaryKey];
                total += [lucienNumber floatValue];
            }
        }
        [lucienDictionary setObject:[NSNumber numberWithFloat:total] forKey:@"lucien"];
        [lucienList addObject:lucienDictionary];
    }
}

-(NSNumber *)calculateLucienParameter:(NSString *)line forTeam:(TeamData *)team forScores:(NSArray *)matches {
    float average;
    NSDictionary *request = [parameterDictionary objectForKey:line];
    NSDictionary *databaseSelection = [self getDatabaseSelection:request];
    if (!databaseSelection) return nil;
    // if it is a team data parameter, just fetch it and set its true or false value in the dictionary
    // if it is a team score item, send off for the parmeter and get back a sorted array of the right number of values
    if ([[databaseSelection objectForKey:@"table"] isEqualToString:@"TeamData"]) {
        //NSLog(@"%@", [team valueForKey:[lucienSelection objectForKey:@"key"]]);
        average = [[team valueForKey:[databaseSelection objectForKey:@"key"]] floatValue];
        if (average < 0) average = 0.0;
    }
    else {
        average = [self calculateAverage:team forScores:matches forParameter:request forData:databaseSelection];
    }
    
    NSNumber *lucienNumber;
    float normal = [[request objectForKey:@"normal"] floatValue];
    if (fabs(normal) < 1.0e-6) {
        normal = 1.0;
    }
    float factor = [[request objectForKey:@"factor"] floatValue];
    lucienNumber = [NSNumber numberWithFloat:(average / normal * factor)];

    return lucienNumber;
}

-(NSDictionary *)getDatabaseSelection:(NSDictionary *)parameter {
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"name = %@", [parameter objectForKey:@"name"]];
    NSArray *lucienObjects = [databaseList filteredArrayUsingPredicate:pred];
    if ([lucienObjects count]) return [lucienObjects objectAtIndex:0];
    else return nil;
}
/*        NSString *skipZeros = [parameter objectForKey:@"skipZeros"];
 int count=0;
 for (int i=0; i<numberOfMatches; i++) {
 TeamScore *match = [matches objectAtIndex:i];
 float item = [[match valueForKey:[parameter objectForKey:@"key"]] floatValue];
 // Add skipZeros stuff
 if (skipZeros && [skipZeros boolValue]) {
 if (fabs(item) > 0.000001) {
 total += item;
 count++;
 }
 else {
 total += item;
 count++;
 }
 }
*/
-(float)calculateAverage:(TeamData *)team forScores:matches forParameter:(NSDictionary *)parameter forData:(NSDictionary *)lucienSelection {
    // NSLog(@"%@", [matches valueForKey:[lucienSelection objectForKey:@"key"]]);
    NSSortDescriptor *highestToLowest = [[NSSortDescriptor alloc] initWithKey:[lucienSelection objectForKey:@"key"] ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:highestToLowest, nil];
    matches = [matches sortedArrayUsingDescriptors:sortDescriptors];
    // NSLog(@"Calculation = %@", [parameter objectForKey:@"selection"]);
    NSString *calculation = [parameter objectForKey:@"selection"];
    int number = 0;
    for (int i=0; i<[averageList count]; i++) {
        if ([calculation isEqualToString:[averageList objectAtIndex:i]]) {
            if (i == 0) number = [matches count];
            else number = i;
            break;
        }
    }
    if (number > [matches count]) number = [matches count];
    if (number == 0) return 0.0;
    float total = 0.0;
    float average = 0.0;
    int count = 0;
    NSString *skipZeros = [lucienSelection objectForKey:@"skipZeros"];
    BOOL skipping = NO;
    skipping = (skipZeros && [skipZeros boolValue]);
    for (int i=0; i<number; i++) {
        TeamScore *score = [matches objectAtIndex:i];
        float item = [[score valueForKey:[lucienSelection objectForKey:@"key"]] floatValue];
        //NSLog(@"Match = %@, Value = %@", score.match.number, [score valueForKey:[lucienSelection objectForKey:@"key"]]);
        if (skipping) {
            if (fabs(item) > 0.000001) {
                total += item;
                count++;
            }
        }
        else {
            total += item;
            count++;
        }
    }
    if (count) {
        average = total/count;
    }
    // NSLog(@"Average = %f", average);
    return average;
}

-(float)calculateNumbers:(NSMutableArray *)list forAverage:(NSNumber *)average forNormal:(NSNumber *)normal forFactor:(NSNumber *)factor {
    float magicNumber = 0.0;
    int count = 0;
    
    if ([average intValue] == 0) {
        count = [list count];
    }
    else {
        count = [average intValue];
        NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:nil ascending:NO];
        [list sortUsingDescriptors:[NSArray arrayWithObject:highestToLowest]];
    }

    float score = 0.0;
    for (int i=0; i<count; i++) {
        score += [[list objectAtIndex:i] intValue];
    }
    
    float ave = score / count;
    float norm = [normal floatValue];
    if (fabs(norm) < 1.0e-6) {
        norm = 1.0;
    }
    magicNumber = ave/norm * [factor floatValue];
    return magicNumber;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *resultingString = [textField.text stringByReplacingCharactersInRange: range withString: string];
    
    // This allows backspace
    if ([resultingString length] == 0) {
        return true;
    }
    float holder;
    NSScanner *scan = [NSScanner scannerWithString: resultingString];
    return [scan scanFloat: &holder] && [scan isAtEnd];
}

-(void)initializePreferences {
    settingsFile = [[FileIOMethods applicationLibraryDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"Preferences/lucienPagePreferences.plist"]];

    fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:settingsFile]) {
        NSData *plistData = [NSData dataWithContentsOfFile:settingsFile];
        NSError *error;
        NSPropertyListFormat plistFormat;
        parameterDictionary = [NSPropertyListSerialization propertyListWithData:plistData options:NSPropertyListImmutable format:&plistFormat error:&error];
    }
    else {
        parameterDictionary = [[NSMutableDictionary alloc] init];
    }
    // Create a default dictionary for adding desired parameters
    // Load dictionary with list of parameters for Lucien's List
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"LucienNumberFields" ofType:@"plist"];
    databaseList = [[NSArray alloc] initWithContentsOfFile:plistPath];

}

-(void)saveSelections {
    NSError *error;
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:parameterDictionary format:NSPropertyListXMLFormat_v1_0 options:nil error:&error];
    if(data) {
        [data writeToFile:settingsFile atomically:YES];
    }
    else {
        NSLog(@"An error has occured %@", error);
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    //    NSLog(@"viewWillDisappear");
    [self saveSelections];
}

-(void)SetBigButtonDefaults:(UIButton *)currentButton {
    currentButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:24.0];
    // Round button corners
    CALayer *btnLayer = [currentButton layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:10.0f];
    // Apply a 1 pixel, black border
    [btnLayer setBorderWidth:1.0f];
    [btnLayer setBorderColor:[[UIColor grayColor] CGColor]];
    // Set the button Background Color
    [currentButton setBackgroundColor:[UIColor whiteColor]];
    // Set the button Text Color
    [currentButton setTitleColor:[UIColor colorWithRed:(0.0/255) green:(0.0/255) blue:(120.0/255) alpha:1.0 ]forState: UIControlStateNormal];
}

-(void)SetSmallButtonDefaults:(UIButton *)currentButton {
    currentButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    switch(toInterfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            //( , , , )
            _mainLogo.frame = CGRectMake(0, -74, 1024, 285);
            [_mainLogo setImage:[UIImage imageNamed:@"robonauts app banner original.jpg"]];
            _labelText.frame = CGRectMake(20, 538, 372, 21);
            break;
        default:
            break;
            
    }
}


@end
