//
//  LucienPageViewController.m
// Robonauts Scouting
//
//  Created by FRC on 4/21/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "LucienPageViewController.h"
#import "DataManager.h"
#import "TournamentData.h"
#import "TeamData.h"
#import "TeamDataInterfaces.h"
#import "TeamScore.h"
#import "MatchData.h"
#import "PopUpPickerViewController.h"
#import "parseCSV.h"
#import "LucienNumberObject.h"
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
@end

@implementation LucienPageViewController {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSMutableArray *averages;
    NSMutableArray *normals;
    NSMutableArray *factors;
    NSString *settingsFile;
    BOOL dataChange;
    NSFileManager *fileManager;
    NSString *storePath;
 //   NSMutableArray *lucienList;

    NSMutableDictionary *settingsDictionary;
    NSMutableDictionary *lucienDictionary;
    NSArray *lucienSelectionList;

    id popUp;
    BOOL parameterSelected;
    BOOL averageSelected;
    
    PopUpPickerViewController *parameterPicker;
    UIPopoverController *parameterPickerPopover;
    NSMutableArray *parameterList;
    PopUpPickerViewController *averagePicker;
    NSMutableArray *averageList;
    UIPopoverController *averagePickerPopover;
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

    [self initializePreferences];

    dataChange = NO;
    parameterSelected = FALSE;
    averageSelected = FALSE;
    
    [self createParameterList];

    averageList = [[NSMutableArray alloc] initWithObjects:
                    @"All", @"Top One", @"Top 2", @"Top 3", @"Top 4", @"Top 5", @"Top 6", @"Top 7", @"Top 8", @"Top 9", @"Top 10", @"Top 11", @"<", @">", nil];
    _heightList = [[NSMutableArray alloc] initWithObjects:
                    @"<", @">", nil];

    averages = [[NSMutableArray alloc] initWithObjects:
                [NSNumber numberWithInt:0],
                [NSNumber numberWithInt:0],
                [NSNumber numberWithInt:0],
                [NSNumber numberWithInt:0],
                [NSNumber numberWithInt:0],
                [NSNumber numberWithInt:0],
                [NSNumber numberWithInt:0],
                [NSNumber numberWithInt:0], nil];

    normals = [[NSMutableArray alloc] initWithObjects:
               [NSNumber numberWithFloat:1.0],
               [NSNumber numberWithFloat:1.0],
               [NSNumber numberWithFloat:1.0],
               [NSNumber numberWithFloat:1.0],
               [NSNumber numberWithFloat:1.0],
               [NSNumber numberWithFloat:1.0],
               [NSNumber numberWithFloat:1.0],
               [NSNumber numberWithFloat:1.0], nil];
    factors = [[NSMutableArray alloc] initWithObjects:
               [NSNumber numberWithFloat:1.0],
               [NSNumber numberWithFloat:1.0],
               [NSNumber numberWithFloat:1.0],
               [NSNumber numberWithFloat:1.0],
               [NSNumber numberWithFloat:1.0],
               [NSNumber numberWithFloat:1.0],
               [NSNumber numberWithFloat:1.0],
               [NSNumber numberWithFloat:1.0], nil];

//    lucienList = [[NSMutableArray alloc] init];

    storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"lucienFactors.csv"];
    fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:storePath]) {
        CSVParser *parser = [CSVParser new];
        [parser openFile: storePath];
        NSMutableArray *csvContent = [parser parseFile];
        float junk;
        int stupid;
        for (int i=0; i<[[csvContent objectAtIndex:0] count]; i++) {
            stupid = [[[csvContent objectAtIndex:0] objectAtIndex:i] intValue];
            [averages replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:stupid]];
            junk = [[[csvContent objectAtIndex:1] objectAtIndex:i] floatValue];
            [normals replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:junk]];
            junk = [[[csvContent objectAtIndex:2] objectAtIndex:i] floatValue];
            [factors replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:junk]];
        }
    }
    // Set Font and Text for Calculate Button
    [_calculateButton setTitle:@"Calculate Lucien Number" forState:UIControlStateNormal];
    _calculateButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:24.0];
    
    [self setDisplayData];
}

