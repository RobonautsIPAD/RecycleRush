//
//  MatchPhotoCollectionViewController.m
//  RecycleRush
//
//  Created by FRC on 2/21/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import "MatchPhotoCollectionViewController.h"
#import "UIDefaults.h"
#import "MatchCell.h"

@interface MatchPhotoCollectionViewController ()
@property (weak, nonatomic) IBOutlet UIButton *teamNumberButton;
@property (weak, nonatomic) IBOutlet UICollectionView *matchCollection;

@end

@implementation MatchPhotoCollectionViewController {
    NSNumber *currectTeamNumber;
    PopUpPickerViewController *teamPicker;
    UIPopoverController *teamPickerPopover;
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
    [UIDefaults setBigButtonDefaults:_teamNumberButton withFontSize:nil];
    currectTeamNumber = _teamNumber;
    [self showTeam];
    [_matchCollection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"MatchCell"];
}

-(void)showTeam {
    [_teamNumberButton setTitle:[NSString stringWithFormat:@"%@", currectTeamNumber] forState:UIControlStateNormal];
    NSLog(@"Get match photo list");
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
    NSInteger matchCount = 0;
    if (matchCount > 0) [_matchCollection setHidden:NO];
    else [_matchCollection setHidden:YES];
    return matchCount;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MatchCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MatchCell" forIndexPath:indexPath];
//    NSString *photo = [photoList objectAtIndex:indexPath.row];
//    cell.thumbnail = [UIImage imageWithContentsOfFile:[photoUtilities getThumbnailPath:photo]];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath  {
/*    action = _photoCollectionView;
    selectedPhoto = [photoList objectAtIndex:indexPath.row];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Set as Prime", @"Show Full Screen",  @"Delete Photo", nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showFromRect:_cameraBtn.frame inView:self.view animated:YES];*/
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(50, 50);
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
