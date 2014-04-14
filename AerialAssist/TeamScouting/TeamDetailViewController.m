//
//  TeamDetailViewController.m
// Robonauts Scouting
//
//  Created by Kris Pettinger on 6/24/12.
//  Copyright (c) 2012 __RobonautsScouting__. All rights reserved.
//

#import <QuartzCore/CALayer.h>
#import "TeamDetailViewController.h"
#import "TournamentData.h"
#import "TeamData.h"
#import "TeamScore.h"
#import "CreateMatch.h"
#import "MatchData.h"
#import "DataManager.h"
#import "Regional.h"
#import "Photo.h"
#import "PhotoCell.h"
#import "PhotoAttributes.h"
#import "DriveTypeDictionary.h"
#import "TrooleanDictionary.h"
#import "IntakeTypeDictionary.h"
#import "ShooterTypeDictionary.h"
#import "TunnelDictionary.h"
#import "QuadStateDictionary.h"
#import "NumberEnumDictionary.h"
#import "FieldDrawingViewController.h"
#import "MatchOverlayViewController.h"
#import "FullSizeViewer.h"
#import <ImageIO/ImageIO.h>
#import <ImageIO/CGImageProperties.h>

@interface TeamDetailViewController ()
    @property (nonatomic, weak) IBOutlet UICollectionView *photoCollectionView;
    @property (weak, nonatomic) IBOutlet UIButton *tunnelButton;
//    @property (nonatomic, weak) IBOutlet UIButton *autonCapacityButton;
    @property (nonatomic, weak) IBOutlet UIButton *autonMobilityButton;
    @property (nonatomic, weak) IBOutlet UIButton *catcherButton;
    @property (nonatomic, weak) IBOutlet UIButton *goalieButton;
    @property (nonatomic, weak) IBOutlet UIButton *hotTrackerButton;
//    @property (nonatomic, weak) IBOutlet UIButton *robotClassButton;
    @property (nonatomic, weak) IBOutlet UIButton *shooterButton;
    @property (nonatomic, weak) IBOutlet UITextField *ballReleaseHeightText;
    @property (nonatomic, weak) IBOutlet UIButton *classAButton;
    @property (nonatomic, weak) IBOutlet UIButton *classBButton;
    @property (nonatomic, weak) IBOutlet UIButton *classCButton;
    @property (nonatomic, weak) IBOutlet UIButton *classDButton;
    @property (nonatomic, weak) IBOutlet UIButton *classEButton;
    @property (nonatomic, weak) IBOutlet UIButton *classFButton;
    @property (weak, nonatomic) IBOutlet UIButton *matchOverlayButton;
    @property (weak, nonatomic) IBOutlet UIButton *spitBotButton;
@end


@implementation TeamDetailViewController {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSString *deviceName;
    DriveTypeDictionary *driveDictionary;
    IntakeTypeDictionary *intakeDictionary;
    UIView *matchHeader;
    NSArray *matchList;
    UIView *regionalHeader;
    NSArray *regionalList;
    NSString *robotPhotoLibrary;
    NSString *robotThumbnailLibrary;
    BOOL imageIsFullScreen;
    CGRect imagePrevFrame;
    id popUp;
    id action;
    BOOL dataChange;
    PhotoAttributes *primePhoto;
    BOOL getAssetURL;
    NSFileManager *fileManager;

    PopUpPickerViewController *trooleanPicker;
    UIPopoverController *trooleanPickerPopover;
    NSMutableArray *trooleanList;
    TrooleanDictionary *trooleanDictionary;

    PopUpPickerViewController *quadStatePicker;
    UIPopoverController *quadStatePickerPopover;
    NSMutableArray *quadStateList;
    QuadStateDictionary *quadStateDictionary;

    PopUpPickerViewController *shooterPicker;
    UIPopoverController *shooterPickerPopover;
    NSMutableArray *shooterList;
    ShooterTypeDictionary *shooterDictionary;
    
    PopUpPickerViewController *tunnelPicker;
    UIPopoverController *tunnelPickerPopover;
    TunnelDictionary *tunnelDictionary;
    NSMutableArray *tunnelList;

    NSArray *photoList;
    NSString *selectedPhoto;
}

@synthesize dataManager = _dataManager;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize teamIndex = _teamIndex;
@synthesize team = _team;

@synthesize driveTypePicker = _driveTypePicker;
@synthesize drivePickerPopover = _drivePickerPopover;
@synthesize driveTypeList = _driveTypeList;
@synthesize driveType = _driveType;

@synthesize intakePicker = _intakePicker;
@synthesize intakePickerPopover = _intakePickerPopover;
@synthesize intakeList = _intakeList;
@synthesize intakeType = _intakeType;

@synthesize numberText = _numberText;
@synthesize nameTextField = _nameTextField;
@synthesize notesViewField = _notesViewField;

@synthesize shootingLevel = _shootingLevel;
@synthesize maxHeight = _maxHeight;
@synthesize minHeight = _minHeight;
@synthesize wheelType = _wheelType;
@synthesize nwheels = _nwheels;
@synthesize wheelDiameter = _wheelDiameter;
@synthesize cims = _cims;

