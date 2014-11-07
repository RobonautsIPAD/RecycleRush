//
//  DataSync.m
//  AerialAssist
//
//  Created by FRC on 11/1/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "DataSync.h"
#import "DataManager.h"
#import "TeamData.h"
#import "MatchData.h"
#import "ExportTeamData.h"
#import "ExportMatchData.h"
#import "ExportScoreData.h"
#import "ImportDataFromiTunes.h"
#import "PhotoUtilities.h"
#import "FileIOMethods.h"

@implementation DataSync {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSString *deviceName;
    NSNumber *teamDataSync;
    NSNumber *matchScheduleSync;
    NSNumber *matchResultsSync;

    NSArray *tournamentList;
    NSArray *teamList;
    NSArray *matchScheduleList;
    NSArray *matchResultsList;

    ExportTeamData *teamDataPackage;
    ExportMatchData *matchDataPackage;
    ExportScoreData *matchResultsPackage;
    NSString *exportFilePath;
    NSString *transferFilePath;

    ImportDataFromiTunes *importPackage;
    PhotoUtilities *photoPackage;
}

- (id)init:(DataManager *)initManager {
	if ((self = [super init])) {
        _dataManager = initManager;
        // Retrieve all preferences
        prefs = [NSUserDefaults standardUserDefaults];
        tournamentName = [prefs objectForKey:@"tournament"];
        deviceName = [prefs objectForKey:@"deviceName"];
        teamDataSync = [prefs objectForKey:@"teamDataSync"];
        matchScheduleSync = [prefs objectForKey:@"matchScheduleSync"];
        matchResultsSync = [prefs objectForKey:@"matchResultsSync"];
        importPackage = [[ImportDataFromiTunes alloc] init:_dataManager];
        photoPackage = [[PhotoUtilities alloc] init:_dataManager];
	}
	return self;
}

-(NSArray *)getFilteredTeamList:(SyncOptions)syncOption {
    NSArray *filteredTeamList;
    if (!teamList) {
        NSError *error;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:@"TeamData" inManagedObjectContext:_dataManager.managedObjectContext];
        [fetchRequest setEntity:entity];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"ANY tournaments.name = %@", tournamentName];
        [fetchRequest setPredicate:pred];
        teamList = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    }
    
    NSPredicate *pred;
    switch (syncOption) {
        case SyncAll:
            filteredTeamList = [NSArray arrayWithArray:teamList];
            break;
        case SyncAllSavedHere:
            pred = [NSPredicate predicateWithFormat:@"savedBy = %@", deviceName];
            filteredTeamList = [teamList filteredArrayUsingPredicate:pred];
            break;
        case SyncAllSavedSince:
            // For the phone, we are interested in passing along anything
            //  saved or received
            pred = [NSPredicate predicateWithFormat:@"saved > %@ OR received > %@", teamDataSync, teamDataSync];
            filteredTeamList = [teamList filteredArrayUsingPredicate:pred];
            break;
        default:
            filteredTeamList = [NSArray arrayWithArray:teamList];
            break;
    }
    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:numberDescriptor, nil];
    filteredTeamList = [filteredTeamList sortedArrayUsingDescriptors:sortDescriptors];
    
    return filteredTeamList;
}

-(NSArray *)getFilteredMatchList:(SyncOptions)syncOption {
    NSArray *filteredMatchList;
    if (!matchScheduleList) {
        NSError *error;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:@"MatchData" inManagedObjectContext:_dataManager.managedObjectContext];
        [fetchRequest setEntity:entity];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"tournamentName = %@", tournamentName];
        [fetchRequest setPredicate:pred];
        matchScheduleList = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    }
    
    NSPredicate *pred;
    switch (syncOption) {
        case SyncAll:
            filteredMatchList = [NSArray arrayWithArray:matchScheduleList];
            break;
        case SyncAllSavedHere:
            pred = [NSPredicate predicateWithFormat:@"savedBy = %@", deviceName];
            filteredMatchList = [matchScheduleList filteredArrayUsingPredicate:pred];
            break;
        case SyncAllSavedSince:
            // For the phone, we are interested in passing along anything
            //  saved or received
            pred = [NSPredicate predicateWithFormat:@"saved > %@ OR received > %@", matchScheduleSync, matchScheduleSync];
            filteredMatchList = [matchScheduleList filteredArrayUsingPredicate:pred];
            break;
        default:
            filteredMatchList = [NSArray arrayWithArray:matchScheduleList];
            break;
    }
    NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"matchType" ascending:YES];
    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:typeDescriptor, numberDescriptor, nil];
    filteredMatchList = [filteredMatchList sortedArrayUsingDescriptors:sortDescriptors];
    
    return filteredMatchList;
}

