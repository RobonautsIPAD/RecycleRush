//
//  ImportDataFromiTunes.m
//  AerialAssist
//
//  Created by FRC on 3/6/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "ImportDataFromiTunes.h"
#import "DataManager.h"
#import "ExportTeamData.h"
#import "MatchDataInterfaces.h"
#import "TeamScoreInterfaces.h"
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
        documentImportPath = [self applicationDocumentsDirectory];
        alreadyImportedPath = [[self applicationLibraryDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"Imported Data/%@", tournamentName]];
        NSLog(@"Already imported path = %@", alreadyImportedPath);
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
            [file.pathExtension compare:@"csv" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
           // NSLog(@"file = %@", file);
            [fileList addObject:file];
        }
    }
    return fileList;
}

-(NSMutableArray *)importDataPhoto:(NSString *) importFile {
    NSError *error;
    NSString *fullOriginalPath = [documentImportPath stringByAppendingPathComponent:importFile];
    NSString *destinationPath = [documentImportPath stringByAppendingPathComponent:@"RobotPhotos"];
    NSLog(@"import file = %@", importFile);
    NSLog(@"Remove original file");
    NSData *importData = [NSData dataWithContentsOfFile:fullOriginalPath];
    if ([fileManager fileExistsAtPath:fullOriginalPath]) {
        NSFileWrapper *dirWrapper = [[NSFileWrapper alloc] initWithSerializedRepresentation:importData];
        if (dirWrapper == nil) {
            [self showAlert:@"Unable to unpack import data"];
        }
        NSURL *dirUrl = [NSURL fileURLWithPath:destinationPath];
        BOOL success = [dirWrapper writeToURL:dirUrl options:NSFileWrapperWritingAtomic originalContentsURL:nil error:&error];
        if (!success) {
            [self showAlert:@"Unable to create import files"];
            return nil;
        }
        [fileManager removeItemAtPath:fullOriginalPath error:&error];
    }
    return nil;
}

-(NSMutableArray *)importData:(NSString *) importFile {
    NSError *error;
    NSString *fullOriginalPath = [documentImportPath stringByAppendingPathComponent:importFile];
    NSString *destinationPath = [alreadyImportedPath stringByAppendingPathComponent:importFile];
    
    BOOL success;
    success = [fileManager createDirectoryAtPath:alreadyImportedPath withIntermediateDirectories:YES attributes:nil error:&error];
    if (![fileManager fileExistsAtPath:destinationPath]) {
        success &= [fileManager copyItemAtPath:fullOriginalPath toPath:destinationPath error:&error];
    }
    if (!success) {
        [self showAlert:@"Unable to create import directory"];
        return nil;
    }
    // put this in success loop when the rest is done
    NSLog(@"Remove original file");
    NSMutableArray *importedList = [self unserializeAndLoad:destinationPath];
    [fileManager removeItemAtPath:fullOriginalPath error:&error];
    
    return importedList;
}

-(NSMutableArray *)unserializeAndLoad:(NSString *)importFile {
    NSLog(@"unserialize");
    NSMutableArray *receivedData = [[NSMutableArray alloc] init];
    NSError *error;
    NSString *transferPath = [alreadyImportedPath stringByAppendingPathComponent:@"Unpack"];
    BOOL success = [fileManager createDirectoryAtPath:transferPath withIntermediateDirectories:YES attributes:nil error:&error];
    if (!success) {
        [self showAlert:@"Unable to create import workspace"];
        return nil;
    }
    if ([importFile.pathExtension compare:@"csv" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        LoadCSVData *csvImport = [[LoadCSVData alloc] initWithDataManager:_dataManager];
        [csvImport loadMatchFile:importFile];
        [fileManager removeItemAtPath:transferPath error:&error];
        return nil;
    }

    NSData *importData = [NSData dataWithContentsOfFile:importFile];
    NSFileWrapper *dirWrapper = [[NSFileWrapper alloc] initWithSerializedRepresentation:importData];
    if (dirWrapper == nil) {
        [self showAlert:@"Unable to unpack import data"];
    }
    // Calculate desired name
    NSURL *dirUrl = [NSURL fileURLWithPath:transferPath];
    success = [dirWrapper writeToURL:dirUrl options:NSFileWrapperWritingAtomic originalContentsURL:nil error:&error];
    if (!success) {
        [self showAlert:@"Unable to create import files"];
        return nil;
    }
    NSLog(@"Decide which unpackage call to make");

    NSArray *files = [fileManager contentsOfDirectoryAtPath:transferPath error:&error];
    if (files == nil) {
        [self showAlert:@"Error reading transfer directory"];
        return nil;
    }

    if ([importFile.pathExtension compare:@"mrd" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        TeamScoreInterfaces *matchResultsPackage = [[TeamScoreInterfaces alloc] initWithDataManager:_dataManager];
        for (NSString *file in files) {
            if ([file.pathExtension compare:@"pck" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
               // NSLog(@"file = %@", file);
                NSString *fullPath = [transferPath stringByAppendingPathComponent:file];
                NSData *myData = [NSData dataWithContentsOfFile:fullPath];
                NSDictionary *scoreReceived = [matchResultsPackage unpackageScoreForXFer:myData];
                if (scoreReceived) [receivedData addObject:scoreReceived];
            }
        }
    }
    else if ([importFile.pathExtension compare:@"tmd" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        ExportTeamData *teamDataPackage = [[ExportTeamData alloc] init:_dataManager];
        for (NSString *file in files) {
            if ([file.pathExtension compare:@"pck" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                NSLog(@"file = %@", file);
                NSString *fullPath = [transferPath stringByAppendingPathComponent:file];
                NSData *myData = [NSData dataWithContentsOfFile:fullPath];
                NSDictionary *teamReceived = [teamDataPackage unpackageTeamForXFer:myData];
                if (teamReceived) [receivedData addObject:teamReceived];
            }
        }
    }
    else if ([importFile.pathExtension compare:@"msd" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        MatchDataInterfaces *matchDataPackage = [[MatchDataInterfaces alloc] initWithDataManager:_dataManager];
        for (NSString *file in files) {
            if ([file.pathExtension compare:@"pck" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                NSLog(@"file = %@", file);
                NSString *fullPath = [transferPath stringByAppendingPathComponent:file];
                NSData *myData = [NSData dataWithContentsOfFile:fullPath];
                NSDictionary *matchReceived = [matchDataPackage unpackageMatchForXFer:myData];
                if (matchReceived) [receivedData addObject:matchReceived];
            }
        }
    }
    [fileManager removeItemAtPath:transferPath error:&error];

    return receivedData;
}

-(void)showAlert:(NSString *)errorMessage {
    UIAlertView *prompt  = [[UIAlertView alloc] initWithTitle:@"Import Alert"
                                                      message:errorMessage
                                                     delegate:nil
                                            cancelButtonTitle:@"Ok"
                                            otherButtonTitles:nil];
    [prompt setAlertViewStyle:UIAlertViewStyleDefault];
    [prompt show];
}

/**
 Returns the path to the application's Library directory.
 */
- (NSString *)applicationLibraryDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
}

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


@end