@synthesize pictureController = _pictureController;
@synthesize imageView = _imageView;
@synthesize cameraBtn = _cameraBtn;
@synthesize imagePickerController = _imagePickerController;

@synthesize matchInfo = _matchInfo;
@synthesize regionalInfo = _regionalInfo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
} 

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    // Check to make sure the data manager has been initialized
    if (!_dataManager) {
        _dataManager = [[DataManager alloc] init];
    }

    // Set the notification to receive information after a photo has been saved
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoSaved:) name:@"photoSaved" object:nil];

    // Set the notification to receive information after a photo has been retrieved
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoRetrieved:) name:@"photoRetrieved" object:nil];

    // Get the preferences needed for this VC
    prefs = [NSUserDefaults standardUserDefaults];
    tournamentName = [prefs objectForKey:@"tournament"];
    deviceName = [prefs objectForKey:@"deviceName"];

    [self createPhotoDirectories];
 
    // Set defaults for all the text boxes
    [self SetTextBoxDefaults:_numberText];
    [self SetTextBoxDefaults:_nameTextField];
    [self SetTextBoxDefaults:_ballReleaseHeightText];
    [self SetTextBoxDefaults:_minHeight];
    [self SetTextBoxDefaults:_maxHeight];
    [self SetTextBoxDefaults:_wheelType];
    [self SetTextBoxDefaults:_nwheels];
    [self SetTextBoxDefaults:_wheelDiameter];
    [self SetTextBoxDefaults:_cims];
    [self SetTextBoxDefaults:_ballReleaseHeightText];
    [self SetBigButtonDefaults:_tunnelButton];
    [self SetBigButtonDefaults:_autonMobilityButton];
    [self SetBigButtonDefaults:_catcherButton];
    [self SetBigButtonDefaults:_spitBotButton];
    [self SetBigButtonDefaults:_goalieButton];
    [self SetBigButtonDefaults:_hotTrackerButton];
    [self SetBigButtonDefaults:_shooterButton];
    [self SetBigButtonDefaults:_matchOverlayButton];

    //sets text colors for "shoots" buttons relative to UIControllerState
    
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageIsFullScreen = FALSE;
    UITapGestureRecognizer *photoTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoTapped:)];
    photoTapGestureRecognizer.numberOfTapsRequired = 1;
    [_imageView addGestureRecognizer:photoTapGestureRecognizer];
    [_photoCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"PhotoCell"];
    primePhoto = [[PhotoAttributes alloc] init];
    getAssetURL = FALSE;


    // Initialize the headers for the regional and match tables
    [self createRegionalHeader];
    [self createMatchHeader];
    
    // Initialize the choices for the pop-up menus.
    driveDictionary = [[DriveTypeDictionary alloc] init];
    _driveTypeList = [[driveDictionary getDriveTypes] mutableCopy];
    intakeDictionary = [[IntakeTypeDictionary alloc] init];
    _intakeList = [[intakeDictionary getIntakeTypes] mutableCopy];
    trooleanDictionary = [[TrooleanDictionary alloc] init];
    trooleanList = [[trooleanDictionary getTrooleanTypes] mutableCopy];
    shooterDictionary = [[ShooterTypeDictionary alloc] init];
    shooterList = [[shooterDictionary getShooterTypes] mutableCopy];
    tunnelDictionary = [[TunnelDictionary alloc] init];
    tunnelList = [[tunnelDictionary getTunnelTypes] mutableCopy];
    quadStateDictionary = [[QuadStateDictionary alloc] init];
    quadStateList = [[quadStateDictionary getQuadTypes] mutableCopy];
    
    // Team Detail can be reached from different views. If the parent VC is Team List VC, then
    //  the whole team list is passed in through the fetchedResultsController, so the prev and next
    //  buttons are activated. If the parent is the Mason VC, then only just one team is passed in, so
    //  there are no next and previous teams in the list, so the buttons should be hidden.
    if (_fetchedResultsController && _teamIndex) {
        _team = [_fetchedResultsController objectAtIndexPath:_teamIndex];
        [_prevTeamButton setHidden:NO];
        [_nextTeamButton setHidden:NO];
    }
    else {
        [_prevTeamButton setHidden:YES];
        [_nextTeamButton setHidden:YES];
    }
    
    [self showTeam];
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated
{
}

-(void)setDataChange {
    //  A change to one of the database fields has been detected. Set the time tag for the
    //  saved filed and set the device name into the field to indicated who made the change.
    _team.saved = [NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()];
    _team.savedBy = deviceName;
    NSLog(@"Saved by:%@\tTime = %@", _team.savedBy, _team.saved);
    dataChange = TRUE;
}

