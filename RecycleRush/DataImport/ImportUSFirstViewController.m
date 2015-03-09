//
//  ImportUSFirstViewController.m
//  RecycleRush
//
//  Created by FRC on 1/11/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "ImportUSFirstViewController.h"
#import "DataManager.h"

@interface ImportUSFirstViewController ()

@end

@implementation ImportUSFirstViewController {
    NSUserDefaults *prefs;
    NSString *tournamentName;
}

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
    if (!_dataManager) {
        _dataManager = [[DataManager alloc] init];
    }
    
    prefs = [NSUserDefaults standardUserDefaults];
    tournamentName = [prefs objectForKey:@"tournament"];
    if (tournamentName) {
        self.title =  [NSString stringWithFormat:@"%@ Extract some name", tournamentName];
    }
    else {
        self.title = @"Extract some name";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
