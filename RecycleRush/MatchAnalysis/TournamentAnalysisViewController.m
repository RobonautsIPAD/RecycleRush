//
//  TournamentAnalysisViewController.m
//  RecycleRush
//
//  Created by FRC on 1/13/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "TournamentAnalysisViewController.h"
#import "DataManager.h"
#import "MainLogo.h"

@interface TournamentAnalysisViewController ()
    @property (nonatomic, weak) IBOutlet UIImageView *splashPicture;
    @property (nonatomic, weak) IBOutlet UIImageView *mainLogo;
    @property (nonatomic, weak) IBOutlet UILabel *pictureCaption;
    @property (nonatomic, weak) IBOutlet UIButton *masonPageButton;
    @property (nonatomic, weak) IBOutlet UIButton *lucianPageButton;
    @property (nonatomic, weak) IBOutlet UIButton *ridleyPageButton;
@property (weak, nonatomic) IBOutlet UIButton *cancel;
@property (weak, nonatomic) IBOutlet UIButton *addTeam;
@end

@implementation TournamentAnalysisViewController

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
    
    // Display the Label for the Picture
    _pictureCaption.font = [UIFont fontWithName:@"Nasalization" size:24.0];
    _pictureCaption.text = @"Just Hangin' Out";
    //Set Font And Text For Mason Page Button
    [_masonPageButton setTitle:@"Brogan Page" forState:UIControlStateNormal];
    _masonPageButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:36.0];
    //Set Font And Text For Lucian Page Button
    [_lucianPageButton setTitle:@"Lucien Page" forState:UIControlStateNormal];
    _lucianPageButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:36.0];
    //Set Font And Page For Ridley Page Button
    [_ridleyPageButton setTitle:@"Ridley Page" forState:UIControlStateNormal];
    _ridleyPageButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:36.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillLayoutSubviews {
    _mainLogo = [MainLogo rotate:self.view forImageView:_mainLogo forOrientation:self.interfaceOrientation];
}

- (IBAction)addTeam:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}

- (IBAction)opps:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}

@end
