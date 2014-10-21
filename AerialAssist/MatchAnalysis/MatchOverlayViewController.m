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

@implementation MatchOverlayViewController {
    CalculateTeamStats *teamStats;
    NSMutableDictionary *stats;
    NSString *tournamentName;
    NSUserDefaults *prefs;
    NSMutableArray *matchViews;
    NSMutableArray *matchButtons;
    UIView *teamHeader;
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
    prefs = [NSUserDefaults standardUserDefaults];
    tournamentName = [prefs objectForKey:@"tournament"];
    if (tournamentName) {
        self.title =  [NSString stringWithFormat:@"%@ %d Match Overlay", tournamentName, [_numberTeam.number intValue]];
        
    }
    else {
        self.title = @"Match Overlay";
    }

    matchViews = [[NSMutableArray alloc] init];
    matchButtons = [[NSMutableArray alloc] init];
    UILabel *mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(890,15,104,24)];
    mainLabel.text = @"Matches";
    mainLabel.textColor = [UIColor greenColor];
    mainLabel.textColor = [UIColor colorWithRed:1.0 green:190.0/255 blue:0.0 alpha:1];
    mainLabel.backgroundColor = [UIColor clearColor];
    mainLabel.font = [UIFont systemFontOfSize:24.0];
    [self.view addSubview:mainLabel];
    CGFloat yPos = 50;
    NSUInteger count = 0;
    for (TeamScore *score in _matchList) {
        if ([score.results boolValue] && score.fieldDrawing.trace) {
            UIImageView *trace =[[UIImageView alloc] initWithFrame:CGRectMake(0,0,848,424)];
            trace.image = [UIImage imageWithData:score.fieldDrawing.trace];
            if ([score.allianceStation intValue] > 2) {
                trace.transform = CGAffineTransformMakeScale(-1, 1);
            }
            [self.view addSubview:trace];
            [matchViews addObject:trace];
//            NSString *labelText = [NSString stringWithFormat:@"%@ %@", [score.match.matchType substringToIndex:4], score.match.number];
//            NSLog(@"%@", labelText);
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(915,yPos,84,24)];
//            label.text = labelText;
            label.textColor = [UIColor colorWithRed:1.0 green:190.0/255 blue:0.0 alpha:1];
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont boldSystemFontOfSize:18.0];
            [self.view addSubview:label];
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(875,yPos+2,20,20)];
            [button setSelected:YES];
            [button addTarget:self action:@selector(toggleButton:) forControlEvents:UIControlEventTouchUpInside];
            [button setTag:count];
            [self setRadioButtonState:button forState:YES];
            [self.view addSubview:button];
            yPos += 25;
            count++;
        }
    }
    
    teamStats = [[CalculateTeamStats alloc] initWithDataManager:_dataManager];
    stats = [teamStats calculateMasonStats:_numberTeam forTournament:tournamentName];
    
    teamHeader = [[UIView alloc] initWithFrame:CGRectMake(0,0,768,50)];
    teamHeader.backgroundColor = [UIColor lightGrayColor];
    teamHeader.opaque = YES;
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 50)];
	headerLabel.text = @"Header";
    headerLabel.backgroundColor = [UIColor clearColor];
    [teamHeader addSubview:headerLabel];
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(120, 0, 200, 50)];
	label1.text = @"High Hot";
    label1.backgroundColor = [UIColor clearColor];
    [teamHeader addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(230, 0, 200, 50)];
	label2.text = @"TeleOp High";
    label2.backgroundColor = [UIColor clearColor];
    [teamHeader addSubview:label2];
    
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(360, 0, 200, 50)];
	label3.text = @"Truss Throw";
    label3.backgroundColor = [UIColor clearColor];
    [teamHeader addSubview:label3];
    
    UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(480, 0, 200, 50)];
	label4.text = @"Speed";
    label4.backgroundColor = [UIColor clearColor];
    [teamHeader addSubview:label4];
    
    UILabel *lable5 = [[UILabel alloc] initWithFrame:CGRectMake(560, 0, 200, 50)];
	lable5.text = @"Drive";
    lable5.backgroundColor = [UIColor clearColor];
    [teamHeader addSubview:lable5];
    
    UILabel *label6 = [[UILabel alloc] initWithFrame:CGRectMake(650, 0, 200, 50)];
	label6.text = @"Bully";
    label6.backgroundColor = [UIColor clearColor];
    [teamHeader addSubview:label6];
    
    UILabel *label7 = [[UILabel alloc] initWithFrame:CGRectMake(740, 0, 200, 50)];
	label7.text = @"Block";
    label7.backgroundColor = [UIColor clearColor];
    [teamHeader addSubview:label7];
    
    UILabel *label8 = [[UILabel alloc] initWithFrame:CGRectMake(820, 0, 200, 50)];
	label8.text = @"Floor Pass";
    label8.backgroundColor = [UIColor clearColor];
    [teamHeader addSubview:label8];
}

