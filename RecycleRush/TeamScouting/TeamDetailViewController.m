//
//  TeamDetailViewController.m
// Robonauts Scouting
//
//  Created by Kris Pettinger on 6/24/12.
//  Copyright (c) 2012 __RobonautsScouting__. All rights reserved.
//

#import <QuartzCore/CALayer.h>
#import "TeamDetailViewController.h"
#import "DataManager.h"
#import "FileIOMethods.h"
#import "TeamData.h"
#import "MatchData.h"
#import "TeamScore.h"
#import "Regional.h"
#import "ScoreAccessors.h"
#import "PhotoCell.h"
#import "PhotoAttributes.h"
#import "PhotoUtilities.h"
#import "EnumerationDictionary.h"
#import "FieldDrawingViewController.h"
#import "MatchOverlayViewController.h"
#import "FullSizeViewer.h"
#import "LNNumberpad.h"
#import "MainMatchAnalysisViewController.h"
#import "MatchAccessors.h"
#import "TeamSummaryViewController.h"
#import "MatchSummaryViewController.h"


@interface TeamDetailViewController ()
@property (weak, nonatomic) IBOutlet UITextField *robotWeight;
    @property (nonatomic, weak) IBOutlet UIButton *prevTeamButton;
    @property (nonatomic, weak) IBOutlet UIButton *nextTeamButton;
    @property (nonatomic, weak) IBOutlet UITextField *numberText;
    @property (nonatomic, weak) IBOutlet UITextField *nameTextField;
    @property (nonatomic, weak) IBOutlet UITextView *notesViewField;
    @property (nonatomic, weak) IBOutlet UIImageView *imageView;
    @property (nonatomic, weak) IBOutlet UIButton *intakeType;
@property (weak, nonatomic) IBOutlet UIButton *stackingMechButton;
    @property (nonatomic, weak) IBOutlet UITextField *maxHeight;
@property (weak, nonatomic) IBOutlet UIButton *liftTypeButton;
    @property (nonatomic, weak) IBOutlet UITextField *wheelType;
@property (weak, nonatomic) IBOutlet UIButton *canIntakeButton;
    @property (nonatomic, weak) IBOutlet UITextField *nwheels;
@property (weak, nonatomic) IBOutlet UITextField *stackLevelText;
    @property (nonatomic, weak) IBOutlet UITextField *wheelDiameter;
    @property (nonatomic, weak) IBOutlet UIButton *driveType;
    @property (nonatomic, weak) IBOutlet UITextField *cims;
    @property (nonatomic, weak) IBOutlet UIButton *cameraBtn;
    @property (nonatomic, strong) UIPopoverController *pictureController;
@property (weak, nonatomic) IBOutlet UIButton *teamInfoButton;
    @property (nonatomic, weak) IBOutlet UITableView *matchInfo;
    @property (nonatomic, weak) IBOutlet UITableView *regionalInfo;
    @property (nonatomic, strong) UIImagePickerController *imagePickerController;
    @property (nonatomic, weak) IBOutlet UICollectionView *photoCollectionView;
//    @property (nonatomic, weak) IBOutlet UIButton *autonCapacityButton;
    @property (nonatomic, weak) IBOutlet UIButton *autonMobilityButton;
//    @property (nonatomic, weak) IBOutlet UIButton *robotClassButton;
    @property (weak, nonatomic) IBOutlet UIButton *matchOverlayButton;
