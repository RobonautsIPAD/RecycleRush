//
//  RecordScorePickerController.h
// Robonauts Scouting
//
//  Created by FRC on 1/23/13.
//
//

#import <UIKit/UIKit.h>

@protocol AutonScorePickerDelegate
- (void)scoreSelected:(NSString *)scoreButton;
@end

@interface AutonScorePickerController : UITableViewController
@property (nonatomic, retain) NSMutableArray *scoreChoices;
@property (nonatomic, assign) id<AutonScorePickerDelegate> delegate;

@end
