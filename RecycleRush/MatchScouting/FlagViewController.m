//
//  FlagViewController.m
//  RecycleRush
//
//  Created by Austin on 4/15/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import "FlagViewController.h"
#import "TeamScore.h"
#import "TeamData.h"
#import "MatchAccessors.h"
#import "TeamAccessors.h"

@interface FlagViewController ()
@property (weak, nonatomic) IBOutlet UIButton *finished;
@property (weak, nonatomic) IBOutlet UILabel *teamNumber;

@end

@implementation FlagViewController
TeamScore *currentScore;
TeamData *info;

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
- (IBAction)finished:(id)sender {
   // if (!changedData) {
     //   [_delegate scoringViewFinished];
        [self dismissViewControllerAnimated:YES completion:Nil];
        return;
}

@end
