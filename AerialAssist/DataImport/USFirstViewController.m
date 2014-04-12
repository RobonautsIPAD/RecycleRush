//
//  USFirstViewController.m
//  AerialAssist
//
//  Created by Kylor Wang on 4/2/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "USFirstViewController.h"
#import "parseUSFirst.h"
#import "TournamentData.h"
#import "DataManager.h"
#import "CreateMatch.h"
#import "MatchData.h"

@interface USFirstViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tblMain;
@property (strong, nonatomic) IBOutlet UIButton *btnSelectYear;
@property (strong, nonatomic) IBOutlet UIButton *btnSelectTour;
@property (strong, nonatomic) IBOutlet UISegmentedControl *sgmType;
@property (strong, nonatomic) IBOutlet UIButton *btnImport;

@end

@implementation USFirstViewController {
    int actionSheetSender;
    int thisYear;
    NSUserDefaults *prefs;
    NSArray *tournamentList;
    int tournamentYear;
    NSString *tournamentCode;
    int matchType;
    NSArray *displayData;
    NSString *tournamentName;
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
	// Do any additional setup after loading the view.
    prefs = [NSUserDefaults standardUserDefaults];
    thisYear = [[[NSCalendar currentCalendar] components:kCFCalendarUnitYear fromDate:[NSDate date]] year];
    [self changeYear: thisYear];
    self.tblMain.delegate = self;
    self.tblMain.dataSource = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Handles change of year
- (void)changeYear:(int)newyear {
    tournamentYear = newyear;
    [_btnSelectYear setTitle:[NSString stringWithFormat:@"%i", tournamentYear] forState:UIControlStateNormal];
    tournamentList = [parseUSFirst parseEventList: tournamentYear];
    NSArray *tournament = [[tournamentList objectAtIndex:0] componentsSeparatedByString: @":"];
    tournamentCode = tournament[0];
    [_btnSelectTour setTitle:tournament[1] forState:UIControlStateNormal];
    NSLog(@"Year Changed: %i", tournamentYear);
}

// Button for selecting year
- (IBAction)btnSelectYear:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Year" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"", nil];
    for (int i = thisYear; i >= 2003; i--) {
        [actionSheet addButtonWithTitle:[NSString stringWithFormat:@"%i", i]];
    }
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
    actionSheetSender = 0;
}

// Button for selecting tournament
- (IBAction)btnSelectTour:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Tournament" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"", nil];
    for (NSString *tournament in tournamentList) {
        [actionSheet addButtonWithTitle:[tournament  componentsSeparatedByString: @":"][1]];
    }
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
    actionSheetSender = 1;
}

// Handles ActionSheet for both tournament and year
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0 || buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    if (actionSheetSender == 0) {
        [self changeYear: thisYear - buttonIndex];
    } else if (actionSheetSender == 1) {
        NSArray *tournament = [[tournamentList objectAtIndex:(buttonIndex-1)] componentsSeparatedByString: @":"];
        NSLog(@"tournament = %@", tournament);
        tournamentCode = tournament[0];
        tournamentName = tournament[1];
        NSLog(@"tournamentName = %@", tournamentName);
        [_btnSelectTour setTitle:tournament[1] forState:UIControlStateNormal];
        NSLog(@"Tournament Selected: %@", tournamentCode);
    }
}

// Button for importing using selected settings
- (IBAction)btnImport:(id)sender {
// Hack for now to only import to a tournament that is in the db. Note the problem with Alamo
    // and its weird name. Obviously, this need to be fixed.
    NSArray *data = [parseUSFirst parseMatchResultList:[NSString stringWithFormat:@"%i", tournamentYear] eventCode:tournamentCode matchType:(matchType == 0 ? @"qual" : @"elim")];
    if (data == nil) {
        displayData = nil;
        NSLog(@"Could not connect to website.");
    } else {
        displayData = data;
        BOOL tournExists = [self getTournament:tournamentName];
        NSString *matchTypeString = matchType == 0 ? @"Seeding" : @"Elimination";
        for (NSArray *row in data) {
            if (tournExists) {
                NSNumber *matchNumber = [NSNumber numberWithInt:[row[matchType + 1] intValue]];
                NSLog(@"match number = %@, type = %@", matchNumber, matchTypeString);
                NSNumber *red1 = [NSNumber numberWithInt:[row[matchType + 2] intValue]];
                NSNumber *red2 = [NSNumber numberWithInt:[row[matchType + 3] intValue]];
                NSNumber *red3 = [NSNumber numberWithInt:[row[matchType + 4] intValue]];
                NSNumber *blue1 = [NSNumber numberWithInt:[row[matchType + 5] intValue]];
                NSNumber *blue2 = [NSNumber numberWithInt:[row[matchType + 6] intValue]];
                NSNumber *blue3 = [NSNumber numberWithInt:[row[matchType + 7] intValue]];
                CreateMatch *matchObject = [CreateMatch new];
                matchObject.managedObjectContext = _dataManager.managedObjectContext;
                MatchData *match = [matchObject AddMatchObjectWithValidate:matchNumber
                                                                  forTeam1:red1
                                                                  forTeam2:red2
                                                                  forTeam3:red3
                                                                  forTeam4:blue1
                                                                  forTeam5:blue2
                                                                  forTeam6:blue3
                                                                  forMatch:matchTypeString
                                                             forTournament:tournamentName
                                                               forRedScore:[NSNumber numberWithInt:-1]
                                                              forBlueScore:[NSNumber numberWithInt:-1]];
                NSLog(@"Move from match list to create match");
                match.saved = [NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()];
                match.savedBy = [prefs objectForKey:@"deviceName"];
                if (match) {
                    NSError *error;
                    if (![_dataManager.managedObjectContext save:&error]) {
                        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                    }
                }
            }
            else {
                NSLog(@"%@ (%@,%@,%@ : %@,%@,%@)", row[matchType + 1], row[matchType + 2], row[matchType + 3], row[matchType + 4], row[matchType + 5], row[matchType + 6], row[matchType + 7]);
            }
        }
    }
    [_tblMain reloadData];
}

-(BOOL)getTournament:(NSString *)name {
    TournamentData *tournament;
    NSError *error;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"TournamentData" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"name CONTAINS %@", name];
    [fetchRequest setPredicate:pred];
    NSArray *tournamentData = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!tournamentData) {
        NSLog(@"Karma disruption error");
        return Nil;
    }
    else {
        if([tournamentData count] > 0) {  // Tournament Exists
            tournament = [tournamentData objectAtIndex:0];
            // NSLog(@"Tournament %@ exists", tournament.name);
            return YES;
        }
        else {
            return NO;
        }
    }
}

// Handles display of TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return displayData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    for (int i = 1; i <= 7; i++) {
        UILabel *label = (UILabel *)[cell viewWithTag:i * 10];
        label.text = [displayData objectAtIndex:indexPath.row][matchType + i];
    }
    return cell;
}

@end