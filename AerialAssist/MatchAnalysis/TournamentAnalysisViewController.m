//
//  TournamentAnalysisViewController.m
//  AerialAssist
//
//  Created by FRC on 1/13/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "TournamentAnalysisViewController.h"
#import "DataManager.h"

@interface TournamentAnalysisViewController ()

@end

@implementation TournamentAnalysisViewController

@synthesize dataManager = _dataManager;
@synthesize mainLogo = _mainLogo;
@synthesize splashPicture = _splashPicture;
@synthesize pictureCaption = _pictureCaption;
@synthesize masonPageButton = _masonPageButton;
@synthesize lucianPageButton = _lucianPageButton;
@synthesize ridleyPageButton = _ridleyPageButton;

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
    
    // Display the Robotnauts Banner
    [_mainLogo setImage:[UIImage imageNamed:@"robonauts app banner.jpg"]];
    // Display the Label for the Picture
    _pictureCaption.font = [UIFont fontWithName:@"Nasalization" size:24.0];
    _pictureCaption.text = @"Just Hangin' Out";
    //Set Font And Text For Mason Page Button
    [_masonPageButton setTitle:@"Mason Page" forState:UIControlStateNormal];
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

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    switch(toInterfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            //( , , , )
            self.mainLogo.frame = CGRectMake(0, -50, 1024, 255);
            [self.mainLogo setImage:[UIImage imageNamed:@"robonauts app banner original.jpg"]];
            self.splashPicture.frame = CGRectMake(50, 233, 468, 330);
            self.pictureCaption.frame = CGRectMake(50, 571, 468, 39);
            self.masonPageButton.frame = CGRectMake(560, 315, 400, 68);
            self.lucianPageButton.frame = CGRectMake(560, 415, 400, 68);
            self.ridleyPageButton.frame = CGRectMake(560, 515, 400, 68);
            _splashPicture.frame = CGRectMake(50, 233, 468, 330);
            break;
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            self.mainLogo.frame = CGRectMake(0, 0, 285, 960);
            [self.mainLogo setImage:[UIImage imageNamed:@"robonauts app banner.jpg"]];
            self.splashPicture.frame = CGRectMake(293, 563, 468, 330);
            self.pictureCaption.frame = CGRectMake(293, 901, 468, 39);
            self.masonPageButton.frame = CGRectMake(328, 89, 400, 68);
            self.lucianPageButton.frame = CGRectMake(328, 273, 400, 68);
            self.ridleyPageButton.frame = CGRectMake(328, 470, 400, 68);
            break;
        default:
            break;
            
    }
}


@end
