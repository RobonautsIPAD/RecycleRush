//
//  SplashPageViewController.m
// Robonauts Scouting
//
//  Created by Kris Pettinger on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SplashPageViewController.h"
#import "SetUpPageViewController.h"
#import "TeamMatchListViewController.h"
#import "DallasMigration.h"

@interface TeamMatchListSegue : UIStoryboardSegue
@end

@implementation TeamMatchListSegue
- (void)perform {
    // our custom segue is being fired, push the tablet error view controller
    UINavigationController *sourceViewController = self.sourceViewController;
    TeamMatchListViewController *destinationViewController = self.destinationViewController;
    [sourceViewController pushViewController:destinationViewController animated:YES];
}
@end

@interface SplashPageViewController ()
@property (nonatomic, strong) TeamMatchListSegue *teamMatchListSegue;
@end

@implementation SplashPageViewController {
    NSUserDefaults *prefs;
    DallasMigration *dallasMigration;
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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{ 
  //  NSLog(@"Splash Page");
    NSLog(@"All Good :)");
    prefs = [NSUserDefaults standardUserDefaults];
    NSString *gameName = [prefs objectForKey:@"gameName"];
    self.title = gameName;
    NSString *mode = [prefs objectForKey:@"mode"];
    if ([mode isEqualToString:@"Analysis"]) {
        NSLog(@"Jump to Anaysis");
        TeamMatchListViewController *teamMatchListView = [[self.navigationController storyboard] instantiateViewControllerWithIdentifier:@"TeamMatchListViewController"];
        [teamMatchListView setDataManager:_dataManager];
        [teamMatchListView setConnectionUtility:_connectionUtility];
        self.teamMatchListSegue = [[TeamMatchListSegue alloc] initWithIdentifier:@"TeamMatchListViewController"
                                                                          source:self.navigationController
                                                                     destination:teamMatchListView];
        [self.teamMatchListSegue perform];
    }
//    NSLog(@"Do not leave Sacramento migration in place !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
//    dallasMigration = [[DallasMigration alloc] init:_dataManager];
//    [dallasMigration sacramentoMigration];
//    [dallasMigration dallasMigration2];
 
    // Display the Label for the Picture
    _pictureCaption.font = [UIFont fontWithName:@"Nasalization" size:36.0];
    _pictureCaption.text = @"Just Hangin' Out";
    _pictureCaption.lineBreakMode = 2;
    // Set Font and Text for Team Scouting Button
    [_teamScoutingButton setTitle:@"Team/Pit Scouting" forState:UIControlStateNormal];
    _teamScoutingButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:36.0];
    // Set Font and Text for Tournament Set Up Button
    [_matchSetUpButton setTitle:@"SetUp" forState:UIControlStateNormal];
    _matchSetUpButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:36.0];
    // Set Font and Text for Match Scouting Up Button
    [_matchScoutingButton setTitle:@"Match Scouting" forState:UIControlStateNormal];
    _matchScoutingButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:36.0];
    //set Font and Text for Tournament Analysis Button
    [_tournamentAnalysisButton setTitle:@"analysis" forState:UIControlStateNormal];
    _tournamentAnalysisButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:36.0];
    [super viewDidLoad];
    
  //  NSLog(@"Analysis Pages");
}
                    
 -(void) moveObject {
     image.center = CGPointMake(image.center.x, image.center.y +5);
                       }

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setDataManager:_dataManager];
    if ([segue.identifier isEqualToString:@"Full"]) {
        [segue.destinationViewController setConnectionUtility:_connectionUtility];
    }
}

- (void)scoutingPageStatus:(NSUInteger)sectionIndex forRow:(NSUInteger)rowIndex forTeam:(NSUInteger)teamIndex {
    NSLog(@"scouting delegate");    
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
            _mainLogo.frame = CGRectMake(0, -50, 1024, 285);
            [_mainLogo setImage:[UIImage imageNamed:@"robonauts app banner original.jpg"]];
            _teamScoutingButton.frame = CGRectMake(550, 215, 400, 68);
            _matchSetUpButton.frame = CGRectMake(550, 315, 400, 68);
            _matchScoutingButton.frame = CGRectMake(550, 415, 400, 68);
            _matchAnalysisButton.frame = CGRectMake(550, 515, 400, 68);
            _tournamentAnalysisButton.frame =CGRectMake(550, 615, 400, 68);
            _splashPicture.frame = CGRectMake(50, 233, 468, 330);
            _pictureCaption.frame = CGRectMake(50, 571, 468, 39);
            break;
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            _mainLogo.frame = CGRectMake(-20, 0, 285, 960);
            [_mainLogo setImage:[UIImage imageNamed:@"robonauts app banner.jpg"]];
            _teamScoutingButton.frame = CGRectMake(325, 25, 400, 68);
            _matchSetUpButton.frame = CGRectMake(325, 125, 400, 68);
            _matchScoutingButton.frame = CGRectMake(325, 225, 400, 68);
            _matchAnalysisButton.frame = CGRectMake(325, 325, 400, 68);
            _tournamentAnalysisButton.frame =CGRectMake(325, 425, 400, 68);
            _splashPicture.frame = CGRectMake(293, 563, 468, 330);
            _pictureCaption.frame = CGRectMake(293, 901, 468, 39);
            
            break;
        default:
            break;
            
    }
} */

/*
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            _mainLogo.frame = CGRectMake(0, 0, 285, 960);
            [_mainLogo setImage:[UIImage imageNamed:@"robonauts app banner.jpg"]];
            _teamScoutingButton.frame = CGRectMake(325, 125, 400, 68);
            _matchSetUpButton.frame = CGRectMake(325, 225, 400, 68);
            _matchScoutingButton.frame = CGRectMake(325, 325, 400, 68);
            _matchAnalysisButton.frame = CGRectMake(325, 425, 400, 68);
            _splashPicture.frame = CGRectMake(293, 563, 468, 330);
            _pictureCaption.frame = CGRectMake(293, 901, 468, 39);
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            _mainLogo.frame = CGRectMake(0, -50, 1024, 285);
            [_mainLogo setImage:[UIImage imageNamed:@"robonauts app banner original.jpg"]];
            _teamScoutingButton.frame = CGRectMake(550, 215, 400, 68);
            _matchSetUpButton.frame = CGRectMake(550, 315, 400, 68);
            _matchScoutingButton.frame = CGRectMake(550, 415, 400, 68);
            _matchAnalysisButton.frame = CGRectMake(550, 515, 400, 68);
            _splashPicture.frame = CGRectMake(50, 233, 468, 330);
            _pictureCaption.frame = CGRectMake(50, 571, 468, 39);
            break;
        default:
            break;
    }
    // Return YES for supported orientations
	return YES;
}

*/
 
@end
