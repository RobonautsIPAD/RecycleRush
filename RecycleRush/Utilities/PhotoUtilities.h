//
//  PhotoUtilities.h
//  RecycleRush
//
//  Created by FRC on 10/16/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataManager;
@class PhotoAttributes;

@interface PhotoUtilities : NSObject
@property (nonatomic, strong) DataManager *dataManager;
-(id)init:(DataManager *)initManager;
-(void)exportTournamentPhotos:(NSString *)tournament;
-(NSString *)getFullImagePath:(NSString *)photoName;
-(NSString *)getThumbnailPath:(NSString *)photoName;
-(NSArray *)getThumbnailList:(NSNumber *)teamNumber;
-(NSString *)createBaseName:(NSNumber *)baseNumber;
-(NSString *)savePhoto:(NSString *)photoNameBase withImage:(UIImage *)image;
-(NSMutableArray *)importDataPhoto:(NSString *) importFile error:(NSError **)error;

-(void)removePhoto:(NSString *)photoName;
@end
