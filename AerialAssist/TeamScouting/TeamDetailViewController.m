//
//  TeamDetailViewController.m
// Robonauts Scouting
//
//  Created by Kris Pettinger on 6/24/12.
//  Copyright (c) 2012 __RobonautsScouting__. All rights reserved.
//

#import "TeamDetailViewController.h"
#import "TournamentData.h"
#import "TeamData.h"
#import "TeamScore.h"
#import "CreateMatch.h"
#import "MatchData.h"
#import "DataManager.h"
#import "Regional.h"
#import "Photo.h"
#import "PhotoAttributes.h"
#import "DriveTypeDictionary.h"
#import "FieldDrawingViewController.h"
#import "FullSizeViewer.h"
#import <ImageIO/ImageIO.h>
#import <ImageIO/CGImageProperties.h>

@interface TeamDetailViewController ()
    @property (nonatomic, weak) IBOutlet UICollectionView *photoCollectionView;
@end


@implementation TeamDetailViewController {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSString *deviceName;
    DriveTypeDictionary *driveDictionary;
    UIView *matchHeader;
    NSArray *matchList;
    UIView *regionalHeader;
    NSArray *regionalList;
    NSString *photoPath;
    BOOL imageIsFullScreen;
    CGRect imagePrevFrame;
    id popUp;
    BOOL dataChange;
    PhotoAttributes *primePhoto;
    BOOL getAssetURL;
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

@synthesize climbZonePicker = _climbZonePicker;
@synthesize climbZonePickerPopover = _climbZonePickerPopover;
@synthesize climbZoneList = _climbZoneList;
@synthesize climbZone = _climbZone;

@synthesize numberText = _numberText;
@synthesize nameTextField = _nameTextField;
@synthesize notesViewField = _notesViewField;

@synthesize shootingLevel = _shootingLevel;
@synthesize auton = _auton;
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

- (void)viewDidUnload
{
    [super viewDidUnload];
    //  Variables declared in the .m
    prefs = nil;
    tournamentName = nil;
    deviceName = nil;
    driveDictionary = nil;
    matchHeader = nil;
    matchList = nil;
    regionalList = nil;
    regionalHeader = nil;
    photoPath = nil;
    popUp = nil;

    //  Variables declared in the .h
    _dataManager = nil;
    _fetchedResultsController = nil;
    _teamIndex = nil;
    _team = nil;
    _pictureController = nil;
    _driveTypePicker = nil;
    _driveTypeList = nil;
    _intakePicker = nil;
    _intakeList = nil;
    _climbZonePicker = nil;
    _climbZoneList = nil;
}

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

    // Set defaults for all the text boxes
    [self SetTextBoxDefaults:_numberText];
    [self SetTextBoxDefaults:_nameTextField];
    [self SetTextBoxDefaults:_shootingLevel];
    [self SetTextBoxDefaults:_auton];
    [self SetTextBoxDefaults:_minHeight];
    [self SetTextBoxDefaults:_maxHeight];
    [self SetTextBoxDefaults:_wheelType];
    [self SetTextBoxDefaults:_nwheels];
    [self SetTextBoxDefaults:_wheelDiameter];
    [self SetTextBoxDefaults:_cims];

    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageIsFullScreen = FALSE;
    UITapGestureRecognizer *photoTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoTapped:)];
    photoTapGestureRecognizer.numberOfTapsRequired = 1;
    [_imageView addGestureRecognizer:photoTapGestureRecognizer];
    [_photoCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"PhotoCell"];
    primePhoto = [[PhotoAttributes alloc] init];
    getAssetURL = FALSE;

