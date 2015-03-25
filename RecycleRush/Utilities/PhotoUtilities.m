//
//  PhotoUtilities.m
//  RecycleRush
//
//  Created by FRC on 10/16/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "PhotoUtilities.h"
#import "DataManager.h"
#import "TeamAccessors.h"
#import "FileIOMethods.h"
#import <ImageIO/ImageIO.h>
#import <ImageIO/CGImageProperties.h>

@implementation PhotoUtilities {
    NSFileManager *fileManager;
    NSUserDefaults *prefs;
    NSString *deviceName;
    NSString *robotPhotoLibrary;
    NSString *robotPhotoDirectory;
    NSString *robotThumbnailDirectory;
}

-(id)init:(DataManager *)initManager {
	if ((self = [super init])) {
        _dataManager = initManager;
        fileManager = [NSFileManager defaultManager];
        prefs = [NSUserDefaults standardUserDefaults];
        deviceName = [prefs objectForKey:@"deviceName"];
        [self setPhotoDirectories];
        [self createPhotoDirectories];
 	}
	return self;
}
-(void)exportTournamentPhotos:(NSString *)tournament {
    NSError *error;
    
    // Build a temporary directory to hold links for just this tournaments photos
    NSString *tmpBuildExport = [[FileIOMethods applicationDocumentsDirectory] stringByAppendingPathComponent:@"tmpPhotoExport"];
    // Remove the tmp directory to make sure old data does not hang around
    [fileManager removeItemAtPath:tmpBuildExport error:&error];

    // Build directories to hold the temporary images and thumbnails
    NSString *tmpPhotoDirectory = [tmpBuildExport stringByAppendingPathComponent:@"Images"];
    NSString *tmpThumbnailDirectory = [tmpBuildExport stringByAppendingPathComponent:@"Thumbnails"];
    if (![fileManager fileExistsAtPath:tmpPhotoDirectory isDirectory:NO]) {
        if (![fileManager createDirectoryAtPath:tmpPhotoDirectory
                    withIntermediateDirectories: YES
                                     attributes: nil
                                          error: NULL]) {
            NSLog(@"Dreadful error creating directory to transfer photos");
            return;
        }
    }
    if (![fileManager fileExistsAtPath:tmpThumbnailDirectory isDirectory:NO]) {
        if (![fileManager createDirectoryAtPath:tmpThumbnailDirectory
                    withIntermediateDirectories: YES
                                     attributes: nil
                                          error: NULL]) {
            NSLog(@"Dreadful error creating directory to tranfer thumbnails");
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

    NSString *photoExportPath = [[FileIOMethods applicationDocumentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ %@ Team Photo Transfer.pho", deviceName, tournament]];
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

-(NSMutableArray *)importDataPhoto:(NSString *) importFile error:(NSError **)error {
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
    NSString *photos = [tmpPhotoImport stringByAppendingPathComponent:@"Images"];
    NSArray *directoryContents = [fileManager contentsOfDirectoryAtPath:photos error:error];
    for (NSString *file in directoryContents) {
        NSString *destinationPath = [robotPhotoDirectory stringByAppendingPathComponent:file];
        if (![fileManager fileExistsAtPath:destinationPath]) {
            [fileManager copyItemAtPath:[photos stringByAppendingPathComponent:file] toPath:destinationPath error:NULL];
            [importedPhotos addObject:file];
        }
    }
    photos = [tmpPhotoImport stringByAppendingPathComponent:@"Thumbnails"];
    directoryContents = [fileManager contentsOfDirectoryAtPath:photos error:error];
    for (NSString *file in directoryContents) {
        NSString *destinationPath = [robotThumbnailDirectory stringByAppendingPathComponent:file];
        if (![fileManager fileExistsAtPath:destinationPath]) {
            [fileManager copyItemAtPath:[photos stringByAppendingPathComponent:file] toPath:destinationPath error:NULL];
        }
    }
    [fileManager removeItemAtPath:photoImportPath error:error];
    [fileManager removeItemAtPath:tmpPhotoImport error:error];
  
    NSLog(@"import file = %@", importFile);
    return importedPhotos;
}

-(NSString *)getFullImagePath:(NSString *)photoName {
    NSString *fullPath = [robotPhotoDirectory stringByAppendingPathComponent:photoName];
    return fullPath;
}

-(NSString *)getThumbnailPath:(NSString *)photoName {
    NSString *fullPath = [robotThumbnailDirectory stringByAppendingPathComponent:photoName];
    return fullPath;
}

-(NSArray *)getThumbnailList:(NSNumber *)teamNumber {
    NSString *baseName = [self createBaseName:teamNumber];
    NSError *error;
    NSArray *thumbNailDirectoryContents = [fileManager contentsOfDirectoryAtPath:robotThumbnailDirectory error:&error];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", baseName];
    NSArray *list = [thumbNailDirectoryContents filteredArrayUsingPredicate:pred];
    return list;
}

-(NSArray *)getPhotoList:(NSNumber *)teamNumber {
    NSString *baseName = [self createBaseName:teamNumber];
    NSError *error;
    NSArray *photoDirectoryContents = [fileManager contentsOfDirectoryAtPath:robotPhotoDirectory error:&error];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", baseName];
    NSArray *list = [photoDirectoryContents filteredArrayUsingPredicate:pred];
    return list;
}


-(NSString *)savePhoto:(NSString *)photoNameBase withImage:(UIImage *)image {
    NSString *photoName;
    // Use the time to create unique photo names
    float currentTime = CFAbsoluteTimeGetCurrent();
    // Create full sized photo name
    NSString *fullName = [photoNameBase stringByAppendingString:[NSString stringWithFormat:@"_%.0f.jpg", currentTime]];
    NSString *fullPath = [robotPhotoDirectory stringByAppendingPathComponent:fullName];
    if ([fileManager fileExistsAtPath:fullPath]) {
        currentTime /= 2;
        fullName = [photoNameBase stringByAppendingString:[NSString stringWithFormat:@"_%.0f.jpg", currentTime]];
        fullPath = [robotPhotoDirectory stringByAppendingPathComponent:fullName];
    }
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);

    if ([imageData writeToFile:fullPath atomically:YES]) {
        photoName = fullName;
    }
    else {
        photoName = Nil;
    }

    // Create and save thumbnail
    fullPath = [robotThumbnailDirectory stringByAppendingPathComponent:fullName];
    CGImageSourceRef myImageSource = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
    CFDictionaryRef options = (__bridge CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:
                                                         (id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailWithTransform,
                                                         (id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailFromImageIfAbsent,
                                                         (id)[NSNumber numberWithFloat:100], (id)kCGImageSourceThumbnailMaxPixelSize,
                                                         nil];
    CGImageRef myThumbnailImage = CGImageSourceCreateThumbnailAtIndex(myImageSource, 0, options);
    UIImage *thumbnail = [UIImage imageWithCGImage:myThumbnailImage];
    [UIImageJPEGRepresentation(thumbnail, 1.0) writeToFile:fullPath atomically:YES];
    CFRelease(myImageSource);
    CGImageRelease(myThumbnailImage);

    return photoName;
}


-(void)removePhoto:(NSString *)photoName {
    NSError *error;
    NSString *fullPath = [robotPhotoDirectory stringByAppendingPathComponent:photoName];
    [fileManager removeItemAtPath:fullPath error:&error];
    fullPath = [robotThumbnailDirectory stringByAppendingPathComponent:photoName];
    [fileManager removeItemAtPath:fullPath error:&error];
}


-(NSString *)createBaseName:(NSNumber *)baseNumber {
    NSString *number;
    if ([baseNumber intValue] < 100) {
        number = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"00%d", [baseNumber intValue]]];
    } else if ( [baseNumber intValue] < 1000) {
        number = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"0%d", [baseNumber intValue]]];
    } else {
        number = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"%d", [baseNumber intValue]]];
    }
    return number;
}

