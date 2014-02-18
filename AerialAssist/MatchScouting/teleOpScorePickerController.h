//
//  RecordScorePickerController.h
// Robonauts Scouting
//
//  Created by FRC on 1/23/13.
//
//

#import <UIKit/UIKit.h>

@protocol TeleOpScorePickerDelegate
- (void)scoreSelected:(NSString *)scoreButton;
@end

@interface TeleOpScorePickerController : UITableViewController
@property (nonatomic, retain) NSMutableArray *scoreChoices;
@property (nonatomic, assign) id<TeleOpScorePickerDelegate> delegate;

@end
