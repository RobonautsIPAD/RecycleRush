//
//  FieldDrawingViewController.m
// Robonauts Scouting
//
//  Created by FRC on 2/15/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "FieldDrawingViewController.h"
#import "MatchData.h"
#import "TeamScore.h"
#import "FieldDrawing.h"
#import "TeamData.h"
#import "TournamentData.h"

@interface FieldDrawingViewController ()
@end

@implementation FieldDrawingViewController {
    TeamScore *currentScore;
    int currentIndex;
    
}
@synthesize startingIndex = _startingIndex;
@synthesize teamScores = _teamScores;
@synthesize prevMatchButton = _prevMatchButton;
@synthesize nextMatchButton = _nextMatchButton;
@synthesize fieldImage = _fieldImage;
@synthesize matchNumber = _matchNumber;
@synthesize matchType = _matchType;
@synthesize teamName = _teamName;
@synthesize teamNumber = _teamNumber;
@synthesize teleOpScoreMade = _teleOpScoreMade;
@synthesize teleOpScoreShot = _teleOpScoreShot;
@synthesize teleOpHigh = _teleOpHigh;
@synthesize teleOpLow = _teleOpLow;
@synthesize teleOpMissed = _teleOpMissed;
@synthesize teleOpBlocked = _teleOpBlocked;
@synthesize autonScoreMade = _autonScoreMade;
@synthesize autonScoreShot = _autonScoreShot;
@synthesize autonHotHigh = _autonHotHigh;
@synthesize autonColdHigh = _autonColdHigh;
@synthesize autonHotLow = _autonHotLow;
@synthesize autonColdLow = _autonColdLow;
@synthesize autonBlocked = _autonBlocked;
@synthesize autonMissed = _autonMissed;
@synthesize wallPickUp = _wallPickUp;
@synthesize wall1 = _wall1;
@synthesize wall2 = _wall2;
@synthesize wall3 = _wall3;
@synthesize wall4 = _wall4;
@synthesize pickUpFLoor = _pickUpFLoor;
@synthesize pickUpHuman = _pickUpHuman;
@synthesize trussCatch = _trussCatch;
@synthesize trussThrow = _trussThrow;
@synthesize passFloor = _passFloor;
@synthesize passAir = _passAir;
@synthesize notes = _notes;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    _teamScores = nil;
    currentScore = nil;
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
    
    [self SetTextBoxDefaults:_matchNumber];
    [self SetBigButtonDefaults:_matchType];
    [self SetBigButtonDefaults:_prevMatchButton];
    [self SetBigButtonDefaults:_nextMatchButton];
    [self SetTextBoxDefaults:_teamName];
    [self SetTextBoxDefaults:_teamNumber];
    [self SetSmallTextBoxDefaults:_autonScoreMade];
    [self SetSmallTextBoxDefaults:_autonScoreShot];
    [self SetSmallTextBoxDefaults:_autonHotHigh];
    [_autonHotHigh setTextColor:[UIColor redColor]];
    [self SetSmallTextBoxDefaults:_autonColdHigh];
    [_autonColdHigh setTextColor:[UIColor blueColor]];
    [self SetSmallTextBoxDefaults:_autonHotLow];
    [_autonHotLow setTextColor:[UIColor redColor]];
    [self SetSmallTextBoxDefaults:_autonColdLow];
    [_autonColdLow setTextColor:[UIColor blueColor]];
    [self SetSmallTextBoxDefaults:_autonMissed];
    [self SetSmallTextBoxDefaults:_autonBlocked];

    [self SetSmallTextBoxDefaults:_teleOpScoreMade];
    [self SetSmallTextBoxDefaults:_teleOpScoreShot];
    [self SetSmallTextBoxDefaults:_teleOpHigh];
    [self SetSmallTextBoxDefaults:_teleOpLow];
    [self SetSmallTextBoxDefaults:_teleOpMissed];
    [self SetSmallTextBoxDefaults:_teleOpBlocked];
    
    [self SetSmallTextBoxDefaults:_pickUpFLoor];
    [self SetSmallTextBoxDefaults:_pickUpHuman];
    [self SetSmallTextBoxDefaults:_trussThrow];
    [self SetSmallTextBoxDefaults:_trussCatch];
    [self SetSmallTextBoxDefaults:_passFloor];
    [self SetSmallTextBoxDefaults:_passAir];
    
    [self SetSmallTextBoxDefaults:_wall1];
    [self SetSmallTextBoxDefaults:_wall2];
    [self SetSmallTextBoxDefaults:_wall3];
    [self SetSmallTextBoxDefaults:_wall4];

    [self setDisplayData];
}

