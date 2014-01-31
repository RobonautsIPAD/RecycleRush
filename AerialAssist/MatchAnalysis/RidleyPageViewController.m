//
//  RidleyPageViewController.m
//  AerialAssist
//
//  Created by FRC on 1/13/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "RidleyPageViewController.h"
#import "DataManager.h"
@interface RidleyPageViewController ()

@end

@implementation RidleyPageViewController

@synthesize dataManager = _dataManager;

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
