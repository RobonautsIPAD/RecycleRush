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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
