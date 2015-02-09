//
//  SetUpPageViewController.m
// Robonauts Scouting
//
//  Created by Kris Pettinger on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SetUpPageViewController.h"
#import "DataManager.h"
#import "MainLogo.h"

@interface SetUpPageViewController ()
@property (nonatomic, weak) IBOutlet UIImageView *mainLogo;
@property (nonatomic, weak) IBOutlet UILabel *pictureCaption;
@property (nonatomic, weak) IBOutlet UIButton *settingsButton;
@property (nonatomic, weak) IBOutlet UIButton *matchListButton;
@property (nonatomic, weak) IBOutlet UIButton *dataTransferButton;
@property (nonatomic, weak) IBOutlet UIImageView *splashPicture;
@property (nonatomic, weak) IBOutlet UIButton *elimDataButton;
@property (nonatomic, weak) IBOutlet UIButton *matchIntegrityButton;
@end

@implementation SetUpPageViewController

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
    
 
    // Set Font and Text for Tournament Set-Up Button
    [_settingsButton setTitle:@"App Mode" forState:UIControlStateNormal];
    _settingsButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:36.0];

    // Set Font and Text for Match Set-Up Button
    [_matchListButton setTitle:@"Match List" forState:UIControlStateNormal];
    _matchListButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:36.0];

   // Set Font and Text for Export Data Button
    [_dataTransferButton setTitle:@"Data Transfer" forState:UIControlStateNormal];
    _dataTransferButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:36.0];
    self.title = @"Set-Up Page";
    
    //Set Font and Text for Elim Data Button
    [_elimDataButton setTitle:@"Create Alliance" forState:UIControlStateNormal];
    _elimDataButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:36.0];
    
    //Set Font and Text for Match Integrity Data Button
    [_matchIntegrityButton setTitle:@"Match Integrity" forState:UIControlStateNormal];
    _matchIntegrityButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:36.0];
 
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setDataManager:_dataManager];
}

/*
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
    
    NSLog(@"IOS Version = IOS 6.1");
    
    switch(toInterfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            //( , , , )
            _mainLogo.frame = CGRectMake(0, -50, 1024, 255);
            [_mainLogo setImage:[UIImage imageNamed:@"robonauts app banner original.jpg"]];
            _settingsButton.frame = CGRectMake(550, 225, 400, 68);
            _matchListButton.frame = CGRectMake(550, 325, 400, 68);
            _dataTransferButton.frame = CGRectMake(550, 425, 400, 68);
            _splashPicture.frame = CGRectMake(50, 243, 468, 330);
            _pictureCaption.frame = CGRectMake(50, 581, 468, 39);
            break;
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            _mainLogo.frame = CGRectMake(-20, 0, 285, 960);
            [_mainLogo setImage:[UIImage imageNamed:@"robonauts app banner.jpg"]];
            _settingsButton.frame = CGRectMake(325, 125, 400, 68);
            _matchListButton.frame = CGRectMake(325, 225, 400, 68);
            _dataTransferButton.frame = CGRectMake(325, 325, 400, 68);
            _splashPicture.frame = CGRectMake(293, 563, 468, 330);
            _pictureCaption.frame = CGRectMake(293, 901, 468, 39);
            break;
        default:
            break;
    }
}
*/

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

-(void)viewWillLayoutSubviews {
    _mainLogo = [MainLogo rotate:self.view forImageView:_mainLogo forOrientation:self.interfaceOrientation];
}
@end
