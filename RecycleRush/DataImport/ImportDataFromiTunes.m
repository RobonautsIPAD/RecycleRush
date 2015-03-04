//
//  ImportDataFromiTunes.m
//  RecycleRush
//
//  Created by FRC on 3/6/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "ImportDataFromiTunes.h"
#import "DataManager.h"
#import "FileIOMethods.h"
#import "TournamentUtilities.h"
#import "TeamUtilities.h"
#import "MatchUtilities.h"
#import "ScoreUtilities.h"
#import "LoadCSVData.h"

@implementation ImportDataFromiTunes {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSFileManager *fileManager;
    NSString *documentImportPath;
    NSString *alreadyImportedPath;
    // Path to Documents/ready to import
    // Path to already imported data
}

- (id)init:(DataManager *)initManager {
	if ((self = [super init])) {
        _dataManager = initManager;
        prefs = [NSUserDefaults standardUserDefaults];
        tournamentName = [prefs objectForKey:@"tournament"];
        fileManager = [NSFileManager defaultManager];
        documentImportPath = [FileIOMethods applicationDocumentsDirectory];
        alreadyImportedPath = [[FileIOMethods applicationLibraryDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"Imported Data/%@", tournamentName]];
        // NSLog(@"Already imported path = %@", alreadyImportedPath);
	}

	return self;
}

-(NSArray *)getImportFileList {
    NSArray *fileList = [self showImportFile:documentImportPath];
    NSLog(@"import file list = %@", fileList);
/*    fileList = [self showImportFile:alreadyImportedPath];
    NSLog(@"already file list = %@", fileList);*/
    return fileList;
}

