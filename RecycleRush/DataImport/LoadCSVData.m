//
//  LoadCSVData.m
// Robonauts Scouting
//
//  Created by Kris Pettinger on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DataManager.h"
#import "TournamentData.h"
#import "LoadCSVData.h"
#import "parseCSV.h"
#import "TeamUtilities.h"
#import "MatchUtilities.h"
#import "TournamentUtilities.h"

@implementation LoadCSVData {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    BOOL loadDataFromBundle;
}

- (id)initWithDataManager:(DataManager *)initManager {
	if ((self = [super init]))
	{
        _dataManager = initManager;
	}
	return self;
}

-(BOOL)loadCSVDataFromBundle {
    // NSLog(@"loadCSVDataFromBundle");

    BOOL inputError = FALSE;
    if (_dataManager == nil) {
        _dataManager = [DataManager new];
        loadDataFromBundle = [_dataManager databaseExists];
    }
    else {
        loadDataFromBundle = _dataManager.loadDataFromBundle;
    }
    
    if (loadDataFromBundle) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"TournamentList" ofType:@"csv"];
        [self loadTournamentFile:filePath];

        filePath = [[NSBundle mainBundle] pathForResource:@"TeamList" ofType:@"csv"];
        inputError |= [self loadTeamFile:filePath];

//        filePath = [[NSBundle mainBundle] pathForResource:@"TeamHistory" ofType:@"csv"];
//        [self loadTeamHistory:filePath];
        
        filePath = [[NSBundle mainBundle] pathForResource:@"MatchList" ofType:@"csv"];
        inputError |= [self loadMatchFile:filePath];
    }
    return inputError;
}

-(BOOL)handleOpenURL:(NSURL *)url {
    BOOL inputError = FALSE;
    if (_dataManager == nil) {
        _dataManager = [DataManager new];
    }
    NSString *filePath = [url path];
    NSLog(@"Emailed File = %@", filePath);
    [self loadTournamentFile:filePath];
    inputError |= [self loadTeamFile:filePath];
    inputError |= [self loadTeamHistory:filePath];
    NSLog(@"loaded history");
    inputError |= [self loadMatchFile:filePath];
    return inputError;
}

-(BOOL)loadTournamentFile:(NSString *)filePath {
    TournamentUtilities *tournamentUtil = [[TournamentUtilities alloc] init:_dataManager];
     BOOL inputError = [tournamentUtil createTournamentFromFile:filePath];
    return inputError;
}

-(BOOL)loadTeamFile:(NSString *)filePath {
    TeamUtilities *teamUtil = [[TeamUtilities alloc] init:_dataManager];
    BOOL inputError = [teamUtil createTeamFromFile:filePath];
    return inputError;
}

-(BOOL)loadTeamHistory:(NSString *)filePath {
    TeamUtilities *teamUtil = [[TeamUtilities alloc] init:_dataManager];
    BOOL inputError = [teamUtil addTeamHistoryFromFile:filePath];
    return inputError;
}

-(BOOL)loadMatchFile:(NSString *)filePath {
    MatchUtilities *matchUtil = [[MatchUtilities alloc] init:_dataManager];
    BOOL inputError = [matchUtil createMatchFromFile:filePath];
    return inputError;
}

@end
