//
//  AddTeamViewController.h
// Robonauts Scouting
//
//  Created by FRC on 10/14/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddTeamDelegate
- (void)teamAdded:(NSNumber *)newTeamNumber forName:(NSString *) newTeamName;
@end

@interface AddTeamViewController : UIViewController <UITextFieldDelegate>
@property (nonatomic, weak) id<AddTeamDelegate> delegate;

@end
