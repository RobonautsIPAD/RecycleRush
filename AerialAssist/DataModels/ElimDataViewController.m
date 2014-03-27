//
//  ElimDataViewController.m
//  AerialAssist
//
//  Created by FRC on 3/22/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "ElimDataViewController.h"
#import "DataManager.h"
#import "TeamData.h"
#import "TeamScore.h"
#import "MatchData.h"
#import "TeamDataInterfaces.h"
#import "TournamentData.h"

@interface ElimDataViewController (){
    NSString *tournamentName;
    NSUserDefaults *prefs;
}
//Aliance 1 Radio Buttons
@property (nonatomic, weak) IBOutlet UIButton *sfAliance1Button;
@property (nonatomic, weak) IBOutlet UIButton *fiAliance1Button;

//Aliance 2 Radio Buttons
@property (nonatomic, weak) IBOutlet UIButton *sfAliance2Button;
@property (nonatomic, weak) IBOutlet UIButton *fiAliance2Button;

//Aliance 3 Radio Buttons
@property (nonatomic, weak) IBOutlet UIButton *sfAliance3Button;
@property (nonatomic, weak) IBOutlet UIButton *fiAliance3Button;


//Aliance 4 Radio Buttons
@property (nonatomic, weak) IBOutlet UIButton *sfAliance4Button;
@property (nonatomic, weak) IBOutlet UIButton *fiAliance4Button;

//Aliance 5 Radio Buttons
@property (nonatomic, weak) IBOutlet UIButton *sfAliance5Button;
@property (nonatomic, weak) IBOutlet UIButton *fiAliance5Button;

//Aliance 6 Radio Buttons
@property (nonatomic, weak) IBOutlet UIButton *sfAliance6Button;
@property (nonatomic, weak) IBOutlet UIButton *fiAliance6Button;

//Aliance 7 Radio Buttons
@property (nonatomic, weak) IBOutlet UIButton *sfAliance7Button;
@property (nonatomic, weak) IBOutlet UIButton *fiAliance7Button;

//Aliance 8 Radio Buttons
@property (nonatomic, weak) IBOutlet UIButton *sfAliance8Button;
@property (nonatomic, weak) IBOutlet UIButton *fiAliance8Button;

//aliance text fields

//aliance 1
@property (nonatomic, weak) IBOutlet UITextField *aliance1Captian;
@property (nonatomic, weak) IBOutlet UITextField *aliance1Partner1;
@property (nonatomic, weak) IBOutlet UITextField *aliance1Partner2;

//aliance 2
@property (nonatomic, weak) IBOutlet UITextField *aliance2Captian;
@property (nonatomic, weak) IBOutlet UITextField *aliance2Partner1;
@property (nonatomic, weak) IBOutlet UITextField *aliance2Partner2;

//aliance 3
@property (nonatomic, weak) IBOutlet UITextField *aliance3Captian;
@property (nonatomic, weak) IBOutlet UITextField *aliance3Partner1;
@property (nonatomic, weak) IBOutlet UITextField *aliance3Partner2;

//aliance 4
@property (nonatomic, weak) IBOutlet UITextField *aliance4Captian;
@property (nonatomic, weak) IBOutlet UITextField *aliance4Partner1;
@property (nonatomic, weak) IBOutlet UITextField *aliance4Partner2;

//aliance 5
@property (nonatomic, weak) IBOutlet UITextField *aliance5Captian;
@property (nonatomic, weak) IBOutlet UITextField *aliance5Partner1;
@property (nonatomic, weak) IBOutlet UITextField *aliance5Partner2;

//aliance 6
@property (nonatomic, weak) IBOutlet UITextField *aliance6Captian;
@property (nonatomic, weak) IBOutlet UITextField *aliance6Partner1;
@property (nonatomic, weak) IBOutlet UITextField *aliance6Partner2;

//aliance 7
@property (nonatomic, weak) IBOutlet UITextField *aliance7Captian;
@property (nonatomic, weak) IBOutlet UITextField *aliance7Partner1;
@property (nonatomic, weak) IBOutlet UITextField *aliance7Partner2;

//aliance 8
@property (nonatomic, weak) IBOutlet UITextField *aliance8Captian;
@property (nonatomic, weak) IBOutlet UITextField *aliance8Partner1;
@property (nonatomic, weak) IBOutlet UITextField *aliance8Partner2;

//Generate Matches Button
@property (nonatomic, weak) IBOutlet UIButton *generateButton;

@end

@implementation ElimDataViewController

@synthesize dataManager = _dataManager;
@synthesize teamIndex = _teamIndex;
@synthesize team = _team;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize teamList = _teamList;