-(void)checkDataStatus {
    // Check to see if a data change has been made. If so, save the database.
    // At some point, we really need to decide on real error handling.
    if (dataChange) {
        NSError *error;
        _team.saved = [NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()];
        if (![_dataManager.managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        dataChange = NO;
    }
}

-(void)createRegionalHeader {
    // Header for the regional data table
    regionalHeader = [[UIView alloc] initWithFrame:CGRectMake(0,0,768,35)];
    regionalHeader.backgroundColor = [UIColor lightGrayColor];
    regionalHeader.opaque = YES;
    
	UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 35)];
	label1.text = @"Week";
    label1.backgroundColor = [UIColor clearColor];
    [regionalHeader addSubview:label1];
    
	UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(95, 0, 200, 35)];
	label2.text = @"Regional";
    label2.backgroundColor = [UIColor clearColor];
    [regionalHeader addSubview:label2];
    
 	UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(205, 0, 200, 35)];
	label3.text = @"Rank";
    label3.backgroundColor = [UIColor clearColor];
    [regionalHeader addSubview:label3];
    
	UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(270, 0, 200, 35)];
	label4.text = @"Record";
    label4.backgroundColor = [UIColor clearColor];
    [regionalHeader addSubview:label4];
    
	UILabel *label5 = [[UILabel alloc] initWithFrame:CGRectMake(365, 0, 200, 35)];
	label5.text = @"CCWM";
    label5.backgroundColor = [UIColor clearColor];
    [regionalHeader addSubview:label5];
    
	UILabel *label6 = [[UILabel alloc] initWithFrame:CGRectMake(460, 0, 200, 35)];
	label6.text = @"OPR";
    label6.backgroundColor = [UIColor clearColor];
    [regionalHeader addSubview:label6];
    
    UILabel *label7 = [[UILabel alloc] initWithFrame:CGRectMake(555, 0, 200, 35)];
	label7.text = @"Elim Position";
    label7.backgroundColor = [UIColor clearColor];
    [regionalHeader addSubview:label7];
    
    UILabel *label8 = [[UILabel alloc] initWithFrame:CGRectMake(730, 0, 200, 35)];
	label8.text = @"Awards";
    label8.backgroundColor = [UIColor clearColor];
    [regionalHeader addSubview:label8];
}

-(void)createMatchHeader {
    // Header for the match list table
    matchHeader = [[UIView alloc] initWithFrame:CGRectMake(0,0,768,50)];
    matchHeader.backgroundColor = [UIColor lightGrayColor];
    matchHeader.opaque = YES;
    
	UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 35)];
	label1.text = @"Match";
    label1.backgroundColor = [UIColor clearColor];
    [matchHeader addSubview:label1];
    
	UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(105, 0, 200, 35)];
	label2.text = @"Type";
    label2.backgroundColor = [UIColor clearColor];
    [matchHeader addSubview:label2];
    
 	UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(235, 0, 200, 35)];
	label3.text = @"Results";
    label3.backgroundColor = [UIColor clearColor];
    [matchHeader addSubview:label3];
    
}

-(void)showTeam {
    //  Set the display fields for the currently selected team.
    self.title = [NSString stringWithFormat:@"%d - %@", [_team.number intValue], _team.name];
    _numberText.text = [NSString stringWithFormat:@"%d", [_team.number intValue]];
    _nameTextField.text = _team.name;
    _notesViewField.text = _team.notes;
    _shootingLevel.text = @"";
    _minHeight.text = [NSString stringWithFormat:@"%.1f", [_team.minHeight floatValue]];
    _maxHeight.text = [NSString stringWithFormat:@"%.1f", [_team.maxHeight floatValue]];
    _wheelType.text = _team.wheelType;
    _nwheels.text = [NSString stringWithFormat:@"%d", [_team.nwheels intValue]];
    _wheelDiameter.text = [NSString stringWithFormat:@"%.1f", [_team.wheelDiameter floatValue]];
    _cims.text = [NSString stringWithFormat:@"%.0f", [_team.cims floatValue]];
    _ballReleaseHeightText.text = [NSString stringWithFormat:@"%.0f  ", [_team.ballReleaseHeight floatValue]];
    
    NSSortDescriptor *regionalSort = [NSSortDescriptor sortDescriptorWithKey:@"week" ascending:YES];
    regionalList = [[_team.regional allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:regionalSort]];
    
    matchList = [[[CreateMatch alloc] initWithDataManager:_dataManager] getMatchListTournament:_team.number forTournament:tournamentName];
    
    [_driveType setTitle:[driveDictionary getString:_team.driveTrainType] forState:UIControlStateNormal];
    [_intakeType setTitle:[intakeDictionary getString:_team.intake] forState:UIControlStateNormal];
    [_shooterButton setTitle:[shooterDictionary getString:_team.shooterType] forState:UIControlStateNormal];
    [_goalieButton setTitle:[trooleanDictionary getString:_team.goalie] forState:UIControlStateNormal];
    [_catcherButton setTitle:[trooleanDictionary getString:_team.catcher] forState:UIControlStateNormal];
    [_tunnelButton setTitle:[tunnelDictionary getString:_team.tunneler] forState:UIControlStateNormal];
    [_spitBotButton setTitle:[quadStateDictionary getString:_team.spitBot] forState:UIControlStateNormal];
    [_autonMobilityButton setTitle:[trooleanDictionary getString:_team.autonMobility] forState:UIControlStateNormal];
    [_hotTrackerButton setTitle:[trooleanDictionary getString:_team.hotTracker] forState:UIControlStateNormal];

    [self setRadioButtonState:_classAButton forState:[_team.classA intValue]];
    [self setRadioButtonState:_classBButton forState:[_team.classB intValue]];
    [self setRadioButtonState:_classCButton forState:[_team.classC intValue]];
    [self setRadioButtonState:_classDButton forState:[_team.classD intValue]];
    [self setRadioButtonState:_classEButton forState:[_team.classE intValue]];
    [self setRadioButtonState:_classFButton forState:[_team.classF intValue]];
    [self getPhoto];
    photoList = [self getPhotoList];
    [_photoCollectionView reloadData];
    dataChange = NO;
}