-(NSArray *)getFilteredResultsList:(SyncOptions)syncOption; {
    NSArray *filteredResultsList;
    if (!matchResultsList) {
        NSError *error;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:@"TeamScore" inManagedObjectContext:_dataManager.managedObjectContext];
        [fetchRequest setEntity:entity];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"tournamentName = %@", tournamentName];
        [fetchRequest setPredicate:pred];
        matchResultsList = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    }
    
    NSPredicate *pred;
    switch (syncOption) {
        case SyncAll:
            pred = [NSPredicate predicateWithFormat:@"results = %@", [NSNumber numberWithBool:YES]];
            filteredResultsList = [matchResultsList filteredArrayUsingPredicate:pred];
            //          filteredResultsList = matchResultsList;
            break;
        case SyncAllSavedHere:
            pred = [NSPredicate predicateWithFormat:@"savedBy = %@", deviceName];
            filteredResultsList = [matchResultsList filteredArrayUsingPredicate:pred];
            break;
        case SyncAllSavedSince:
            // For the phone, we are interested in passing along anything
            //  saved or received
            pred = [NSPredicate predicateWithFormat:@"saved > %@ OR received > %@", matchResultsSync, matchResultsSync];
            filteredResultsList = [matchResultsList filteredArrayUsingPredicate:pred];
            break;
        default:
            filteredResultsList = [NSArray arrayWithArray:matchResultsList];
            break;
    }
    NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"match.matchType" ascending:YES];
    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"match.number" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:typeDescriptor, numberDescriptor, nil];
    filteredResultsList = [filteredResultsList sortedArrayUsingDescriptors:sortDescriptors];
    
    return filteredResultsList;
}

-(NSString *)packageDataForiTunes:(SyncType)syncType forData:(NSArray *)transferList {
    NSString *transferDataFile;
    NSString *error = @"";
    if (![self createExportPaths]) return @"Error";
    switch (syncType) {
        case SyncTeams:
            if (!teamDataPackage) teamDataPackage = [[ExportTeamData alloc] init:_dataManager];
            for (TeamData *team in transferList) {
                [teamDataPackage exportTeamForXFer:team toFile:transferFilePath];
                NSLog(@"Team = %@, saved = %@", team.number, team.saved);
            }
            teamDataSync = [NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()];
            transferDataFile = [exportFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@ %@ Team Data %0.f.tmd", deviceName, tournamentName, [teamDataSync floatValue]]];
            [self serializeDataForTransfer:transferDataFile];
            break;
        case SyncMatchList:
            if (!matchDataPackage) matchDataPackage = [[ExportMatchData alloc] init:_dataManager];
            for (MatchData *match in transferList) {
                [matchDataPackage exportMatchForXFer:match toFile:transferFilePath];
                NSLog(@"Match = %@, saved = %@", match.number, match.saved);
                matchScheduleSync = [NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()];
                transferDataFile = [exportFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@ %@ Match Schedule %0.f.msd", deviceName, tournamentName, [matchScheduleSync floatValue]]];
                [self serializeDataForTransfer:transferDataFile];
            }
            break;
        case SyncMatchResults:
            if (!matchResultsPackage) matchResultsPackage = [[ExportScoreData alloc] init:_dataManager];
            for (TeamScore *score in transferList) {
                [matchResultsPackage exportScoreForXFer:score toFile:transferFilePath];
                //  NSLog(@"Match = %@, Type = %@, Team = %@ Saved = %@, SavedBy = %@", score.match.number, score.match.matchType, score.team.number, score.saved, score.savedBy);
            }
            matchResultsSync = [NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()];
            [prefs setObject:matchResultsSync forKey:@"matchResultsSync"];
            transferDataFile = [exportFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@ %@ Match Results %0.f.mrd", deviceName, tournamentName, [matchResultsSync floatValue]]];
            [self serializeDataForTransfer:transferDataFile];
            break;
        default:
            break;
    }
    NSError *fileError = nil;
    for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:transferFilePath error:&fileError]) {
        NSString *name = [transferFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", file]];
        [[NSFileManager defaultManager] removeItemAtPath:name error:&fileError];
    }
    return error;
}

-(NSString *)serializeDataForTransfer:(NSString *)fileName {
    NSError *error;
    NSURL *url = [NSURL fileURLWithPath:transferFilePath];
    NSFileWrapper *dirWrapper = [[NSFileWrapper alloc] initWithURL:url options:0 error:&error];
    if (dirWrapper == nil) {
        NSString *msg = [NSString stringWithFormat:@"Error creating directory wrapper: %@", error.localizedDescription];
        NSLog(@"%@", msg);
        return msg;
    }
    NSData *transferData = [dirWrapper serializedRepresentation];
    [transferData writeToFile:fileName atomically:YES];
    return @"";
}

- (BOOL)createExportPaths {
    BOOL success = TRUE;
    if (!transferFilePath) {
        transferFilePath = [[FileIOMethods applicationLibraryDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"Transfer Data"]];
        NSError *error;
        success &= [[NSFileManager defaultManager] createDirectoryAtPath:transferFilePath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    if (!exportFilePath) {
        exportFilePath = [FileIOMethods applicationDocumentsDirectory];
    }
    if (!success) {
        UIAlertView *prompt  = [[UIAlertView alloc] initWithTitle:@"Transfer Alert" message:@"Unable to Save Transfer Data" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [prompt setAlertViewStyle:UIAlertViewStyleDefault];
        [prompt show];
    }
    return success;
}

- (NSArray *)getImportFileList {
    return [importPackage getImportFileList];
}

-(NSArray *)importiTunesSelected:(NSString *)importFile {
    NSLog(@"file selected = %@", importFile);
    NSArray *receivedList;
    if ([importFile.pathExtension compare:@"pho" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        NSLog(@"Photo package");
        receivedList = [photoPackage importDataPhoto:importFile];
    } else {
        receivedList = [importPackage importData:importFile];
    }
    return receivedList;
}

@end
