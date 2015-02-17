//
//  AlliancesViewController.m
//  RecycleRush
//
//  Created by FRC on 11/4/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "AlliancesViewController.h"
#import "DataManager.h"
#import "TeamAccessors.h"
#import "EnumerationDictionary.h"
#import "MatchData.h"
#import "MatchUtilities.h"
#import "LNNumberpad.h"

@interface AlliancesViewController ()
    @property (nonatomic, weak) IBOutlet UITextField *alliance1Captain;
    @property (nonatomic, weak) IBOutlet UITextField *alliance1Pick1;
    @property (nonatomic, weak) IBOutlet UITextField *alliance1Pick2;
    @property (nonatomic, weak) IBOutlet UITextField *alliance1Pick3;
    @property (nonatomic, weak) IBOutlet UIButton *alliance1MatchButton;
@property (nonatomic, weak) IBOutlet UILabel *match4Red1;
@property (nonatomic, weak) IBOutlet UILabel *match4Red2;
@property (nonatomic, weak) IBOutlet UILabel *match4Red3;
@property (nonatomic, weak) IBOutlet UILabel *match4Red4;
@property (nonatomic, weak) IBOutlet UILabel *match8Red1;
@property (nonatomic, weak) IBOutlet UILabel *match8Red2;
@property (nonatomic, weak) IBOutlet UILabel *match8Red3;
@property (nonatomic, weak) IBOutlet UILabel *match8Red4;

    @property (nonatomic, weak) IBOutlet UITextField *alliance2Captain;
    @property (nonatomic, weak) IBOutlet UITextField *alliance2Pick1;
    @property (nonatomic, weak) IBOutlet UITextField *alliance2Pick2;
    @property (nonatomic, weak) IBOutlet UITextField *alliance2Pick3;
@property (nonatomic, weak) IBOutlet UIButton *alliance2MatchButton;
@property (nonatomic, weak) IBOutlet UILabel *match2Red1;
@property (nonatomic, weak) IBOutlet UILabel *match2Red2;
@property (nonatomic, weak) IBOutlet UILabel *match2Red3;
@property (nonatomic, weak) IBOutlet UILabel *match2Red4;
@property (nonatomic, weak) IBOutlet UILabel *match6Red1;
@property (nonatomic, weak) IBOutlet UILabel *match6Red2;
@property (nonatomic, weak) IBOutlet UILabel *match6Red3;
@property (nonatomic, weak) IBOutlet UILabel *match6Red4;

@property (nonatomic, weak) IBOutlet UITextField *alliance3Captain;
@property (nonatomic, weak) IBOutlet UITextField *alliance3Pick1;
@property (nonatomic, weak) IBOutlet UITextField *alliance3Pick2;
@property (nonatomic, weak) IBOutlet UITextField *alliance3Pick3;
@property (nonatomic, weak) IBOutlet UIButton *alliance3MatchButton;
@property (nonatomic, weak) IBOutlet UILabel *match3Red1;
@property (nonatomic, weak) IBOutlet UILabel *match3Red2;
@property (nonatomic, weak) IBOutlet UILabel *match3Red3;
@property (nonatomic, weak) IBOutlet UILabel *match3Red4;
@property (nonatomic, weak) IBOutlet UILabel *match7Red1;
@property (nonatomic, weak) IBOutlet UILabel *match7Red2;
@property (nonatomic, weak) IBOutlet UILabel *match7Red3;
@property (nonatomic, weak) IBOutlet UILabel *match7Red4;

@property (nonatomic, weak) IBOutlet UITextField *alliance4Captain;
@property (nonatomic, weak) IBOutlet UITextField *alliance4Pick1;
@property (nonatomic, weak) IBOutlet UITextField *alliance4Pick2;
@property (nonatomic, weak) IBOutlet UITextField *alliance4Pick3;
@property (nonatomic, weak) IBOutlet UIButton *alliance4MatchButton;
@property (nonatomic, weak) IBOutlet UILabel *match1Red1;
@property (nonatomic, weak) IBOutlet UILabel *match1Red2;
@property (nonatomic, weak) IBOutlet UILabel *match1Red3;
@property (nonatomic, weak) IBOutlet UILabel *match1Red4;
@property (nonatomic, weak) IBOutlet UILabel *match5Red1;
@property (nonatomic, weak) IBOutlet UILabel *match5Red2;
@property (nonatomic, weak) IBOutlet UILabel *match5Red3;
@property (nonatomic, weak) IBOutlet UILabel *match5Red4;