-(void)setRadioButtonState:(UIButton *)button forState:(BOOL)selection {
    if (selection == 0) {
        [button setImage:[UIImage imageNamed:@"RadioButton-Unselected.png"] forState:UIControlStateNormal];
    }
    else {
        [button setImage:[UIImage imageNamed:@"RadioButton-Selected.png"] forState:UIControlStateNormal];
    }
}

-(IBAction)toggleButton:(id)sender {
    UIButton * pressedButton = (UIButton*)sender;

    NSUInteger which = pressedButton.tag;
    if ([pressedButton isSelected]) {
        [self setRadioButtonState:pressedButton forState:NO];
        [pressedButton setSelected:NO];
        [[matchViews objectAtIndex:which] setHidden:YES];
    }
    else {
        [self setRadioButtonState:pressedButton forState:YES];
        [pressedButton setSelected:YES];
        [[matchViews objectAtIndex:which] setHidden:NO];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Temp"];
    
    if (indexPath.row == 0) {
        UILabel *label1 = (UILabel *)[cell viewWithTag:10];
        label1.text = @"";
        UILabel *label2 = (UILabel *)[cell viewWithTag:20];
        label2.text = @"HP Intake";
        label2.font = [UIFont boldSystemFontOfSize:16.0];
        UILabel *label3 = (UILabel *)[cell viewWithTag:30];
        label3.text = @"High Hot";
        label3.font = [UIFont boldSystemFontOfSize:16.0];
        UILabel *label4 = (UILabel *)[cell viewWithTag:40];
        label4.text = @"High";
        label4.font = [UIFont boldSystemFontOfSize:16.0];
        UILabel *label5 = (UILabel *)[cell viewWithTag:50];
        label5.text = @"HP Truss";
        label5.font = [UIFont boldSystemFontOfSize:16.0];
        UILabel *label6 = (UILabel *)[cell viewWithTag:60];
        label6.text = @"Bot Intake";
        label6.font = [UIFont boldSystemFontOfSize:16.0];
        UILabel *label7 = (UILabel *)[cell viewWithTag:70];
        label7.text = @"Truss";
        label7.font = [UIFont boldSystemFontOfSize:16.0];
        UILabel *label8 = (UILabel *)[cell viewWithTag:80];
        label8.text = @"Catch";
        label8.font = [UIFont boldSystemFontOfSize:16.0];
        UILabel *label9 = (UILabel *)[cell viewWithTag:90];
        label9.text = @"Low";
        label9.font = [UIFont boldSystemFontOfSize:16.0];
        UILabel *label10 = (UILabel *)[cell viewWithTag:100];
        label10.text = @"Pass";
        label10.font = [UIFont boldSystemFontOfSize:16.0];
    } else if (indexPath.row == 1) {
        UILabel *label1 = (UILabel *)[cell viewWithTag:10];
        label1.text = @"Total";
        label1.font = [UIFont boldSystemFontOfSize:16.0];
        UILabel *label2 = (UILabel *)[cell viewWithTag:20];
        label2.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"IntakefromHuman"] objectForKey:@"total"] floatValue]];
        UILabel *label3 = (UILabel *)[cell viewWithTag:30];
        label3.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"HighHot"] objectForKey:@"total"] floatValue]];
        UILabel *label4 = (UILabel *)[cell viewWithTag:40];
        label4.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"High"] objectForKey:@"total"] floatValue]];
        UILabel *label5 = (UILabel *)[cell viewWithTag:50];
        label5.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"HPTruss"] objectForKey:@"total"] floatValue]];
        UILabel *label6 = (UILabel *)[cell viewWithTag:60];
        label6.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"IntakefromRobot"] objectForKey:@"total"] floatValue]];
        UILabel *label7 = (UILabel *)[cell viewWithTag:70];
        label7.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"TrussThrow"] objectForKey:@"total"] floatValue]];
        UILabel *label8 = (UILabel *)[cell viewWithTag:80];
        label8.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"TrussCatch"] objectForKey:@"total"] floatValue]];
        UILabel *label9 = (UILabel *)[cell viewWithTag:90];
        label9.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"Low"] objectForKey:@"total"] floatValue]];
        UILabel *label10 = (UILabel *)[cell viewWithTag:100];
        label10.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"Pass"] objectForKey:@"total"] floatValue]];
    } else if (indexPath.row == 2) {
        UILabel *label1 = (UILabel *)[cell viewWithTag:10];
        label1.text = @"Average";
        label1.font = [UIFont boldSystemFontOfSize:16.0];
        UILabel *label2 = (UILabel *)[cell viewWithTag:20];
        label2.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"IntakefromHuman"] objectForKey:@"average"] floatValue]];
        UILabel *label3 = (UILabel *)[cell viewWithTag:30];
        label3.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"HighHot"] objectForKey:@"average"] floatValue]];
        UILabel *label4 = (UILabel *)[cell viewWithTag:40];
        label4.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"High"] objectForKey:@"average"] floatValue]];
        UILabel *label5 = (UILabel *)[cell viewWithTag:50];
        label5.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"HPTruss"] objectForKey:@"average"] floatValue]];
        UILabel *label6 = (UILabel *)[cell viewWithTag:60];
        label6.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"IntakefromRobot"] objectForKey:@"average"] floatValue]];
        UILabel *label7 = (UILabel *)[cell viewWithTag:70];
        label7.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"TrussThrow"] objectForKey:@"average"] floatValue]];
        UILabel *label8 = (UILabel *)[cell viewWithTag:80];
        label8.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"TrussCatch"] objectForKey:@"average"] floatValue]];
        UILabel *label9 = (UILabel *)[cell viewWithTag:90];
        label9.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"Low"] objectForKey:@"average"] floatValue]];
        UILabel *label10 = (UILabel *)[cell viewWithTag:100];
        label10.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"Pass"] objectForKey:@"average"] floatValue]];
    } else if (indexPath.row == 3) {
        UILabel *label1 = (UILabel *)[cell viewWithTag:10];
        label1.text = @"Percent";
        label1.font = [UIFont boldSystemFontOfSize:16.0];
        UILabel *label2 = (UILabel *)[cell viewWithTag:20];
        label2.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"IntakefromHuman"] objectForKey:@"percent"] floatValue]*100];
        UILabel *label3 = (UILabel *)[cell viewWithTag:30];
        label3.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"HighHot"] objectForKey:@"percent"] floatValue]*100];
        UILabel *label4 = (UILabel *)[cell viewWithTag:40];
        label4.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"High"] objectForKey:@"percent"] floatValue]*100];
        UILabel *label5 = (UILabel *)[cell viewWithTag:50];
        label5.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"HPTruss"] objectForKey:@"percent"] floatValue]*100];
        UILabel *label6 = (UILabel *)[cell viewWithTag:60];
        label6.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"IntakefromRobot"] objectForKey:@"percent"] floatValue]*100];
        UILabel *label7 = (UILabel *)[cell viewWithTag:70];
        label7.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"TrussThrow"] objectForKey:@"percent"] floatValue]*100];
        UILabel *label8 = (UILabel *)[cell viewWithTag:80];
        label8.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"TrussCatch"] objectForKey:@"percent"] floatValue]*100];
        UILabel *label9 = (UILabel *)[cell viewWithTag:90];
        label9.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"Low"] objectForKey:@"percent"] floatValue]*100];
        UILabel *label10 = (UILabel *)[cell viewWithTag:100];
        label10.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"Pass"] objectForKey:@"percent"] floatValue]*100];
    } else if (indexPath.row == 4) {
        UILabel *label1 = (UILabel *)[cell viewWithTag:10];
        label1.text = @"";
        UILabel *label2 = (UILabel *)[cell viewWithTag:20];
        label2.text = @"High Cold";
        label2.font = [UIFont boldSystemFontOfSize:16.0];
        UILabel *label3 = (UILabel *)[cell viewWithTag:30];
        label3.text = @"Knockout";
        label3.font = [UIFont boldSystemFontOfSize:16.0];
        UILabel *label4 = (UILabel *)[cell viewWithTag:40];
        label4.text = @"Pickup";
        label4.font = [UIFont boldSystemFontOfSize:16.0];
        UILabel *label5 = (UILabel *)[cell viewWithTag:50];
        label5.text = @"Block";
        label5.font = [UIFont boldSystemFontOfSize:16.0];
        UILabel *label6 = (UILabel *)[cell viewWithTag:60];
        label6.text = @"Foul";
        label6.font = [UIFont boldSystemFontOfSize:16.0];
        UILabel *label7 = (UILabel *)[cell viewWithTag:70];
        label7.text = @"Mobility";
        label7.font = [UIFont boldSystemFontOfSize:16.0];
        UILabel *label8 = (UILabel *)[cell viewWithTag:80];
        label8.text = @"Driver";
        label8.font = [UIFont boldSystemFontOfSize:16.0];
        UILabel *label9 = (UILabel *)[cell viewWithTag:90];
        label9.text = @"Bully";
        label9.font = [UIFont boldSystemFontOfSize:16.0];
        UILabel *label10 = (UILabel *)[cell viewWithTag:100];
        label10.text = @"Block";
        label10.font = [UIFont boldSystemFontOfSize:16.0];
    } else if (indexPath.row == 5) {
        UILabel *label1 = (UILabel *)[cell viewWithTag:10];
        label1.text = @"Total";
        label1.font = [UIFont boldSystemFontOfSize:16.0];
        UILabel *label2 = (UILabel *)[cell viewWithTag:20];
        label2.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"HighCold"] objectForKey:@"total"] floatValue]];
        UILabel *label3 = (UILabel *)[cell viewWithTag:30];
        label3.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"Knockout"] objectForKey:@"total"] floatValue]];
        UILabel *label4 = (UILabel *)[cell viewWithTag:40];
        label4.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"Pickup"] objectForKey:@"total"] floatValue]];
        UILabel *label5 = (UILabel *)[cell viewWithTag:50];
        label5.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"Block"] objectForKey:@"total"] floatValue]];
        UILabel *label6 = (UILabel *)[cell viewWithTag:60];
        label6.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"Foul"] objectForKey:@"total"] floatValue]];
        UILabel *label7 = (UILabel *)[cell viewWithTag:70];
        label7.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"Mobility"] objectForKey:@"total"] floatValue]];
        UILabel *label8 = (UILabel *)[cell viewWithTag:80];
        label8.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"DriverSkill"] objectForKey:@"total"] floatValue]];
        UILabel *label9 = (UILabel *)[cell viewWithTag:90];
        label9.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"BullySkill"] objectForKey:@"total"] floatValue]];
        UILabel *label10 = (UILabel *)[cell viewWithTag:100];
        label10.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"BlockSkill"] objectForKey:@"total"] floatValue]];
    } else if (indexPath.row == 6) {
        UILabel *label1 = (UILabel *)[cell viewWithTag:10];
        label1.text = @"Average";
        label1.font = [UIFont boldSystemFontOfSize:16.0];
        UILabel *label2 = (UILabel *)[cell viewWithTag:20];
        label2.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"HighCold"] objectForKey:@"average"] floatValue]];
        UILabel *label3 = (UILabel *)[cell viewWithTag:30];
        label3.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"Knockout"] objectForKey:@"average"] floatValue]];
        UILabel *label4 = (UILabel *)[cell viewWithTag:40];
        label4.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"Pickup"] objectForKey:@"average"] floatValue]];
        UILabel *label5 = (UILabel *)[cell viewWithTag:50];
        label5.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"Block"] objectForKey:@"average"] floatValue]];
        UILabel *label6 = (UILabel *)[cell viewWithTag:60];
        label6.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"Foul"] objectForKey:@"average"] floatValue]];
        UILabel *label7 = (UILabel *)[cell viewWithTag:70];
        label7.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"Mobility"] objectForKey:@"average"] floatValue]];
        UILabel *label8 = (UILabel *)[cell viewWithTag:80];
        label8.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"DriverSkill"] objectForKey:@"average"] floatValue]];
        UILabel *label9 = (UILabel *)[cell viewWithTag:90];
        label9.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"BullySkill"] objectForKey:@"average"] floatValue]];
        UILabel *label10 = (UILabel *)[cell viewWithTag:100];
        label10.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"BlockSkill"] objectForKey:@"average"] floatValue]];
    }
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
