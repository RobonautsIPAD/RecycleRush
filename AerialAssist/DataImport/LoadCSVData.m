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
#import "AddRecordResults.h"

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

        filePath = [[NSBundle mainBundle] pathForResource:@"TeamHistory" ofType:@"csv"];
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
    NSLog(@"Add decision for team or match file");
    [self loadTournamentFile:filePath];
    inputError |= [self loadTeamFile:filePath];
 //   [self loadTeamHistory:filePath];
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

-(void)loadTeamHistory:(NSString *)filePath {
    NSLog(@"Team History");
/*    CSVParser *parser = [CSVParser new];
    [parser openFile: filePath];
    NSMutableArray *csvContent = [parser parseFile];

    if (![csvContent count]) return;

    if ([[[csvContent objectAtIndex: 0] objectAtIndex:0] isEqualToString:@"Team History"]) {
        TeamDataInterfaces *team = [[TeamDataInterfaces alloc] initWithDataManager:_dataManager];
        int c;
        for (c = 1; c < [csvContent count]; c++) {
            // NSLog(@"loadTeamFile:TeamNumber = %@", [[csvContent objectAtIndex: c] objectAtIndex:0]);
            AddRecordResults results = [team addTeamHistoryFromFile:[csvContent objectAtIndex: 0] dataFields:[csvContent objectAtIndex: c]];
            if (results != DB_MATCHED) {
                NSLog(@"Check database - Team History Add Code %d", results);
            }
        }
#ifdef TEST_MODE
        [team testTeamInterfaces];
#endif
    }
    [parser closeFile];*/
}

-(BOOL)loadMatchFile:(NSString *)filePath {
    MatchUtilities *matchUtil = [[MatchUtilities alloc] init:_dataManager];
    BOOL inputError = [matchUtil createMatchFromFile:filePath];
    return inputError;
}

@end
