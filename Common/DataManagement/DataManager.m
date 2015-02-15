//
//  DataManager.m
// Robonauts Scouting
//
//  Created by Kris Pettinger on 6/8/12.
//  Copyright (c) 2012 __Robonauts__. All rights reserved.
//

#import "DataManager.h"
#import "AppDelegate.h"
#import "ConnectionUtility.h"
#import "FileIOMethods.h"
#import "EnumerationDictionary.h"

@implementation DataManager {
    NSUserDefaults *prefs;
    NSString *appName;
    NSDateFormatter *dateFormatter;
    NSFileHandle *errorFileHandle;
    NSFileHandle *warningFileHandle;
}

@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (id)init
{
	if ((self = [super init]))
	{
        prefs = [NSUserDefaults standardUserDefaults];
        appName = [prefs objectForKey:@"appName"];
        [self initializeLogFiles];
        [self managedObjectContext];
        [self initializeDictionaries];
    }
	return self;
}

-(void)initializeLogFiles {
    NSDate *date = [NSDate date];
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *errorFile = @"errorFile.txt";
    _errorFilePath = [[FileIOMethods applicationDocumentsDirectory] stringByAppendingPathComponent:errorFile];
    NSString *msg = [NSString stringWithFormat:@"%@ %@ Started\n", [dateFormatter stringFromDate:date], appName];
    if ( !(errorFileHandle = [NSFileHandle fileHandleForWritingAtPath:_errorFilePath]) ) {
        [msg writeToFile:_errorFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        errorFileHandle = [NSFileHandle fileHandleForWritingAtPath:_errorFilePath];
    }
    else {
        errorFileHandle = [NSFileHandle fileHandleForWritingAtPath:_errorFilePath];
        [errorFileHandle seekToEndOfFile];
        [errorFileHandle writeData:[msg dataUsingEncoding:NSUTF8StringEncoding]];
    }
    NSString *warningFile = @"warningFile.txt";
    _warningFilePath = [[FileIOMethods applicationDocumentsDirectory] stringByAppendingPathComponent:warningFile];
    if ( !(warningFileHandle = [NSFileHandle fileHandleForWritingAtPath:_warningFilePath]) ) {
        [msg writeToFile:_warningFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        warningFileHandle = [NSFileHandle fileHandleForWritingAtPath:_warningFilePath];
    }
    else {
        warningFileHandle = [NSFileHandle fileHandleForWritingAtPath:_warningFilePath];
        [warningFileHandle seekToEndOfFile];
        [warningFileHandle writeData:[msg dataUsingEncoding:NSUTF8StringEncoding]];
    }
}

-(void)resetWarningFile {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    [warningFileHandle closeFile];
    float time = CFAbsoluteTimeGetCurrent();
    NSString *savedWarningFile = [[FileIOMethods applicationDocumentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"warningFile%.0f.txt", time]];
    if ([fileManager moveItemAtPath:_warningFilePath toPath:savedWarningFile error:&error]) {
        NSDate *date = [NSDate date];
        NSString *msg = [NSString stringWithFormat:@"%@ %@ Warning File Reset\n", [dateFormatter stringFromDate:date], appName];
        if ( !(warningFileHandle = [NSFileHandle fileHandleForWritingAtPath:_warningFilePath]) ) {
            [msg writeToFile:_warningFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            warningFileHandle = [NSFileHandle fileHandleForWritingAtPath:_warningFilePath];
        }
    }
    else [self writeErrorMessage:error forType:kErrorMessage];
}

-(void)resetErrorFile {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    [errorFileHandle closeFile];
    float time = CFAbsoluteTimeGetCurrent();
    NSString *savedErrorFile = [[FileIOMethods applicationDocumentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"errorFile%.0f.txt", time]];
    if ([fileManager moveItemAtPath:_errorFilePath toPath:savedErrorFile error:&error]) {
        NSDate *date = [NSDate date];
        NSString *msg = [NSString stringWithFormat:@"%@ %@ Error File Reset\n", [dateFormatter stringFromDate:date], appName];
        if ( !(errorFileHandle = [NSFileHandle fileHandleForWritingAtPath:_errorFilePath]) ) {
            [msg writeToFile:_errorFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            errorFileHandle = [NSFileHandle fileHandleForWritingAtPath:_errorFilePath];
        }
    }
    else [self writeErrorMessage:error forType:kWarningMessage];
}

-(BOOL)databaseExists {
    [self managedObjectContext];
    return _loadDataFromBundle;
}

-(void)writeErrorMessage:(NSError *)error forType:(MessageType)messageType {
    NSDate *date = [NSDate date];
    NSString *msg = [NSString stringWithFormat:@"%@ %@\n", [dateFormatter stringFromDate:date], [error localizedDescription]];
    if (messageType == kErrorMessage) {
        [errorFileHandle seekToEndOfFile];
        [errorFileHandle writeData:[msg dataUsingEncoding:NSUTF8StringEncoding]];
    }
    else {
        [warningFileHandle seekToEndOfFile];
        [warningFileHandle writeData:[msg dataUsingEncoding:NSUTF8StringEncoding]];
    }
}

-(void)initializeDictionaries {
    _matchTypeDictionary = [EnumerationDictionary initializeBundledDictionary:@"MatchType"];
    _allianceDictionary = [EnumerationDictionary initializeBundledDictionary:@"AllianceList"];
}

-(ConnectionUtility *)setConnectionUtility {
    if (_connectionUtility == nil) {
        _connectionUtility = [[ConnectionUtility alloc] init:self];
    }
    return _connectionUtility;
}

-(BOOL)saveContext {
    BOOL success = TRUE;
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;

    if (managedObjectContext) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            [self writeErrorMessage:error forType:kErrorMessage];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Database save error"
                                                            message:@"Unable to save record"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
            [alert show];
            success = FALSE;
        }
    }
    else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Missing managedObjectContext" forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"Save Database" code:kErrorMessage userInfo:userInfo];
        [self writeErrorMessage:error forType:kErrorMessage];
        success = FALSE;
    }
    return success;
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    // To migrate
    NSString *path = [[NSBundle mainBundle] pathForResource:appName ofType:@"momd"];
    NSURL *momURL = [NSURL fileURLWithPath:path];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
    
    // or not to migrate
/*    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:appName withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL]; */
    
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSString *fileName = [appName stringByAppendingString:@".sqlite"];
    NSString *storePath = [[FileIOMethods applicationDocumentsDirectory] stringByAppendingPathComponent: fileName];
    NSURL *storeURL = [NSURL fileURLWithPath:storePath];
	
    _loadDataFromBundle = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:storePath]) {
        // Database doesn't already exist, so check for one in the main bundle
        NSLog(@"Data base does not exist");
        NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:appName ofType:@"sqlite"];
        if (defaultStorePath) {
            // Copy database from the main bundle
            NSLog(@"Found a database file in the main bundle");
            [fileManager copyItemAtPath:defaultStorePath toPath:storePath error:NULL];
        }
        else { // Load data from CSV files in the main bundle
            NSLog(@"No pre-existing databases. Check the main bundle for CSV data");
            _loadDataFromBundle = YES;
        }
    }

    NSError *error = nil;

//    NSDictionary *options = @{ NSSQLitePragmasOption : @{@"journal_mode" : @"DELETE"} };
    // To migrate
    NSDictionary *pragmaOptions = [NSDictionary dictionaryWithObject:@"DELETE"
                                                              forKey:@"journal_mode"];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                             pragmaOptions, NSSQLitePragmasOption,
                             nil];
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])

    // or not to migrate
/*    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])*/
        
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

@end
