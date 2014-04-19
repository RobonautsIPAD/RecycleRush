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
#import "MatchData.h"
#import "MatchDataInterfaces.h"

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
    NSArray *tourData; // data of the selected tournament (code, name)
    int matchType; // selected match type
    NSMutableArray *displayData; // data to be displayed in the TableView
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
    NSLog(@"tournamentList = %@", tournamentList);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Handles change of tournament
- (void)changeTour:(int)index {
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
    NSArray *data = [parseUSFirst parseMatchResultList:[NSString stringWithFormat:@"%i", thisYear] eventCode:tourData[0] matchType:(matchType == 0 ? @"qual" : @"elim")];
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
        for (NSArray *row in data) {
            NSMutableArray *newrow = [NSMutableArray arrayWithArray:row];
            for (int i = 1; i <= 7; i++) {
                newrow[matchType + i] = [NSNumber numberWithInt:[row[matchType + i] intValue]];
            }
            [displayData addObject:newrow];
        }
    }
    [_tblMain reloadData];
}

// Saves the retrieved data to the database
- (IBAction)btnSave:(id)sender {
    if (displayData == nil) return;
    NSArray *teamKeys = [NSArray arrayWithObjects:@"Red 1", @"Red 2", @"Red 3", @"Blue 1", @"Blue 2", @"Blue 3", nil];
    NSArray *matchKeys = [NSArray arrayWithObjects:@"number", @"tournamentName", @"matchType", @"teams", nil];
    for (NSArray *row in displayData) {
        if ([row[matchType + 2] intValue] == 0 && [row[matchType + 3] intValue] == 0 && [row[matchType + 4] intValue] == 0 &&
            [row[matchType + 5] intValue] == 0 && [row[matchType + 6] intValue] == 0 && [row[matchType + 7] intValue] == 0) continue;
        NSArray *teamVals = [NSArray arrayWithObjects:row[matchType + 2], row[matchType + 3], row[matchType + 4],
                             row[matchType + 5], row[matchType + 6], row[matchType + 7], nil];
        NSDictionary *teams = [NSDictionary dictionaryWithObjects:teamVals forKeys:teamKeys];
        NSArray *matchVals = [NSArray arrayWithObjects:row[matchType + 1], tourData[1], matchType == 0 ? @"Seeding" : @"Elimination", teams, nil];
        
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:matchVals forKeys:matchKeys];
        MatchDataInterfaces *matchDataPackage = [[MatchDataInterfaces alloc] initWithDataManager:_dataManager];
        MatchData *match = [matchDataPackage updateMatch:dictionary];
        NSLog(@"%@", match);
    }
}

// Handles display of TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return displayData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    for (int i = 1; i <= 7; i++) {
        UILabel *label = (UILabel *)[cell viewWithTag:i * 10];
        label.text = [NSString stringWithFormat:@"%@", [displayData objectAtIndex:indexPath.row][matchType + i]];
    }
    return cell;
}

@end
