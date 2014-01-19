//
//  SetUpPageViewController.m
// Robonauts Scouting
//
//  Created by Kris Pettinger on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SetUpPageViewController.h"
#import "DataManager.h"

@implementation SetUpPageViewController
@synthesize dataManager = _dataManager;
@synthesize mainLogo = _mainLogo;
@synthesize settingsButton = _settingsButton;
@synthesize matchSetUpButton = _matchSetUpButton;
@synthesize importDataButton = _importDataButton;
@synthesize exportDataButton = _exportDataButton;
@synthesize splashPicture = _splashPicture;
@synthesize pictureCaption = _pictureCaption;

- (id)initWithManagedObject:(NSManagedObjectContext *)managedObjectContext {
	if ((self = [super init]))
	{
//        _managedObjectContext = managedObjectContext;
	}
	return self;
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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    NSLog(@"Set-Up Page");
    if (!_dataManager) {
        _dataManager = [DataManager new];
    }
    
    // Display the Robonauts Banner
    [_mainLogo setImage:[UIImage imageNamed:@"robonauts app banner.jpg"]];
    // Display the Label for the Picture
    _pictureCaption.font = [UIFont fontWithName:@"Nasalization" size:24.0];
    _pictureCaption.text = @"Just Hangin' Out";
 
    // Set Font and Text for Tournament Set-Up Button
    [_settingsButton setTitle:@"Tournament" forState:UIControlStateNormal];
    _settingsButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:36.0];

    // Set Font and Text for Match Set-Up Button
    [_matchSetUpButton setTitle:@"Match List" forState:UIControlStateNormal];
    _matchSetUpButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:36.0];

    // Set Font and Text for Import Data Button
    [_importDataButton setTitle:@"Import Data" forState:UIControlStateNormal];
    _importDataButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:36.0];

    // Set Font and Text for Export Data Button
    [_exportDataButton setTitle:@"Export Data" forState:UIControlStateNormal];
    _exportDataButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:36.0];
    self.title = @"Set-Up Page";
   [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setDataManager:_dataManager];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    _dataManager = nil;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
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
            _mainLogo.frame = CGRectMake(0, -50, 1024, 255);
            [_mainLogo setImage:[UIImage imageNamed:@"robonauts app banner original.jpg"]];
            _settingsButton.frame = CGRectMake(550, 225, 400, 68);
            _matchSetUpButton.frame = CGRectMake(550, 325, 400, 68);
            _importDataButton.frame = CGRectMake(550, 425, 400, 68);
            _exportDataButton.frame = CGRectMake(550, 525, 400, 68);
            _splashPicture.frame = CGRectMake(50, 243, 468, 330);
            _pictureCaption.frame = CGRectMake(50, 581, 468, 39);
            break;
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            _mainLogo.frame = CGRectMake(-20, 0, 285, 960);
            [_mainLogo setImage:[UIImage imageNamed:@"robonauts app banner.jpg"]];
            _settingsButton.frame = CGRectMake(325, 125, 400, 68);
            _matchSetUpButton.frame = CGRectMake(325, 225, 400, 68);
            _importDataButton.frame = CGRectMake(325, 325, 400, 68);
            _exportDataButton.frame = CGRectMake(325, 425, 400, 68);
            _splashPicture.frame = CGRectMake(293, 563, 468, 330);
            _pictureCaption.frame = CGRectMake(293, 901, 468, 39);
            break;
        default:
            break;
    }
}

/*
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            _mainLogo.frame = CGRectMake(-20, 0, 285, 960);
            [_mainLogo setImage:[UIImage imageNamed:@"robonauts app banner.jpg"]];
            _settingsButton.frame = CGRectMake(325, 125, 400, 68);
            _matchSetUpButton.frame = CGRectMake(325, 225, 400, 68);
            _importDataButton.frame = CGRectMake(325, 325, 400, 68);
            _exportDataButton.frame = CGRectMake(325, 425, 400, 68);
            _splashPicture.frame = CGRectMake(293, 563, 468, 330);
            _pictureCaption.frame = CGRectMake(293, 901, 468, 39);
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            _mainLogo.frame = CGRectMake(0, -60, 1024, 255);
            [_mainLogo setImage:[UIImage imageNamed:@"robonauts app banner original.jpg"]];
            _settingsButton.frame = CGRectMake(550, 225, 400, 68);
            _matchSetUpButton.frame = CGRectMake(550, 325, 400, 68);
            _importDataButton.frame = CGRectMake(550, 425, 400, 68);
            _exportDataButton.frame = CGRectMake(550, 525, 400, 68);
            _splashPicture.frame = CGRectMake(50, 243, 468, 330);
            _pictureCaption.frame = CGRectMake(50, 581, 468, 39);
            break;
        default:
            break;
    }
   // Return YES for supported orientations
	return YES;
}
 
*/

@end
