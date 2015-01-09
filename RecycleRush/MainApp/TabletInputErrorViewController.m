//
//  TabletInputErrorViewController.m
//  RecycleRush
//
//  Created by FRC on 11/21/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "TabletInputErrorViewController.h"
#import "DataManager.h"
#import "FileIOMethods.h"

@interface TabletInputErrorViewController ()
@property (weak, nonatomic) IBOutlet UIButton *clearErrorsButton;
@property (weak, nonatomic) IBOutlet UIButton *clearWarningsButton;
- (IBAction)clearAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *errorTextView;
@property (weak, nonatomic) IBOutlet UITextView *warningsTextView;

@end

@implementation TabletInputErrorViewController {
    NSFileManager *fileManager;
    NSString *errorFilePath;
    NSString *warningFilePath;
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
    [self setBigButtonDefaults:_clearErrorsButton];
    [self setBigButtonDefaults:_clearWarningsButton];
    fileManager = [NSFileManager defaultManager];

    if ([fileManager fileExistsAtPath:_dataManager.errorFilePath]) {
        _errorTextView.text = [NSString stringWithContentsOfFile:_dataManager.errorFilePath encoding:NSUTF8StringEncoding error:nil];
    }
    if ([fileManager fileExistsAtPath:_dataManager.warningFilePath]) {
        _warningsTextView.text = [NSString stringWithContentsOfFile:_dataManager.warningFilePath encoding:NSUTF8StringEncoding error:nil];
    }
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

- (IBAction)clearAction:(id)sender {
    if (sender == _clearWarningsButton) {
        [_dataManager resetWarningFile];
        _warningsTextView.text = [NSString stringWithContentsOfFile:_dataManager.warningFilePath encoding:NSUTF8StringEncoding error:nil];
    }
    else if (sender == _clearErrorsButton) {
        [_dataManager resetErrorFile];
        _errorTextView.text = [NSString stringWithContentsOfFile:_dataManager.errorFilePath encoding:NSUTF8StringEncoding error:nil];
    }
}

-(void)setBigButtonDefaults:(UIButton *)currentButton {
    currentButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    // Round button corners
    CALayer *btnLayer = [currentButton layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:10.0f];
    // Apply a 1 pixel, black border
    [btnLayer setBorderWidth:1.0f];
    [btnLayer setBorderColor:[[UIColor blackColor] CGColor]];
    // Set the button Background Color
    [currentButton setBackgroundColor:[UIColor whiteColor]];
    // Set the button Text Color
    [currentButton setTitleColor:[UIColor colorWithRed:(0.0/255) green:(0.0/255) blue:(120.0/255) alpha:1.0 ]forState: UIControlStateNormal];
}

@end
