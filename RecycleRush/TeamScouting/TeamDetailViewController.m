//
//  TeamDetailViewController.m
// Robonauts Scouting
//
//  Created by Kris Pettinger on 6/24/12.
//  Copyright (c) 2012 __RobonautsScouting__. All rights reserved.
//

#import <QuartzCore/CALayer.h>
#import "TeamDetailViewController.h"
#import "TeamData.h"
#import "TeamScore.h"
#import "DataConvenienceMethods.h"
#import "MatchData.h"
#import "DataManager.h"
#import "Regional.h"
#import "PhotoCell.h"
#import "PhotoAttributes.h"
#import "PhotoUtilities.h"
#import "EnumerationDictionary.h"
#import "FileIOMethods.h"
#import "FieldDrawingViewController.h"
#import "MatchOverlayViewController.h"
#import "FullSizeViewer.h"

@interface TeamDetailViewController ()
    @property (nonatomic, weak) IBOutlet UIButton *prevTeamButton;
    @property (nonatomic, weak) IBOutlet UIButton *nextTeamButton;
    @property (nonatomic, weak) IBOutlet UITextField *numberText;
    @property (nonatomic, weak) IBOutlet UITextField *nameTextField;
    @property (nonatomic, weak) IBOutlet UITextView *notesViewField;
    @property (nonatomic, weak) IBOutlet UIImageView *imageView;
    @property (nonatomic, weak) IBOutlet UIButton *intakeType;
    @property (nonatomic, weak) IBOutlet UITextField *minHeight;
    @property (nonatomic, weak) IBOutlet UITextField *shootingLevel;
    @property (nonatomic, weak) IBOutlet UITextField *maxHeight;
    @property (nonatomic, weak) IBOutlet UITextField *wheelType;
    @property (nonatomic, weak) IBOutlet UITextField *nwheels;
    @property (nonatomic, weak) IBOutlet UITextField *wheelDiameter;
    @property (nonatomic, weak) IBOutlet UIButton *driveType;
    @property (nonatomic, weak) IBOutlet UITextField *cims;
    @property (nonatomic, weak) IBOutlet UIButton *cameraBtn;
    @property (nonatomic, strong) UIPopoverController *pictureController;
    @property (nonatomic, weak) IBOutlet UITableView *matchInfo;
    @property (nonatomic, weak) IBOutlet UITableView *regionalInfo;
    @property (nonatomic, strong) UIImagePickerController *imagePickerController;
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
    PhotoUtilities *photoUtilities;
    BOOL getAssetURL;
    NSFileManager *fileManager;
    NSDictionary *matchTypeDictionary;
    NSDictionary *allianceDictionary;
    NSDictionary *triStateDictionary;
    
    PopUpPickerViewController *triStatePicker;
    UIPopoverController *triStatePickerPopover;
    NSArray *triStateList;

    PopUpPickerViewController *quadStatePicker;
    UIPopoverController *quadStatePickerPopover;
    NSArray *quadStateList;

    PopUpPickerViewController *intakePicker;
    UIPopoverController *intakePickerPopover;
    NSArray *intakeList;

    PopUpPickerViewController *driveTypePicker;
    UIPopoverController *drivePickerPopover;
    NSArray *driveTypeList;

    PopUpPickerViewController *shooterPicker;
    UIPopoverController *shooterPickerPopover;
    NSArray *shooterList;
    
    PopUpPickerViewController *tunnelPicker;
    UIPopoverController *tunnelPickerPopover;
    NSArray *tunnelList;

    NSArray *photoList;
    NSString *selectedPhoto;
}

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

    matchTypeDictionary = [EnumerationDictionary initializeBundledDictionary:@"MatchType"];
    allianceDictionary = [EnumerationDictionary initializeBundledDictionary:@"AllianceList"];
    triStateDictionary = [EnumerationDictionary initializeBundledDictionary:@"TriState"];

    photoUtilities = [[PhotoUtilities alloc] init:_dataManager];
 
    // Set defaults for all the text boxes
    [self setTextBoxDefaults:_numberText];
    [self setTextBoxDefaults:_nameTextField];
    [self setTextBoxDefaults:_ballReleaseHeightText];
    [self setTextBoxDefaults:_minHeight];
    [self setTextBoxDefaults:_maxHeight];
    [self setTextBoxDefaults:_wheelType];
    [self setTextBoxDefaults:_nwheels];
    [self setTextBoxDefaults:_wheelDiameter];
    [self setTextBoxDefaults:_cims];
    [self setTextBoxDefaults:_ballReleaseHeightText];
    [self setBigButtonDefaults:_tunnelButton];
    [self setBigButtonDefaults:_autonMobilityButton];
    [self setBigButtonDefaults:_catcherButton];
    [self setBigButtonDefaults:_spitBotButton];
    [self setBigButtonDefaults:_goalieButton];
    [self setBigButtonDefaults:_hotTrackerButton];
    [self setBigButtonDefaults:_shooterButton];
    [self setBigButtonDefaults:_matchOverlayButton];

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
    // NSLog(@"Saved by:%@\tTime = %@", _team.savedBy, _team.saved);
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
    
    matchList = [DataConvenienceMethods getMatchListForTeam:_team.number forTournament:tournamentName fromContext:_dataManager.managedObjectContext];
    
    [_driveType setTitle:_team.driveTrainType forState:UIControlStateNormal];
    [_intakeType setTitle:_team.intake forState:UIControlStateNormal];
    [_shooterButton setTitle:_team.shooterType forState:UIControlStateNormal];
    [_goalieButton setTitle:_team.goalie forState:UIControlStateNormal];
    [_catcherButton setTitle:_team.catcher forState:UIControlStateNormal];
    [_tunnelButton setTitle:_team.tunneler forState:UIControlStateNormal];
    [_spitBotButton setTitle:_team.spitBot forState:UIControlStateNormal];
    [_autonMobilityButton setTitle:_team.autonMobility forState:UIControlStateNormal];
    [_hotTrackerButton setTitle:_team.hotTracker forState:UIControlStateNormal];

    [self setRadioButtonState:_classAButton forState:_team.classA];
    [self setRadioButtonState:_classBButton forState:_team.classB];
    [self setRadioButtonState:_classCButton forState:_team.classC];
    [self setRadioButtonState:_classDButton forState:_team.classD];
    [self setRadioButtonState:_classEButton forState:_team.classE];
    [self setRadioButtonState:_classFButton forState:_team.classF];
    [self getPhoto];
    photoList = [self getPhotoList:_team.number];
    [_photoCollectionView reloadData];
    dataChange = NO;
}