@property (nonatomic, weak) IBOutlet UITextField *alliance5Captain;
@property (nonatomic, weak) IBOutlet UITextField *alliance5Pick1;
@property (nonatomic, weak) IBOutlet UITextField *alliance5Pick2;
@property (nonatomic, weak) IBOutlet UITextField *alliance5Pick3;
@property (nonatomic, weak) IBOutlet UIButton *alliance5MatchButton;
@property (nonatomic, weak) IBOutlet UILabel *match1Blue1;
@property (nonatomic, weak) IBOutlet UILabel *match1Blue2;
@property (nonatomic, weak) IBOutlet UILabel *match1Blue3;
@property (nonatomic, weak) IBOutlet UILabel *match1Blue4;
@property (nonatomic, weak) IBOutlet UILabel *match7Blue1;
@property (nonatomic, weak) IBOutlet UILabel *match7Blue2;
@property (nonatomic, weak) IBOutlet UILabel *match7Blue3;
@property (nonatomic, weak) IBOutlet UILabel *match7Blue4;

@property (nonatomic, weak) IBOutlet UITextField *alliance6Captain;
@property (nonatomic, weak) IBOutlet UITextField *alliance6Pick1;
@property (nonatomic, weak) IBOutlet UITextField *alliance6Pick2;
@property (nonatomic, weak) IBOutlet UITextField *alliance6Pick3;
@property (nonatomic, weak) IBOutlet UIButton *alliance6MatchButton;
@property (nonatomic, weak) IBOutlet UILabel *match3Blue1;
@property (nonatomic, weak) IBOutlet UILabel *match3Blue2;
@property (nonatomic, weak) IBOutlet UILabel *match3Blue3;
@property (nonatomic, weak) IBOutlet UILabel *match3Blue4;
@property (nonatomic, weak) IBOutlet UILabel *match5Blue1;
@property (nonatomic, weak) IBOutlet UILabel *match5Blue2;
@property (nonatomic, weak) IBOutlet UILabel *match5Blue3;
@property (nonatomic, weak) IBOutlet UILabel *match5Blue4;

@property (nonatomic, weak) IBOutlet UITextField *alliance7Captain;
@property (nonatomic, weak) IBOutlet UITextField *alliance7Pick1;
@property (nonatomic, weak) IBOutlet UITextField *alliance7Pick2;
@property (nonatomic, weak) IBOutlet UITextField *alliance7Pick3;
@property (nonatomic, weak) IBOutlet UIButton *alliance7MatchButton;
@property (nonatomic, weak) IBOutlet UILabel *match2Blue1;
@property (nonatomic, weak) IBOutlet UILabel *match2Blue2;
@property (nonatomic, weak) IBOutlet UILabel *match2Blue3;
@property (nonatomic, weak) IBOutlet UILabel *match2Blue4;
@property (nonatomic, weak) IBOutlet UILabel *match8Blue1;
@property (nonatomic, weak) IBOutlet UILabel *match8Blue2;
@property (nonatomic, weak) IBOutlet UILabel *match8Blue3;
@property (nonatomic, weak) IBOutlet UILabel *match8Blue4;

@property (nonatomic, weak) IBOutlet UITextField *alliance8Captain;
@property (nonatomic, weak) IBOutlet UITextField *alliance8Pick1;
@property (nonatomic, weak) IBOutlet UITextField *alliance8Pick2;
@property (nonatomic, weak) IBOutlet UITextField *alliance8Pick3;
@property (nonatomic, weak) IBOutlet UIButton *alliance8MatchButton;
@property (nonatomic, weak) IBOutlet UILabel *match4Blue1;
@property (nonatomic, weak) IBOutlet UILabel *match4Blue2;
@property (nonatomic, weak) IBOutlet UILabel *match4Blue3;
@property (nonatomic, weak) IBOutlet UILabel *match4Blue4;
@property (nonatomic, weak) IBOutlet UILabel *match6Blue1;
@property (nonatomic, weak) IBOutlet UILabel *match6Blue2;
@property (nonatomic, weak) IBOutlet UILabel *match6Blue3;
@property (nonatomic, weak) IBOutlet UILabel *match6Blue4;
@property (nonatomic, weak) IBOutlet UILabel *errorLabel;
@end

