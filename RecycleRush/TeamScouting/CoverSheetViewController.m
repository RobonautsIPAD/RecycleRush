//
//  CoverSheetViewController.m
//  RecycleRush
//
//  Created by FRC on 4/18/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import "CoverSheetViewController.h"
#import <QuartzCore/CALayer.h>

@interface CoverSheetViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *teamLabel;
@property (weak, nonatomic) IBOutlet UITextField *teamNumberField;
@property (weak, nonatomic) IBOutlet UILabel *teamNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *robotPhotoImageView;
@property (weak, nonatomic) IBOutlet UIView *robotInfoView;
@property (weak, nonatomic) IBOutlet UIView *robotHistoryView;
@property (weak, nonatomic) IBOutlet UITextField *oprField;
@property (weak, nonatomic) IBOutlet UITextField *canDomField;
@property (weak, nonatomic) IBOutlet UITextField *ccwmField;
@property (weak, nonatomic) IBOutlet UITextField *canDomTimeField;
@property (weak, nonatomic) IBOutlet UITextField *scoreField;
@property (weak, nonatomic) IBOutlet UILabel *event1Label;
@property (weak, nonatomic) IBOutlet UILabel *event2Label;
@property (weak, nonatomic) IBOutlet UILabel *event3Label;
@property (weak, nonatomic) IBOutlet UILabel *event4Label;
@property (weak, nonatomic) IBOutlet UILabel *event5Label;
@property (weak, nonatomic) IBOutlet UITextField *notesField;

@end

@implementation CoverSheetViewController

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
    _robotInfoView.layer.borderColor = [UIColor blackColor].CGColor;
    _robotInfoView.layer.borderWidth = 2.0f;
    _robotHistoryView.layer.borderColor = [UIColor blackColor].CGColor;
    _robotHistoryView.layer.borderWidth = 1.0f;
    _robotHistoryView.layer.cornerRadius = 10.0f;
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
