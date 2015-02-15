//
//  iPhoneMainViewController.h
// Robonauts Scouting
//
//  Created by FRC on 4/4/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataManager;
@class ConnectionUtility;

@interface iPhoneMainViewController : UIViewController <UITextFieldDelegate>
@property (nonatomic, retain) DataManager *dataManager;
@property (nonatomic, strong) ConnectionUtility *connectionUtility;
- (id)initWithDataManager:(DataManager *)initManager;

/*
@property (strong, nonatomic) IBOutlet UIWebView *viewWeb;
-(void) extractMatchList:(NSArray *)allLines;
- (IBAction)getMatchList:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) NSURL *url;
 */

@end
