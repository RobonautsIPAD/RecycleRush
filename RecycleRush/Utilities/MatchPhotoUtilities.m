//
//  MatchPhotoUtilities.m
//  RecycleRush
//
//  Created by FRC on 3/6/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import "MatchPhotoUtilities.h"
#import "DataManager.h"
#import "FileIOMethods.h"

@implementation MatchPhotoUtilities {
    NSFileManager *fileManager;
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSString *deviceName;
    NSString *matchPhotoDirectory;
}

-(id)init:(DataManager *)initManager {
	if ((self = [super init])) {
        _dataManager = initManager;
        fileManager = [NSFileManager defaultManager];
        prefs = [NSUserDefaults standardUserDefaults];
        tournamentName = [prefs objectForKey:@"tournament"];
        deviceName = [prefs objectForKey:@"deviceName"];
        [self setMatchPhotoDirectory];
        [self createMatchPhotoDirectory];
 	}
	return self;
}

-(NSString *)createBaseName:(NSNumber *)matchNumber forType:(NSString *)matchTypeString forTeam:(NSNumber *)teamNumber {
    if (!matchNumber || !matchTypeString || !teamNumber) return nil;
    NSString *match = nil;
    if ([matchNumber intValue] <1 ) return nil;
    if ([teamNumber intValue] <1 ) return nil;
    if ([matchNumber intValue] < 10) {
        match = [NSString stringWithFormat:@"M%c%@", [matchTypeString characterAtIndex:0], [NSString stringWithFormat:@"00%d", [matchNumber intValue]]];
    } else if ( [matchNumber intValue] < 100) {
        match = [NSString stringWithFormat:@"M%c%@", [matchTypeString characterAtIndex:0], [NSString stringWithFormat:@"0%d", [matchNumber intValue]]];
    } else {
        match = [NSString stringWithFormat:@"M%c%@", [matchTypeString characterAtIndex:0], [NSString stringWithFormat:@"%d", [matchNumber intValue]]];
    }
    NSString *team = nil;
    if ([teamNumber intValue] < 100) {
        team = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"00%d", [teamNumber intValue]]];
    } else if ( [teamNumber intValue] < 1000) {
        team = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"0%d", [teamNumber intValue]]];
    } else {
        team = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"%d", [teamNumber intValue]]];
    }

    NSString *fieldPhotoFile = [NSString stringWithFormat:@"%@_%@.jpg", match, team];
    return fieldPhotoFile;
}

-(NSString *)savePhoto:(UIImage *)image forMatch:(NSNumber *)matchNumber forType:(NSString *)matchTypeString forTeam:(NSNumber *)teamNumber {
    NSString *photoName = [self createBaseName:matchNumber forType:matchTypeString forTeam:teamNumber];
    // Create full path name
    NSString *fullPath = [matchPhotoDirectory stringByAppendingPathComponent:photoName];
    NSData *imageData = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0)];
    if ([imageData writeToFile:fullPath atomically:YES]) {
        return photoName;
    }
    else {
        return nil;
    }
}

-(NSArray *)getTeamPhotoList:(NSNumber *)teamNumber {
    NSString *team = nil;
    if ([teamNumber intValue] < 100) {
        team = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"00%d", [teamNumber intValue]]];
    } else if ( [teamNumber intValue] < 1000) {
        team = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"0%d", [teamNumber intValue]]];
    } else {
        team = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"%d", [teamNumber intValue]]];
    }
    NSError *error;
    NSArray *matchPhotoDirectoryContents = [fileManager contentsOfDirectoryAtPath:matchPhotoDirectory error:&error];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", team];
    NSArray *list = [matchPhotoDirectoryContents filteredArrayUsingPredicate:pred];
/*    NSMutableArray *fullPathList = [NSMutableArray array];
    for (NSString *file in list) {
        NSString *fullPath = [self getFullPath:file];
        [fullPathList addObject:fullPath];
    }*/
    return list;
}

-(NSString *)getFullPath:(NSString *)photoName {
    NSString *fullPath = [matchPhotoDirectory stringByAppendingPathComponent:photoName];
    return fullPath;
}