-(void)setRadioButtonState:(UIButton *)button forState:(NSUInteger)selection {
    if (selection == -1 || selection == 0) {
        [button setImage:[UIImage imageNamed:@"RadioButton-Unselected.png"] forState:UIControlStateNormal];
    }
    else {
        [button setImage:[UIImage imageNamed:@"RadioButton-Selected.png"] forState:UIControlStateNormal];
    }
}


-(NSInteger)getNumberOfTeams {
    return [[[_fetchedResultsController sections] objectAtIndex:0] numberOfObjects];
}

-(IBAction)PrevButton {
    //  Access the previous team in the list
    [self checkDataStatus];
    NSInteger nteams = [self getNumberOfTeams];
    NSInteger row = _teamIndex.row;
    if (row > 0) row--;
    else row =  nteams-1;
    _teamIndex = [NSIndexPath indexPathForRow:row inSection:0];
    _team = [_fetchedResultsController objectAtIndexPath:_teamIndex];
    [self showTeam];
}

-(IBAction)NextButton {
    //  Access the next team in the list
    [self checkDataStatus];
    NSInteger nteams = [self getNumberOfTeams];
    NSInteger row = _teamIndex.row;
    if (row < (nteams-1)) row++;
    else row = 0;
    _teamIndex = [NSIndexPath indexPathForRow:row inSection:0];
    _team = [_fetchedResultsController objectAtIndexPath:_teamIndex];
    [self showTeam];
}

- (IBAction)radioButtonTapped:(id)sender {
    if (sender == _classAButton) {
        if ([_team.classA intValue] == -1 || [_team.classA intValue] == 0) {
            _team.classA = [NSNumber numberWithInt:1];
        }
        else {
            _team.classA = [NSNumber numberWithInt:0];
        }
        [self setRadioButtonState:_classAButton forState:[_team.classA intValue]];
    }
    if (sender == _classBButton) {
        if ([_team.classB intValue] == -1 || [_team.classB intValue] == 0) {
            _team.classB = [NSNumber numberWithInt:1];
        }
        else {
            _team.classB = [NSNumber numberWithInt:0];
        }
        [self setRadioButtonState:_classBButton forState:[_team.classB intValue]];
    }
    if (sender == _classCButton) {
        if ([_team.classC intValue] == -1 || [_team.classC intValue] == 0) {
            _team.classC = [NSNumber numberWithInt:1];
        }
        else {
            _team.classC = [NSNumber numberWithInt:0];
        }
        [self setRadioButtonState:_classCButton forState:[_team.classC intValue]];
    }
    if (sender == _classDButton) {
        if ([_team.classD intValue] == -1 || [_team.classD intValue] == 0) {
            _team.classD = [NSNumber numberWithInt:1];
        }
        else {
            _team.classD = [NSNumber numberWithInt:0];
        }
        [self setRadioButtonState:_classDButton forState:[_team.classD intValue]];
    }
    if (sender == _classEButton) {
        if ([_team.classE intValue] == -1 || [_team.classE intValue] == 0) {
            _team.classE = [NSNumber numberWithInt:1];
        }
        else {
            _team.classE = [NSNumber numberWithInt:0];
        }
        [self setRadioButtonState:_classEButton forState:[_team.classE intValue]];
    }
    if (sender == _classFButton) {
        if ([_team.classF intValue] == -1 || [_team.classF intValue] == 0) {
            _team.classF = [NSNumber numberWithInt:1];
        }
        else {
            _team.classF = [NSNumber numberWithInt:0];
        }
        [self setRadioButtonState:_classFButton forState:[_team.classF intValue]];
    }
    [self setDataChange];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self checkDataStatus];
    [super viewWillDisappear:animated];
}

