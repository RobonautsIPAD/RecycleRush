//
//  AddTeamViewController.m
// Robonauts Scouting
//
//  Created by FRC on 10/14/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "AddTeamViewController.h"

@interface AddTeamViewController ()

@end

@implementation AddTeamViewController {
    NSNumber *teamNumber;
    NSString *teamName;
}

@synthesize teamNumberTextField = _teamNumberTextField;
@synthesize teamNameTextField = _teamNameTextField;
@synthesize delegate = _delegate;
@synthesize splashPicture =_splashPicture;
@synthesize mainLogo = _mainLogo;
@synthesize pictureCaption = _pictureCaption;

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
    self.title =  @"Add Team";
	// Do any additional setup after loading the view.
    
    // Display the Robotnauts Banner
    [_mainLogo setImage:[UIImage imageNamed:@"robonauts app banner.jpg"]];
    // Display the Label for the Picture
    _pictureCaption.font = [UIFont fontWithName:@"Nasalization" size:24.0];
    _pictureCaption.text = @"Just Hangin' Out";
}

- (void)viewDidUnload {
    teamName = nil;
    teamNumber = nil;
}

- (IBAction)cancelVC:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}

- (IBAction)addAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
    NSLog(@"Adding team %@", teamNumber);
    if (_delegate == nil) NSLog(@"no delegate");
    [_delegate teamAdded:teamNumber forName:teamName];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField != _teamNumberTextField)  return YES;

    NSString *resultingString = [textField.text stringByReplacingCharactersInRange: range withString: string];
    
    // This allows backspace
    if ([resultingString length] == 0) {
        return true;
    }
    
    NSInteger holder;
    NSScanner *scan = [NSScanner scannerWithString: resultingString];
    
    return [scan scanInteger: &holder] && [scan isAtEnd];
}

#pragma mark -
#pragma mark Text

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    //    NSLog(@"team should end editing");
    if (textField == _teamNumberTextField) {
        teamNumber = [NSNumber numberWithInt:[_teamNumberTextField.text intValue]];
	}
	else if (textField == _teamNameTextField) {
        teamName = _teamNameTextField.text;
	}
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
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
    return UIInterfaceOrientationMaskLandscape;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    switch(toInterfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            //( , , , )
            _mainLogo.frame = CGRectMake(0, 0, 1024, 285);
            [_mainLogo setImage:[UIImage imageNamed:@"robonauts app banner original.jpg"]];
            _splashPicture.frame = CGRectMake(23, 308, 468, 330);
            _pictureCaption.frame = CGRectMake(23, 646, 468, 39);
            break;
        default:
            break;
            
    }
}

@end
