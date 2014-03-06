//
//  ImportDataFromiTunes.m
//  AerialAssist
//
//  Created by FRC on 3/6/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "ImportDataFromiTunes.h"

@implementation ImportDataFromiTunes {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSString *documentImportPath;
    NSString *alreadyImportedPath;
    // Path to Documents/ready to import
    // Path to already imported data
}

- (id)init {
	if ((self = [super init])) {
        prefs = [NSUserDefaults standardUserDefaults];
        tournamentName = [prefs objectForKey:@"tournament"];
        documentImportPath = [self applicationDocumentsDirectory];
        alreadyImportedPath = [[self applicationLibraryDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"Imported Data/%@", tournamentName]];
        NSLog(@"Already imported path = %@", alreadyImportedPath);
	}
	return self;
}

-(NSArray *)getImportFileList {
    NSArray *fileList = [self showImportFile:documentImportPath];
    NSLog(@"import file list = %@", fileList);
    fileList = [self showImportFile:alreadyImportedPath];
    NSLog(@"already file list = %@", fileList);
    return fileList;
}

-(NSArray *)showImportFile:(NSString *)importPath {
    NSError *error;
    NSMutableArray *fileList = [NSMutableArray array];

    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:importPath error:&error];
    if (files == nil) {
        NSLog(@"Error reading contents of directory: %@", [error localizedDescription]);
        return nil;
    }
    
    for (NSString *file in files) {
        if ([file.pathExtension compare:@"mrd" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            NSLog(@"file = %@", file);
            [fileList addObject:file];
        }
    }
    return fileList;
}

/*
-(BOOL)createExportPaths {
    BOOL success = TRUE;
    if (!transferFilePath) {
        transferFilePath = [[self applicationLibraryDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"Transfer Data"]];
        NSError *error;
        success &= [[NSFileManager defaultManager] createDirectoryAtPath:transferFilePath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    if (!exportFilePath) {
        exportFilePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ Transfer Data", deviceName]];
        NSError *error;
        success &= [[NSFileManager defaultManager] createDirectoryAtPath:exportFilePath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    if (!success) {
        UIAlertView *prompt  = [[UIAlertView alloc] initWithTitle:@"Transfer Alert"
                                                          message:@"Unable to Save Transfer Data"
                                                         delegate:nil
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
        [prompt setAlertViewStyle:UIAlertViewStyleDefault];
        [prompt show];
    }
    return success;
}*/

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
