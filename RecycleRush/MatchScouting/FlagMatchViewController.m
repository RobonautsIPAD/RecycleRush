//
//  FlagMatchViewController.m
//  RecycleRush
//
//  Created by FRC on 3/7/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import "FlagMatchViewController.h"

@interface FlagMatchViewController ()
@property (weak, nonatomic) IBOutlet UIButton *blacklistRobot;
@property (weak, nonatomic) IBOutlet UIButton *blacklistDriver;
@property (weak, nonatomic) IBOutlet UIButton *blacklistHP;
@property (weak, nonatomic) IBOutlet UIButton *wowRobot;
@property (weak, nonatomic) IBOutlet UIButton *wowDriver;
@property (weak, nonatomic) IBOutlet UIButton *wowHP;
@property (weak, nonatomic) IBOutlet UITextView *robotNotes;
@property (weak, nonatomic) IBOutlet UITextView *foulNotes;
@property (weak, nonatomic) IBOutlet UITextField *redCardNumber;
@property (weak, nonatomic) IBOutlet UITextField *yellowCardNumber;

@end

@implementation FlagMatchViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