@property (weak, nonatomic) IBOutlet UIButton *programmingLanguage;
@property (weak, nonatomic) IBOutlet UITextField *robotLength;
@property (weak, nonatomic) IBOutlet UITextField *robotWidth;
@property (weak, nonatomic) IBOutlet UIButton *canDomRadio;
@property (weak, nonatomic) IBOutlet UIButton *baneRadioButton;
@property (weak, nonatomic) IBOutlet UIButton *typeOfBane;
@property (weak, nonatomic) IBOutlet UIButton *canDomNumber;
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
    TeamScore *currentScore;
    
    PopUpPickerViewController *liftTypePicker;
    UIPopoverController *liftTypePickerPopover;
    NSArray *liftTypeList;
    
    PopUpPickerViewController *programmingLanguagePicker;
    UIPopoverController *programmingLanguagePickerPopover;
    NSArray *programmingLanguageList;
    
    PopUpPickerViewController *typeBanePicker;
    UIPopoverController *typeBanePickerPopover;
    NSArray *typeBaneList;
    
    PopUpPickerViewController *canDomNumberPicker;
    UIPopoverController *canDomNumberPickerPopover;
    NSArray *canDomNumberList;
    
    PopUpPickerViewController *canDomPicker;
    UIPopoverController *canDomPickerPopover;
    NSArray *canDomList;

    PopUpPickerViewController *stackingMechPicker;
    UIPopoverController *stackingMechPickerPopover;
    NSArray *stackingMechList;

    PopUpPickerViewController *quadStatePicker;
    UIPopoverController *quadStatePickerPopover;
    NSArray *quadStateList;

    PopUpPickerViewController *driveTypePicker;
    UIPopoverController *drivePickerPopover;
    NSArray *driveTypeList;
    
    PopUpPickerViewController *toteIntakePicker;
    UIPopoverController *toteIntakePickerPopover;
    NSArray *toteIntakeList;

    PopUpPickerViewController *canIntakePicker;
    UIPopoverController *canIntakePickerPopover;
    NSArray *canIntakeList;
    

    PopUpPickerViewController *maxStackPicker;
    UIPopoverController *maxStackPickerPopover;
    NSArray *maxStackList;
    
    NSArray *photoList;
    NSString *selectedPhoto;
}

TeamData *currentteam;

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

    matchTypeDictionary = _dataManager.matchTypeDictionary;
    allianceDictionary = _dataManager.allianceDictionary;
    triStateDictionary = [EnumerationDictionary initializeBundledDictionary:@"TriState"];

    photoUtilities = [[PhotoUtilities alloc] init:_dataManager];
 
    // Set defaults for all the text boxes
    [self setTextBoxDefaults:_numberText];
    [self setTextBoxDefaults:_nameTextField];
    [self setTextBoxDefaults:_maxHeight];
    [self setTextBoxDefaults:_wheelType];
    [self setTextBoxDefaults:_nwheels];
    [self setTextBoxDefaults:_wheelDiameter];
    [self setTextBoxDefaults:_cims];
    [self setTextBoxDefaults:_robotWeight];
    [self setTextBoxDefaults:_robotWidth];
    [self setTextBoxDefaults:_robotLength];
    [self setTextBoxDefaults:_stackLevelText];
    
    _stackLevelText.inputView  = [LNNumberpad defaultLNNumberpad];
    _cims.inputView  = [LNNumberpad defaultLNNumberpad];
    _robotWeight.inputView  = [LNNumberpad defaultLNNumberpad];
    _maxHeight.inputView  = [LNNumberpad defaultLNNumberpad];
    _wheelDiameter.inputView  = [LNNumberpad defaultLNNumberpad];
    _nwheels.inputView  = [LNNumberpad defaultLNNumberpad];
    _numberText.inputView  = [LNNumberpad defaultLNNumberpad];
    _robotWeight.inputView  = [LNNumberpad defaultLNNumberpad];
    _robotLength.inputView  = [LNNumberpad defaultLNNumberpad];
    _robotWidth.inputView  = [LNNumberpad defaultLNNumberpad];

       // Set defaults for all the buttons
    [self setBigButtonDefaults:_intakeType];
    [self setBigButtonDefaults:_canIntakeButton];
    [self setBigButtonDefaults:_liftTypeButton];
    [self setBigButtonDefaults:_programmingLanguage];
    [self setBigButtonDefaults:_typeOfBane];
    [self setBigButtonDefaults:_canDomNumber];
    [self setBigButtonDefaults:_stackingMechButton];
    [self setBigButtonDefaults:_driveType];
    [self setBigButtonDefaults:_matchOverlayButton];
    [self setBigButtonDefaults:_teamInfoButton];
    
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
        _team.saved = [NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()];
        if (![_dataManager saveContext]) {
            UIAlertView *prompt  = [[UIAlertView alloc] initWithTitle:@"Horrible Problem"
                                                              message:@"Unable to save data"
                                                             delegate:nil
                                                    cancelButtonTitle:@"Ok"
                                                    otherButtonTitles:nil];
            [prompt setAlertViewStyle:UIAlertViewStyleDefault];
            [prompt show];
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
    
	UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(120, 0, 200, 35)];
	label2.text = @"Type";
    label2.backgroundColor = [UIColor clearColor];
    [matchHeader addSubview:label2];
    
 	UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(200, 0, 200, 35)];
	label3.text = @"Score";
    label3.backgroundColor = [UIColor clearColor];
    [matchHeader addSubview:label3];
    
    UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(290, 0, 200, 35)];
	label4.text = @"Alliance Members";
    label4.backgroundColor = [UIColor clearColor];
    [matchHeader addSubview:label4];
    
    UILabel *label5 = [[UILabel alloc] initWithFrame:CGRectMake(450, 0, 200, 35)];
	label5.text = @"Robot Type";
    label5.backgroundColor = [UIColor clearColor];
    [matchHeader addSubview:label5];
}

