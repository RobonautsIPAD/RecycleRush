//
//  FlagMatchViewController.m
//  RecycleRush
//
//  Created by FRC on 3/28/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import "FlagMatchViewController.h"
#import "MatchSummaryViewController.h"
#import "DataManager.h"
#import "TeamScore.h"
#import "TeamData.h"
#import "MatchAccessors.h"
#import "LNNumberpad.h"

@interface FlagMatchViewController ()
@property (weak, nonatomic) IBOutlet UITextField *redFlag;
@property (weak, nonatomic) IBOutlet UITextField *yellowFlag;
@property (weak, nonatomic) IBOutlet UITextView *robotFlagNotes;
@property (weak, nonatomic) IBOutlet UIButton *finishedButton;
@property (weak, nonatomic) IBOutlet UIButton *wowRobot;
@property (weak, nonatomic) IBOutlet UIButton *wowDriver;
@property (weak, nonatomic) IBOutlet UIButton *wowHP;
@property (weak, nonatomic) IBOutlet UIButton *blackRobot;
@property (weak, nonatomic) IBOutlet UIButton *blackDriver;
@property (weak, nonatomic) IBOutlet UIButton *blackHP;


@end

@implementation FlagMatchViewController

  BOOL dataChange;
TeamScore *currentScore;

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
    _redFlag.inputView  = [LNNumberpad defaultLNNumberpad];
    _yellowFlag.inputView  = [LNNumberpad defaultLNNumberpad];
    
    [self setRadioButtonState:_blackDriver forState:[currentScore.blacklistDriver intValue]];
    [self setRadioButtonState:_blackHP forState:[currentScore.blacklistHP intValue]];
    [self setRadioButtonState:_blackRobot forState:[currentScore.blacklistRobot intValue]];
    [self setRadioButtonState:_wowDriver forState:[currentScore.wowlistDriver intValue]];
    [self setRadioButtonState:_wowHP forState:[currentScore.wowlistHP intValue]];
    [self setRadioButtonState:_wowRobot forState:[currentScore.wowlistRobot intValue]];
    
}

-(void)setDataChange {
    currentScore.saved = [NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()];
    dataChange = TRUE;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setRadioButtonState:(UIButton *)button forState:(NSUInteger)selection {
    if (selection == -1 || selection == 0) {
        [button setImage:[UIImage imageNamed:@"RadioButton-Unselected.png"] forState:UIControlStateNormal];
    }
    else {
        [button setImage:[UIImage imageNamed:@"RadioButton-Selected.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)radioButtonTapped:(id)sender {
    if (sender == _blackDriver) { // It is on, turn it off
        if ([currentScore.blacklistDriver intValue]) {
            currentScore.blacklistDriver = [NSNumber numberWithBool:FALSE];
        }
        else { // It is off, turn it on
            currentScore.blacklistDriver = [NSNumber numberWithBool:TRUE];
        }
        [self setRadioButtonState:_blackDriver forState:[currentScore.blacklistDriver intValue]];
    }
    [self setDataChange];
}

- (IBAction)pressedFinished:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
    return;
}
- (IBAction)changedData:(id)sender {
    _redFlag.text = [NSString stringWithFormat:@"%@", currentScore.redCards];
    _yellowFlag.text = [NSString stringWithFormat:@"%@", currentScore.yellowCards];
    _robotFlagNotes.text = currentScore.foulNotes;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (void)textField2ShouldEndEditing:(UITextView *)textView {
    if (textView == _robotFlagNotes) {
		currentScore.foulNotes = _robotFlagNotes.text;
	}
}

- (void)textFieldShouldEndEditing:(UITextField *)textField {
    //    NSLog(@"should end editing");
    if (textField == _yellowFlag) {
        currentScore.yellowCards = [NSNumber numberWithInt:[_yellowFlag.text intValue]];
    }
    else if (textField == _redFlag) {
        currentScore.redCards = [NSNumber numberWithInt:[_redFlag.text intValue]];
    }

}

@end