-(IBAction)detailChanged:(id)sender {
    // One of the pop-up menus has been selected. Determine which one
    //  and push the correct pop-up VC
    UIButton * PressedButton = (UIButton*)sender;
    popUp = PressedButton;
    if (PressedButton == _intakeType) {
        if (_intakePicker == nil) {
            _intakePicker = [[PopUpPickerViewController alloc]
                             initWithStyle:UITableViewStylePlain];
            _intakePicker.delegate = self;
            _intakePicker.pickerChoices = _intakeList;
        }
        if (!_intakePickerPopover) {
            self.intakePickerPopover = [[UIPopoverController alloc]
                                            initWithContentViewController:_intakePicker];
        }
        [self.intakePickerPopover presentPopoverFromRect:PressedButton.bounds inView:PressedButton
                                permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else if (PressedButton == _driveType) {
        if (_driveTypePicker == nil) {
            _driveTypePicker = [[PopUpPickerViewController alloc]
                             initWithStyle:UITableViewStylePlain];
            _driveTypePicker.delegate = self;
            _driveTypePicker.pickerChoices = _driveTypeList;
        }
        if (!_drivePickerPopover) {
            self.drivePickerPopover = [[UIPopoverController alloc]
                                            initWithContentViewController:_driveTypePicker];
        }
        [self.drivePickerPopover presentPopoverFromRect:PressedButton.bounds inView:PressedButton
                                permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else if (PressedButton == _shooterButton) {
        if (shooterPicker == nil) {
            shooterPicker = [[PopUpPickerViewController alloc]
                                initWithStyle:UITableViewStylePlain];
            shooterPicker.delegate = self;
            shooterPicker.pickerChoices = shooterList;
        }
        if (!shooterPickerPopover) {
            shooterPickerPopover = [[UIPopoverController alloc]
                                    initWithContentViewController:shooterPicker];
        }
        [shooterPickerPopover presentPopoverFromRect:PressedButton.bounds inView:PressedButton
                               permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else if (PressedButton == _tunnelButton) {
        if (tunnelPicker == nil) {
            tunnelPicker = [[PopUpPickerViewController alloc]
                             initWithStyle:UITableViewStylePlain];
            tunnelPicker.delegate = self;
            tunnelPicker.pickerChoices = tunnelList;
        }
        if (!tunnelPickerPopover) {
            tunnelPickerPopover = [[UIPopoverController alloc]
                                          initWithContentViewController:tunnelPicker];
        }
        [tunnelPickerPopover presentPopoverFromRect:PressedButton.bounds inView:PressedButton
                            permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else if (PressedButton == _spitBotButton) {
        if (quadStatePicker == nil) {
            quadStatePicker = [[PopUpPickerViewController alloc]
                            initWithStyle:UITableViewStylePlain];
            quadStatePicker.delegate = self;
            quadStatePicker.pickerChoices = quadStateList;
        }
        if (!quadStatePickerPopover) {
            quadStatePickerPopover = [[UIPopoverController alloc]
                                   initWithContentViewController:quadStatePicker];
        }
        [quadStatePickerPopover presentPopoverFromRect:PressedButton.bounds inView:PressedButton
                           permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else if (PressedButton == _autonMobilityButton || PressedButton == _hotTrackerButton || PressedButton == _goalieButton ||
             PressedButton == _catcherButton) {
        if (trooleanPicker == nil) {
            trooleanPicker = [[PopUpPickerViewController alloc]
                                   initWithStyle:UITableViewStylePlain];
            trooleanPicker.delegate = self;
            trooleanPicker.pickerChoices = trooleanList;
        }
        if (!trooleanPickerPopover) {
            trooleanPickerPopover = [[UIPopoverController alloc]
                                        initWithContentViewController:trooleanPicker];
        }
        [trooleanPickerPopover presentPopoverFromRect:PressedButton.bounds inView:PressedButton
                                  permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

-(NSNumber *)changeSelected:(NSString *)newPick forButton:(UIButton *)button forDictionary:dictionary {
    NSNumber *valueSelected;
    valueSelected = [dictionary getEnumValue:newPick];
    [button setTitle:[dictionary getString:valueSelected] forState:UIControlStateNormal];

    [self setDataChange];
    return valueSelected;
}

- (void)pickerSelected:(NSString *)newPick {
    // The user has made a selection on one of the pop-ups. Dismiss the pop-up
    //  and call the correct method to change the right field.
    if (popUp == _driveType) {
        [_drivePickerPopover dismissPopoverAnimated:YES];
        _team.driveTrainType = [self changeSelected:newPick forButton:popUp forDictionary:driveDictionary];
    }
    else if (popUp == _intakeType) {
        [_intakePickerPopover dismissPopoverAnimated:YES];
        _team.intake = [self changeSelected:newPick forButton:popUp forDictionary:intakeDictionary];
    }
    else if (popUp == _shooterButton) {
        [shooterPickerPopover dismissPopoverAnimated:YES];
        _team.shooterType = [self changeSelected:newPick forButton:popUp forDictionary:shooterDictionary];
    }
    else if (popUp == _tunnelButton) {
        [tunnelPickerPopover dismissPopoverAnimated:YES];
        _team.tunneler = [self changeSelected:newPick forButton:popUp forDictionary:tunnelDictionary];
    }
    else if (popUp == _spitBotButton) {
        [quadStatePickerPopover dismissPopoverAnimated:YES];
        _team.spitBot = [self changeSelected:newPick forButton:popUp forDictionary:quadStateDictionary];
    }
    else if (popUp == _autonMobilityButton) {
        [trooleanPickerPopover dismissPopoverAnimated:YES];
        _team.autonMobility = [self changeSelected:newPick forButton:popUp forDictionary:trooleanDictionary];
    }
    else if (popUp == _catcherButton) {
        [trooleanPickerPopover dismissPopoverAnimated:YES];
        _team.catcher = [self changeSelected:newPick forButton:popUp forDictionary:trooleanDictionary];
    }
    else if (popUp == _goalieButton) {
        [trooleanPickerPopover dismissPopoverAnimated:YES];
        _team.goalie = [self changeSelected:newPick forButton:popUp forDictionary:trooleanDictionary];
    }
    else if (popUp == _hotTrackerButton) {
        [trooleanPickerPopover dismissPopoverAnimated:YES];
        _team.hotTracker = [self changeSelected:newPick forButton:popUp forDictionary:trooleanDictionary];;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self setDataChange];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
//    NSLog(@"team should end editing");
    if (textField == _nameTextField) {
		_team.name = _nameTextField.text;
	}
	else if (textField == _ballReleaseHeightText) {
		_team.ballReleaseHeight = [NSNumber numberWithFloat:[_ballReleaseHeightText.text floatValue]];
	}
	else if (textField == _shootingLevel) {
	//	_team.shootsTo = @"";
	}
	else if (textField == _minHeight) {
		_team.minHeight = [NSNumber numberWithFloat:[_minHeight.text floatValue]];
	}
	else if (textField == _maxHeight) {
		_team.maxHeight = [NSNumber numberWithFloat:[_maxHeight.text floatValue]];
	}
	else if (textField == _wheelType) {
		_team.wheelType = _wheelType.text;
	}
	else if (textField == _nwheels) {
		_team.nwheels = [NSNumber numberWithInt:[_nwheels.text floatValue]];
	}
	else if (textField == _wheelDiameter) {
		_team.wheelDiameter = [NSNumber numberWithFloat:[_wheelDiameter.text floatValue]];
	}
	else if (textField == _cims) {
		_team.cims = [NSNumber numberWithInt:[_cims.text intValue]];
	}

	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Limit these text fields to numbers only.
    if (textField == _nameTextField || textField == _wheelType || textField == _shootingLevel)  return YES;
    
    NSString *resultingString = [textField.text stringByReplacingCharactersInRange: range withString: string];
    
    // This allows backspace
    if ([resultingString length] == 0) {
        return true;
    }
    if (textField == _cims || textField == _nwheels || textField == _numberText) {
        NSInteger holder;
        NSScanner *scan = [NSScanner scannerWithString: resultingString];
        
        return [scan scanInteger: &holder] && [scan isAtEnd];
    }
    else {
        float holder;
        NSScanner *scan = [NSScanner scannerWithString: resultingString];
        
        return [scan scanFloat: &holder] && [scan isAtEnd];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self setDataChange];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    _team.notes = _notesViewField.text;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView; {
    return YES;
}

-(void)getPhoto {
    _imageView.image = nil;
    _imageView.userInteractionEnabled = YES;
    if (!_team.primePhoto) return;
    NSString *fullPath = [robotPhotoLibrary stringByAppendingPathComponent:_team.primePhoto];
    [_imageView setImage:[UIImage imageWithContentsOfFile:fullPath]];
}

-(NSArray *)getPhotoList {
    NSString *baseName = [self createPhotoName];
    NSError *error;
    NSArray *thumbNailDirectory = [fileManager contentsOfDirectoryAtPath:robotThumbnailLibrary error:&error];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", baseName];
    NSArray *list = [thumbNailDirectory filteredArrayUsingPredicate:pred];
    return list;
}

-(void) takePhoto {
    //  Use the camera to take a new robot photo
    if (!_imagePickerController) {
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
        _imagePickerController.allowsEditing = NO;
    }
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera]) {
        _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        _imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }
    [self presentViewController:_imagePickerController animated:YES completion:Nil];
}

- (void)choosePhoto {
    if (!_imagePickerController) {
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
        _imagePickerController.delegate = self;
    }
    _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;// UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    if (!_pictureController) {
        _pictureController = [[UIPopoverController alloc]
                                  initWithContentViewController:_imagePickerController];
        _pictureController.delegate = self;
    }
    [_pictureController presentPopoverFromRect:_cameraBtn.bounds inView:_cameraBtn
                      permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    _imageView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSString *photoNameBase = [self createPhotoName];
    // Use the time to create unique photo names
    float currentTime = CFAbsoluteTimeGetCurrent();
    // Create full sized photo name
    NSString *photoName = [photoNameBase stringByAppendingString:[NSString stringWithFormat:@"_%.0f.jpg", currentTime]];
    NSString *fullPath = [robotPhotoLibrary stringByAppendingPathComponent:photoName];
    if ([fileManager fileExistsAtPath:fullPath]) {
        currentTime /= 2;
        fullPath = [robotPhotoLibrary stringByAppendingPathComponent:photoName];
    }
    
    NSData *imageData = UIImageJPEGRepresentation(_imageView.image, 1.0);
    [imageData writeToFile:fullPath atomically:YES];
    _team.primePhoto = photoName;

    // Create and save thumbnail
    fullPath = [robotThumbnailLibrary stringByAppendingPathComponent:photoName];
    CGImageSourceRef myImageSource = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
    CFDictionaryRef options = (__bridge CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:
                                                         (id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailWithTransform,
                                                         (id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailFromImageIfAbsent,
                                                         (id)[NSNumber numberWithFloat:100], (id)kCGImageSourceThumbnailMaxPixelSize,
                                                         nil];
    CGImageRef myThumbnailImage = CGImageSourceCreateThumbnailAtIndex(myImageSource, 0, options);
    UIImage *thumbnail = [UIImage imageWithCGImage:myThumbnailImage];
    [UIImageJPEGRepresentation(thumbnail, 1.0) writeToFile:fullPath atomically:YES];
    CGImageRelease(myThumbnailImage);

    // add photo to photo list
    // set as prime photo
//    [self addTeamPhotoRecord:_team forPhoto:photoName forThumbNail:thumbNailName];
    [self setDataChange];
    [self.pictureController dismissPopoverAnimated:true];
    NSLog(@"image picker finish");
    [picker dismissViewControllerAnimated:YES completion:Nil];
}

- (IBAction)photoControllerActionSheet:(id)sender {
    action = sender;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Existing",  nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showFromRect:_cameraBtn.frame inView:self.view animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (action == _cameraBtn) {
        if (buttonIndex == 0) {
            [self takePhoto];
        } else if (buttonIndex == 1) {
            [self choosePhoto];
        }
    }
    else if (action == _photoCollectionView) {
        if (buttonIndex == 0) {
            NSString *fullPath = [robotPhotoLibrary stringByAppendingPathComponent:selectedPhoto];
            _team.primePhoto = selectedPhoto;
            [_imageView setImage:[UIImage imageWithContentsOfFile:fullPath]];
            [self setDataChange];
        }
        if (buttonIndex == 1) {
            NSString *fullPath = [robotPhotoLibrary stringByAppendingPathComponent:selectedPhoto];
            FullSizeViewer *photoViewer = [[FullSizeViewer alloc] init];
            photoViewer.fullImage = [UIImage imageWithContentsOfFile:fullPath];
            [self.navigationController pushViewController:photoViewer animated:YES];
        }
        if (buttonIndex == 2) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Really delete?" message:@"Do you really want to delete this photo?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
            [alert addButtonWithTitle:@"Yes"];
            [alert show];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSError *error;
        NSString *fullPath = [robotPhotoLibrary stringByAppendingPathComponent:selectedPhoto];
        [fileManager removeItemAtPath:fullPath error:&error];
        fullPath = [robotThumbnailLibrary stringByAppendingPathComponent:selectedPhoto];
        [fileManager removeItemAtPath:fullPath error:&error];
        if ([selectedPhoto isEqualToString:_team.primePhoto]) {
            _team.primePhoto = nil;
            [_imageView setImage:nil];
            [self setDataChange];
        }
        photoList = [self getPhotoList];
        [_photoCollectionView reloadData];
    }
}

-(void)photoTapped:(UITapGestureRecognizer *)gestureRecognizer {
    FullSizeViewer *photoViewer = [[FullSizeViewer alloc] init];
    photoViewer.fullImage = _imageView.image;
//    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.navigationController pushViewController:photoViewer animated:YES];
}

-(void)createPhotoDirectories {
    // Set and create the robot photo directories
    fileManager = [NSFileManager defaultManager];
    NSString *library = [self applicationDocumentsDirectory];
    robotPhotoLibrary = [library stringByAppendingPathComponent:[NSString stringWithFormat:@"RobotPhotos/Images"]];
    // Check if robot directory exists, if not, create it
    if (![fileManager fileExistsAtPath:robotPhotoLibrary isDirectory:NO]) {
        if (![fileManager createDirectoryAtPath:robotPhotoLibrary
                                      withIntermediateDirectories: YES
                                                       attributes: nil
                                                            error: NULL]) {
            NSLog(@"Dreadful error creating directory to save photos");
        }
    }
    robotThumbnailLibrary = [library stringByAppendingPathComponent:[NSString stringWithFormat:@"RobotPhotos/Thumbnails"]];
    if (![fileManager fileExistsAtPath:robotThumbnailLibrary isDirectory:NO]) {
        if (![fileManager createDirectoryAtPath:robotThumbnailLibrary
                                      withIntermediateDirectories: YES
                                                       attributes: nil
                                                            error: NULL]) {
            NSLog(@"Dreadful error creating directory to save thumbnails");
        }
    }
}

-(NSString *)createPhotoName {
    NSString *number;
    if ([_team.number intValue] < 100) {
        number = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"00%d", [_team.number intValue]]];
    } else if ( [_team.number intValue] < 1000) {
        number = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"0%d", [_team.number intValue]]];
    } else {
        number = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"%d", [_team.number intValue]]];
    }
    return number;
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    NSInteger photoCount = [photoList count];
    if (photoCount > 0) [_photoCollectionView setHidden:NO];
    else [_photoCollectionView setHidden:YES];
    return photoCount;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"thumbnail" forIndexPath:indexPath];
    NSString *fullPath = [robotThumbnailLibrary stringByAppendingPathComponent:[photoList objectAtIndex:indexPath.row]];
    cell.thumbnail = [UIImage imageWithContentsOfFile:fullPath];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath  {
    action = _photoCollectionView;
    selectedPhoto = [photoList objectAtIndex:indexPath.row];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Set as Prime", @"Show Full Screen",  @"Delete Photo", nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showFromRect:_cameraBtn.frame inView:self.view animated:YES];}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(50, 50);
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Segue occurs when the user selects a match out of the match list table. Receiving
    //  VC is the FieldDrawing VC.
    if ([segue.identifier isEqualToString:@"MatchSchedule"]) {
        NSIndexPath *indexPath = [self.matchInfo indexPathForCell:sender];
        [segue.destinationViewController setTeamScores:matchList];
        [segue.destinationViewController setStartingIndex:indexPath.row];
        [_matchInfo deselectRowAtIndexPath:indexPath animated:YES];
    }
    else if ([segue.identifier isEqualToString:@"MatchOverlay"]) {
        [segue.destinationViewController setMatchList:matchList];
        [segue.destinationViewController setNumberTeam:_team];
    }
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (tableView == _regionalInfo) return regionalHeader;
    if (tableView == _matchInfo) return matchHeader;
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _regionalInfo) return [regionalList count];
    else return [matchList count];
 
}

- (void)configureRegionalCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Regional *regional = [regionalList objectAtIndex:indexPath.row];
    
	UILabel *label1 = (UILabel *)[cell viewWithTag:10];
	label1.text = [NSString stringWithFormat:@"%d", [regional.week intValue]];

	UILabel *label2 = (UILabel *)[cell viewWithTag:20];
    label2.text = regional.name;

	UILabel *label3 = (UILabel *)[cell viewWithTag:30];
	label3.text = [NSString stringWithFormat:@"%d", [regional.rank intValue]];

	UILabel *label4 = (UILabel *)[cell viewWithTag:40];
    label4.text = regional.seedingRecord;

    // CCWM
    UILabel *label5 = (UILabel *)[cell viewWithTag:50];
	label5.text = [NSString stringWithFormat:@"%.1f", [regional.ccwm floatValue]];

	UILabel *label6 = (UILabel *)[cell viewWithTag:60];
	label6.text = [NSString stringWithFormat:@"%.1f", [regional.opr floatValue]];

	UILabel *label7 = (UILabel *)[cell viewWithTag:70];
	label7.text = regional.finishPosition;

	UILabel *label8 = (UILabel *)[cell viewWithTag:80];
	label8.text = regional.awards;
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
    UITableViewCell *cell = nil;
    if (tableView == _regionalInfo) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Regional"];
        // Set up the cell...
        [self configureRegionalCell:cell atIndexPath:indexPath];
    }
    else if (tableView == _matchInfo) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MatchSchedule"];
        // Set up the cell...
        [self configureMatchCell:cell atIndexPath:indexPath];
    }
    
    return cell;
}

-(MatchData *)getMatchData: (TeamScore *) teamScore {
    // Future plans
/*  if (teamScore.red1) return teamScore.red1;
    if (teamScore.red2) return teamScore.red2;
    if (teamScore.red3) return teamScore.red3;
    if (teamScore.blue1) return teamScore.blue1;
    if (teamScore.blue2) return teamScore.blue2;
    if (teamScore.blue3) return teamScore.blue3; */
    
    return nil; 
}

-(IBAction)MatchNumberChanged {
    // The user has typed a new team number in the field. Access that team and display it.
     NSLog(@"TeamNumberChanged");
    [self checkDataStatus];
    int currentTeam = [_numberText.text intValue];
    printf("%d", currentTeam);
    for(int x = 0; x < [self getNumberOfTeams]; x++){
        NSIndexPath *teamIndex = [NSIndexPath indexPathForRow:x inSection:0];
        TeamData* team = [_fetchedResultsController objectAtIndexPath: teamIndex];
        if([team.number intValue] == currentTeam){
            _teamIndex = teamIndex;
            _team = team;
            [self showTeam];
            break;
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{   return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

-(void)SetTextBoxDefaults:(UITextField *)currentTextField {
    currentTextField.font = [UIFont fontWithName:@"Helvetica" size:22.0];
}

-(void)SetBigButtonDefaults:(UIButton *)currentButton {
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

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

@end
