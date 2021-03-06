//
//  MatchPhotoUtilities.h
//  RecycleRush
//
//  Created by FRC on 3/6/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DataManager;

@interface MatchPhotoUtilities : NSObject
@property (nonatomic, strong) DataManager *dataManager;
-(id)init:(DataManager *)initManager;
-(NSString *)createBaseName:(NSNumber *)matchNumber forType:(NSString *)matchTypeString forTeam:(NSNumber *)teamNumber;
-(NSString *)savePhoto:(UIImage *)image forMatch:(NSNumber *)matchNumber forType:(NSString *)matchTypeString forTeam:(NSNumber *)teamNumber;
-(void)saveTransferPhoto:(NSData *)imageData forName:(NSString *)photoName;
-(NSString *)getFullPath:(NSString *)photoName;
-(void)exportMatchPhotos;
-(BOOL)exportMatchPhotoList:(NSArray *)matchPhotoList;
-(NSMutableArray *)importMatchPhotos:(NSString *)importFile error:(NSError **)error;
-(NSArray *)getTeamPhotoList:(NSNumber *)teamNumber;
@end
