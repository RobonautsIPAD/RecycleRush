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
#import "CreateMatch.h"
#import "TournamentUtilities.h"
#import "AddRecordResults.h"

@implementation LoadCSVData {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    BOOL loadDataFromBundle;
}

@synthesize dataManager = _dataManager;

- (id)initWithDataManager:(DataManager *)initManager {
	if ((self = [super init]))
	{
        _dataManager = initManager;
	}
	return self;
}

-(void)loadCSVDataFromBundle {
    // NSLog(@"loadCSVDataFromBundle");

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
        [self loadTeamFile:filePath];

        filePath = [[NSBundle mainBundle] pathForResource:@"TeamHistory" ofType:@"csv"];
//        [self loadTeamHistory:filePath];
        
        filePath = [[NSBundle mainBundle] pathForResource:@"MatchList" ofType:@"csv"];
        [self loadMatchFile:filePath];

        filePath = [[NSBundle mainBundle] pathForResource:@"MatchResults" ofType:@"csv"];
//        [self loadMatchResults:filePath];
    }
 
}

-(void) handleOpenURL:(NSURL *)url {
    if (_dataManager == nil) {
        _dataManager = [DataManager new];
    }
    NSString *filePath = [url path];
    NSLog(@"Emailed File = %@", filePath);
    NSLog(@"Add decision for team or match file");
    [self loadTournamentFile:filePath];
    [self loadTeamFile:filePath];
 //   [self loadTeamHistory:filePath];
    NSLog(@"loaded history");
    [self loadMatchFile:filePath];
//    [self loadMatchResults:filePath];
}

-(void)loadTournamentFile:(NSString *)filePath {
    TournamentUtilities *tournamentUtil = [[TournamentUtilities alloc] init:_dataManager];
    [tournamentUtil createTournamentFromFile:filePath];
}

-(void)loadTeamFile:(NSString *)filePath {
    TeamUtilities *teamUtil = [[TeamUtilities alloc] init:_dataManager];
    [teamUtil createTeamFromFile:filePath];
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

-(void)loadMatchFile:(NSString *)filePath {
    MatchUtilities *matchUtil = [[MatchUtilities alloc] init:_dataManager];
    [matchUtil createMatchFromFile:filePath];
}

-(void)loadMatchResults:(NSString *)filePath {
    CSVParser *parser = [CSVParser new];
    [parser openFile: filePath];
    NSMutableArray *csvContent = [parser parseFile];

    if (![csvContent count]) return;

    if ([[[csvContent objectAtIndex: 0] objectAtIndex:0] isEqualToString:@"Tournament"]) {
        CreateMatch *match = [[CreateMatch alloc] initWithDataManager:_dataManager];
        int c;
        for (c = 1; c < [csvContent count]; c++) {
            // NSLog(@"Match = %@", [csvContent objectAtIndex: c]);
            AddRecordResults results = [match addMatchResultsFromFile:[csvContent objectAtIndex: 0] dataFields:[csvContent objectAtIndex: c]];
            if (results != DB_ADDED) {
                NSLog(@"Check database - Match Results Code %d", results);
            }
        }
    }
    [parser closeFile];    
}

@end
