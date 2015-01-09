//
//  PopUpPickerViewController.h
// Robonauts Scouting
//
//  Created by FRC on 4/7/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PopUpPickerDelegate
- (void)pickerSelected:(NSString *)newPick;
@end


@interface PopUpPickerViewController : UITableViewController

@property (nonatomic, strong) NSArray *pickerChoices;
@property (nonatomic, weak) id<PopUpPickerDelegate> delegate;

@end
