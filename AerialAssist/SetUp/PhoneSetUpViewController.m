//
//  PhoneSetUpViewController.m
//  AerialAssist
//
//  Created by FRC on 2/15/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "PhoneSetUpViewController.h"
#import "DataManager.h"
#import "TournamentData.h"

@interface PhoneSetUpViewController ()
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *tournamentLabel;
@property (nonatomic, weak) IBOutlet UIButton *tournamentButton;
@property (nonatomic, weak) IBOutlet UISegmentedControl *bluetoothSegment;

@end

@implementation PhoneSetUpViewController {
    NSUserDefaults *prefs;
    NSMutableArray *tournamentList;
    NSString *gameName;
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
        _dataManager = [DataManager new];
    }
    prefs = [NSUserDefaults standardUserDefaults];
    gameName = [prefs objectForKey:@"gameName"];
    
    _titleLabel.font = [UIFont fontWithName:@"Nasalization" size:14.0];
    _titleLabel.text = [NSString stringWithFormat:@"%@ Set-Up", gameName];

    // Set Font and Text for Tournament Set-Up Button
    [_tournamentButton setTitle:[prefs objectForKey:@"tournament"] forState:UIControlStateNormal];
    _tournamentButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:14.0];

    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TournamentData" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *tournamentSort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:tournamentSort]];
    NSArray *tournamentData = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!tournamentData) {
        NSLog(@"Karma disruption error");
        tournamentList = nil;
    }
    else {
        TournamentData *t;
        tournamentList = [NSMutableArray array];
        for (int i=0; i < [tournamentData count]; i++) {
            t = [tournamentData objectAtIndex:i];
            NSLog(@"Tournament %@ exists", t.name);
            [tournamentList addObject:t.name];
        }
    }
    NSLog(@"Tournament List = %@", tournamentList);

    // Set Bluetooth segment
    if ([[prefs objectForKey:@"bluetooth"] intValue] == Scouter) {
        _bluetoothSegment.selectedSegmentIndex = Scouter;
    }
    else {
        _bluetoothSegment.selectedSegmentIndex = Master;
    }
}

- (IBAction)tournamentSelection:(id)sender {
    NSLog(@"Tournament Button");
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Tournament" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
    for (NSString *tournament in tournamentList) {
        [actionSheet addButtonWithTitle:tournament];
    }
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *newTournament = [tournamentList objectAtIndex:(buttonIndex-1)];
    [_tournamentButton setTitle:newTournament forState:UIControlStateNormal];
    [prefs setObject:newTournament forKey:@"tournament"];
}

- (IBAction)bluetoothSelectionChanged:(id)sender {
    NSLog(@"Bluetooth selection change");
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    int current;
    current = segmentedControl.selectedSegmentIndex;
    
    if (current == 0) {
        [prefs setObject:[NSNumber numberWithInt:Scouter] forKey:@"bluetooth"];
    }
    else {
        [prefs setObject:[NSNumber numberWithInt:Master] forKey:@"bluetooth"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