//    Undecided about the take photo and choose photo buttons. We are
//    probably going to look into finding the camera button that most apps
//    that access the camera use.
//    [takePhotoBtn setTitle:@"Take Photo" forState:UIControlStateNormal];
//    takePhotoBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:24.0];

    // Initialize the headers for the regional and match tables
    [self createRegionalHeader];
    [self createMatchHeader];
    
    // Initialize the choices for the pop-up menus.
    driveDictionary = [[DriveTypeDictionary alloc] init];
    _driveTypeList = [[driveDictionary getDriveTypes] mutableCopy];
    _intakeList = [[NSMutableArray alloc] initWithObjects:@"Unknown", @"Floor", @"Human", @"Both", nil];
    _climbZoneList = [[NSMutableArray alloc] initWithObjects:@"Unknown", @"One", @"Two", @"Three", nil];

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
    _auton.text = [NSString stringWithFormat:@"%d", [_team.auton intValue]];
    _minHeight.text = [NSString stringWithFormat:@"%.1f", [_team.minHeight floatValue]];
    _maxHeight.text = [NSString stringWithFormat:@"%.1f", [_team.maxHeight floatValue]];
    _wheelType.text = _team.wheelType;
    _nwheels.text = [NSString stringWithFormat:@"%d", [_team.nwheels intValue]];
    _wheelDiameter.text = [NSString stringWithFormat:@"%.1f", [_team.wheelDiameter floatValue]];
    _cims.text = [NSString stringWithFormat:@"%.0f", [_team.cims floatValue]];
    
    NSSortDescriptor *regionalSort = [NSSortDescriptor sortDescriptorWithKey:@"week" ascending:YES];
    regionalList = [[_team.regional allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:regionalSort]];
    
    matchList = [[[CreateMatch alloc] initWithDataManager:_dataManager] getMatchListTournament:_team.number forTournament:tournamentName];
    
    [_driveType setTitle:[driveDictionary getDriveTypeString:_team.driveTrainType] forState:UIControlStateNormal];
    
    [_intakeType setTitle:[_intakeList objectAtIndex:[_team.intake intValue]+1] forState:UIControlStateNormal];
    
    [_climbZone setTitle:[_climbZoneList objectAtIndex:[_team.climbLevel intValue]+1] forState:UIControlStateNormal];
    
    NSString *path = [NSString stringWithFormat:@"Library/RobotPhotos/%@", [NSString stringWithFormat:@"%d", [_team.number intValue]]];
    photoPath = [NSHomeDirectory() stringByAppendingPathComponent:path];
    NSArray *list = [_team.photoList allObjects];
    for (int i=0; i<[list count]; i++) {
        Photo *photo = [list objectAtIndex:i];
        NSLog(@"Photo list = %@", photo.assetURL);
    }
    [self getPhoto];
    [self getPhotoThumbnails];
    dataChange = NO;
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

- (void)viewWillDisappear:(BOOL)animated
{
    [self checkDataStatus];
    [super viewWillDisappear:animated];
}

