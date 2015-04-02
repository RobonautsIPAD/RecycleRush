//
//  DetailScrollViewController.m
//  RecycleRush
//
//  Created by FRC on 4/1/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import "DetailScrollViewController.h"

@interface DetailScrollViewController ()

@end

@implementation DetailScrollViewController

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

#pragma mark - Navigation
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"TeamDetail"]) {
        [segue.destinationViewController setDataManager:_dataManager];
        [segue.destinationViewController setTeam:_team];
    }
}

@end