-(void)setRadioButtonState:(UIButton *)button forState:(NSString *)selection {
    NSNumber *newState = [triStateDictionary objectForKey:selection];
    if ([newState intValue] == -1 || [newState intValue] == 0) {
        [button setImage:[UIImage imageNamed:@"RadioButton-Unselected.png"] forState:UIControlStateNormal];
    }
    else {
        [button setImage:[UIImage imageNamed:@"RadioButton-Selected.png"] forState:UIControlStateNormal];
    }
}

-(NSInteger)getNumberOfTeams {
    return [[[_fetchedResultsController sections] objectAtIndex:0] numberOfObjects];
}

-(IBAction)prevButton {
    //  Access the previous team in the list
    [self checkDataStatus];
    NSInteger nteams = [self getNumberOfTeams];
    NSInteger row = _teamIndex.row;
    if (row > 0) row--;
    else row =  nteams-1;
    _teamIndex = [NSIndexPath indexPathForRow:row inSection:0];
    _team = [_fetchedResultsController objectAtIndexPath:_teamIndex];
    [self showTeam];
    [_matchInfo reloadData];
    [_regionalInfo reloadData];
}

-(IBAction)nextButton {
    //  Access the next team in the list
    [self checkDataStatus];
    NSInteger nteams = [self getNumberOfTeams];
    NSInteger row = _teamIndex.row;
    if (row < (nteams-1)) row++;
    else row = 0;
    _teamIndex = [NSIndexPath indexPathForRow:row inSection:0];
    _team = [_fetchedResultsController objectAtIndexPath:_teamIndex];
    [self showTeam];
    [_matchInfo reloadData];
    [_regionalInfo reloadData];
}

- (IBAction)radioButtonTapped:(id)sender {
    if (sender == _classAButton) {
        _team.classA = [self getNextTriState:_team.classA];
        [self setRadioButtonState:_classAButton forState:_team.classA];
    }
    if (sender == _classBButton) {
        _team.classB = [self getNextTriState:_team.classB];
        [self setRadioButtonState:_classBButton forState:_team.classB];
    }
    if (sender == _classCButton) {
        _team.classC = [self getNextTriState:_team.classC];
        [self setRadioButtonState:_classCButton forState:_team.classC];
    }
    if (sender == _classDButton) {
        _team.classD = [self getNextTriState:_team.classD];

        [self setRadioButtonState:_classDButton forState:_team.classD];
    }
    if (sender == _classEButton) {
        _team.classE = [self getNextTriState:_team.classE];
        [self setRadioButtonState:_classEButton forState:_team.classE];
    }
    if (sender == _classFButton) {
        _team.classF = [self getNextTriState:_team.classF];
        [self setRadioButtonState:_classFButton forState:_team.classF];
    }
    [self setDataChange];
}

