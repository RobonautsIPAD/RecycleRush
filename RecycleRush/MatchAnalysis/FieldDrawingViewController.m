//
//  FieldDrawingViewController.m
// Robonauts Scouting
//
//  Created by FRC on 2/15/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <QuartzCore/CALayer.h>
#import "FieldDrawingViewController.h"
#import "DataManager.h"
#import "MatchOverlayViewController.h"
#import "MatchData.h"
#import "TeamScore.h"
#import "FieldDrawing.h"
#import "TeamData.h"
#import "TournamentData.h"
#import "TeamAccessors.h"
#import "EnumerationDictionary.h"

@interface FieldDrawingViewController ()
@property (nonatomic, weak) IBOutlet UIButton *prevMatchButton;
@property (nonatomic, weak) IBOutlet UIButton *nextMatchButton;
@property (nonatomic, weak) IBOutlet UITextField *matchNumber;
@property (nonatomic, weak) IBOutlet UIButton *matchType;
@property (nonatomic, weak) IBOutlet UITextField *teamName;
@property (nonatomic, weak) IBOutlet UITextField *teamNumber;

@property (nonatomic, weak) IBOutlet UITextView  *notes;
@property (nonatomic, weak) IBOutlet UIImageView *fieldImage;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIButton *matchOverlayButton;
@property (weak, nonatomic) IBOutlet UIButton *autonMobility;
@property (weak, nonatomic) IBOutlet UIButton *noShow;
@property (weak, nonatomic) IBOutlet UIButton *deadOnArrival;
@property (weak, nonatomic) IBOutlet UITextField *speedRating;
@property (weak, nonatomic) IBOutlet UITextField *driverRating;
@property (weak, nonatomic) IBOutlet UITextField *fouls;
@property (weak, nonatomic) IBOutlet UITextField *scouter;

@end

@implementation FieldDrawingViewController {
    TeamScore *currentScore;
    TeamData *team;
    int currentIndex;
    NSDictionary *matchTypeDictionary;
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
    currentIndex = _startingIndex;
    currentScore = [_teamScores objectAtIndex:currentIndex];
    if (currentScore.tournamentName) {
        self.title =  [NSString stringWithFormat:@"%@ Match Analysis", currentScore.tournamentName];
    }
    else {
        self.title = @"Match Analysis";
    }
    matchTypeDictionary = [EnumerationDictionary initializeBundledDictionary:@"MatchType"];

    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gotoNextMatch:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeLeft.numberOfTouchesRequired = 1;
    swipeLeft.delegate = self;
    [self.view addGestureRecognizer:swipeLeft];
 
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gotoPrevMatch:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    swipeRight.numberOfTouchesRequired = 1;
    swipeRight.delegate = self;
    [self.view addGestureRecognizer:swipeRight];
    
    [self.view sendSubviewToBack:_backgroundImage];
    [self SetTextBoxDefaults:_matchNumber];
    [self SetBigButtonDefaults:_matchType];
    [self SetBigButtonDefaults:_prevMatchButton];
    [self SetBigButtonDefaults:_nextMatchButton];
    [self SetTextBoxDefaults:_teamName];
    [self SetTextBoxDefaults:_teamNumber];
    [self SetSmallButtonDefaults:_matchOverlayButton];

    [self SetSmallTextBoxDefaults:_speedRating];
    [self SetSmallTextBoxDefaults:_driverRating];

    [self SetSmallTextBoxDefaults:_fouls];
    [self SetSmallTextBoxDefaults:_scouter];

    

    [self setDisplayData];
}

-(void)setDisplayData {
    _matchNumber.text = [NSString stringWithFormat:@"%d", [currentScore.matchNumber intValue]];
    [_matchType setTitle:[EnumerationDictionary getKeyFromValue:currentScore.matchType forDictionary:matchTypeDictionary] forState:UIControlStateNormal];
    team = [TeamAccessors getTeam:currentScore.teamNumber fromDataManager:_dataManager];
    _teamName.text = team.name;
    _teamNumber.text = [NSString stringWithFormat:@"%d", [team.number intValue]];
    _notes.text = currentScore.notes;
    
    //NSLog(@"block = %@", currentScore.defenseBlockRating);
    _speedRating.text = [NSString stringWithFormat:@"%d", [currentScore.robotSpeed intValue]];
    _driverRating.text = [NSString stringWithFormat:@"%d", [currentScore.driverRating intValue]];

 //   [self setRadioButtonState:_autonMobility forState:[currentScore.autonMobility boolValue]];
    [self setRadioButtonState:_noShow forState:[currentScore.noShow boolValue]];
    [self setRadioButtonState:_deadOnArrival forState:[currentScore.deadOnArrival boolValue]];
    
    [self loadFieldDrawing];
}

-(void)setRadioButtonState:(UIButton *)button forState:(NSUInteger)selection {
    if (selection == -1 || selection == 0) {
        [button setImage:[UIImage imageNamed:@"RadioButton-Unselected.png"] forState:UIControlStateNormal];
    }
    else {
        [button setImage:[UIImage imageNamed:@"RadioButton-Selected.png"] forState:UIControlStateNormal];
    }
}

