//
//  MatchAnalysisViewController.m
// Robonauts Scouting
//
//  Created by FRC on 2/15/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "MatchAnalysisViewController.h"
#import "FieldDrawingViewController.h"
#import "DataManager.h"
#import "TeamData.h"
#import "TeamDataInterfaces.h"
#import "TournamentData.h"
#import "CreateMatch.h"
#import "MatchData.h"
#import "TeamScore.h"

@interface MatchAnalysisViewController ()
    @property  (nonatomic, weak) IBOutlet UITableView *matchesTable;
@end


@implementation MatchAnalysisViewController{
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSMutableArray *teamList;
    NSArray *matchList;
    TeamData *team;
}
@synthesize dataManager = _dataManager;
@synthesize mainLogo = _mainLogo;
@synthesize matchPicture = _matchPicture;
@synthesize splashPicture = _splashPicture;
@synthesize pictureCaption = _pictureCaption;

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
    NSLog(@"Set-Up Page");
    // Display the Robotnauts Banner
    [_mainLogo setImage:[UIImage imageNamed:@"robonauts app banner.jpg"]];
    // Display the Label for the Picture
    _pictureCaption.font = [UIFont fontWithName:@"Nasalization" size:24.0];
    _pictureCaption.text = @"Just Hangin' Out";
    
    prefs = [NSUserDefaults standardUserDefaults];
    tournamentName = [prefs objectForKey:@"tournament"];
    if (tournamentName) {
        self.title = tournamentName;
    }
    
    matchList = [[[CreateMatch alloc] initWithDataManager:_dataManager] getMatchListTournament:[NSNumber numberWithInt:118] forTournament:tournamentName];
    NSLog(@"Printing Matchlist");
    NSLog(@"%@", matchList);
    
    self.title = @"Match Analysis";
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Segue occurs when the user selects a match out of the match list table. Receiving
    //  VC is the FieldDrawing VC.
    NSIndexPath *indexPath = [self.matchesTable indexPathForCell:sender];
    [segue.destinationViewController setDataManager:_dataManager];
    [_matchesTable deselectRowAtIndexPath:indexPath animated:YES];
}
-(NSInteger)numberOfRowsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        return [matchList count];
}

- (void)configureMatchCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    TeamScore *score = [matchList objectAtIndex:indexPath.row];
    
	UILabel *label1 = (UILabel *)[cell viewWithTag:10];
	label1.text = [NSString stringWithFormat:@"%d", [score.match.number intValue]];
    
    UILabel *label2 = (UILabel *)[cell viewWithTag:20];
	label2.text = score.match.matchType;
    
    UILabel *label3 = (UILabel *)[cell viewWithTag:30];
    label3.text = @"";
    

    //    if ([score.saved intValue] || [score.synced intValue]) label3.text = @"Y";
    //    else label3.text = @"N";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        NSLog(@"Filling Cell");
        UITableViewCell *cell = nil;
        cell = [tableView dequeueReusableCellWithIdentifier:@"MatchSchedule"];
        // Set up the cell...
        [self configureMatchCell:cell atIndexPath:indexPath];
    
    return cell;
}

/*
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            _mainLogo.frame = CGRectMake(-20, 0, 285, 960);
            [_mainLogo setImage:[UIImage imageNamed:@"robonauts app banner.jpg"]];
            _masonPageButton.frame = CGRectMake(325, 125, 400, 68);
            _lucienPageButton.frame = CGRectMake(325, 225, 400, 68);
            _splashPicture.frame = CGRectMake(293, 563, 468, 330);
            _pictureCaption.frame = CGRectMake(293, 901, 468, 39);
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            _mainLogo.frame = CGRectMake(0, -60, 1024, 255);
            [_mainLogo setImage:[UIImage imageNamed:@"robonauts app banner original.jpg"]];
            _masonPageButton.frame = CGRectMake(550, 225, 400, 68);
            _lucienPageButton.frame = CGRectMake(550, 325, 400, 68);
            _splashPicture.frame = CGRectMake(50, 243, 468, 330);
            _pictureCaption.frame = CGRectMake(50, 581, 468, 39);
            break;
        default:
            break;
    }
    // Return YES for supported orientations
	return YES;
} */

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
