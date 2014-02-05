//
//  DataManager.h
// Robonauts Scouting
//
//  Created by Kris Pettinger on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AssetsLibrary/AssetsLibrary.h>
#import "ALAssetsLibrary+CustomPhotoAlbum.h"

@interface DataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectContext *smManagedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, assign) BOOL loadDataFromBundle;
@property (strong, atomic) ALAssetsLibrary *photoLibrary;

-(void)saveContext;
-(NSString *)applicationDocumentsDirectory;
-(BOOL)databaseExists;

-(void)savePhotoToAlbum:(UIImage*)image;
-(void)addPhotoToAlbum:(NSURL*)assetURL;
-(void)getPhotoFromAlbum:(NSURL *)photoURL;
@end
