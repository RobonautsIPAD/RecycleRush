//
//  ExportMatchData.h
//  AerialAssist
//
//  Created by FRC on 2/15/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DataManager;
@class MatchData;

@interface ExportMatchData : NSObject
@property (nonatomic, strong) DataManager *dataManager;

-(id)init:(DataManager *)initManager;

-(NSString *)matchDataCSVExport:(NSString *)tournamentName;
-(NSData *)packageMatchForXFer:(MatchData *)match;
-(NSDictionary *)unpackageMatchForXFer:(NSData *)xferData;
-(void)exportMatchForXFer:(MatchData *)match toFile:(NSString *)exportFilePath;


@end