-(void)setDisplayData {
    NSMutableDictionary *row = [self getRowDictionary:@"One"];
    [self setDisplayRow:row forParameter:_parameter1Button
                            forAverage:_average1Button
                            forNormal:_normal1Text
                            forFactor:_factor1Text];
    row = [self getRowDictionary:@"Two"];
    [self setDisplayRow:row forParameter:_parameter2Button
                            forAverage:_average2Button
                            forNormal:_normal2Text
                            forFactor:_factor2Text];
    row = [self getRowDictionary:@"Three"];
    [self setDisplayRow:row forParameter:_parameter3Button
                            forAverage:_average3Button
                            forNormal:_normal3Text
                            forFactor:_factor3Text];
    row = [self getRowDictionary:@"Four"];
    [self setDisplayRow:row forParameter:_parameter4Button
                            forAverage:_average4Button
                            forNormal:_normal4Text
                            forFactor:_factor4Text];
    row = [self getRowDictionary:@"Five"];
    [self setDisplayRow:row forParameter:_parameter5Button
                            forAverage:_average5Button
                            forNormal:_normal5Text
                            forFactor:_factor5Text];
    row = [self getRowDictionary:@"Six"];
    [self setDisplayRow:row forParameter:_parameter6Button
                            forAverage:_average6Button
                            forNormal:_normal6Text
                            forFactor:_factor6Text];
    row = [self getRowDictionary:@"Seven"];
    [self setDisplayRow:row forParameter:_parameter7Button
                            forAverage:_average7Button
                            forNormal:_normal7Text
                            forFactor:_factor7Text];
    row = [self getRowDictionary:@"Eight"];
    [self setDisplayRow:row forParameter:_parameter8Button
                            forAverage:_average8Button
                            forNormal:_normal8Text
                            forFactor:_factor8Text];
}

-(void)setDisplayRow:(NSMutableDictionary *)row forParameter:(UIButton *)parameterButton forAverage:(UIButton *)averageButton forNormal:(UITextField *)normalButton forFactor:(UITextField *)factorButton {
    [parameterButton setTitle:[row objectForKey:@"name"] forState:UIControlStateNormal];
    [averageButton setTitle:[row objectForKey:@"selection"] forState:UIControlStateNormal];
    normalButton.text = [NSString stringWithFormat:@"%.1f", [[row objectForKey:@"normal"] floatValue]];
    factorButton.text = [NSString stringWithFormat:@"%.1f", [[row objectForKey:@"factor"] floatValue]];
}

-(NSMutableDictionary *) getRowDictionary:(NSString *)row {
    NSMutableDictionary *result = [settingsDictionary objectForKey:row];
    if (result) return result;
    else {
        // Create a default dictionary
        NSString *name = @"";
        NSString *selectionCriteria = @"";
        NSNumber *normal = [NSNumber numberWithFloat:1.0];
        NSNumber *factor = [NSNumber numberWithFloat:0.0];
        
        NSMutableDictionary *defaultDictionary = [NSMutableDictionary dictionaryWithObjects:
                                [NSArray arrayWithObjects: name, selectionCriteria, normal, factor, nil]
                                forKeys:[NSArray arrayWithObjects:@"name", @"selection", @"normal", @"factor", nil]];
        [settingsDictionary setObject:defaultDictionary forKey:row];
        return defaultDictionary;
    }
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
    if ([choices count]) {
        validChoice = [choices objectAtIndex:0];
    }
    else {
        validChoice = @"";
    }
    [popUp setTitle:validChoice forState:UIControlStateNormal];
    NSString *dictionaryId;
    if (popUp == _parameter1Button)         dictionaryId = @"One";
    else if (popUp == _parameter2Button)    dictionaryId = @"Two";
    else if (popUp == _parameter3Button)    dictionaryId = @"Three";
    else if (popUp == _parameter4Button)    dictionaryId = @"Four";
    else if (popUp == _parameter5Button)    dictionaryId = @"Five";
    else if (popUp == _parameter6Button)    dictionaryId = @"Six";
    else if (popUp == _parameter7Button)    dictionaryId = @"Seven";
    else if (popUp == _parameter8Button)    dictionaryId = @"Eight";
    
    [self setRowEntry:validChoice forKey:@"name" forDictionaryId:dictionaryId];
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
    if (popUp == _average1Button)         dictionaryId = @"One";
    else if (popUp == _average2Button)    dictionaryId = @"Two";
    else if (popUp == _average3Button)    dictionaryId = @"Three";
    else if (popUp == _average4Button)    dictionaryId = @"Four";
    else if (popUp == _average5Button)    dictionaryId = @"Five";
    else if (popUp == _average6Button)    dictionaryId = @"Six";
    else if (popUp == _average7Button)    dictionaryId = @"Seven";
    else if (popUp == _average8Button)    dictionaryId = @"Eight";
    
    [self setRowEntry:validChoice forKey:@"selection" forDictionaryId:dictionaryId];
}