-(void)setDisplayData {
    _matchNumber.text = [NSString stringWithFormat:@"%d", [currentScore.match.number intValue]];
    [_matchType setTitle:currentScore.match.matchType forState:UIControlStateNormal];
    _teamName.text = currentScore.team.name;
    _teamNumber.text = [NSString stringWithFormat:@"%d", [currentScore.team.number intValue]];
    _notes.text = currentScore.notes;
    _autonScoreMade.text = [NSString stringWithFormat:@"%d", [currentScore.autonShotsMade intValue]];
    _autonScoreShot.text = [NSString stringWithFormat:@"%d", [currentScore.totalAutonShots intValue]];
    _autonHotHigh.text = [NSString stringWithFormat:@"%d", [currentScore.autonHighHot intValue]];
    _autonColdHigh.text = [NSString stringWithFormat:@"%d", [currentScore.autonHighCold intValue]];
    _autonHotLow.text = [NSString stringWithFormat:@"%d", [currentScore.autonLowHot intValue]];
    _autonColdLow.text = [NSString stringWithFormat:@"%d", [currentScore.autonLowCold intValue]];
    _autonMissed.text = [NSString stringWithFormat:@"%d", [currentScore.autonMissed intValue]];
    _autonBlocked.text = [NSString stringWithFormat:@"%d", [currentScore.autonBlocks intValue]];
    
    
    _teleOpScoreMade.text = [NSString stringWithFormat:@"%d", [currentScore.teleOpShots intValue]];
    _teleOpScoreShot.text = [NSString stringWithFormat:@"%d", [currentScore.totalTeleOpShots intValue]];
    _teleOpHigh.text = [NSString stringWithFormat:@"%d", [currentScore.teleOpHigh intValue]];
    _teleOpLow.text = [NSString stringWithFormat:@"%d", [currentScore.teleOpLow intValue]];
    _teleOpMissed.text = [NSString stringWithFormat:@"%d", [currentScore.teleOpMissed intValue]];
    _teleOpBlocked.text = [NSString stringWithFormat:@"%d", [currentScore.teleOpBlocks intValue]];
    
    _wall1.text = [NSString stringWithFormat:@"%d", [currentScore.wallPickUp1 intValue]];
    _wall2.text = [NSString stringWithFormat:@"%d", [currentScore.wallPickUp2 intValue]];
    _wall3.text = [NSString stringWithFormat:@"%d", [currentScore.wallPickUp3 intValue]];
    _wall4.text = [NSString stringWithFormat:@"%d", [currentScore.wallPickUp4 intValue]];
    
    _pickUpFLoor.text = [NSString stringWithFormat:@"%d", [currentScore.floorPickUp intValue]];
    _pickUpHuman.text = [NSString stringWithFormat:@"%d", [currentScore.humanPickUp intValue]];
    _trussCatch.text = [NSString stringWithFormat:@"%d", [currentScore.trussCatch intValue]];
    _trussThrow.text = [NSString stringWithFormat:@"%d", [currentScore.trussThrow intValue]];
    _passFloor.text = [NSString stringWithFormat:@"%d", [currentScore.floorPasses intValue]];
    _passAir.text = [NSString stringWithFormat:@"%d", [currentScore.airPasses intValue]];
    
    
    [self loadFieldDrawing];
}

-(void)loadFieldDrawing {
    if (currentScore.fieldDrawing.trace) {
        [_fieldImage setImage:[UIImage imageWithData:currentScore.fieldDrawing.trace]];
    }
    else {
        // No field drawing set in data base. Set blank field image.
        NSLog(@"Error: No stored field drawing");
        [_fieldImage setImage:[UIImage imageNamed:@"2014_field.png"]];
    }
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
