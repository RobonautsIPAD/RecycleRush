//
//  LoadCSVData.h
// Robonauts Scouting
//
//  Created by Kris Pettinger on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DataManager;

@interface LoadCSVData : NSObject

@property (nonatomic, strong) DataManager *dataManager;

-(id)initWithDataManager:(DataManager *)initManager;
-(BOOL)loadCSVDataFromBundle;
-(BOOL)handleOpenURL:(NSURL *)url;
-(void)loadTournamentFile:(NSString *)filePath;
-(void)loadTeamHistory:(NSString *)filePath;
-(void)loadMatchResults:(NSString *)filePath;
-(BOOL)loadMatchFile:(NSString *)filePath;

@end
