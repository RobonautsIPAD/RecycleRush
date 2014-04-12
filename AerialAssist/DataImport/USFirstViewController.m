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
    NSArray *displayData; // data to be displayed in the TableView
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
    thisYear = 2014;
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
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Tournament" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
    for (NSString *tournament in tournamentList) {
        [actionSheet addButtonWithTitle:[tournament componentsSeparatedByString: @":"][1]];
    }
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}

// Handles ActionSheet for both tournament and year
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    [self changeTour:buttonIndex - 1];
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
        NSLog(@"Could not connect to website.");
    } else {
        displayData = data;
    }
    [_tblMain reloadData];
}

// Saves the retrieved data to the database
- (IBAction)btnSave:(id)sender {
    NSString *matchTypeString = matchType == 0 ? @"Seeding" : @"Elimination";
    for (NSArray *row in displayData) {
        /*
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
                                                     forTournament:tourData[1]
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
        */
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
