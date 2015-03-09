//
//  SyncMethods.m
//  RecycleRush
//
//  Created by FRC on 11/1/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "SyncMethods.h"

@implementation SyncMethods

+(NSString *)getSyncTypeString:(SyncType)syncType {
    NSString *syncString;
    switch (syncType) {
        case 0:
            syncString = @"Sync Team Data";
            break;
        case 1:
            syncString = @"Sync Tournament Names";
            break;
        case 2:
            syncString = @"Sync Match Results";
            break;
        case 3:
            syncString = @"Sync Match Schedule";
            break;
        default:
            syncString = @"";
            break;
    }
    return syncString;
}

+(NSString *)getPhoneSyncTypeString:(SyncType)syncType {
    NSString *syncString;
    switch (syncType) {
        case 0:
            syncString = @"Teams";
            break;
        case 1:
            syncString = @"Tournament";
            break;
        case 2:
            syncString = @"Results";
            break;
        case 3:
            syncString = @"Schedule";
            break;
        default:
            syncString = @"";
            break;
    }
    return syncString;
}


+(NSString *)getSyncOptionString:(SyncOptions)syncOption {
    NSString *syncString;
    switch (syncOption) {
        case 0:
            syncString = @"Sync All";
            break;
        case 1:
            syncString = @"Sync All Saved on this Device";
            break;
        case 2:
            syncString = @"Sync All Since Last Sync";
            break;
        default:
            syncString = @"";
            break;
    }
    return syncString;
}

+(NSString *)getPhoneSyncOptionString:(SyncOptions)syncOption {
    NSString *syncString;
    switch (syncOption) {
        case 0:
            syncString = @"All";
            break;
        case 1:
            syncString = @"Local";
            break;
        case 2:
            syncString = @"Latest";
            break;
        default:
            syncString = @"";
            break;
    }
    return syncString;
}

+(SyncType)getSyncType:(NSString *)syncTypeString {
    if ([syncTypeString isEqualToString:@"Sync Team Data"]) {
        return SyncTeams;
    }
    if ([syncTypeString isEqualToString:@"Sync Tournament Names"]) {
        return SyncTournaments;
    }
    if ([syncTypeString isEqualToString:@"Sync Match Results"]) {
        return SyncMatchResults;
    }
    if ([syncTypeString isEqualToString:@"Sync Match Schedule"]) {
        return SyncMatchList;
    }
   return 0;
}

+(SyncOptions)getSyncOption:(NSString *)syncOptionString {
    if ([syncOptionString isEqualToString:@"Sync All"]) {
        return SyncAll;
    }
    if ([syncOptionString isEqualToString:@"Sync All Saved on this Device"]) {
        return SyncAllSavedHere;
    }
    if ([syncOptionString isEqualToString:@"Sync All Since Last Sync"]) {
        return SyncAllSavedSince;
    }
    return 0;
}

+(NSArray *)getSyncOptionList {
    return  [NSArray arrayWithObjects:@"Sync All", @"Sync All Saved on this Device", @"Sync All Since Last Sync", nil];
}

+(NSArray *)getSyncTypeList {
    return [NSArray arrayWithObjects:@"Sync Team Data", @"Sync Tournament Names", @"Sync Match Results", @"Sync Match Schedule", nil];
}



@end
