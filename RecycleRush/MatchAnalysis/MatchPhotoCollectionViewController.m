//
//  MatchPhotoCollectionViewController.m
//  RecycleRush
//
//  Created by FRC on 2/21/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import "MatchPhotoCollectionViewController.h"
#import "UIDefaults.h"
#import "MatchPhotoUtilities.h"
#import "FullSizeViewer.h"
#import "PhotoCell.h"

@interface MatchPhotoCollectionViewController ()
@property (weak, nonatomic) IBOutlet UIButton *teamNumberButton;
@property (weak, nonatomic) IBOutlet UICollectionView *matchCollection;

@end

@implementation MatchPhotoCollectionViewController {
    NSNumber *currectTeamNumber;
    MatchPhotoUtilities *matchPhotoUtilities;
    NSArray *matchPhotoList;
    PopUpPickerViewController *teamPicker;
    UIPopoverController *teamPickerPopover;
    float ratio;
    NSUInteger nPhotos;
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
    matchPhotoUtilities = [[MatchPhotoUtilities alloc] init:_dataManager];
    [UIDefaults setBigButtonDefaults:_teamNumberButton withFontSize:nil];
    currectTeamNumber = _teamNumber;
    ratio = 567/437;
    [self showTeam];
    [_matchCollection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"MatchCell"];
}

-(void)showTeam {
    [_teamNumberButton setTitle:[NSString stringWithFormat:@"%@", currectTeamNumber] forState:UIControlStateNormal];
    matchPhotoList = [matchPhotoUtilities getTeamPhotoList:currectTeamNumber];
    if (matchPhotoList) nPhotos = [matchPhotoList count];
    else nPhotos = 0;
    [_matchCollection reloadData];
}

-(IBAction)teamSelectionChanged:(id)sender {
    if (teamPicker == nil) {
        teamPicker = [[PopUpPickerViewController alloc]
                      initWithStyle:UITableViewStylePlain];
        teamPicker.delegate = self;
        teamPicker.pickerChoices = _teamList;
    }
    if (!teamPickerPopover) {
        teamPickerPopover = [[UIPopoverController alloc]
                             initWithContentViewController:teamPicker];
    }
    [teamPickerPopover presentPopoverFromRect:_teamNumberButton.bounds inView:_teamNumberButton
                     permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)pickerSelected:(NSString *)newPick {
    [teamPickerPopover dismissPopoverAnimated:YES];
    NSUInteger index = [_teamList indexOfObject:newPick];
    if (index != NSNotFound) currectTeamNumber = [_teamList objectAtIndex:index];
    [self showTeam];

}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return nPhotos;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"thumbnail" forIndexPath:indexPath];
    NSString *photo = [matchPhotoList objectAtIndex:indexPath.row];
    cell.thumbnail = [UIImage imageWithContentsOfFile:[matchPhotoUtilities getFullPath:photo]];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath  {
    FullSizeViewer *photoViewer = [[FullSizeViewer alloc] init];
    photoViewer.imagePath = [matchPhotoUtilities getFullPath:[matchPhotoList objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:photoViewer animated:YES];
/*    action = _photoCollectionView;
    selectedPhoto = [photoList objectAtIndex:indexPath.row];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Set as Prime", @"Show Full Screen",  @"Delete Photo", nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showFromRect:_cameraBtn.frame inView:self.view animated:YES];*/
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(317, 244);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