@implementation AlliancesViewController {
    NSString *tournamentName;
    NSUserDefaults *prefs;
    NSDictionary *matchTypeDictionary;
    NSDictionary *allianceDictionary;
    MatchUtilities *matchUtilities;
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
        self.title =  [NSString stringWithFormat:@"%@ Alliance Selections", tournamentName];
        
        _alliance1Captain.inputView  = [LNNumberpad defaultLNNumberpad];
        _alliance1Pick1.inputView  = [LNNumberpad defaultLNNumberpad];
        _alliance1Pick2.inputView  = [LNNumberpad defaultLNNumberpad];
        _alliance1Pick3.inputView  = [LNNumberpad defaultLNNumberpad];
        _alliance2Captain.inputView  = [LNNumberpad defaultLNNumberpad];
        _alliance2Pick1.inputView  = [LNNumberpad defaultLNNumberpad];
        _alliance2Pick2.inputView  = [LNNumberpad defaultLNNumberpad];
        _alliance2Pick3.inputView  = [LNNumberpad defaultLNNumberpad];
        _alliance3Captain.inputView  = [LNNumberpad defaultLNNumberpad];
        _alliance3Pick1.inputView  = [LNNumberpad defaultLNNumberpad];
        _alliance3Pick2.inputView  = [LNNumberpad defaultLNNumberpad];
        _alliance3Pick3.inputView  = [LNNumberpad defaultLNNumberpad];
        _alliance4Captain.inputView  = [LNNumberpad defaultLNNumberpad];
        _alliance4Pick1.inputView  = [LNNumberpad defaultLNNumberpad];
        _alliance4Pick2.inputView  = [LNNumberpad defaultLNNumberpad];
        _alliance4Pick3.inputView  = [LNNumberpad defaultLNNumberpad];
        _alliance5Captain.inputView  = [LNNumberpad defaultLNNumberpad];
        _alliance5Pick1.inputView  = [LNNumberpad defaultLNNumberpad];
        _alliance5Pick2.inputView  = [LNNumberpad defaultLNNumberpad];
        _alliance5Pick3.inputView  = [LNNumberpad defaultLNNumberpad];
        _alliance6Captain.inputView  = [LNNumberpad defaultLNNumberpad];
        _alliance6Pick1.inputView  = [LNNumberpad defaultLNNumberpad];
        _alliance6Pick2.inputView  = [LNNumberpad defaultLNNumberpad];
        _alliance6Pick3.inputView  = [LNNumberpad defaultLNNumberpad];
        _alliance7Captain.inputView  = [LNNumberpad defaultLNNumberpad];
        _alliance7Pick1.inputView  = [LNNumberpad defaultLNNumberpad];
        _alliance7Pick2.inputView  = [LNNumberpad defaultLNNumberpad];
        _alliance7Pick3.inputView  = [LNNumberpad defaultLNNumberpad];
        _alliance8Captain.inputView  = [LNNumberpad defaultLNNumberpad];
        _alliance8Pick1.inputView  = [LNNumberpad defaultLNNumberpad];
        _alliance8Pick2.inputView  = [LNNumberpad defaultLNNumberpad];
        _alliance8Pick3.inputView  = [LNNumberpad defaultLNNumberpad];
     
    }
    else {
        self.title = @"Alliance Selections";
    }
    matchUtilities = [[MatchUtilities alloc] init:_dataManager];
    matchTypeDictionary = [EnumerationDictionary initializeBundledDictionary:@"MatchType"];
    allianceDictionary = [EnumerationDictionary initializeBundledDictionary:@"AllianceList"];
}

-(NSMutableArray *) buildTeamList:(NSString *)alliance forTextBox:(UITextField *)teamTextField forTeamList:(NSMutableArray *)teamList {
    // Return a thing with the alliance station in the first slot
    // and the team number in the second slot
    if (!alliance || [alliance isEqualToString:@""]) return teamList;
    if (!teamTextField.text || [teamTextField.text isEqualToString:@""]) return teamList;
    NSNumber *teamNumber = [NSNumber numberWithInt:[teamTextField.text intValue]];
    NSDictionary *teamInfo = [NSDictionary dictionaryWithObject:teamNumber forKey:alliance];
    [teamList addObject:teamInfo];
    return teamList;
}

- (IBAction)alliance1Create:(id)sender {
    NSMutableArray *teamList = [[NSMutableArray alloc] init];
    NSError *error = nil;
    teamList = [self buildTeamList:@"Red 1" forTextBox:_alliance1Captain forTeamList:teamList];
    teamList = [self buildTeamList:@"Red 2" forTextBox:_alliance1Pick1 forTeamList:teamList];
    teamList = [self buildTeamList:@"Red 3" forTextBox:_alliance1Pick2 forTeamList:teamList];
    teamList = [self buildTeamList:@"Red 4" forTextBox:_alliance1Pick3 forTeamList:teamList];
    NSLog(@"%@", teamList);
    MatchData *match = [matchUtilities addMatch:[NSNumber numberWithInt:1] forMatchType:@"Elimination" forTeams:teamList forTournament:tournamentName error:&error];
    if (!match) _errorLabel.text = [NSString stringWithFormat:@"Bad things happened creating Match 1"];
    [teamList removeAllObjects];
    teamList = [self buildTeamList:@"Red 1" forTextBox:_alliance1Pick2 forTeamList:teamList];
    teamList = [self buildTeamList:@"Red 2" forTextBox:_alliance1Captain forTeamList:teamList];
    teamList = [self buildTeamList:@"Red 3" forTextBox:_alliance1Pick1 forTeamList:teamList];
    teamList = [self buildTeamList:@"Red 4" forTextBox:_alliance1Pick3 forTeamList:teamList];
    match = [matchUtilities addMatch:[NSNumber numberWithInt:5] forMatchType:@"Elimination" forTeams:teamList forTournament:tournamentName error:&error];
    if (!match) _errorLabel.text = [NSString stringWithFormat:@"Bad things happened creating Match 5"];
    else {
        _match4Red1.text = _alliance1Pick2.text;
        _match4Red2.text = _alliance1Captain.text;
        _match4Red3.text = _alliance1Pick1.text;
        _match4Red4.text = _alliance1Pick3.text;
    }
    [teamList removeAllObjects];
    teamList = [self buildTeamList:@"Red 1" forTextBox:_alliance1Pick1 forTeamList:teamList];
    teamList = [self buildTeamList:@"Red 2" forTextBox:_alliance1Pick2 forTeamList:teamList];
    teamList = [self buildTeamList:@"Red 3" forTextBox:_alliance1Captain forTeamList:teamList];
    teamList = [self buildTeamList:@"Red 4" forTextBox:_alliance1Pick3 forTeamList:teamList];
    match = [matchUtilities addMatch:[NSNumber numberWithInt:9] forMatchType:@"Elimination" forTeams:teamList forTournament:tournamentName error:&error];
    if (!match) _errorLabel.text = [NSString stringWithFormat:@"Bad things happened creating Match 9"];
    
    else {
        _match8Red1.text = _alliance1Pick1.text;
        _match8Red2.text = _alliance1Pick2.text;
        _match8Red3.text = _alliance1Captain.text;
        _match8Red4.text = _alliance1Pick3.text;
    }
    NSError *err = nil;
    if (match) {
        if (![_dataManager.managedObjectContext save:&err]) {
            NSLog(@"Whoops, couldn't save: %@", [err localizedDescription]);
        }
    }
}