-(void)setMatchPhotoDirectory {
    // Get the match photo directories
    NSUInteger location = [tournamentName rangeOfString:@" "].location;
    NSString *result = location == NSNotFound ? tournamentName : [tournamentName substringToIndex:location];
    NSString *library = [FileIOMethods applicationDocumentsDirectory];
    matchPhotoDirectory = [library stringByAppendingPathComponent:[NSString stringWithFormat:@"%@MatchPhotos", result]];
}

-(void)createMatchPhotoDirectory {
    // Create the match photo directory
    // Check if directory exists, if not, create it
    if (![fileManager fileExistsAtPath:matchPhotoDirectory isDirectory:NO]) {
        if (![fileManager createDirectoryAtPath:matchPhotoDirectory
                    withIntermediateDirectories: YES
                                     attributes: nil
                                          error: NULL]) {
            NSError *error = [NSError errorWithDomain:@"setMatchPhotoDirectory" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:@"Dreadful error creating directory to save match photos" forKey:NSLocalizedDescriptionKey]];
            [_dataManager writeErrorMessage:error forType:[error code]];
        }
    }
}

-(NSMutableArray *)importMatchPhotos:(NSString *)importFile error:(NSError **)error {
    NSMutableArray *importedPhotos = [[NSMutableArray alloc] init];
    NSString *photoImportPath = [[FileIOMethods applicationDocumentsDirectory] stringByAppendingPathComponent:[NSString stringWithString:importFile]];
    // Build a temporary directory to hold imported photo directories
    NSString *tmpPhotoImport = [[FileIOMethods applicationDocumentsDirectory] stringByAppendingPathComponent:@"tmpPhotoImport"];
    // Remove the tmp directory to make sure old data is not hanging around
    [fileManager removeItemAtPath:tmpPhotoImport error:error];
    NSData *importData = [NSData dataWithContentsOfFile:photoImportPath];
    
    if ([fileManager fileExistsAtPath:photoImportPath]) {
        NSFileWrapper *dirWrapper = [[NSFileWrapper alloc] initWithSerializedRepresentation:importData];
        if (dirWrapper == nil) {
            return nil;
        }
        NSURL *dirUrl = [NSURL fileURLWithPath:tmpPhotoImport];
        BOOL success = [dirWrapper writeToURL:dirUrl options:NSFileWrapperWritingAtomic originalContentsURL:nil error:error];
        if (!success) {
            return nil;
        }
    }
    NSArray *directoryContents = [fileManager contentsOfDirectoryAtPath:tmpPhotoImport error:error];
    for (NSString *file in directoryContents) {
        NSString *destinationPath = [matchPhotoDirectory stringByAppendingPathComponent:file];
        if (![fileManager fileExistsAtPath:destinationPath]) {
            [fileManager copyItemAtPath:[tmpPhotoImport stringByAppendingPathComponent:file] toPath:destinationPath error:NULL];
            [importedPhotos addObject:file];
        }
    }
    [fileManager removeItemAtPath:photoImportPath error:error];
    [fileManager removeItemAtPath:tmpPhotoImport error:error];
    
    NSLog(@"import file = %@", importFile);
    return importedPhotos;
}

