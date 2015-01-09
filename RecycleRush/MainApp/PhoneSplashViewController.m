//
//  PhoneSplashViewController.m
//  RecycleRush
//
//  Created by FRC on 2/14/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "PhoneSplashViewController.h"
#import "DataManager.h"
#import "PhoneSetUpViewController.h"
#import "PhoneSyncViewController.h"

@interface PhoneSplashViewController ()
@property (nonatomic, weak) IBOutlet UIButton *exportButton;
@property (nonatomic, weak) IBOutlet UIButton *syncButton;

@end

@implementation PhoneSplashViewController {
    NSUserDefaults *prefs;
    PhoneSyncViewController *syncViewController;
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
    if (!_dataManager) {
        _dataManager = [[DataManager alloc] init];
    }

    prefs = [NSUserDefaults standardUserDefaults];
    NSString *gameName = [prefs objectForKey:@"gameName"];
    self.title = gameName;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setDataManager:_dataManager];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
