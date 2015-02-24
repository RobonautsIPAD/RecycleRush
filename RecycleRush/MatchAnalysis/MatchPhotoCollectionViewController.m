//
//  MatchPhotoCollectionViewController.m
//  RecycleRush
//
//  Created by FRC on 2/21/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import "MatchPhotoCollectionViewController.h"
#import "UIDefaults.h"

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
    [UIDefaults setBigButtonDefaults:_teamNumberButton];
    currectTeamNumber = _teamNumber;
    [self showTeam];
}

-(void)showTeam {
    [_teamNumberButton setTitle:[NSString stringWithFormat:@"%@", currectTeamNumber] forState:UIControlStateNormal];
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
