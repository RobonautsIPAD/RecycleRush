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
    NSString *matchPhotoDirectory;
}

-(id)init:(DataManager *)initManager {
	if ((self = [super init])) {
        _dataManager = initManager;
        fileManager = [NSFileManager defaultManager];
        prefs = [NSUserDefaults standardUserDefaults];
        tournamentName = [prefs objectForKey:@"tournament"];
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

-(NSString *)savePhoto:(NSData *)imageData forMatch:(NSNumber *)matchNumber forType:(NSString *)matchTypeString forTeam:(NSNumber *)teamNumber {
    NSString *photoName = [self createBaseName:matchNumber forType:matchTypeString forTeam:teamNumber];
    // Create full path name
    NSString *fullPath = [matchPhotoDirectory stringByAppendingPathComponent:photoName];
    if ([imageData writeToFile:fullPath atomically:YES]) {
        return photoName;
    }
    else {
        return nil;
    }
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


@end
