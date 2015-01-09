//
//  ImportDataFromiTunes.h
//  RecycleRush
//
//  Created by FRC on 3/6/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DataManager;

@interface ImportDataFromiTunes : NSObject <UIAlertViewDelegate>
@property (nonatomic, strong) DataManager *dataManager;
- (id)init:(DataManager *)initManager;
-(NSArray *)getImportFileList;
-(NSMutableArray *)importData:(NSString *) importFile error:(NSError **)error;

@end
