//
//  iPhoneMatchXferViewController.h
// Robonauts Scouting
//
//  Created by FRC on 7/25/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@class DataManager;
@class MatchResultsObject;
@class TeamScore;

@interface iPhoneMatchXferViewController : UIViewController <GKPeerPickerControllerDelegate, GKSessionDelegate, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, retain) DataManager *dataManager;
@property (nonatomic, retain) GKSession *currentSession;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) UIView *headerView;
@property (nonatomic, assign) int xfer_mode;

@property (weak, nonatomic) IBOutlet UIButton *connectStatusButton;
- (IBAction)gameKitHookUp:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *peerName;
@property (weak, nonatomic) IBOutlet UITableView *matchList;

-(BOOL)addMatchScore:(MatchResultsObject *) xferData;
-(void)unpackXferData:(MatchResultsObject *)xferData forScore:(TeamScore *)score;

@end