-(void)showTeam {
    //  Set the display fields for the currently selected team.
    self.title = [NSString stringWithFormat:@"%d - %@", [_team.number intValue], _team.name];
    _numberText.text = [NSString stringWithFormat:@"%d", [_team.number intValue]];
    _nameTextField.text = _team.name;
    _notesViewField.text = _team.notes;
    _maxHeight.text = [NSString stringWithFormat:@"%.1f", [_team.maxHeight floatValue]];
    _wheelType.text = _team.wheelType;
    _nwheels.text = [NSString stringWithFormat:@"%d", [_team.nwheels intValue]];
    _wheelDiameter.text = [NSString stringWithFormat:@"%.1f", [_team.wheelDiameter floatValue]];
    _cims.text = [NSString stringWithFormat:@"%.0f", [_team.cims floatValue]];
    _robotWeight.text = [NSString stringWithFormat:@"%.0f", [_team.weight floatValue]];
    _robotWidth.text = [NSString stringWithFormat:@"%.0f", [_team.width floatValue]];
    _robotLength.text = [NSString stringWithFormat:@"%.0f", [_team.length floatValue]];

    NSSortDescriptor *regionalSort = [NSSortDescriptor sortDescriptorWithKey:@"eventNumber" ascending:YES];
    regionalList = [[_team.regional allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:regionalSort]];
    
    matchList = [ScoreAccessors getMatchListForTeam:_team.number forTournament:tournamentName fromDataManager:_dataManager];

    // Look for Qual or Elim matches Only
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"matchType = %@ || matchType = %@", [EnumerationDictionary getValueFromKey:@"Qualification" forDictionary:matchTypeDictionary], [EnumerationDictionary getValueFromKey:@"Elimination" forDictionary:matchTypeDictionary]];
    NSArray *matches = [matchList filteredArrayUsingPredicate:pred];
    // If there aren't any Qual or Elim matches, then use practice matches
    if (![matches count]) {
        pred = [NSPredicate predicateWithFormat:@"matchType = %@", [EnumerationDictionary getValueFromKey:@"Practice" forDictionary:matchTypeDictionary]];
        matches = [matchList filteredArrayUsingPredicate:pred];
    }
    int max = [[matches valueForKeyPath:@"@max.maxToteHeight"] intValue];
    if (max > 6) NSLog(@"matches = %@", matches);
    // NSLog(@"Max tote = %d", max);
    if ([_team.maxToteStack intValue] != max) {
        _team.maxToteStack = [NSNumber numberWithInt:max];
        [self setDataChange];
        [self checkDataStatus];
    }
    max = [[matches valueForKeyPath:@"@max.maxCanHeight"] intValue];
    // NSLog(@"Max can = %d", max);
    if ([_team.maxCanHeight intValue] != max) {
        _team.maxCanHeight = [NSNumber numberWithInt:max];
        [self setDataChange];
        [self checkDataStatus];
    }
    
    _stackLevelText.text = [NSString stringWithFormat:@"%d", [_team.maxToteStack intValue]];

    [_driveType setTitle:_team.driveTrainType forState:UIControlStateNormal];
    [_intakeType setTitle:_team.toteIntake forState:UIControlStateNormal];
    [_canIntakeButton setTitle:_team.canIntake forState:UIControlStateNormal];
    [_liftTypeButton setTitle:_team.liftType forState:UIControlStateNormal];
    [_stackingMechButton setTitle:_team.stackMechanism forState:UIControlStateNormal];
    [_autonMobilityButton setTitle:_team.autonMobility forState:UIControlStateNormal];
    [_programmingLanguage setTitle:_team.language forState:UIControlStateNormal];
    [_typeOfBane setTitle:_team.typeOfBane forState:UIControlStateNormal];
    [_canDomNumber setTitle:_team.numberOfCans forState:UIControlStateNormal];
    [self setRadioButtonState:_baneRadioButton forState:[_team.projectBane intValue]];
    [self setRadioButtonState:_canDomRadio forState:[_team.canDom intValue]];

    [self getPhoto];
    photoList = [self getPhotoList:_team.number];
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

