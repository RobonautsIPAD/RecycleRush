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
@property (nonatomic, weak) IBOutlet UITextField *teamNumberTextField;
@property (nonatomic, weak) IBOutlet UITextField *teamNameTextField;
@property (nonatomic, weak) IBOutlet UIImageView *mainLogo;
@property (nonatomic, weak) IBOutlet UILabel *pictureCaption;
@property (nonatomic, weak) IBOutlet UIImageView *splashPicture;

- (IBAction)cancelVC:(id)sender;
- (IBAction)addAction:(id)sender;

@end