-(void)setRowEntry:validChoice forKey:(NSString *)key forDictionaryId:(NSString *)line {
    NSMutableDictionary *row = [self getRowDictionary:line];
    if ([row objectForKey:key]) {
        [row setObject:validChoice forKey:key];
    }
}

-(void)createParameterList {
    if (!parameterList) {
        parameterList = [[NSMutableArray alloc] init];
    }
    else {
        [parameterList removeAllObjects];
    }
    for (int i=0; i<[lucienSelectionList count]; i++) {
        [parameterList addObject:[[lucienSelectionList objectAtIndex:i] objectForKey:@"name"]];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    dataChange = YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    //    NSLog(@"team should end editing");
    if (textField == _normal1Text) {
        [self setRowEntry:[NSNumber numberWithFloat:[textField.text floatValue]] forKey:@"normal" forDictionaryId:@"One"];
	}
	else if (textField == _normal2Text) {
        [self setRowEntry:[NSNumber numberWithFloat:[textField.text floatValue]] forKey:@"normal" forDictionaryId:@"Two"];
	}
	else if (textField == _normal3Text) {
        [self setRowEntry:[NSNumber numberWithFloat:[textField.text floatValue]] forKey:@"normal" forDictionaryId:@"Three"];
	}
	else if (textField == _normal4Text) {
        [self setRowEntry:[NSNumber numberWithFloat:[textField.text floatValue]] forKey:@"normal" forDictionaryId:@"Four"];
	}
	else if (textField == _normal5Text) {
        [self setRowEntry:[NSNumber numberWithFloat:[textField.text floatValue]] forKey:@"normal" forDictionaryId:@"Five"];
	}
	else if (textField == _normal6Text) {
        [self setRowEntry:[NSNumber numberWithFloat:[textField.text floatValue]] forKey:@"normal" forDictionaryId:@"Six"];
	}
	else if (textField == _normal7Text) {
        [self setRowEntry:[NSNumber numberWithFloat:[textField.text floatValue]] forKey:@"normal" forDictionaryId:@"Seven"];
	}
	else if (textField == _normal8Text) {
        [self setRowEntry:[NSNumber numberWithFloat:[textField.text floatValue]] forKey:@"normal" forDictionaryId:@"Eight"];
	}
	else if (textField == _factor1Text) {
        [self setRowEntry:[NSNumber numberWithFloat:[textField.text floatValue]] forKey:@"factor" forDictionaryId:@"One"];
	}
	else if (textField == _factor2Text) {
        [self setRowEntry:[NSNumber numberWithFloat:[textField.text floatValue]] forKey:@"factor" forDictionaryId:@"Two"];
	}
	else if (textField == _factor3Text) {
        [self setRowEntry:[NSNumber numberWithFloat:[textField.text floatValue]] forKey:@"factor" forDictionaryId:@"Three"];
	}
	else if (textField == _factor4Text) {
        [self setRowEntry:[NSNumber numberWithFloat:[textField.text floatValue]] forKey:@"factor" forDictionaryId:@"Four"];
	}
	else if (textField == _factor5Text) {
        [self setRowEntry:[NSNumber numberWithFloat:[textField.text floatValue]] forKey:@"factor" forDictionaryId:@"Five"];
	}
	else if (textField == _factor6Text) {
        [self setRowEntry:[NSNumber numberWithFloat:[textField.text floatValue]] forKey:@"factor" forDictionaryId:@"Six"];
	}
	else if (textField == _factor7Text) {
        [self setRowEntry:[NSNumber numberWithFloat:[textField.text floatValue]] forKey:@"factor" forDictionaryId:@"Seven"];
	}
	else if (textField == _factor8Text) {
        [self setRowEntry:[NSNumber numberWithFloat:[textField.text floatValue]] forKey:@"factor" forDictionaryId:@"Eight"];
	}
    
	return YES;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSArray *teamData = [[[TeamDataInterfaces alloc] initWithDataManager:_dataManager] getTeamListTournament:tournamentName];

//    [lucienList removeAllObjects];
    
    for (int i=0; i<[teamData count]; i++) {
        TeamData *team = [teamData objectAtIndex:i];
        LucienNumberObject *lucienNumbers = [[LucienNumberObject alloc] init];
        //NSLog(@"Team = %@, min height = %@, max height = %.@", team.number, team.minHeight, team.maxHeight);
        lucienNumbers.teamNumber = [team.number intValue];
        NSArray *allMatches = [team.match allObjects];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"tournamentName = %@", tournamentName];
        NSArray *matches = [allMatches filteredArrayUsingPredicate:pred];
        NSMutableArray *autonList = [NSMutableArray array];
        NSMutableArray *teleOpList = [NSMutableArray array];
        NSMutableArray *drivingList = [NSMutableArray array];
        NSMutableArray *defenseList = [NSMutableArray array];
        NSMutableArray *speedList = [NSMutableArray array];
        NSMutableArray *hangPointsList = [NSMutableArray array];
        for (int j=0; j<[matches count]; j++) {
            TeamScore *score = [matches objectAtIndex:j];
            int autonPoints = 0;
            int teleOpPoints = 0;
            float hangpoints = 0.0;
           // Only use Seeding or Elimination matches that have been saved or synced
            if ( ([score.match.matchType isEqualToString:@"Seeding"]
                  || [score.match.matchType isEqualToString:@"Elimination"])
                && ([score.saved intValue] || [score.received intValue])) {
//                autonPoints = [score.autonHigh intValue]*6 + [score.autonMid intValue]*5 + [score.autonLow intValue]*4;
//                [autonList addObject:[NSNumber numberWithInt:autonPoints]];
//                teleOpPoints = [score.teleOpHigh intValue]*3 + [score.teleOpMid intValue]*2 + [score.teleOpLow intValue]*1;
                [teleOpList addObject:[NSNumber numberWithInt:teleOpPoints]];
                [drivingList addObject:score.driverRating];
//                [defenseList addObject:score.defenseRating];
                [speedList addObject:score.robotSpeed];
//                hangpoints = [score.climbLevel intValue]*10 + [score.pyramid intValue]*5;
                [hangPointsList addObject:[NSNumber numberWithInt:hangpoints]];
            }
        }
        // NSLog(@"Auton List = %@", autonList);
        lucienNumbers.autonNumber = [self calculateNumbers:autonList forAverage:[averages objectAtIndex:0] forNormal:[normals objectAtIndex:0] forFactor:[factors objectAtIndex:0]];
        // NSLog(@"Auton magic number = %.2f", lucienNumbers.autonNumber);

        //NSLog(@"TeleOp List = %@", teleOpList);
        lucienNumbers.teleOpNumber = [self calculateNumbers:teleOpList forAverage:[averages objectAtIndex:1] forNormal:[normals objectAtIndex:1] forFactor:[factors objectAtIndex:1]];
        //NSLog(@"Teleop magic number = %.2f", lucienNumbers.teleOpNumber);

        //NSLog(@"Hanging List = %@", hangPointsList);
        lucienNumbers.hangingNumber = [self calculateNumbers:hangPointsList forAverage:[averages objectAtIndex:2] forNormal:[normals objectAtIndex:2] forFactor:[factors objectAtIndex:2]];
        //NSLog(@"Hanging magic number = %.2f", lucienNumbers.hangingNumber);

        //NSLog(@"Driving List = %@", drivingList);
        lucienNumbers.drivingNumber = [self calculateNumbers:drivingList forAverage:[averages objectAtIndex:3] forNormal:[normals objectAtIndex:3] forFactor:[factors objectAtIndex:3]];
        //NSLog(@"Driving magic number = %.2f", lucienNumbers.drivingNumber);

        //NSLog(@"Speed List = %@", speedList);
        lucienNumbers.speedNumber = [self calculateNumbers:speedList forAverage:[averages objectAtIndex:4] forNormal:[normals objectAtIndex:4] forFactor:[factors objectAtIndex:4]];
        //NSLog(@"Speed magic number = %.2f", lucienNumbers.speedNumber);

        //NSLog(@"Defense List = %@", defenseList);
        lucienNumbers.defenseNumber = [self calculateNumbers:defenseList forAverage:[averages objectAtIndex:5] forNormal:[normals objectAtIndex:5] forFactor:[factors objectAtIndex:5]];
        //NSLog(@"Defense magic number = %.2f", lucienNumbers.defenseNumber);
 
        //NSLog(@"Height check = %d", ([team.minHeight floatValue] < [[normals objectAtIndex:6] floatValue]));
        lucienNumbers.height1Number = ([team.minHeight floatValue] < [[normals objectAtIndex:6] floatValue]) * [[factors objectAtIndex:6] floatValue];
        lucienNumbers.height2Number = ([team.maxHeight floatValue] < [[normals objectAtIndex:7] floatValue]) * [[factors objectAtIndex:7] floatValue];
        
        lucienNumbers.lucienNumber = lucienNumbers.autonNumber +
                                     lucienNumbers.teleOpNumber +
                                     lucienNumbers.hangingNumber +
                                     lucienNumbers.drivingNumber +
                                     lucienNumbers.speedNumber +
                                     lucienNumbers.defenseNumber +
                                     lucienNumbers.height1Number +
                                     lucienNumbers.height2Number;
        
//        [lucienList addObject:lucienNumbers];
    }
    // Create the Lucien table view controller and set the data.
    LucienTableViewController *lucienTableViewController = [segue destinationViewController];
 //   lucienTableViewController.lucienNumbers = lucienList;
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
    settingsFile = [[self applicationLibraryDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"Preferences/lucienPagePreferences.plist"]];

    fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:settingsFile]) {
        NSData *plistData = [NSData dataWithContentsOfFile:settingsFile];
        NSError *error;
        NSPropertyListFormat plistFormat;
        settingsDictionary = [NSPropertyListSerialization propertyListWithData:plistData options:NSPropertyListImmutable format:&plistFormat error:&error];
    }
    else {
        settingsDictionary = [NSMutableDictionary dictionaryWithCapacity:8];
    }
    
    // Load dictionary with list of parameters for Lucien's List
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"LucienNumberFields" ofType:@"plist"];
    lucienSelectionList = [[NSArray alloc] initWithContentsOfFile:plistPath];
}

- (void) viewWillDisappear:(BOOL)animated
{
    //    NSLog(@"viewWillDisappear");
    NSError *error;
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:settingsDictionary format:NSPropertyListXMLFormat_v1_0 options:nil error:&error];
    if(data) {
        [data writeToFile:settingsFile atomically:YES];
    }
    else {
        NSLog(@"An error has occured %@", error);
    }
}

-(void)SetBigButtonDefaults:(UIButton *)currentButton {
    currentButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:24.0];
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

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark - Application's Library directory

/**
 Returns the path to the application's Library directory.
 */
- (NSString *)applicationLibraryDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
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
