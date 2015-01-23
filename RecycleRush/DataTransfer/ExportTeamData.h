//
//  ExportTeamData.h
//  RecycleRush
//
//  Created by FRC on 2/14/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataManager;
@class TeamData;

@interface ExportTeamData : NSObject
@property (nonatomic, strong) DataManager *dataManager;
-(id)init:(DataManager *)initManager;
-(NSString *)teamDataCSVExport:(NSString *)tournamentName;
-(NSData *)packageTeamForXFer:(TeamData *)team;
-(NSDictionary *)XMLpackageTeamForXFer:(TeamData *)team;
-(void)exportTeamForXFer:(TeamData *)team toFile:(NSString *)exportFilePath;

@end
