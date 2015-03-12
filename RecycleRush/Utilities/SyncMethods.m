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
        case SyncTeams:
            syncString = @"Sync Team Data";
            break;
        case SyncTournaments:
            syncString = @"Sync Tournament Names";
            break;
        case SyncMatchResults:
            syncString = @"Sync Match Results";
            break;
        case SyncMatchList:
            syncString = @"Sync Match Schedule";
            break;
        case SyncQuickRequest:
            syncString = @"Quick Request Status";
            break;
        case SyncMitchData:
            syncString = @"Sync Mitch Data";
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
        case SyncTeams:
            syncString = @"Teams";
            break;
        case SyncTournaments:
            syncString = @"Tournament";
            break;
        case SyncMatchResults:
            syncString = @"Results";
            break;
        case SyncMatchList:
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
        case SyncAll:
            syncString = @"Sync All";
            break;
        case SyncAllSavedHere:
            syncString = @"Sync All Saved on this Device";
            break;
        case SyncAllSavedSince:
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
        case SyncAll:
            syncString = @"All";
            break;
        case SyncAllSavedHere:
            syncString = @"Local";
            break;
        case SyncAllSavedSince:
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
    if ([syncTypeString isEqualToString:@"Quick Request Status"]) {
        return SyncQuickRequest;
    }
    if ([syncTypeString isEqualToString:@"Sync Mitch Data"]) {
        return SyncMitchData;
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
    return [NSArray arrayWithObjects:@"Sync Team Data", @"Sync Tournament Names", @"Sync Match Results", @"Sync Match Schedule", @"Quick Request Status", @"Sync Mitch Data", nil];
}



@end