- (id)initWithDataManager:(DataManager *)initManager {
	if ((self = [super init]))
	{
        _dataManager = initManager;
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if (!_dataManager) {
        _dataManager = [[DataManager alloc] init];
    }
    
    prefs = [NSUserDefaults standardUserDefaults];
    tournamentName = [prefs objectForKey:@"tournament"];
    if (tournamentName) {
        self.title = tournamentName;
    }
    else {
        self.title = @"Elim Data";
    }

    
    //Set SF & FI RadioButtons to Defualt to Off
    
    //SF Butttons
    [self setRadioButtonDefaults:_sfAliance1Button];
    [self setRadioButtonDefaults:_sfAliance2Button];
    [self setRadioButtonDefaults:_sfAliance3Button];
    [self setRadioButtonDefaults:_sfAliance4Button];
    [self setRadioButtonDefaults:_sfAliance5Button];
    [self setRadioButtonDefaults:_sfAliance6Button];
    [self setRadioButtonDefaults:_sfAliance7Button];
    [self setRadioButtonDefaults:_sfAliance8Button];
    
    //FI Buttons
    [self setRadioButtonDefaults:_fiAliance1Button];
    [self setRadioButtonDefaults:_fiAliance2Button];
    [self setRadioButtonDefaults:_fiAliance3Button];
    [self setRadioButtonDefaults:_fiAliance4Button];
    [self setRadioButtonDefaults:_fiAliance5Button];
    [self setRadioButtonDefaults:_fiAliance6Button];
    [self setRadioButtonDefaults:_fiAliance7Button];
    [self setRadioButtonDefaults:_fiAliance8Button];
    
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"MatchData" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"tournamentName = %@ AND matchType = %@", tournamentName, @"Elimination"];
    [fetchRequest setPredicate:pred];
    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:numberDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSArray *matchList = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    NSSortDescriptor *allianceSort = [NSSortDescriptor sortDescriptorWithKey:@"allianceSection" ascending:YES];
    
    MatchData *match;
    NSArray *scores;
    NSNumber *teamNumber;
    if([matchList count] > 0) {
        match = [matchList objectAtIndex:0];
        scores = [[match.score allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:allianceSort]];
        
        switch ([scores count]){
            case 6:{
                teamNumber = [[[scores objectAtIndex:5] valueForKey:@"team"] valueForKey:@"number"];
                _aliance8Partner2.text = [NSString stringWithFormat:@"%d", [teamNumber intValue]];
            }
            case 5:{
                teamNumber = [[[scores objectAtIndex:4] valueForKey:@"team"] valueForKey:@"number"];
                _aliance8Partner1.text = [NSString stringWithFormat:@"%d", [teamNumber intValue]];
            }
            case 4:{
                teamNumber = [[[scores objectAtIndex:3] valueForKey:@"team"] valueForKey:@"number"];
                _aliance8Captian.text = [NSString stringWithFormat:@"%d", [teamNumber intValue]];
            }
            case 3:{
                teamNumber = [[[scores objectAtIndex:2] valueForKey:@"team"] valueForKey:@"number"];
                _aliance1Partner2.text = [NSString stringWithFormat:@"%d", [teamNumber intValue]];
            }
            case 2:{
                teamNumber = [[[scores objectAtIndex:1] valueForKey:@"team"] valueForKey:@"number"];
                _aliance1Partner1.text = [NSString stringWithFormat:@"%d", [teamNumber intValue]];
            }
            case 1:{
                teamNumber = [[[scores objectAtIndex:0] valueForKey:@"team"] valueForKey:@"number"];
                _aliance1Captian.text = [NSString stringWithFormat:@"%d", [teamNumber intValue]];
            }
            default:
                break;
        }
    }
    
    if([matchList count] > 1){
        match = [matchList objectAtIndex:1];
        scores = [[match.score allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:allianceSort]];
        switch ([scores count]){
            case 6:{
                teamNumber = [[[scores objectAtIndex:5] valueForKey:@"team"] valueForKey:@"number"];
                _aliance7Partner2.text = [NSString stringWithFormat:@"%d", [teamNumber intValue]];
            }
            case 5:{
                teamNumber = [[[scores objectAtIndex:4] valueForKey:@"team"] valueForKey:@"number"];
                _aliance7Partner1.text = [NSString stringWithFormat:@"%d", [teamNumber intValue]];
            }
            case 4:{
                teamNumber = [[[scores objectAtIndex:3] valueForKey:@"team"] valueForKey:@"number"];
                _aliance7Captian.text = [NSString stringWithFormat:@"%d", [teamNumber intValue]];
            }
            case 3:{
                teamNumber = [[[scores objectAtIndex:2] valueForKey:@"team"] valueForKey:@"number"];
                _aliance2Partner2.text = [NSString stringWithFormat:@"%d", [teamNumber intValue]];
            }
            case 2:{
                teamNumber = [[[scores objectAtIndex:1] valueForKey:@"team"] valueForKey:@"number"];
                _aliance2Partner1.text = [NSString stringWithFormat:@"%d", [teamNumber intValue]];
            }
            case 1:{
                teamNumber = [[[scores objectAtIndex:0] valueForKey:@"team"] valueForKey:@"number"];
                _aliance2Captian.text = [NSString stringWithFormat:@"%d", [teamNumber intValue]];
            }
            default:
                break;
        }
    }
    
    if([matchList count] > 2){
        match = [matchList objectAtIndex:2];
        scores = [[match.score allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:allianceSort]];
        switch ([scores count]){
            case 6:{
                teamNumber = [[[scores objectAtIndex:5] valueForKey:@"team"] valueForKey:@"number"];
                _aliance6Partner2.text = [NSString stringWithFormat:@"%d", [teamNumber intValue]];
            }
            case 5:{
                teamNumber = [[[scores objectAtIndex:4] valueForKey:@"team"] valueForKey:@"number"];
                _aliance6Partner1.text = [NSString stringWithFormat:@"%d", [teamNumber intValue]];
            }
            case 4:{
                teamNumber = [[[scores objectAtIndex:3] valueForKey:@"team"] valueForKey:@"number"];
                _aliance6Captian.text = [NSString stringWithFormat:@"%d", [teamNumber intValue]];
            }
            case 3:{
                teamNumber = [[[scores objectAtIndex:2] valueForKey:@"team"] valueForKey:@"number"];
                _aliance3Partner2.text = [NSString stringWithFormat:@"%d", [teamNumber intValue]];
            }
            case 2:{
                teamNumber = [[[scores objectAtIndex:1] valueForKey:@"team"] valueForKey:@"number"];
                _aliance3Partner1.text = [NSString stringWithFormat:@"%d", [teamNumber intValue]];
            }
            case 1:{
                teamNumber = [[[scores objectAtIndex:0] valueForKey:@"team"] valueForKey:@"number"];
                _aliance3Captian.text = [NSString stringWithFormat:@"%d", [teamNumber intValue]];
            }
            default:
                break;
        }
    }
    
    if([matchList count] > 3){
        match = [matchList objectAtIndex:3];
        scores = [[match.score allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:allianceSort]];
        switch ([scores count]){
            case 6:{
                teamNumber = [[[scores objectAtIndex:5] valueForKey:@"team"] valueForKey:@"number"];
                _aliance5Partner2.text = [NSString stringWithFormat:@"%d", [teamNumber intValue]];
            }
            case 5:{
                teamNumber = [[[scores objectAtIndex:4] valueForKey:@"team"] valueForKey:@"number"];
                _aliance5Partner1.text = [NSString stringWithFormat:@"%d", [teamNumber intValue]];
            }
            case 4:{
                teamNumber = [[[scores objectAtIndex:3] valueForKey:@"team"] valueForKey:@"number"];
                _aliance5Captian.text = [NSString stringWithFormat:@"%d", [teamNumber intValue]];
            }
            case 3:{
                teamNumber = [[[scores objectAtIndex:2] valueForKey:@"team"] valueForKey:@"number"];
                _aliance4Partner2.text = [NSString stringWithFormat:@"%d", [teamNumber intValue]];
            }
            case 2:{
                teamNumber = [[[scores objectAtIndex:1] valueForKey:@"team"] valueForKey:@"number"];
                _aliance4Partner1.text = [NSString stringWithFormat:@"%d", [teamNumber intValue]];
            }
            case 1:{
                teamNumber = [[[scores objectAtIndex:0] valueForKey:@"team"] valueForKey:@"number"];
                _aliance4Captian.text = [NSString stringWithFormat:@"%d", [teamNumber intValue]];
            }
            default:
                break;
        }
    }
    
}

-(void)setRadioButtonDefaults:(UIButton *)button{
    [button setImage:[UIImage imageNamed:@"RadioButton-Unselected.png"] forState:UIControlStateNormal];
}

-(IBAction)toggleRadioButtonState:(id)sender{
    if ([sender isSelected]) {
        [sender setImage:[UIImage imageNamed:@"RadioButton-Unselected.png"] forState:UIControlStateNormal];
        [sender setSelected:NO];
    } else {
        [sender setImage:[UIImage imageNamed:@"RadioButton-Selected.png"] forState:UIControlStateSelected];
        [sender setSelected:YES];
        
        
    }
}


-(IBAction)generateMatch:(id)sender{
 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
