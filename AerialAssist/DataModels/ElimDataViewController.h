//
//  ElimDataViewController.h
//  AerialAssist
//
//  Created by FRC on 3/22/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataManager.h"

@class MatchData;
@class TeamData;

@interface ElimDataViewController : UIViewController
@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) NSIndexPath *teamIndex;
@property (nonatomic, strong) TeamData *team;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSMutableArray *teamList;

-(IBAction)toggleRadioButtonState:(id)sender;
-(IBAction)generateMatch:(id)sender;

@end
