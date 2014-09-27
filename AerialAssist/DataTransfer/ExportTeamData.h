//
//  ExportTeamData.h
//  AerialAssist
//
//  Created by FRC on 2/14/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExportTeamData : NSObject 

-(NSString *)teamDataCSVExport:(NSString *)tournamentName fromContext:(NSManagedObjectContext *)managedObjectContext;

@end