- (IBAction)alliance2Create:(id)sender {
    NSMutableArray *teamList = [[NSMutableArray alloc] init];
    NSError *error = nil;
    teamList = [self buildTeamList:@"Red 1" forTextBox:_alliance2Captain forTeamList:teamList];
    teamList = [self buildTeamList:@"Red 2" forTextBox:_alliance2Pick1 forTeamList:teamList];
    teamList = [self buildTeamList:@"Red 3" forTextBox:_alliance2Pick2 forTeamList:teamList];
    teamList = [self buildTeamList:@"Red 4" forTextBox:_alliance2Pick3 forTeamList:teamList];
    NSLog(@"%@", teamList);
    MatchData *match = [matchUtilities addMatch:[NSNumber numberWithInt:3] forMatchType:@"Elimination" forTeams:teamList forTournament:tournamentName error:&error];
    if (!match) _errorLabel.text = [NSString stringWithFormat:@"Bad things happened creating Match 1"];
    [teamList removeAllObjects];
    teamList = [self buildTeamList:@"Red 1" forTextBox:_alliance2Pick2 forTeamList:teamList];
    teamList = [self buildTeamList:@"Red 2" forTextBox:_alliance2Captain forTeamList:teamList];
    teamList = [self buildTeamList:@"Red 3" forTextBox:_alliance2Pick1 forTeamList:teamList];
    teamList = [self buildTeamList:@"Red 4" forTextBox:_alliance2Pick3 forTeamList:teamList];
    match = [matchUtilities addMatch:[NSNumber numberWithInt:7] forMatchType:@"Elimination" forTeams:teamList forTournament:tournamentName error:&error];
    if (!match) _errorLabel.text = [NSString stringWithFormat:@"Bad things happened creating Match 5"];
    else {
        _match2Red1.text = _alliance2Pick2.text;
        _match2Red2.text = _alliance2Captain.text;
        _match2Red3.text = _alliance2Pick1.text;
        _match2Red4.text = _alliance2Pick3.text;
    }
    [teamList removeAllObjects];
    teamList = [self buildTeamList:@"Red 1" forTextBox:_alliance2Pick1 forTeamList:teamList];
    teamList = [self buildTeamList:@"Red 2" forTextBox:_alliance2Pick2 forTeamList:teamList];
    teamList = [self buildTeamList:@"Red 3" forTextBox:_alliance2Captain forTeamList:teamList];
    teamList = [self buildTeamList:@"Red 4" forTextBox:_alliance2Pick3 forTeamList:teamList];
    match = [matchUtilities addMatch:[NSNumber numberWithInt:11] forMatchType:@"Elimination" forTeams:teamList forTournament:tournamentName error:&error];
    if (!match) _errorLabel.text = [NSString stringWithFormat:@"Bad things happened creating Match 9"];
    
    else {
        _match6Red1.text = _alliance2Pick1.text;
        _match6Red2.text = _alliance2Pick2.text;
        _match6Red3.text = _alliance2Captain.text;
        _match6Red4.text = _alliance2Pick3.text;
    }
    NSError *err;
    if (match) {
        if (![_dataManager.managedObjectContext save:&err]) {
            NSLog(@"Whoops, couldn't save: %@", [err localizedDescription]);
        }
    }
}

