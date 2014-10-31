//
//  ImportDataViewController.m
// Robonauts Scouting
//
//  Created by FRC on 4/2/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "ImportDataViewController.h"
#import "DataManager.h"

#import "TournamentData.h"

@interface ImportDataViewController()
    @property (nonatomic, weak) IBOutlet UIButton *importUSFirstButton;
    @property (nonatomic, weak) IBOutlet UIButton *importMatchList;
@end

@implementation ImportDataViewController {
    NSUserDefaults *prefs;
    NSString *tournamentName;
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
         _dataManager = [DataManager new];
    }

    prefs = [NSUserDefaults standardUserDefaults];
    tournamentName = [prefs objectForKey:@"tournament"];
    if (tournamentName) {
        self.title =  [NSString stringWithFormat:@"%@ Import", tournamentName];
    }
    else {
        self.title = @"Import";
    }
    
    [_importUSFirstButton setTitle:@"Import from US First" forState:UIControlStateNormal];
    _importUSFirstButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:20.0];
    [_importMatchList setTitle:@"Xfer Match List from iDevice" forState:UIControlStateNormal];
    _importMatchList.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:20.0];
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

- (void)viewDidUnload {
    [self setImportMatchList:nil];
    [super viewDidUnload];
}
@end