-(NSString *)getNextTriState:(NSString *)currentState {
    if ([triStateDictionary objectForKey:currentState]) {
        // Good, the current value is valid.
        if ([currentState isEqualToString:@"Yes"]) {
            // It is currently Yes, set it to No
            return @"No";
        }
        else {
            // It is currently No, set it to Yes
            return @"Yes";
        }
    }
    else {
        // The current value is invalid. Set to Unknown.
        return @"Unknown";
    }
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
        if (!intakeList) intakeList = [FileIOMethods initializePopUpList:@"IntakeType"];
        if (intakePicker == nil) {
            intakePicker = [[PopUpPickerViewController alloc]
                             initWithStyle:UITableViewStylePlain];
            intakePicker.delegate = self;
            intakePicker.pickerChoices = intakeList;
        }
        if (!intakePickerPopover) {
            intakePickerPopover = [[UIPopoverController alloc]
                                            initWithContentViewController:intakePicker];
        }
        [intakePickerPopover presentPopoverFromRect:PressedButton.bounds inView:PressedButton
                                permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else if (PressedButton == _driveType) {
        if (!driveTypeList) driveTypeList = [FileIOMethods initializePopUpList:@"DriveType"];
        if (driveTypePicker == nil) {
            driveTypePicker = [[PopUpPickerViewController alloc]
                             initWithStyle:UITableViewStylePlain];
            driveTypePicker.delegate = self;
            driveTypePicker.pickerChoices = driveTypeList;
        }
        if (!drivePickerPopover) {
            drivePickerPopover = [[UIPopoverController alloc]
                                            initWithContentViewController:driveTypePicker];
        }
        [drivePickerPopover presentPopoverFromRect:PressedButton.bounds inView:PressedButton
                                permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else if (PressedButton == _shooterButton) {
        if (!shooterList) shooterList = [FileIOMethods initializePopUpList:@"ShooterType"];
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
        if (!tunnelList) tunnelList = [FileIOMethods initializePopUpList:@"Tunnel"];
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
        if (!quadStateList) quadStateList = [FileIOMethods initializePopUpList:@"QuadState"];
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
        if (!triStateList) triStateList = [FileIOMethods initializePopUpList:@"TriState"];
        if (triStatePicker == nil) {
            triStatePicker = [[PopUpPickerViewController alloc]
                                   initWithStyle:UITableViewStylePlain];
            triStatePicker.delegate = self;
            triStatePicker.pickerChoices = triStateList;
        }
        if (!triStatePickerPopover) {
            triStatePickerPopover = [[UIPopoverController alloc]
                                        initWithContentViewController:triStatePicker];
        }
        [triStatePickerPopover presentPopoverFromRect:PressedButton.bounds inView:PressedButton
                                  permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

-(void)pickerSelected:(NSString *)newPick {
    // The user has made a selection on one of the pop-ups. Dismiss the pop-up
    //  and call the correct method to change the right field.
    NSLog(@"new pick = %@", newPick);
    if (popUp == _driveType) {
        [drivePickerPopover dismissPopoverAnimated:YES];
        _team.driveTrainType = newPick;
    }
    else if (popUp == _intakeType) {
        [intakePickerPopover dismissPopoverAnimated:YES];
        _team.intake = newPick;
    }
    else if (popUp == _shooterButton) {
        [shooterPickerPopover dismissPopoverAnimated:YES];
        _team.shooterType = newPick;
    }
    else if (popUp == _tunnelButton) {
        [tunnelPickerPopover dismissPopoverAnimated:YES];
        _team.tunneler = newPick;
    }
    else if (popUp == _spitBotButton) {
        [quadStatePickerPopover dismissPopoverAnimated:YES];
        _team.spitBot = newPick;
    }
    else if (popUp == _autonMobilityButton) {
        [triStatePickerPopover dismissPopoverAnimated:YES];
        _team.autonMobility = newPick;
    }
    else if (popUp == _catcherButton) {
        [triStatePickerPopover dismissPopoverAnimated:YES];
        _team.catcher = newPick;
    }
    else if (popUp == _goalieButton) {
        [triStatePickerPopover dismissPopoverAnimated:YES];
        _team.goalie = newPick;
    }
    else if (popUp == _hotTrackerButton) {
        [triStatePickerPopover dismissPopoverAnimated:YES];
        _team.hotTracker = newPick;
    }
    [popUp setTitle:newPick forState:UIControlStateNormal];
}

-(IBAction)teamNumberChanged {
    // The user has typed a new team number in the field. Access that team and display it.
    // NSLog(@"teamNumberChanged");
    [self checkDataStatus];
    if ([_numberText.text isEqualToString:@""]) {
        _numberText.text = [NSString stringWithFormat:@"%d", [_team.number intValue]];
        return;
    }
    int currentTeam = [_numberText.text intValue];
    BOOL found = FALSE;
    for(int x = 0; x < [self getNumberOfTeams]; x++){
        NSIndexPath *teamIndex = [NSIndexPath indexPathForRow:x inSection:0];
        TeamData* team = [_fetchedResultsController objectAtIndexPath: teamIndex];
        if([team.number intValue] == currentTeam) {
            _teamIndex = teamIndex;
            _team = team;
            [self showTeam];
            found = TRUE;
            break;
        }
    }
    if (!found) _numberText.text = [NSString stringWithFormat:@"%d", [_team.number intValue]];        
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
    [_imageView setImage:[UIImage imageWithContentsOfFile:[photoUtilities getFullImagePath:_team.primePhoto]]];
}

-(NSArray *)getPhotoList:(NSNumber *)teamNumber {
    return [photoUtilities getThumbnailList:teamNumber];
}

-(void)takePhoto {
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

-(void)choosePhoto {
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

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    _imageView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSString *photoNameBase = [photoUtilities createBaseName:_team.number];
    NSString *photoName = [photoUtilities savePhoto:photoNameBase withImage:_imageView.image];
    _team.primePhoto = photoName;

    [self setDataChange];
    [self.pictureController dismissPopoverAnimated:true];
    // NSLog(@"image picker finish");
    [picker dismissViewControllerAnimated:YES completion:Nil];
}

-(IBAction)photoControllerActionSheet:(id)sender {
    action = sender;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Existing",  nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showFromRect:_cameraBtn.frame inView:self.view animated:YES];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (action == _cameraBtn) {
        if (buttonIndex == 0) {
            [self takePhoto];
        } else if (buttonIndex == 1) {
            [self choosePhoto];
        }
    }
    else if (action == _photoCollectionView) {
        if (buttonIndex == 0) {
            _team.primePhoto = selectedPhoto;
            [_imageView setImage:[UIImage imageWithContentsOfFile:[photoUtilities getFullImagePath:selectedPhoto]]];
            [self setDataChange];
        }
        if (buttonIndex == 1) {
            FullSizeViewer *photoViewer = [[FullSizeViewer alloc] init];
            photoViewer.fullImage = [UIImage imageWithContentsOfFile:[photoUtilities getFullImagePath:selectedPhoto]];
            [self.navigationController pushViewController:photoViewer animated:YES];
        }
        if (buttonIndex == 2) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Really delete?" message:@"Do you really want to delete this photo?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
            [alert addButtonWithTitle:@"Yes"];
            [alert show];
        }
    }
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [photoUtilities removePhoto:selectedPhoto];
        if ([selectedPhoto isEqualToString:_team.primePhoto]) {
            _team.primePhoto = nil;
            [_imageView setImage:nil];
            [self setDataChange];
        }
        photoList = [self getPhotoList:_team.number];
        [_photoCollectionView reloadData];
    }
}

-(void)photoTapped:(UITapGestureRecognizer *)gestureRecognizer {
    FullSizeViewer *photoViewer = [[FullSizeViewer alloc] init];
    photoViewer.fullImage = _imageView.image;
//    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.navigationController pushViewController:photoViewer animated:YES];
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
    NSString *photo = [photoList objectAtIndex:indexPath.row];
    cell.thumbnail = [UIImage imageWithContentsOfFile:[photoUtilities getThumbnailPath:photo]];
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
    [segue.destinationViewController setDataManager:_dataManager];
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
	label1.text = [NSString stringWithFormat:@"%d", [score.matchNumber intValue]];

    UILabel *label2 = (UILabel *)[cell viewWithTag:20];
    label2.text  = [[EnumerationDictionary getKeyFromValue:score.matchType forDictionary:matchTypeDictionary] substringToIndex:4];

    UILabel *label3 = (UILabel *)[cell viewWithTag:30];
    label3.text = @"";
    
    if ([score.saved intValue] || [score.results boolValue]) label3.text = @"Y";
    else label3.text = @"N";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"table view");
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{   return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

-(void)setTextBoxDefaults:(UITextField *)currentTextField {
    currentTextField.font = [UIFont fontWithName:@"Helvetica" size:22.0];
}

-(void)setBigButtonDefaults:(UIButton *)currentButton {
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

@end