- (IBAction)alliance3Create:(id)sender {
    NSMutableArray *teamList = [[NSMutableArray alloc] init];
    NSError *error = nil;
    teamList = [self buildTeamList:@"Red 1" forTextBox:_alliance3Captain forTeamList:teamList];
    teamList = [self buildTeamList:@"Red 2" forTextBox:_alliance3Pick1 forTeamList:teamList];
    teamList = [self buildTeamList:@"Red 3" forTextBox:_alliance3Pick2 forTeamList:teamList];
    teamList = [self buildTeamList:@"Red 4" forTextBox:_alliance3Pick3 forTeamList:teamList];
    NSLog(@"%@", teamList);
    MatchData *match = [matchUtilities addMatch:[NSNumber numberWithInt:4] forMatchType:@"Elimination" forTeams:teamList forTournament:tournamentName error:&error];
    if (!match) _errorLabel.text = [NSString stringWithFormat:@"Bad things happened creating Match 1"];
    [teamList removeAllObjects];
    teamList = [self buildTeamList:@"Red 1" forTextBox:_alliance3Pick2 forTeamList:teamList];
    teamList = [self buildTeamList:@"Red 2" forTextBox:_alliance3Captain forTeamList:teamList];
    teamList = [self buildTeamList:@"Red 3" forTextBox:_alliance3Pick1 forTeamList:teamList];
    teamList = [self buildTeamList:@"Red 4" forTextBox:_alliance3Pick3 forTeamList:teamList];
    match = [matchUtilities addMatch:[NSNumber numberWithInt:8] forMatchType:@"Elimination" forTeams:teamList forTournament:tournamentName error:&error];
    if (!match) _errorLabel.text = [NSString stringWithFormat:@"Bad things happened creating Match 5"];
    else {
        _match3Red1.text = _alliance3Pick2.text;
        _match3Red2.text = _alliance3Captain.text;
        _match3Red3.text = _alliance3Pick1.text;
        _match3Red4.text = _alliance3Pick3.text;
    }
    [teamList removeAllObjects];
    teamList = [self buildTeamList:@"Red 1" forTextBox:_alliance3Pick1 forTeamList:teamList];
    teamList = [self buildTeamList:@"Red 2" forTextBox:_alliance3Pick2 forTeamList:teamList];
    teamList = [self buildTeamList:@"Red 3" forTextBox:_alliance3Captain forTeamList:teamList];
    teamList = [self buildTeamList:@"Red 4" forTextBox:_alliance3Pick3 forTeamList:teamList];
    match = [matchUtilities addMatch:[NSNumber numberWithInt:12] forMatchType:@"Elimination" forTeams:teamList forTournament:tournamentName error:&error];
    if (!match) _errorLabel.text = [NSString stringWithFormat:@"Bad things happened creating Match 9"];
    
    else {
        _match7Red1.text = _alliance3Pick1.text;
        _match7Red2.text = _alliance3Pick2.text;
        _match7Red3.text = _alliance3Captain.text;
        _match7Red4.text = _alliance3Pick3.text;
    }
    NSError *err;
    if (match) {
        if (![_dataManager.managedObjectContext save:&err]) {
            NSLog(@"Whoops, couldn't save: %@", [err localizedDescription]);
        }
    }
}

- (IBAction)alliance4Create:(id)sender {
    NSMutableArray *teamList = [[NSMutableArray alloc] init];
    NSError *error = nil;
    teamList = [self buildTeamList:@"Red 1" forTextBox:_alliance4Captain forTeamList:teamList];
    teamList = [self buildTeamList:@"Red 2" forTextBox:_alliance4Pick1 forTeamList:teamList];
    teamList = [self buildTeamList:@"Red 3" forTextBox:_alliance4Pick2 forTeamList:teamList];
    teamList = [self buildTeamList:@"Red 4" forTextBox:_alliance4Pick3 forTeamList:teamList];
    NSLog(@"%@", teamList);
    MatchData *match = [matchUtilities addMatch:[NSNumber numberWithInt:2] forMatchType:@"Elimination" forTeams:teamList forTournament:tournamentName error:&error];
    if (!match) _errorLabel.text = [NSString stringWithFormat:@"Bad things happened creating Match 1"];
    [teamList removeAllObjects];
    teamList = [self buildTeamList:@"Red 1" forTextBox:_alliance4Pick2 forTeamList:teamList];
    teamList = [self buildTeamList:@"Red 2" forTextBox:_alliance4Captain forTeamList:teamList];
    teamList = [self buildTeamList:@"Red 3" forTextBox:_alliance4Pick1 forTeamList:teamList];
    teamList = [self buildTeamList:@"Red 4" forTextBox:_alliance4Pick3 forTeamList:teamList];
    match = [matchUtilities addMatch:[NSNumber numberWithInt:6] forMatchType:@"Elimination" forTeams:teamList forTournament:tournamentName error:&error];
    if (!match) _errorLabel.text = [NSString stringWithFormat:@"Bad things happened creating Match 5"];
    else {
        _match1Red1.text = _alliance4Pick2.text;
        _match1Red2.text = _alliance4Captain.text;
        _match1Red3.text = _alliance4Pick1.text;
        _match1Red4.text = _alliance4Pick3.text;
    }
    [teamList removeAllObjects];
    teamList = [self buildTeamList:@"Red 1" forTextBox:_alliance4Pick1 forTeamList:teamList];
    teamList = [self buildTeamList:@"Red 2" forTextBox:_alliance4Pick2 forTeamList:teamList];
    teamList = [self buildTeamList:@"Red 3" forTextBox:_alliance4Captain forTeamList:teamList];
    teamList = [self buildTeamList:@"Red 4" forTextBox:_alliance4Pick3 forTeamList:teamList];
    match = [matchUtilities addMatch:[NSNumber numberWithInt:10] forMatchType:@"Elimination" forTeams:teamList forTournament:tournamentName error:&error];
    if (!match) _errorLabel.text = [NSString stringWithFormat:@"Bad things happened creating Match 9"];
    
    else {
        _match5Red1.text = _alliance4Pick1.text;
        _match5Red2.text = _alliance4Pick2.text;
        _match5Red3.text = _alliance4Captain.text;
        _match5Red4.text = _alliance4Pick3.text;
    }
    NSError *err;
    if (match) {
        if (![_dataManager.managedObjectContext save:&err]) {
            NSLog(@"Whoops, couldn't save: %@", [err localizedDescription]);
        }
    }
}

