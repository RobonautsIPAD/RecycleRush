//
//  USFirstViewController.m
//  AerialAssist
//
//  Created by Kylor Wang on 4/2/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "USFirstViewController.h"
#import "parseUSFirst.h"

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
    NSArray *tournamentList;
    int tournamentYear;
    NSString *tournamentCode;
    int matchType;
    NSArray *displayData;
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
    thisYear = [[[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:[NSDate date]] year];
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
        NSArray *tournament = [[tournamentList objectAtIndex: buttonIndex] componentsSeparatedByString: @":"];
        tournamentCode = tournament[0];
        [_btnSelectTour setTitle:tournament[1] forState:UIControlStateNormal];
        NSLog(@"Tournament Selected: %@", tournamentCode);
    }
}

// Button for importing using selected settings
- (IBAction)btnImport:(id)sender {
    matchType = _sgmType.selectedSegmentIndex;
    NSArray *data = [parseUSFirst parseMatchResultList:[NSString stringWithFormat:@"%i", tournamentYear] eventCode:tournamentCode matchType:(matchType == 0 ? @"qual" : @"elim")];
    if (data == nil) {
        displayData = nil;
        NSLog(@"Could not connect to website.");
    } else {
        displayData = data;
        for (NSArray *row in data) {
            NSLog(@"%@ (%@,%@,%@ : %@,%@,%@)", row[matchType + 1], row[matchType + 2], row[matchType + 3], row[matchType + 4], row[matchType + 5], row[matchType + 6], row[matchType + 7]);
        }
    }
    [_tblMain reloadData];
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
