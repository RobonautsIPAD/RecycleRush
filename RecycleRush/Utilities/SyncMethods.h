//
//  SyncMethods.h
//  RecycleRush
//
//  Created by FRC on 11/1/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SyncMethods : NSObject


typedef enum {
    SyncTeams,
    SyncTournaments,
    SyncMatchResults,
    SyncMatchList,
    SyncPhotos
} SyncType;

typedef enum {
    SyncAll,
    SyncAllSavedHere,
    SyncAllSavedSince,
    SyncQuickRequest,
} SyncOptions;

+(NSString *)getSyncTypeString:(SyncType)syncType;
+(NSString *)getSyncOptionString:(SyncOptions)syncType;
+(SyncType)getSyncType:(NSString *)syncTypeString;
+(SyncOptions)getSyncOption:(NSString *)syncOptionString;
+(NSArray *)getSyncOptionList;
+(NSArray *)getSyncTypeList;

@end