-(void)setPhotoDirectories {
    // Get the robot photo directories
    NSString *library = [FileIOMethods applicationDocumentsDirectory];
    robotPhotoLibrary = [library stringByAppendingPathComponent:[NSString stringWithFormat:@"RobotPhotos"]];
    robotPhotoDirectory = [robotPhotoLibrary stringByAppendingPathComponent:@"Images"];
    robotThumbnailDirectory = [robotPhotoLibrary stringByAppendingPathComponent:@"Thumbnails"];
}

-(void)createPhotoDirectories {
    // Create the robot photo directories
    // Check if directory exists, if not, create it
    if (![fileManager fileExistsAtPath:robotPhotoDirectory isDirectory:NO]) {
        if (![fileManager createDirectoryAtPath:robotPhotoDirectory
                    withIntermediateDirectories: YES
                                     attributes: nil
                                          error: NULL]) {
            NSLog(@"Dreadful error creating directory to save photos");
        }
    }
    if (![fileManager fileExistsAtPath:robotThumbnailDirectory isDirectory:NO]) {
        if (![fileManager createDirectoryAtPath:robotThumbnailDirectory
                    withIntermediateDirectories: YES
                                     attributes: nil
                                          error: NULL]) {
            NSLog(@"Dreadful error creating directory to save thumbnails");
        }
    }
}

@end
