//
//  MatchSummaryViewController.m
//  RecycleRush
//
//  Created by FRC on 1/24/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import "MatchSummaryViewController.h"
#import "DataManager.h"
#import "TeamScore.h"
#import "TeamData.h"
#import "MatchAccessors.h"

@interface MatchSummaryViewController ()
@property (weak, nonatomic) IBOutlet UILabel *teamNumber;
@property (weak, nonatomic) IBOutlet UILabel *teamName;
@property (weak, nonatomic) IBOutlet UILabel *matchType;
@property (weak, nonatomic) IBOutlet UILabel *matchNumber;
@property (weak, nonatomic) IBOutlet UILabel *alliance;
//Auton
@property (weak, nonatomic) IBOutlet UILabel *canDomCans;
@property (weak, nonatomic) IBOutlet UILabel *canDomTime;
@property (weak, nonatomic) IBOutlet UILabel *toteSet;
@property (weak, nonatomic) IBOutlet UILabel *canSet;
@property (weak, nonatomic) IBOutlet UILabel *toteStack;
@property (weak, nonatomic) IBOutlet UILabel *robotSet;
//Tele-Op
@property (weak, nonatomic) IBOutlet UILabel *totes;
@property (weak, nonatomic) IBOutlet UILabel *cans;
@property (weak, nonatomic) IBOutlet UILabel *litterInCans;
@property (weak, nonatomic) IBOutlet UILabel *totalScore;
@property (weak, nonatomic) IBOutlet UILabel *allianceScore;
@property (weak, nonatomic) IBOutlet UITableViewCell *totesandcansTable;
@property (weak, nonatomic) IBOutlet UITableViewCell *totalsTable;
@property (weak, nonatomic) IBOutlet UILabel *totesStep;
@property (weak, nonatomic) IBOutlet UILabel *totesLandfill;
@property (weak, nonatomic) IBOutlet UILabel *totesHP;
@property (weak, nonatomic) IBOutlet UILabel *totalTotes;
@property (weak, nonatomic) IBOutlet UILabel *canlandfill;
@property (weak, nonatomic) IBOutlet UILabel *canStep;
@property (weak, nonatomic) IBOutlet UILabel *t0;
@property (weak, nonatomic) IBOutlet UILabel *t1;
@property (weak, nonatomic) IBOutlet UILabel *t2;
@property (weak, nonatomic) IBOutlet UILabel *t3;
@property (weak, nonatomic) IBOutlet UILabel *t4;
@property (weak, nonatomic) IBOutlet UILabel *t5;
@property (weak, nonatomic) IBOutlet UILabel *t6;
@property (weak, nonatomic) IBOutlet UILabel *c0;
@property (weak, nonatomic) IBOutlet UILabel *c1;
@property (weak, nonatomic) IBOutlet UILabel *c2;
@property (weak, nonatomic) IBOutlet UILabel *c3;
@property (weak, nonatomic) IBOutlet UILabel *c4;
@property (weak, nonatomic) IBOutlet UILabel *c5;
@property (weak, nonatomic) IBOutlet UILabel *c6;

//Other Match Info
@property (weak, nonatomic) IBOutlet UILabel *coopSetTop;
@property (weak, nonatomic) IBOutlet UILabel *coopSetBottom;
@property (weak, nonatomic) IBOutlet UILabel *coopStackTop;
@property (weak, nonatomic) IBOutlet UILabel *coopStackBottom;
@property (weak, nonatomic) IBOutlet UILabel *knockdowns;
@property (weak, nonatomic) IBOutlet UILabel *driverRating;
@property (weak, nonatomic) IBOutlet UILabel *robotType;
@property (weak, nonatomic) IBOutlet UILabel *dataSavedBy;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *goAnaylsis;



@end

