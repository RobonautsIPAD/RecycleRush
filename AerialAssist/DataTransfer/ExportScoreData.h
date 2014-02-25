//
//  ExportScoreData.h
//  AerialAssist
//
//  Created by FRC on 2/15/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DataManager;

@interface ExportScoreData : NSObject
@property (nonatomic, strong) DataManager *dataManager;

-(id)initWithDataManager:(DataManager *)initManager;
-(NSString *)teamScoreCSVExport;
-(NSString *)spreadsheetCSVExport;

@end
