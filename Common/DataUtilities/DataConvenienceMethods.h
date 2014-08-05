//
//  DataConvenienceMethods.h
//  AerialAssist
//
//  Created by FRC on 7/2/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TournamentData;

@interface DataConvenienceMethods : NSObject
+(TournamentData *)getTournament:(NSString *)name fromContext:(NSManagedObjectContext *)managedObjectContext;

@end