- (IBAction)alliance5Create:(id)sender {
    NSMutableArray *teamList = [[NSMutableArray alloc] init];
    NSError *error = nil;
    teamList = [self buildTeamList:@"Blue 1" forTextBox:_alliance5Captain forTeamList:teamList];
    teamList = [self buildTeamList:@"Blue 2" forTextBox:_alliance5Pick1 forTeamList:teamList];
    teamList = [self buildTeamList:@"Blue 3" forTextBox:_alliance5Pick2 forTeamList:teamList];
    teamList = [self buildTeamList:@"Blue 4" forTextBox:_alliance5Pick3 forTeamList:teamList];
    NSLog(@"%@", teamList);
    MatchData *match = [matchUtilities addMatch:[NSNumber numberWithInt:2] forMatchType:@"Elimination" forTeams:teamList forTournament:tournamentName error:&error];
    if (!match) _errorLabel.text = [NSString stringWithFormat:@"Bad things happened creating Match 1"];
    [teamList removeAllObjects];
    teamList = [self buildTeamList:@"Blue 1" forTextBox:_alliance5Pick2 forTeamList:teamList];
    teamList = [self buildTeamList:@"Blue 2" forTextBox:_alliance5Captain forTeamList:teamList];
    teamList = [self buildTeamList:@"Blue 3" forTextBox:_alliance5Pick1 forTeamList:teamList];
    teamList = [self buildTeamList:@"Blue 4" forTextBox:_alliance5Pick3 forTeamList:teamList];
    match = [matchUtilities addMatch:[NSNumber numberWithInt:6] forMatchType:@"Elimination" forTeams:teamList forTournament:tournamentName error:&error];
    if (!match) _errorLabel.text = [NSString stringWithFormat:@"Bad things happened creating Match 5"];
    else {
        _match1Blue1.text = _alliance5Pick2.text;
        _match1Blue2.text = _alliance5Captain.text;
        _match1Blue3.text = _alliance5Pick1.text;
        _match1Blue4.text = _alliance5Pick3.text;
    }
    [teamList removeAllObjects];
    teamList = [self buildTeamList:@"Blue 1" forTextBox:_alliance5Pick1 forTeamList:teamList];
    teamList = [self buildTeamList:@"Blue 2" forTextBox:_alliance5Pick2 forTeamList:teamList];
    teamList = [self buildTeamList:@"Blue 3" forTextBox:_alliance5Captain forTeamList:teamList];
    teamList = [self buildTeamList:@"Blue 4" forTextBox:_alliance5Pick3 forTeamList:teamList];
    match = [matchUtilities addMatch:[NSNumber numberWithInt:10] forMatchType:@"Elimination" forTeams:teamList forTournament:tournamentName error:&error];
    if (!match) _errorLabel.text = [NSString stringWithFormat:@"Bad things happened creating Match 9"];
    
    else {
        _match7Blue1.text = _alliance5Pick1.text;
        _match7Blue2.text = _alliance5Pick2.text;
        _match7Blue3.text = _alliance5Captain.text;
        _match7Blue4.text = _alliance5Pick3.text;
    }
    NSError *err;
    if (match) {
        if (![_dataManager.managedObjectContext save:&err]) {
            NSLog(@"Whoops, couldn't save: %@", [err localizedDescription]);
        }
    }
}

