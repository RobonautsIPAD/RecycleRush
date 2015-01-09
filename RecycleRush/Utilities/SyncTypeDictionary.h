//
//  SyncTypeDictionary.h
// Robonauts Scouting
//
//  Created by FRC on 12/19/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncMethods.h"
@interface SyncTypeDictionary : NSObject
-(NSString *)getSyncTypeString:(SyncType) key;
-(id)getSyncTypeEnum:(NSString *) value;
-(NSArray *)getSyncTypes;
@end
