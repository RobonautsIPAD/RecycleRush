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
-(NSString *)spreadsheetCSVExport:(NSString *)tournamentName;
-(void)exportFullMatchData:(NSArray *)teamList;
-(void)exportScoreForXFer:(TeamScore *)score toFile:(NSString *)exportFilePath;
-(NSData *)packageScoreForXFer:(TeamScore *)score;
-(NSDictionary *)packageScoreForBluetooth:(TeamScore *)score;
@end
