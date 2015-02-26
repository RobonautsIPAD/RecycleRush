//
//  StackViewController.h
//  RecycleRush
//
//  Created by FRC on 2/19/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataManager;
@class TeamScore;

@protocol StackViewDelegate
- (void)scoringViewFinished:(NSData *)data;
@end


@interface StackViewController : UIViewController <UITextFieldDelegate>
@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) TeamScore *currentScore;
@property (nonatomic, strong) NSString *allianceString;
@property (nonatomic, weak) id<StackViewDelegate> delegate;
@property (nonatomic, strong) NSData *savedData;

@end
