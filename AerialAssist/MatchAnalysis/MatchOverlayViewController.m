//
//  MatchOverlayViewController.m
//  AerialAssist
//
//  Created by FRC on 3/14/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "MatchOverlayViewController.h"
#import "MatchData.h"
#import "TeamScore.h"
#import "FieldDrawing.h"
#import "CalculateTeamStats.h"
#import "DataManager.h"
#import "TeamData.h"

@interface MatchOverlayViewController ()
@end

@implementation MatchOverlayViewController{
    CalculateTeamStats *teamStats;
    NSString *tournamentName;
    NSUserDefaults *prefs;
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
    for (int i=0; i<[_matchList count]; i++) {
        TeamScore *score = [_matchList objectAtIndex:i];
        if ([score.results boolValue] && score.fieldDrawing.trace) {
            UIImageView *trace =[[UIImageView alloc] initWithFrame:CGRectMake(0,0,848,424)];
            trace.image = [UIImage imageWithData:score.fieldDrawing.trace];
            if ([score.allianceSection intValue] > 2) {
                trace.transform = CGAffineTransformMakeScale(-1, 1);
            }
            [self.view addSubview:trace];
        }
        
        
    }
    prefs = [NSUserDefaults standardUserDefaults];
    tournamentName = [prefs objectForKey:@"tournament"];
    if (tournamentName) {
        self.title =  [NSString stringWithFormat:@"%@ Match Overlay", tournamentName];
        
    }
    else {
        self.title = @"Match Overlay";
    }
    
    teamStats = [[CalculateTeamStats alloc] initWithDataManager:_dataManager];
    NSMutableDictionary *stats = [teamStats calculateMasonStats:_numberTeam forTournament:tournamentName];
    
    
    _teamHeader = [[UIView alloc] initWithFrame:CGRectMake(0,0,768,50)];
    _teamHeader.backgroundColor = [UIColor lightGrayColor];
    _teamHeader.opaque = YES;
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 50)];
	headerLabel.text = @"Header";
    headerLabel.backgroundColor = [UIColor clearColor];
    [_teamHeader addSubview:headerLabel];
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(120, 0, 200, 50)];
	label1.text = @"High Hot";
    label1.backgroundColor = [UIColor clearColor];
    [_teamHeader addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(230, 0, 200, 50)];
	label2.text = @"TeleOp High";
    label2.backgroundColor = [UIColor clearColor];
    [_teamHeader addSubview:label2];
    
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(360, 0, 200, 50)];
	label3.text = @"Truss Throw";
    label3.backgroundColor = [UIColor clearColor];
    [_teamHeader addSubview:label3];
    
    UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(480, 0, 200, 50)];
	label4.text = @"Speed";
    label4.backgroundColor = [UIColor clearColor];
    [_teamHeader addSubview:label4];
    
    UILabel *lable5 = [[UILabel alloc] initWithFrame:CGRectMake(560, 0, 200, 50)];
	lable5.text = @"Drive";
    lable5.backgroundColor = [UIColor clearColor];
    [_teamHeader addSubview:lable5];
    
    UILabel *label6 = [[UILabel alloc] initWithFrame:CGRectMake(650, 0, 200, 50)];
	label6.text = @"Bully";
    label6.backgroundColor = [UIColor clearColor];
    [_teamHeader addSubview:label6];
    
    UILabel *label7 = [[UILabel alloc] initWithFrame:CGRectMake(740, 0, 200, 50)];
	label7.text = @"Block";
    label7.backgroundColor = [UIColor clearColor];
    [_teamHeader addSubview:label7];
    
    UILabel *label8 = [[UILabel alloc] initWithFrame:CGRectMake(820, 0, 200, 50)];
	label8.text = @"Floor Pass";
    label8.backgroundColor = [UIColor clearColor];
    [_teamHeader addSubview:label8];
    
    NSLog(@"%@", stats);
    NSLog(@"%@", tournamentName);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return _teamHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections DONT CHANGE!!!.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Temp"];
    return cell;
}

- (void)configureScoreCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
