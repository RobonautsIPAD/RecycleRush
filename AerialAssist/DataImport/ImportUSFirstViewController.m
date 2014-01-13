//
//  ImportUSFirstViewController.m
//  AerialAssist
//
//  Created by FRC on 1/11/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "ImportUSFirstViewController.h"
#import "DataManager.h"
#import "TeamDataInterfaces.h"

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
    
    
    // Interface to add a new team. Give it the team number, name and tournament
    // If the team does not exist, this method creates it.
    // If the team does exist, it adds the tournament to the list of tournaments
    //      for this team. If the team already exists for this tournament, it returns
    //      false and nothing happens.
/*
    TeamDataInterfaces *team = [[TeamDataInterfaces alloc] initWithDataManager:_dataManager];
    if ([team addTeam:newTeamNumber forName:newTeamName forTournament:tournamentName]) {
        NSError *error;
        if (![_dataManager.managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }*/
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