- (IBAction)alliance6Create:(id)sender {
    NSMutableArray *teamList = [[NSMutableArray alloc] init];
    NSError *error = nil;
    teamList = [self buildTeamList:@"Blue 1" forTextBox:_alliance6Captain forTeamList:teamList];
    teamList = [self buildTeamList:@"Blue 2" forTextBox:_alliance6Pick1 forTeamList:teamList];
    teamList = [self buildTeamList:@"Blue 3" forTextBox:_alliance6Pick2 forTeamList:teamList];
    teamList = [self buildTeamList:@"Blue 4" forTextBox:_alliance6Pick3 forTeamList:teamList];
    NSLog(@"%@", teamList);
    MatchData *match = [matchUtilities addMatch:[NSNumber numberWithInt:4] forMatchType:@"Elimination" forTeams:teamList forTournament:tournamentName error:&error];
    if (!match) _errorLabel.text = [NSString stringWithFormat:@"Bad things happened creating Match 1"];
    [teamList removeAllObjects];
    teamList = [self buildTeamList:@"Blue 1" forTextBox:_alliance6Pick2 forTeamList:teamList];
    teamList = [self buildTeamList:@"Blue 2" forTextBox:_alliance6Captain forTeamList:teamList];
    teamList = [self buildTeamList:@"Blue 3" forTextBox:_alliance6Pick1 forTeamList:teamList];
    teamList = [self buildTeamList:@"Blue 4" forTextBox:_alliance6Pick3 forTeamList:teamList];
    match = [matchUtilities addMatch:[NSNumber numberWithInt:8] forMatchType:@"Elimination" forTeams:teamList forTournament:tournamentName error:&error];
    if (!match) _errorLabel.text = [NSString stringWithFormat:@"Bad things happened creating Match 5"];
    else {
        _match3Blue1.text = _alliance6Pick2.text;
        _match3Blue2.text = _alliance6Captain.text;
        _match3Blue3.text = _alliance6Pick1.text;
        _match3Blue4.text = _alliance6Pick3.text;
    }
    [teamList removeAllObjects];
    teamList = [self buildTeamList:@"Blue 1" forTextBox:_alliance6Pick1 forTeamList:teamList];
    teamList = [self buildTeamList:@"Blue 2" forTextBox:_alliance6Pick2 forTeamList:teamList];
    teamList = [self buildTeamList:@"Blue 3" forTextBox:_alliance6Captain forTeamList:teamList];
    teamList = [self buildTeamList:@"Blue 4" forTextBox:_alliance6Pick3 forTeamList:teamList];
    match = [matchUtilities addMatch:[NSNumber numberWithInt:12] forMatchType:@"Elimination" forTeams:teamList forTournament:tournamentName error:&error];
    if (!match) _errorLabel.text = [NSString stringWithFormat:@"Bad things happened creating Match 9"];
    
    else {
        _match5Blue1.text = _alliance6Pick1.text;
        _match5Blue2.text = _alliance6Pick2.text;
        _match5Blue3.text = _alliance6Captain.text;
        _match5Blue4.text = _alliance6Pick3.text;
    }
    NSError *err;
    if (match) {
        if (![_dataManager.managedObjectContext save:&err]) {
            NSLog(@"Whoops, couldn't save: %@", [err localizedDescription]);
        }
    }
}

- (IBAction)alliance7Create:(id)sender {
    NSMutableArray *teamList = [[NSMutableArray alloc] init];
    NSError *error = nil;
    teamList = [self buildTeamList:@"Blue 1" forTextBox:_alliance7Captain forTeamList:teamList];
    teamList = [self buildTeamList:@"Blue 2" forTextBox:_alliance7Pick1 forTeamList:teamList];
    teamList = [self buildTeamList:@"Blue 3" forTextBox:_alliance7Pick2 forTeamList:teamList];
    teamList = [self buildTeamList:@"Blue 4" forTextBox:_alliance7Pick3 forTeamList:teamList];
    NSLog(@"%@", teamList);
    MatchData *match = [matchUtilities addMatch:[NSNumber numberWithInt:3] forMatchType:@"Elimination" forTeams:teamList forTournament:tournamentName error:&error];
    if (!match) _errorLabel.text = [NSString stringWithFormat:@"Bad things happened creating Match 1"];
    [teamList removeAllObjects];
    teamList = [self buildTeamList:@"Blue 1" forTextBox:_alliance7Pick2 forTeamList:teamList];
    teamList = [self buildTeamList:@"Blue 2" forTextBox:_alliance7Captain forTeamList:teamList];
    teamList = [self buildTeamList:@"Blue 3" forTextBox:_alliance7Pick1 forTeamList:teamList];
    teamList = [self buildTeamList:@"Blue 4" forTextBox:_alliance7Pick3 forTeamList:teamList];
    match = [matchUtilities addMatch:[NSNumber numberWithInt:7] forMatchType:@"Elimination" forTeams:teamList forTournament:tournamentName error:&error];
    if (!match) _errorLabel.text = [NSString stringWithFormat:@"Bad things happened creating Match 5"];
    else {
        _match2Blue1.text = _alliance7Pick2.text;
        _match2Blue2.text = _alliance7Captain.text;
        _match2Blue3.text = _alliance7Pick1.text;
        _match2Blue4.text = _alliance7Pick3.text;
    }
    [teamList removeAllObjects];
    teamList = [self buildTeamList:@"Blue 1" forTextBox:_alliance7Pick1 forTeamList:teamList];
    teamList = [self buildTeamList:@"Blue 2" forTextBox:_alliance7Pick2 forTeamList:teamList];
    teamList = [self buildTeamList:@"Blue 3" forTextBox:_alliance7Captain forTeamList:teamList];
    teamList = [self buildTeamList:@"Blue 4" forTextBox:_alliance7Pick3 forTeamList:teamList];
    match = [matchUtilities addMatch:[NSNumber numberWithInt:11] forMatchType:@"Elimination" forTeams:teamList forTournament:tournamentName error:&error];
    if (!match) _errorLabel.text = [NSString stringWithFormat:@"Bad things happened creating Match 9"];
    
    else {
        _match8Blue1.text = _alliance7Pick1.text;
        _match8Blue2.text = _alliance7Pick2.text;
        _match8Blue3.text = _alliance7Captain.text;
        _match8Blue4.text = _alliance7Pick3.text;
    }
    NSError *err;
    if (match) {
        if (![_dataManager.managedObjectContext save:&err]) {
            NSLog(@"Whoops, couldn't save: %@", [err localizedDescription]);
        }
    }
}