@implementation MatchSummaryViewController
TeamScore *currentScore;
TeamData *info;


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
    // NSLog(@"%@",_currentScore);
    [self setLabels:(UILabel *) _teamNumber];
    [self setLabels:(UILabel *) _matchNumber];
    [self setLabels:(UILabel *) _driverRating];
    [self setLabels:(UILabel *) _knockdowns];
    [self setLabels:(UILabel *) _canDomTime];
    [self setLabels:(UILabel *) _canDomCans];
    [self setLabels:(UILabel *) _coopSetBottom];
    [self setLabels:(UILabel *) _coopSetTop];
    [self setLabels:(UILabel *) _coopStackBottom];
    [self setLabels:(UILabel *) _coopStackTop];
    [self setLabels:(UILabel *) _toteSet];
    [self setLabels:(UILabel *) _canSet];
    [self setLabels:(UILabel *) _totalScore];
    [self setLabels:(UILabel *) _totes];
    [self setLabels:(UILabel *) _cans];
    [self setLabels:(UILabel *) _litterInCans];
    [self setLabels:(UILabel *) _dataSavedBy];
    [self setLabels:(UILabel *) _totesLandfill];
    [self setLabels:(UILabel *) _totesStep];
    [self setLabels:(UILabel *) _totesHP];
    [self setLabels:(UILabel *) _totalTotes];
    [self setLabels:(UILabel *) _canStep];
    [self setLabels:(UILabel *) _canlandfill];
    [self setLabels:(UILabel *) _teamName];
    [self setLabels:(UILabel *) _robotSet];
    [self setLabels:(UILabel *) _toteStack];
    [self setLabels:(UILabel *) _robotType];
    [self setLabels:(UILabel *) _t0];
    [self setLabels:(UILabel *) _t1];
    [self setLabels:(UILabel *) _t2];
    [self setLabels:(UILabel *) _t3];
    [self setLabels:(UILabel *) _t4];
    [self setLabels:(UILabel *) _t5];
    [self setLabels:(UILabel *) _t6];
    [self setLabels:(UILabel *) _c0];
    [self setLabels:(UILabel *) _c1];
    [self setLabels:(UILabel *) _c2];
    [self setLabels:(UILabel *) _c3];
    [self setLabels:(UILabel *) _c4];
    [self setLabels:(UILabel *) _c5];
    [self setLabels:(UILabel *) _c6];
    [self setLabels:(UILabel *) _matchType];
    [self setLabels:(UILabel *) _alliance];
    [self setLabels:(UILabel *) _teamName];

    if (_currentScore.matchNumber) {
        self.title =  [NSString stringWithFormat:@"Match %@ : Match Summary", _currentScore.matchNumber];
    }
    else {
        self.title = @"Match Summary";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setLabels:(UILabel *)label {
    //    NSLog(@"should end editing");
    if (label == _teamNumber) {
		_teamNumber.text = [NSString stringWithFormat:@"%@", _currentScore.teamNumber];
	}
    else if (label == _matchNumber) {
		_matchNumber.text = [NSString stringWithFormat:@"%@", _currentScore.matchNumber];
	}
    else if (label == _matchType) {
		_matchType.text = [MatchAccessors getMatchTypeString:_currentScore.matchType fromDictionary:_dataManager.matchTypeDictionary];
	}
    else if (label == _alliance) {
		_alliance.text = [MatchAccessors getAllianceString:_currentScore.allianceStation fromDictionary:_dataManager.allianceDictionary];
	}
    else if (label == _driverRating) {
		_driverRating.text = [NSString stringWithFormat:@"%@", _currentScore.driverRating];
	}
    else if (label == _teamName) {
		_teamName.text = [NSString stringWithFormat:@"%@", info.name];
	}
    else if (label == _knockdowns) {
		_knockdowns.text = [NSString stringWithFormat:@"%@", _currentScore.stackKnockdowns];
	}
    else if (label == _canDomTime) {
		_canDomTime.text = [NSString stringWithFormat:@"%@", _currentScore.canDominationTime];
	}
    else if (label == _canDomCans) {
		_canDomCans.text = [NSString stringWithFormat:@"%@", _currentScore.autonCansFromStep];
	}
    else if (label == _coopSetBottom) {
		_coopSetBottom.text = [NSString stringWithFormat:@"%@", _currentScore.coopSetDenominator];
	}
    else if (label == _coopSetTop) {
		_coopSetTop.text = [NSString stringWithFormat:@"%@", _currentScore.coopSetNumerator];
	}
    else if (label == _coopStackBottom) {
		_coopStackBottom.text = [NSString stringWithFormat:@"%@", _currentScore.coopStackDenominator];
	}
    else if (label == _coopStackTop) {
		_coopStackTop.text = [NSString stringWithFormat:@"%@", _currentScore.coopStackNumerator];
	}
    else if (label == _toteSet) {
		_toteSet.text = [NSString stringWithFormat:@"%@", _currentScore.autonToteSet];
	}
    else if (label == _canSet) {
		_canSet.text = [NSString stringWithFormat:@"%@", _currentScore.autonCansScored];
	}
    else if (label == _totalScore) {
		_totalScore.text = [NSString stringWithFormat:@"%@", _currentScore.totalScore];
	}
    else if (label == _totes) {
		_totes.text = [NSString stringWithFormat:@"%@", _currentScore.totalTotesScored];
	}
    else if (label == _cans) {
		_cans.text = [NSString stringWithFormat:@"%@", _currentScore.totalCansScored];
	}
    else if (label == _litterInCans) {
		_litterInCans.text = [NSString stringWithFormat:@"%@", _currentScore.litterInCan];
	}
    else if (label == _dataSavedBy) {
		_dataSavedBy.text = [NSString stringWithFormat:@"%@", _currentScore.scouter];
	}
    else if (label == _totesLandfill) {
		_totesLandfill.text = [NSString stringWithFormat:@"%@", _currentScore.toteIntakeLandfill];
	}
    else if (label == _totesStep) {
		_totesStep.text = [NSString stringWithFormat:@"%@", _currentScore.toteIntakeStep];
	}
    else if (label == _totesHP) {
		_totesHP.text = [NSString stringWithFormat:@"%@", _currentScore.toteIntakeHP];
	}
    else if (label == _totalTotes) {
		_totalTotes.text = [NSString stringWithFormat:@"%@", _currentScore.totalTotesIntake];
	}
    else if (label == _canStep) {
		_canStep.text = [NSString stringWithFormat:@"%@", _currentScore.cansFromStep];
	}
    else if (label == _canlandfill) {
		_canlandfill.text = [NSString stringWithFormat:@"%@", _currentScore.canIntakeFloor];
	}
    else if (label == _robotSet) {
		_robotSet.text = [NSString stringWithFormat:@"%@", [_currentScore.autonRobotSet boolValue] ? @"Yes": @"No"];
	}
    else if (label == _toteStack) {
		_toteStack.text = [NSString stringWithFormat:@"%@", [_currentScore.autonToteStack boolValue] ? @"Yes": @"No"];
    }
    else if (label == _robotType) {
		_robotType.text = [NSString stringWithFormat:@"%@", _currentScore.robotType];
	}
    
    else if (label == _t0) {
		_t0.text = [NSString stringWithFormat:@"%@", _currentScore.totesOn0];
	}
    else if (label == _t1) {
		_t1.text = [NSString stringWithFormat:@"%@", _currentScore.totesOn1];
	}
    else if (label == _t2) {
		_t2.text = [NSString stringWithFormat:@"%@", _currentScore.totesOn2];
	}
    else if (label == _t3) {
		_t3.text = [NSString stringWithFormat:@"%@", _currentScore.totesOn3];
	}
    else if (label == _t4) {
		_t4.text = [NSString stringWithFormat:@"%@", _currentScore.totesOn4];
	}
    else if (label == _t5) {
		_t5.text = [NSString stringWithFormat:@"%@", _currentScore.totesOn5];
	}
    else if (label == _t6) {
		_t6.text = [NSString stringWithFormat:@"%@", _currentScore.totesOn6];
	}
    else if (label == _c0) {
		_c0.text = [NSString stringWithFormat:@"%@", _currentScore.cansOn0];
	}
    else if (label == _c1) {
		_c1.text = [NSString stringWithFormat:@"%@", _currentScore.cansOn1];
	}
    else if (label == _c2) {
		_c2.text = [NSString stringWithFormat:@"%@", _currentScore.cansOn2];
	}
    else if (label == _c3) {
		_c3.text = [NSString stringWithFormat:@"%@", _currentScore.cansOn3];
	}
    else if (label == _c4) {
		_c4.text = [NSString stringWithFormat:@"%@", _currentScore.cansOn4];
	}
    else if (label == _c5) {
		_c5.text = [NSString stringWithFormat:@"%@", _currentScore.cansOn5];
	}
    else if (label == _c6) {
		_c6.text = [NSString stringWithFormat:@"%@", _currentScore.cansOn6];
	}

}
- (IBAction)goAnaylsis:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
    return;
}
- (IBAction)goScouting:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
    return;
}

  @end