-(NSArray *)showImportFile:(NSString *)importPath {
    NSError *error;
    NSMutableArray *fileList = [NSMutableArray array];

    NSArray *files = [fileManager contentsOfDirectoryAtPath:importPath error:&error];
    if (files == nil) {
        NSLog(@"Error reading contents of directory: %@", [error localizedDescription]);
        return nil;
    }
    
    for (NSString *file in files) {
        if ([file.pathExtension compare:@"mrd" options:NSCaseInsensitiveSearch] == NSOrderedSame ||
            [file.pathExtension compare:@"pho" options:NSCaseInsensitiveSearch] == NSOrderedSame ||
            [file.pathExtension compare:@"msd" options:NSCaseInsensitiveSearch] == NSOrderedSame ||
            [file.pathExtension compare:@"tmd" options:NSCaseInsensitiveSearch] == NSOrderedSame ||
            [file.pathExtension compare:@"tnd" options:NSCaseInsensitiveSearch] == NSOrderedSame ||
            [file.pathExtension compare:@"csv" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
           // NSLog(@"file = %@", file);
            [fileList addObject:file];
        }
    }
    return fileList;
}

-(NSMutableArray *)importData:(NSString *) importFile error:(NSError **)error {
    NSString *fullOriginalPath = [documentImportPath stringByAppendingPathComponent:importFile];
    NSString *destinationPath = [alreadyImportedPath stringByAppendingPathComponent:importFile];
    
    BOOL success;
    success = [fileManager createDirectoryAtPath:alreadyImportedPath withIntermediateDirectories:YES attributes:nil error:error];
    if (![fileManager fileExistsAtPath:destinationPath]) {
        success &= [fileManager copyItemAtPath:fullOriginalPath toPath:destinationPath error:error];
    }
    if (!success) {
        return nil;
    }
    NSMutableArray *importedList = [self unserializeAndLoad:destinationPath error:error];
    [fileManager removeItemAtPath:fullOriginalPath error:error];
    
    return importedList;
}

-(NSMutableArray *)unserializeAndLoad:(NSString *)importFile error:(NSError **)error {
    //NSLog(@"unserialize");
    NSMutableArray *receivedData = [[NSMutableArray alloc] init];
    NSString *transferPath = [alreadyImportedPath stringByAppendingPathComponent:@"Unpack"];
    if (![fileManager createDirectoryAtPath:transferPath withIntermediateDirectories:YES attributes:nil error:error]) {
        if (*error) [_dataManager writeErrorMessage:*error forType:[*error code]];
        return nil;
    }
    if ([importFile.pathExtension compare:@"csv" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        LoadCSVData *csvImport = [[LoadCSVData alloc] initWithDataManager:_dataManager];
        [csvImport loadMatchFile:importFile];
        [fileManager removeItemAtPath:transferPath error:error];
        if (*error) [_dataManager writeErrorMessage:*error forType:[*error code]];
        return nil;
    }
    else if ([importFile.pathExtension compare:@"tnd" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        TournamentUtilities *tournamentUtilitiesPackage = [[TournamentUtilities alloc] init:_dataManager];
        NSData *importData = [NSData dataWithContentsOfFile:importFile];
        NSArray *tournamentList = (NSArray *) [NSKeyedUnarchiver unarchiveObjectWithData:importData];
        receivedData = [tournamentUtilitiesPackage unpackageTournamentsForXFer:tournamentList];
        [fileManager removeItemAtPath:transferPath error:error];        
        return receivedData;
    }

    NSData *importData = [NSData dataWithContentsOfFile:importFile];
    NSFileWrapper *dirWrapper = [[NSFileWrapper alloc] initWithSerializedRepresentation:importData];
    if (dirWrapper == nil) {
         *error = [NSError errorWithDomain:@"unserializeAndLoad" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:@"Unable to unpack import data" forKey:NSLocalizedDescriptionKey]];
        if (*error) [_dataManager writeErrorMessage:*error forType:[*error code]];
    }
    // Calculate desired name
    NSURL *dirUrl = [NSURL fileURLWithPath:transferPath];
    if (![dirWrapper writeToURL:dirUrl options:NSFileWrapperWritingAtomic originalContentsURL:nil error:error]) {
        *error = [NSError errorWithDomain:@"unserializeAndLoad" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:@"Unable to create import files" forKey:NSLocalizedDescriptionKey]];
        if (*error) [_dataManager writeErrorMessage:*error forType:[*error code]];
        return nil;
    }

    NSArray *files = [fileManager contentsOfDirectoryAtPath:transferPath error:error];
    if (files == nil) {
        *error = [NSError errorWithDomain:@"unserializeAndLoad" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:@"Error reading transfer directory" forKey:NSLocalizedDescriptionKey]];
        if (*error) [_dataManager writeErrorMessage:*error forType:[*error code]];
        return nil;
    }

    if ([importFile.pathExtension compare:@"mrd" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        ScoreUtilities *scoreUtilities = [[ScoreUtilities alloc] init:_dataManager];
        for (NSString *file in files) {
            if ([file.pathExtension compare:@"pck" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
               // NSLog(@"file = %@", file);
                NSString *fullPath = [transferPath stringByAppendingPathComponent:file];
                NSData *importData = [NSData dataWithContentsOfFile:fullPath];
                NSDictionary *importDictionary = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:importData];
                NSDictionary *scoreReceived = [scoreUtilities unpackageScoreForXFer:importDictionary];
                if (scoreReceived) [receivedData addObject:scoreReceived];
            }
        }
    }
    else if ([importFile.pathExtension compare:@"tmd" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        TeamUtilities *teamDataPackage = [[TeamUtilities alloc] init:_dataManager];
        for (NSString *file in files) {
            if ([file.pathExtension compare:@"pck" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                //NSLog(@"file = %@", file);
                NSString *fullPath = [transferPath stringByAppendingPathComponent:file];
                NSData *importData = [NSData dataWithContentsOfFile:fullPath];
                NSDictionary *importDictionary = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:importData];
                NSDictionary *teamReceived = [teamDataPackage unpackageTeamForXFer:importDictionary];
                if (teamReceived) [receivedData addObject:teamReceived];
            }
        }
    }
    else if ([importFile.pathExtension compare:@"msd" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        MatchUtilities *matchUtilitiesPackage = [[MatchUtilities alloc] init:_dataManager];
        for (NSString *file in files) {
            if ([file.pathExtension compare:@"pck" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                //NSLog(@"file = %@", file);
                NSString *fullPath = [transferPath stringByAppendingPathComponent:file];
                NSData *importData = [NSData dataWithContentsOfFile:fullPath];
                NSDictionary *importDictionary = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:importData];
                NSDictionary *matchReceived = [matchUtilitiesPackage unpackageMatchForXFer:importDictionary];
                if (matchReceived) [receivedData addObject:matchReceived];
            }
        }
    }
    [fileManager removeItemAtPath:transferPath error:error];

    return receivedData;
}

@end