- (IBAction)alliance8Create:(id)sender {
    NSMutableArray *teamList = [[NSMutableArray alloc] init];
    NSError *error = nil;
    teamList = [self buildTeamList:@"Blue 1" forTextBox:_alliance8Captain forTeamList:teamList];
    teamList = [self buildTeamList:@"Blue 2" forTextBox:_alliance8Pick1 forTeamList:teamList];
    teamList = [self buildTeamList:@"Blue 3" forTextBox:_alliance8Pick2 forTeamList:teamList];
    teamList = [self buildTeamList:@"Blue 4" forTextBox:_alliance8Pick3 forTeamList:teamList];
    NSLog(@"%@", teamList);
    MatchData *match = [matchUtilities addMatch:[NSNumber numberWithInt:1] forMatchType:@"Elimination" forTeams:teamList forTournament:tournamentName error:&error];
    if (!match) _errorLabel.text = [NSString stringWithFormat:@"Bad things happened creating Match 1"];
    [teamList removeAllObjects];
    teamList = [self buildTeamList:@"Blue 1" forTextBox:_alliance8Pick2 forTeamList:teamList];
    teamList = [self buildTeamList:@"Blue 2" forTextBox:_alliance8Captain forTeamList:teamList];
    teamList = [self buildTeamList:@"Blue 3" forTextBox:_alliance8Pick1 forTeamList:teamList];
    teamList = [self buildTeamList:@"Blue 4" forTextBox:_alliance8Pick3 forTeamList:teamList];
    match = [matchUtilities addMatch:[NSNumber numberWithInt:5] forMatchType:@"Elimination" forTeams:teamList forTournament:tournamentName error:&error];
    if (!match) _errorLabel.text = [NSString stringWithFormat:@"Bad things happened creating Match 5"];
    else {
        _match4Blue1.text = _alliance8Pick2.text;
        _match4Blue2.text = _alliance8Captain.text;
        _match4Blue3.text = _alliance8Pick1.text;
        _match4Blue4.text = _alliance8Pick3.text;
    }
    [teamList removeAllObjects];
    teamList = [self buildTeamList:@"Blue 1" forTextBox:_alliance8Pick1 forTeamList:teamList];
    teamList = [self buildTeamList:@"Blue 2" forTextBox:_alliance8Pick2 forTeamList:teamList];
    teamList = [self buildTeamList:@"Blue 3" forTextBox:_alliance8Captain forTeamList:teamList];
    teamList = [self buildTeamList:@"Blue 4" forTextBox:_alliance8Pick3 forTeamList:teamList];
    match = [matchUtilities addMatch:[NSNumber numberWithInt:9] forMatchType:@"Elimination" forTeams:teamList forTournament:tournamentName error:&error];
    if (!match) _errorLabel.text = [NSString stringWithFormat:@"Bad things happened creating Match 9"];
    
    else {
        _match6Blue1.text = _alliance8Pick1.text;
        _match6Blue2.text = _alliance8Pick2.text;
        _match6Blue3.text = _alliance8Captain.text;
        _match6Blue4.text = _alliance8Pick3.text;
    }
    NSError *err;
    if (match) {
        if (![_dataManager.managedObjectContext save:&err]) {
            NSLog(@"Whoops, couldn't save: %@", [err localizedDescription]);
        }
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *resultingString = [textField.text stringByReplacingCharactersInRange: range withString: string];
    
    // This allows backspace
    if ([resultingString length] == 0) {
        return true;
    }
    
    NSInteger holder;
    NSScanner *scan = [NSScanner scannerWithString: resultingString];
    
    return [scan scanInteger: &holder] && [scan isAtEnd];
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    NSNumber *teamNumber = [NSNumber numberWithInt:[textField.text intValue]];
    if (![TeamAccessors getTeam:teamNumber inTournament:tournamentName fromDataManager:_dataManager]) {
        _errorLabel.text = [NSString stringWithFormat:@"Team %@ is not a valid team in this tournament", teamNumber];
        textField.text = @"";
    }
    else {
        _errorLabel.text = @"";
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
