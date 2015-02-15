//
//  pitScoutingImagePage.m
//  RecycleRush
//
//  Created by FRC on 1/24/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import "pitScoutingImagePage.h"
#import "DataManager.h" 
#import "PhotoCell.h"
#import "PhotoAttributes.h"
#import "FullSizeViewer.h"
#import "PhotoUtilities.h"
#import "TeamData.h"
#import "pitScoutingDataSheet.h"


@interface pitScoutingImagePage ()
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIButton *cameraBtn;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, weak) IBOutlet UICollectionView *photoCollectionView;
@property (nonatomic, strong) UIPopoverController *pictureController;
@property (weak, nonatomic) IBOutlet UITextField *teamName;
@property (weak, nonatomic) IBOutlet UITextField *teamNumber;


@end

@implementation pitScoutingImagePage {
    PhotoAttributes *primePhoto;
        BOOL dataChange;
    PhotoUtilities *photoUtilities;
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSString *deviceName;
     id action;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
 photoUtilities = [[PhotoUtilities alloc] init:_dataManager];
    // Get the preferences needed for this VC
    prefs = [NSUserDefaults standardUserDefaults];
    tournamentName = [prefs objectForKey:@"tournament"];
    deviceName = [prefs objectForKey:@"deviceName"];
    // Team Detail can be reached from different views. If the parent VC is Team List VC, then
    //  the whole team list is passed in through the fetchedResultsController, so the prev and next
    //  buttons are activated. If the parent is the Mason VC, then only just one team is passed in, so
    //  there are no next and previous teams in the list, so the buttons should be hidden.
    if (_fetchedResultsController && _teamIndex) {
        _team = [_fetchedResultsController objectAtIndexPath:_teamIndex];
    }
    
    [self showTeam];
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
-(void)showTeam {
    //  Set the display fields for the currently selected team.
    self.title = [NSString stringWithFormat:@"%d - %@", [_team.number intValue], _team.name];
    _teamNumber.text = [NSString stringWithFormat:@"%d", [_team.number intValue]];
    _teamName.text = _team.name;
        
    [self getPhoto];
    photoList = [self getPhotoList:_team.number];
    [_photoCollectionView reloadData];
    dataChange = NO;
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



- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}
- (IBAction)camerabutton:(id)sender {
    action=sender;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Existing",  nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showFromRect:_cameraBtn.frame inView:self.view animated:YES];
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
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
/*    if (!_pictureController) {
        _pictureController = [[UIPopoverController alloc]
                              initWithContentViewController:_imagePickerController];
        _pictureController.delegate = self;
    }
    [_pictureController presentPopoverFromRect:_cameraBtn.bounds inView:_cameraBtn
                      permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES]; */
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

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (action == _cameraBtn) {
        if (buttonIndex == 0) {
            [self takePhoto];
        } else if (buttonIndex == 1) {
            [self choosePhoto];
        }
    }
    else if (action == _photoCollectionView) {
/*        if (buttonIndex == 0) {
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
        }*/
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"TeamDetail"]) {
        [segue.destinationViewController setDataManager:_dataManager];
        [segue.destinationViewController setTeam:_team];
    }

    }



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