-(IBAction)detailChanged:(id)sender {
    // One of the pop-up menus has been selected. Determine which one
    //  and push the correct pop-up VC
    UIButton * PressedButton = (UIButton*)sender;
    if (PressedButton == _intakeType) {
        popUp = _intakeType;
        if (_intakePicker == nil) {
            _intakePicker = [[PopUpPickerViewController alloc]
                             initWithStyle:UITableViewStylePlain];
            _intakePicker.delegate = self;
        }
        _intakePicker.pickerChoices = _intakeList;
        self.intakePickerPopover = [[UIPopoverController alloc]
                                        initWithContentViewController:_intakePicker];
        [self.intakePickerPopover presentPopoverFromRect:PressedButton.bounds inView:PressedButton
                                permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else if (PressedButton == _driveType) {
        popUp = _driveType;
        if (_driveTypePicker == nil) {
            _driveTypePicker = [[PopUpPickerViewController alloc]
                             initWithStyle:UITableViewStylePlain];
            _driveTypePicker.delegate = self;
        }
        _driveTypePicker.pickerChoices = _driveTypeList;
        self.drivePickerPopover = [[UIPopoverController alloc]
                                        initWithContentViewController:_driveTypePicker];
        [self.drivePickerPopover presentPopoverFromRect:PressedButton.bounds inView:PressedButton
                                permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else if (PressedButton == _climbZone) {
        popUp = _climbZone;
        if (_climbZonePicker == nil) {
            _climbZonePicker = [[PopUpPickerViewController alloc]
                                initWithStyle:UITableViewStylePlain];
            _climbZonePicker.delegate = self;
        }
        _climbZonePicker.pickerChoices = _climbZoneList;
        self.climbZonePickerPopover = [[UIPopoverController alloc]
                                        initWithContentViewController:_climbZonePicker];
        [self.climbZonePickerPopover presentPopoverFromRect:PressedButton.bounds inView:PressedButton
                                permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

-(void)changeIntake:(NSString *)newIntake {
    // The user has changed the intake type
   for (int i = 0 ; i < [_intakeList count] ; i++) {
        if ([newIntake isEqualToString:[_intakeList objectAtIndex:i]]) {
            [_intakeType setTitle:newIntake forState:UIControlStateNormal];
            _team.intake = [NSNumber numberWithInt:(i-1)];
            [self setDataChange];
            break;
        }
    }
}

-(void)changeDriveType:(NSString *)newDriveType {
    // The user has changed the drive train type
    for (int i = 0 ; i < [_driveTypeList count] ; i++) {
        if ([newDriveType isEqualToString:[_driveTypeList objectAtIndex:i]]) {
            [_driveType setTitle:newDriveType forState:UIControlStateNormal];
            _team.driveTrainType = [NSNumber numberWithInt:(i-1)];
            [self setDataChange];
            break;
        }
    }
}

-(void)changeClimbZone:(NSString *)newClimbZone {
    // The user has changed the climb zone
    for (int i = 0 ; i < [_climbZoneList count] ; i++) {
        if ([newClimbZone isEqualToString:[_climbZoneList objectAtIndex:i]]) {
            [_climbZone setTitle:newClimbZone forState:UIControlStateNormal];
            _team.climbLevel = [NSNumber numberWithInt:(i-1)];
            [self setDataChange];
            break;
        }
    }
}

- (void)pickerSelected:(NSString *)newPick {
    // The user has made a selection on one of the pop-ups. Dismiss the pop-up
    //  and call the correct method to change the right field.
    if (popUp == _driveType) {
        [_drivePickerPopover dismissPopoverAnimated:YES];
        _drivePickerPopover = nil;
        [self changeDriveType:newPick];
    }
    else if (popUp == _intakeType) {
        [_intakePickerPopover dismissPopoverAnimated:YES];
        _intakePickerPopover = nil;
        [self changeIntake:newPick];
    }
    else if (popUp == _climbZone) {
        [_climbZonePickerPopover dismissPopoverAnimated:YES];
        _climbZonePickerPopover = nil;
        [self changeClimbZone:newPick];
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
	else if (textField == _auton) {
		_team.auton = [NSNumber numberWithInt:[_auton.text floatValue]];
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
    // Load the picture for the display. Need to change this to use the new album stuff implemented
    //  last week.
    NSLog(@"Get photo");
    if (_team.primePhoto) {
        NSLog(@"Team = %@", _team.number);
        NSLog(@"Date = %@", _team.primePhotoDate);
        getAssetURL = FALSE;
        [_dataManager getPhotoFromAlbum:[NSURL URLWithString:_team.primePhoto]];
        _imageView.userInteractionEnabled = YES;
    }
    else if (_team.primePhotoDate) {
        NSLog(@"Team = %@", _team.number);
        NSLog(@"Date = %@", _team.primePhotoDate);
        getAssetURL = TRUE;
        [_dataManager getPhotoFromAlbumWithDate:_team.primePhotoDate];
    }
    else {
        _imageView.image = nil;
        _imageView.userInteractionEnabled = NO;
    }
}

-(void)photoRetrieved:(NSNotification *)notification {
    NSLog(@"Photo retrieved");
    if (getAssetURL) {
        getAssetURL = FALSE;
        NSURL *passedURL = [[notification userInfo] objectForKey:@"assetURL"];
        _team.primePhoto = [passedURL absoluteString];
        _imageView.image = [[notification userInfo] objectForKey:@"photoImage"];
        // Save the record so that we don't have to search for the assetURL the next time we
        // load this picture. Do not update the save time or the savedBy flag because
        // the assetURL is non-transferrable so it doesn't need to trip the ready to transfer
        // logic.
        NSError *error;
        if (![_dataManager.managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }    }
    else {
        UIImage *fetchedImage = [[notification userInfo] objectForKey:@"photoImage"];
        _imageView.image = fetchedImage;
    }
//    primePhoto = [[notification userInfo] objectForKey:@"photoImage"];
//    _imageView.image = primePhoto.regularImage;
}

-(void)getPhotoThumbnails {
    NSArray *allPhotos = [_team.photoList allObjects];
    if (![allPhotos count]) return;
    
    // for each photo in list
        // check for assetURL, if no assetURL, go off and fetch it, save db without save marker if fetched
        // fetch thumbnail, set it in an array for the collection view
    
}

-(void) takePhoto {
    //  Use the camera to take a new robot photo
    NSLog(@"Take photo");
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
    _imageView.userInteractionEnabled = YES;
    if ([picker sourceType] == UIImagePickerControllerSourceTypeCamera) {
        [_dataManager savePhotoToAlbum:[info objectForKey:UIImagePickerControllerOriginalImage]];
    }
    else {
        [_dataManager savePhotoToAlbum:[info objectForKey:UIImagePickerControllerOriginalImage]];
//        [_dataManager addPhotoToAlbum:[info objectForKey:UIImagePickerControllerReferenceURL]];
    }
    [self.pictureController dismissPopoverAnimated:true];
    NSLog(@"image picker finish");
    [picker dismissViewControllerAnimated:YES completion:Nil];
}

- (IBAction)photoControllerActionSheet:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Existing",  nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showFromRect:_cameraBtn.frame inView:self.view animated:YES];
//    [actionSheet showInView:_cameraBtn];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self takePhoto];
    } else if (buttonIndex == 1) {
        [self choosePhoto];
    }
}

-(void)photoSaved:(NSNotification *)notification {
    // The photo has been saved. A notification was sent from the ALAsset save function letting
    //  us find out what the photo name was. The names are saved in the database so that we
    //  have a list of all the photos for this robot.
    NSURL *passedURL = [[notification userInfo] objectForKey:@"assetURL"];
    _team.primePhoto = [passedURL absoluteString];
    _team.primePhotoDate = [[notification userInfo] objectForKey:@"photoDate"];
    NSLog(@"Prime Photo string = %@\nDate = %@", _team.primePhoto, _team.primePhotoDate);
    [self addTeamPhotoRecord:_team forPhoto:_team.primePhoto forDate:_team.primePhotoDate];
    [self setDataChange];
}

-(void)addTeamPhotoRecord:(TeamData *)team forPhoto:(NSString *)photoAsset forDate:(NSDate *)photoDate {
    Photo *photoRecord;
    NSArray *allPhotos = [team.photoList allObjects];
    if ([allPhotos count]) {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"assetURL = %@", photoAsset];
        NSArray *photo = [allPhotos filteredArrayUsingPredicate:pred];
        if ([photo count]) return;
        photoRecord = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:_dataManager.managedObjectContext];
    }
    else {
        photoRecord = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:_dataManager.managedObjectContext];
    }
    photoRecord.assetURL = photoAsset;
    photoRecord.photoDate = photoDate;
    [_team addPhotoListObject:photoRecord];
    [self setDataChange];
}

-(void)photoTapped:(UITapGestureRecognizer *)gestureRecognizer {
    NSLog(@"Photo tapped");
    FullSizeViewer *photoViewer = [[FullSizeViewer alloc] init];
    photoViewer.fullImage = _imageView.image;
    [self.navigationController pushViewController:photoViewer animated:YES];
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    NSInteger photoCount = [_team.photoList count];
    if (photoCount > 1) [_photoCollectionView setHidden:NO];
    else [_photoCollectionView setHidden:YES];
    return 0; //photoCount;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"PhotoCell " forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

#pragma mark – UICollectionViewDelegateFlowLayout

// 1
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    NSString *searchTerm = self.searches[indexPath.section];
//    FlickrPhoto *photo = self.searchResults[searchTerm][indexPath.row];
    // 2
//    CGSize retval = photo.thumbnail.size.width > 0 ? photo.thumbnail.size : CGSizeMake(100, 100);
CGSize retval = CGSizeMake(50, 50);
//    retval.height += 35; retval.width += 35;
    return retval;
}

// 3
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(50, 20, 50, 20);
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Segue occurs when the user selects a match out of the match list table. Receiving
    //  VC is the FieldDrawing VC.
    NSIndexPath *indexPath = [self.matchInfo indexPathForCell:sender];
    [segue.destinationViewController setTeamScores:matchList];
    [segue.destinationViewController setStartingIndex:indexPath.row];
    [_matchInfo deselectRowAtIndexPath:indexPath animated:YES];
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
    if ([score.saved intValue] || [score.synced intValue]) label3.text = @"Y";
    else label3.text = @"N";
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
    currentButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:22.0];
}



@end