-(void)exportMatchPhotos {
    NSError *error;
    NSString *photoExportPath = [[FileIOMethods applicationDocumentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ %@ Match Photo Transfer.mph", deviceName, tournamentName]];
    NSURL *url = [NSURL fileURLWithPath:matchPhotoDirectory];
    NSFileWrapper *dirWrapper = [[NSFileWrapper alloc] initWithURL:url options:0 error:&error];
    if (dirWrapper == nil) {
        NSLog(@"Error creating directory wrapper: %@", error.localizedDescription);
        return;
    }
    NSData *transferData = [dirWrapper serializedRepresentation];
    [transferData writeToFile:photoExportPath atomically:YES];
}

-(BOOL)exportMatchPhotoList:(NSArray *)matchPhotoList {
    NSError *error;
    // Build a temporary directory to hold just this tournament's photos
    NSString *tmpBuildExport = [[FileIOMethods applicationDocumentsDirectory] stringByAppendingPathComponent:@"tmpPhotoExport"];
    // Remove the tmp directory to make sure old data does not hang around
    [fileManager removeItemAtPath:tmpBuildExport error:&error];
    
    // Build directory to hold the temporary images
    if (![fileManager fileExistsAtPath:tmpBuildExport isDirectory:NO]) {
        if (![fileManager createDirectoryAtPath:tmpBuildExport
                    withIntermediateDirectories: YES
                                     attributes: nil
                                          error: NULL]) {
            NSLog(@"Dreadful error creating directory to transfer match photos");
            return FALSE;
        }
    }
    for (NSString *matchPhoto in matchPhotoList) {
        [fileManager copyItemAtPath:[matchPhotoDirectory stringByAppendingPathComponent:matchPhoto] toPath:[tmpBuildExport stringByAppendingPathComponent:matchPhoto] error:NULL];
    }
    float currentTime = CFAbsoluteTimeGetCurrent();
    NSString *photoExportPath = [[FileIOMethods applicationDocumentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ %@ Match Photo Transfer_%.0f.mph", deviceName, tournamentName, currentTime]];
    NSURL *url = [NSURL fileURLWithPath:tmpBuildExport];
    NSFileWrapper *dirWrapper = [[NSFileWrapper alloc] initWithURL:url options:0 error:&error];
    if (dirWrapper == nil) {
        NSLog(@"Error creating directory wrapper: %@", error.localizedDescription);
        return FALSE;
    }
    NSData *transferData = [dirWrapper serializedRepresentation];
    [transferData writeToFile:photoExportPath atomically:YES];
    // Remove the tmp directory to make sure old data does not hang around
    [fileManager removeItemAtPath:tmpBuildExport error:&error];

    return FALSE;
}

#ifdef NOTUSED
-(void)exportMatchPhotos:(NSString *)tournament {
    NSError *error;
    // Build a temporary directory to hold just this tournament's photos
    NSString *tmpBuildExport = [[FileIOMethods applicationDocumentsDirectory] stringByAppendingPathComponent:@"tmpPhotoExport"];
    // Remove the tmp directory to make sure old data does not hang around
    [fileManager removeItemAtPath:tmpBuildExport error:&error];
    
    // Build directory to hold the temporary images
    if (![fileManager fileExistsAtPath:tmpBuildExport isDirectory:NO]) {
        if (![fileManager createDirectoryAtPath:tmpBuildExport
                    withIntermediateDirectories: YES
                                     attributes: nil
                                          error: NULL]) {
            NSLog(@"Dreadful error creating directory to transfer match photos");
            return;
        }
    }
    
    // Build the list of files to transfer and create symbolic links in the transfer directory
    NSArray *teamList = [TeamAccessors getTeamsInTournament:tournament fromDataManager:_dataManager];
    for (NSNumber *teamNumber in teamList) {
        for (NSString *photo in [self getPhotoList:teamNumber]) {
            [fileManager copyItemAtPath:[robotPhotoDirectory stringByAppendingPathComponent:photo] toPath:[tmpPhotoDirectory stringByAppendingPathComponent:photo] error:NULL];
            
        }
        for (NSString *photo in [self getThumbnailList:teamNumber]) {
            [fileManager copyItemAtPath:[robotThumbnailDirectory stringByAppendingPathComponent:photo] toPath:[tmpThumbnailDirectory stringByAppendingPathComponent:photo] error:NULL];
            
        }
    }
    
    float currentTime = CFAbsoluteTimeGetCurrent();
    NSString *photoExportPath = [[FileIOMethods applicationDocumentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ Match Photo Transfer.pho", tournament]];
    NSURL *url = [NSURL fileURLWithPath:tmpBuildExport];
    NSFileWrapper *dirWrapper = [[NSFileWrapper alloc] initWithURL:url options:0 error:&error];
    if (dirWrapper == nil) {
        NSLog(@"Error creating directory wrapper: %@", error.localizedDescription);
        return;
    }
    NSData *transferData = [dirWrapper serializedRepresentation];
    [transferData writeToFile:photoExportPath atomically:YES];
    // Remove the tmp directory to make sure old data does not hang around
    [fileManager removeItemAtPath:tmpBuildExport error:&error];
}
#endif


@end
