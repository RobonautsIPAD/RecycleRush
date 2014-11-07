//
//  SyncOptionDictionary.h
// Robonauts Scouting
//
//  Created by FRC on 12/19/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncMethods.h"
@interface SyncOptionDictionary : NSObject
-(NSString *)getSyncOptionString:(SyncOptions) key;
-(id)getSyncOptionEnum:(NSString *) value;
-(NSArray *)getSyncOptions;
@end