-(void)loadFieldDrawing {
/*    if (currentScore.fieldDrawing.trace) {
        [_fieldImage setImage:[UIImage imageWithData:currentScore.fieldDrawing.trace]];
    }
    else {
        [_fieldImage setImage:nil];
    }*/
}

- (IBAction)nextMatch:(id)sender {
    if (currentIndex < ([_teamScores count]-1)) currentIndex++;
    else currentIndex = 0;
    currentScore = [_teamScores objectAtIndex:currentIndex];
    [self setDisplayData];
}

- (IBAction)prevMatch:(id)sender {
    if (currentIndex == 0) currentIndex = [_teamScores count] - 1;
    else currentIndex--;
    currentScore = [_teamScores objectAtIndex:currentIndex];
    [self setDisplayData];
}

-(void)gotoNextMatch:(UISwipeGestureRecognizer *)gestureRecognizer {
    if (currentIndex < ([_teamScores count]-1)) currentIndex++;
    else currentIndex = 0;
    currentScore = [_teamScores objectAtIndex:currentIndex];
    [self setDisplayData];
}

-(void)gotoPrevMatch:(UISwipeGestureRecognizer *)gestureRecognizer {
    if (currentIndex == 0) currentIndex = [_teamScores count] - 1;
    else currentIndex--;
    currentScore = [_teamScores objectAtIndex:currentIndex];
    [self setDisplayData];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Segue occurs when the user selects a match out of the match list table. Receiving
    //  VC is the FieldDrawing VC.
    if ([segue.identifier isEqualToString:@"MatchOverlay"]) {
        [segue.destinationViewController setMatchList:_teamScores];
        [segue.destinationViewController setNumberTeam:team];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{   return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

-(void)SetTextBoxDefaults:(UITextField *)currentTextField {
    currentTextField.font = [UIFont fontWithName:@"Helvetica" size:24.0];
   
}

-(void)SetSmallTextBoxDefaults:(UITextField *)currentTextField {
    currentTextField.font = [UIFont fontWithName:@"Helvetica" size:18.0];
     [currentTextField setEnabled:NO];
    [currentTextField setUserInteractionEnabled:NO];
}

-(void)SetBigButtonDefaults:(UIButton *)currentButton {
    currentButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:24.0];
    // Round button corners
    CALayer *btnLayer = [currentButton layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:10.0f];
    // Apply a 1 pixel, black border
    [btnLayer setBorderWidth:1.0f];
    [btnLayer setBorderColor:[[UIColor blackColor] CGColor]];
    // Set the button Background Color
    [currentButton setBackgroundColor:[UIColor whiteColor]];
    // Set the button Text Color
    [currentButton setTitleColor:[UIColor colorWithRed:(0.0/255) green:(0.0/255) blue:(120.0/255) alpha:1.0 ]forState: UIControlStateNormal];
}

-(void)SetSmallButtonDefaults:(UIButton *)currentButton {
    currentButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    // Round button corners
    CALayer *btnLayer = [currentButton layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:10.0f];
    // Apply a 1 pixel, black border
    [btnLayer setBorderWidth:1.0f];
    [btnLayer setBorderColor:[[UIColor blackColor] CGColor]];
    // Set the button Background Color
    [currentButton setBackgroundColor:[UIColor whiteColor]];
    // Set the button Text Color
    [currentButton setTitleColor:[UIColor colorWithRed:(0.0/255) green:(0.0/255) blue:(120.0/255) alpha:1.0 ]forState: UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*NSString *match;
if ([currentScore.match.number intValue] < 10) {
    match = [NSString stringWithFormat:@"M%c%@", [currentScore.match.matchType characterAtIndex:0], [NSString stringWithFormat:@"00%d", [currentScore.match.number intValue]]];
} else if ( [currentScore.match.number intValue] < 100) {
    match = [NSString stringWithFormat:@"M%c%@", [currentScore.match.matchType characterAtIndex:0], [NSString stringWithFormat:@"0%d", [currentScore.match.number intValue]]];
} else {
    match = [NSString stringWithFormat:@"M%c%@", [currentScore.match.matchType characterAtIndex:0], [NSString stringWithFormat:@"%d", [currentScore.match.number intValue]]];
}
NSString *team;
if ([currentScore.team.number intValue] < 100) {
    team = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"00%d", [currentScore.team.number intValue]]];
} else if ( [currentScore.team.number intValue] < 1000) {
    team = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"0%d", [currentScore.team.number intValue]]];
} else {
    team = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"%d", [currentScore.team.number intValue]]];
}
fieldDrawingFile = [NSString stringWithFormat:@"%@_%@.png", match, team];
fieldDrawingPath = [baseDrawingPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", [currentScore.team.number intValue]]];
NSString *path = [fieldDrawingPath stringByAppendingPathComponent:fieldDrawingFile];
NSLog(@"Full path = %@", path);
if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
    [fieldImage setImage:[UIImage imageWithContentsOfFile:path]];
}
else {
    [fieldImage setImage:[UIImage imageNamed:@"2013_field.png"]];
    NSLog(@"Error reading field drawing file %@", fieldDrawingFile);
} */


@end
