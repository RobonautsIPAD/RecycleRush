//
//  DataManager.h
// Robonauts Scouting
//
//  Created by Kris Pettinger on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSString *errorFilePath;
@property (readonly, strong, nonatomic) NSString *warningFilePath;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, assign) BOOL loadDataFromBundle;
@property (readonly, nonatomic, strong) NSDictionary *matchTypeDictionary;
@property (readonly, nonatomic, strong) NSDictionary *allianceDictionary;

-(BOOL)saveContext;
-(BOOL)databaseExists;
-(void)writeErrorMessage:(NSError *)error forType:(MessageType)messageType;

@end
