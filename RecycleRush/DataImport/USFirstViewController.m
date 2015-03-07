//
//  USFirstViewController.m
//  RecycleRush
//
//  Created by Kylor Wang on 4/2/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "USFirstViewController.h"
#import "parseUSFirst.h"
#import "TournamentData.h"
#import "DataManager.h"
#import "MatchData.h"
#import "MatchUtilities.h"

@interface USFirstViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tblMain;
@property (strong, nonatomic) IBOutlet UIButton *btnSelectTour;
@property (strong, nonatomic) IBOutlet UISegmentedControl *sgmType;
@property (strong, nonatomic) IBOutlet UIButton *btnGet;

@end

@implementation USFirstViewController {
    NSUserDefaults *prefs;
    int thisYear; // current year
    NSMutableArray *tournamentList; // list of all tournaments
    NSString *deviceName;
    NSArray *tourData; // data of the selected tournament (code, name)
    int matchType; // selected match type
    NSMutableArray *displayData; // data to be displayed in the TableView
    MatchUtilities *matchUtilities;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    prefs = [NSUserDefaults standardUserDefaults];
    thisYear = [[prefs objectForKey:@"year"] intValue];
    deviceName = [prefs objectForKey:@"deviceName"];
    self.tblMain.delegate = self;
    self.tblMain.dataSource = self;
    
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TournamentData" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *tournamentSort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:tournamentSort]];
    NSArray *tournamentData = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!tournamentData) {
        NSLog(@"Karma disruption error");
        tournamentList = nil;
    } else {
        tournamentList = [NSMutableArray array];
        for (TournamentData *t in tournamentData) {
            if ([t.code isEqualToString:@""]) continue;
            [tournamentList addObject:[NSString stringWithFormat:@"%@:%@", t.code, t.name]];
            if ([t.name isEqualToString:[prefs objectForKey:@"tournament"]]) {
                [self changeTour:[tournamentList count] - 1];
            }
        }
    }
    matchUtilities = [[MatchUtilities alloc] init:_dataManager];
    NSLog(@"tournamentList = %@", tournamentList);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Handles change of tournament
- (void)changeTour:(NSInteger)index {
    tourData = [[tournamentList objectAtIndex:index] componentsSeparatedByString: @":"];
    NSLog(@"tourData = %@", tourData);
    [_btnSelectTour setTitle:tourData[1] forState:UIControlStateNormal];
}

// Button for selecting tournament
- (IBAction)btnSelectTour:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Tournament" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    for (NSString *tournament in tournamentList) {
        [actionSheet addButtonWithTitle:[tournament componentsSeparatedByString: @":"][1]];
    }
    [actionSheet addButtonWithTitle:@"Cancel"];
    [actionSheet setCancelButtonIndex:[tournamentList count]];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}

// Handles ActionSheet for both tournament and year
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) return;
    [self changeTour:buttonIndex];
}

// Update match type when SegmentedControl changes
- (IBAction)sgmType:(id)sender {
    matchType = _sgmType.selectedSegmentIndex;
}

// Gets the match data and display it in the TableView
- (IBAction)btnGet:(id)sender {
    NSArray *data = [parseUSFirst parseMatchResultList:[NSString stringWithFormat:@"%i", thisYear] eventCode:tourData[0] matchType:(matchType == 0 ? @"qualifications" : @"playoffs")];
    if (data == nil) {
        displayData = nil;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Cannot connect to the website"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        displayData = [NSMutableArray array];
        for (int line=0; line<[data count]; line+=14) {
            NSMutableArray *newrow = [NSMutableArray array];
            for (int i = 0; i < 14; i++) {
                if (i==1) continue;
                NSString *row = [data objectAtIndex:line+i];
                NSString *newString = [[row componentsSeparatedByCharactersInSet:
                                        [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                                       componentsJoinedByString:@""];
                [newrow addObject:newString];
            }
            [displayData addObject:newrow];
        }
    }
    [_tblMain reloadData];
}


-(NSMutableArray *)buildTeamList:(NSString *)alliance forTeam:(NSString *)teamNumber forTeamList:(NSMutableArray *)teamList {
    NSDictionary *teamDictionary = [matchUtilities teamDictionary:alliance forTeam:teamNumber];
    if (teamDictionary) [teamList addObject:teamDictionary];
    return teamList;
}

// Saves the retrieved data to the database
- (IBAction)btnSave:(id)sender {
    if (displayData == nil) return;
    for (NSArray *row in displayData) {
        if ([[row objectAtIndex:1] intValue] == 0 && [[row objectAtIndex:2] intValue] == 0 && [[row objectAtIndex:3] intValue] == 0 &&
            [[row objectAtIndex:4] intValue] == 0 && [[row objectAtIndex:5] intValue] == 0 && [[row objectAtIndex:6] intValue] == 0) continue;
        NSMutableArray *teamList = [[NSMutableArray alloc] init];
        teamList = [self buildTeamList:@"Red 1" forTeam:[row objectAtIndex:1] forTeamList:teamList];
        teamList = [self buildTeamList:@"Red 2" forTeam:[row objectAtIndex:2] forTeamList:teamList];
        teamList = [self buildTeamList:@"Red 3" forTeam:[row objectAtIndex:3] forTeamList:teamList];
        teamList = [self buildTeamList:@"Blue 1" forTeam:[row objectAtIndex:4] forTeamList:teamList];
        teamList = [self buildTeamList:@"Blue 2" forTeam:[row objectAtIndex:5] forTeamList:teamList];
        teamList = [self buildTeamList:@"Blue 3" forTeam:[row objectAtIndex:6] forTeamList:teamList];
        NSError *error = nil;
        MatchData *newMatch = [matchUtilities addMatch:[NSNumber numberWithInt:[[row objectAtIndex:0] intValue]] forMatchType:matchType == 0 ? @"Qualification" : @"Elimination" forTeams:teamList forTournament:tourData[1] error:&error];
        newMatch.saved = [NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()];
        newMatch.savedBy = deviceName;
        [_dataManager saveContext];
    }
}

// Handles display of TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return displayData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSArray *row = [displayData objectAtIndex:indexPath.row];
    for (int i = 0; i < 7; i++) {
        UILabel *label = (UILabel *)[cell viewWithTag:(i+1) * 10];
        label.text = [NSString stringWithFormat:@"%@", [row objectAtIndex:i]];
    }
    return cell;
}

@end
