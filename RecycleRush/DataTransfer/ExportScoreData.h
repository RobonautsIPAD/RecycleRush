//
//  ExportScoreData.h
//  RecycleRush
//
//  Created by FRC on 2/15/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DataManager;
@class TeamData;
@class TeamScore;

@interface ExportScoreData : NSObject
@property (nonatomic, strong) DataManager *dataManager;

-(id)init:(DataManager *)initManager;
-(NSString *)teamScoreCSVExport;
-(BOOL)spreadsheetCSVExport:(NSString *)tournamentName toFile:(NSString *)fullPath;
-(NSString *)scoreBundleCSVExport:(NSString *)tournamentName;
-(void)exportFullMatchData:(NSArray *)teamList;
-(void)exportScoreForXFer:(TeamScore *)score toFile:(NSString *)exportFilePath;
@end