- (IBAction)radioButtonTapped:(id)sender {
    if (sender == _baneRadioButton) { // It is on, turn it off
        if ([_team.projectBane intValue]) {
            _team.projectBane = [NSNumber numberWithBool:NO];
        }
        else { // It is off, turn it on
            _team.projectBane = [NSNumber numberWithBool:YES];
        }
        [self setRadioButtonState:_baneRadioButton forState:[_team.projectBane intValue]];
    }
    [self setDataChange];
   
if (sender == _canDomRadio) { // It is on, turn it off
        if ([_team.canDom intValue]) {
            _team.canDom = [NSNumber numberWithBool:NO];
        }
        else { // It is off, turn it on
            _team.canDom = [NSNumber numberWithBool:YES];
        }
        [self setRadioButtonState:_canDomRadio forState:[_team.canDom intValue]];
    }
    [self setDataChange];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(IBAction)detailChanged:(id)sender {
    // One of the pop-up menus has been selected. Determine which one
    //  and push the correct pop-up VC
    UIButton * PressedButton = (UIButton*)sender;
    popUp = PressedButton;
    
    if (PressedButton == _intakeType) {
        if (!toteIntakeList) toteIntakeList = [FileIOMethods initializePopUpList:@"ToteIntakeType"];
        if (toteIntakePicker == nil) {
            toteIntakePicker = [[PopUpPickerViewController alloc]
                               initWithStyle:UITableViewStylePlain];
            toteIntakePicker.delegate = self;
            toteIntakePicker.pickerChoices = toteIntakeList;
        }
        if (!toteIntakePickerPopover) {

            toteIntakePickerPopover = [[UIPopoverController alloc]
                                      initWithContentViewController:toteIntakePicker];
        }
        [toteIntakePickerPopover presentPopoverFromRect:PressedButton.bounds inView:PressedButton
                              permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }    else if (PressedButton == _driveType) {
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
    else if (PressedButton == _canIntakeButton) {
        if (!canIntakeList) canIntakeList = [FileIOMethods initializePopUpList:@"CanIntake"];
        if (canIntakePicker == nil) {
            canIntakePicker = [[PopUpPickerViewController alloc]
                                initWithStyle:UITableViewStylePlain];
            canIntakePicker.delegate = self;
            canIntakePicker.pickerChoices = canIntakeList;
        }
        if (!canIntakePickerPopover) {
            canIntakePickerPopover = [[UIPopoverController alloc]
                                    initWithContentViewController:canIntakePicker];
        }
        [canIntakePickerPopover presentPopoverFromRect:PressedButton.bounds inView:PressedButton
                               permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else if (PressedButton == _liftTypeButton) {
        if (!liftTypeList) liftTypeList = [FileIOMethods initializePopUpList:@"LiftType"];
        if (liftTypePicker == nil) {
            liftTypePicker = [[PopUpPickerViewController alloc]
                                   initWithStyle:UITableViewStylePlain];
            liftTypePicker.delegate = self;
            liftTypePicker.pickerChoices = liftTypeList;
        }
        if (!liftTypePickerPopover) {
            liftTypePickerPopover = [[UIPopoverController alloc]
                                        initWithContentViewController:liftTypePicker];
        }
        [liftTypePickerPopover presentPopoverFromRect:PressedButton.bounds inView:PressedButton
                                  permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else if (PressedButton == _programmingLanguage) {
        if (!programmingLanguageList) programmingLanguageList = [FileIOMethods initializePopUpList:@"ProgrammingLanguage"];
        if (programmingLanguagePicker == nil) {
            programmingLanguagePicker = [[PopUpPickerViewController alloc]
                              initWithStyle:UITableViewStylePlain];
            programmingLanguagePicker.delegate = self;
            programmingLanguagePicker.pickerChoices = programmingLanguageList;
        }
        if (!programmingLanguagePickerPopover) {
            programmingLanguagePickerPopover = [[UIPopoverController alloc]
                                     initWithContentViewController:programmingLanguagePicker];
        }
        [programmingLanguagePickerPopover presentPopoverFromRect:PressedButton.bounds inView:PressedButton
                             permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else if (PressedButton == _typeOfBane) {
        if (!typeBaneList) typeBaneList = [FileIOMethods initializePopUpList:@"Bane"];
        if (typeBanePicker == nil) {
            typeBanePicker = [[PopUpPickerViewController alloc]
                                         initWithStyle:UITableViewStylePlain];
            typeBanePicker.delegate = self;
            typeBanePicker.pickerChoices = typeBaneList;
        }
        if (!typeBanePickerPopover) {
            typeBanePickerPopover = [[UIPopoverController alloc]
                                                initWithContentViewController:typeBanePicker];
        }
        [typeBanePickerPopover presentPopoverFromRect:PressedButton.bounds inView:PressedButton
                                        permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else if (PressedButton == _canDomNumber) {
        if (!canDomNumberList) canDomNumberList = [FileIOMethods initializePopUpList:@"CanDomNumber"];
        if (canDomNumberPicker == nil) {
            canDomNumberPicker = [[PopUpPickerViewController alloc]
                                         initWithStyle:UITableViewStylePlain];
            canDomNumberPicker.delegate = self;
            canDomNumberPicker.pickerChoices = canDomNumberList;
        }
        if (!canDomNumberPickerPopover) {
            canDomNumberPickerPopover = [[UIPopoverController alloc]
                                                initWithContentViewController:canDomNumberPicker];
        }
        [canDomNumberPickerPopover presentPopoverFromRect:PressedButton.bounds inView:PressedButton
                                        permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }

    else if (PressedButton == _canDomRadio) {
        if (!canDomList) canDomList = [FileIOMethods initializePopUpList:@"CanDom"];
        if (canDomPicker == nil) {
            canDomPicker = [[PopUpPickerViewController alloc]
                            initWithStyle:UITableViewStylePlain];
            canDomPicker.delegate = self;
            canDomPicker.pickerChoices = canDomList;
        }
        if (!canDomPickerPopover) {
            canDomPickerPopover = [[UIPopoverController alloc]
                                   initWithContentViewController:canDomPicker];
        }
        [canDomPickerPopover presentPopoverFromRect:PressedButton.bounds inView:PressedButton
                           permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else if (PressedButton == _stackingMechButton) {
        if (!stackingMechList) stackingMechList = [FileIOMethods initializePopUpList:@"StackingMech"];
        if (stackingMechPicker == nil) {
            stackingMechPicker = [[PopUpPickerViewController alloc]
                              initWithStyle:UITableViewStylePlain];
            stackingMechPicker.delegate = self;
            stackingMechPicker.pickerChoices = stackingMechList;
        }
        if (!stackingMechPickerPopover) {
            stackingMechPickerPopover = [[UIPopoverController alloc]
                                     initWithContentViewController:stackingMechPicker];
        }
        [stackingMechPickerPopover presentPopoverFromRect:PressedButton.bounds inView:PressedButton
                             permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

-(void)pickerSelected:(NSString *)newPick {
    // The user has made a selection on one of the pop-ups. Dismiss the pop-up
    //  and call the correct method to change the right field.
    //NSLog(@"new pick = %@", newPick);
    if (popUp == _driveType) {
        [drivePickerPopover dismissPopoverAnimated:YES];
        _team.driveTrainType = newPick;
    }
    else if (popUp == _intakeType) {
        [toteIntakePickerPopover dismissPopoverAnimated:YES];
        _team.toteIntake = newPick;
    }
    else if (popUp == _liftTypeButton) {
        [liftTypePickerPopover dismissPopoverAnimated:YES];
        _team.liftType = newPick;
    }
    else if (popUp == _stackingMechButton) {
        [stackingMechPickerPopover dismissPopoverAnimated:YES];
        _team.stackMechanism = newPick;
    }
    else if (popUp == _canIntakeButton) {
        [canIntakePickerPopover dismissPopoverAnimated:YES];
        _team.canIntake = newPick;
    }
    else if (popUp == _programmingLanguage) {
        [programmingLanguagePickerPopover dismissPopoverAnimated:YES];
        _team.language = newPick;
    }
    else if (popUp == _canDomNumber) {
        [canDomNumberPickerPopover dismissPopoverAnimated:YES];
        _team.numberOfCans = newPick;
    }
    else if (popUp == _typeOfBane) {
        [typeBanePickerPopover dismissPopoverAnimated:YES];
        _team.typeOfBane = newPick;
    }
    
    [self setDataChange];
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
    if (textField != _numberText) {
        [self setDataChange];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
//    NSLog(@"team should end editing");
    if (textField == _nameTextField) {
		_team.name = _nameTextField.text;
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
    else if (textField == _robotWeight) {
		_team.weight = [NSNumber numberWithFloat:[_robotWeight.text floatValue]];
	}
    else if (textField == _robotWidth) {
		_team.width = [NSNumber numberWithFloat:[_robotWidth.text floatValue]];
	}
    else if (textField == _robotLength) {
		_team.length = [NSNumber numberWithFloat:[_robotLength.text floatValue]];
	}
	else if (textField == _cims) {
		_team.cims = [NSNumber numberWithFloat:[_cims.text floatValue]];
	}
    else if (textField == _stackLevelText) {
		_team.maxToteStack = [NSNumber numberWithInt:[_stackLevelText.text intValue]];
    }
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Limit these text fields to numbers only.
    if (textField == _nameTextField || textField == _wheelType)  return YES;
    
    NSString *resultingString = [textField.text stringByReplacingCharactersInRange: range withString: string];
    
    // This allows backspace
    if ([resultingString length] == 0) {
        return true;
    }
    if (textField == _nwheels || textField == _numberText) {
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
    _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;    
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

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
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
            photoViewer.imagePath = [photoUtilities getFullImagePath:selectedPhoto];
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
    else if ([segue.identifier isEqualToString:@"TeamMatchSummary"]) {
        [segue.destinationViewController setNumberTeam:_team];
    }
    else if ([segue.identifier isEqualToString:@"TeamSummary"]) {
        TeamSummaryViewController *detailViewController = [segue destinationViewController];
        // NSLog(@"Team = %@", [_teamList objectAtIndex:indexPath.row]);
        detailViewController.initialTeam = _team;
        detailViewController.teamList = [NSArray arrayWithObject:_team];
        //detailViewController.matchNumber = currentMatch.number;
           }
    else if ([segue.identifier isEqualToString:@"MatchSummary"])  {
        [segue.destinationViewController setDataManager:_dataManager];
        NSIndexPath *indexPath = [self.matchInfo indexPathForCell:sender];
        [segue.destinationViewController setCurrentScore:[matchList objectAtIndex:indexPath.row]];
        [_matchInfo deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (IBAction)goHome:(id)sender {
    UINavigationController * navigationController = self.navigationController;
    [navigationController popToRootViewControllerAnimated:YES];
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
	label1.text = [NSString stringWithFormat:@"%d", [regional.eventNumber intValue]];

	UILabel *label2 = (UILabel *)[cell viewWithTag:20];
    label2.text = regional.eventName;

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
    label3.text = [NSString stringWithFormat:@"%d", [score.totalScore intValue]];
    
    UILabel *label5 = (UILabel *)[cell viewWithTag:70];
    label5.text = [score.robotType substringToIndex:4];
    
    //UILabel *label4 = (UILabel *)[cell viewWithTag:40];
	//label4.text = [NSString stringWithFormat:@"%d", [matchList.  intValue]];
    NSDictionary *allianceMembersDictionary = [MatchAccessors buildTeamList:score.match forAllianceDictionary:allianceDictionary];
    NSString *allianceString = [MatchAccessors getAllianceString:score.allianceStation fromDictionary:allianceDictionary];
    NSArray *allKeys = [allianceMembersDictionary allKeys];
    if ([[allianceString substringToIndex:1] isEqualToString:@"R"]) {
        int tag = 40;
        for (NSString *key in allKeys) {
            if ([[key substringToIndex:1] isEqualToString:@"R"]) {
                int otherMembers = [[allianceMembersDictionary objectForKey:key] intValue];
                if ([_team.number intValue]== otherMembers) continue;
                UILabel *label = (UILabel *)[cell viewWithTag:tag];
                label.text = [NSString stringWithFormat:@"%d", otherMembers];
                tag = 50;
            }
        }
         }
    else if ([[allianceString substringToIndex:1] isEqualToString:@"B"]) {
        int tag = 40;
        for (NSString *key in allKeys) {
            if ([[key substringToIndex:1] isEqualToString:@"B"]) {
                int otherMembers = [[allianceMembersDictionary objectForKey:key] intValue];
                if ([_team.number intValue]== otherMembers) continue;
                UILabel *label = (UILabel *)[cell viewWithTag:tag];
                label.text = [NSString stringWithFormat:@"%d", otherMembers];
                tag = 50;
            }
        }
    }
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
