//
//  TeamDetailViewController.h
// Robonauts Scouting
//
//  Created by Kris Pettinger on 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopUpPickerViewController.h"

@class DataManager;
@class TeamData;
@class MatchData;
@class TeamScore;

@interface TeamDetailViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UIActionSheetDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, PopUpPickerDelegate>

@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSIndexPath *teamIndex;
@property (nonatomic, strong) TeamData *team;
@property (nonatomic, weak) IBOutlet UIButton *prevTeamButton;
@property (nonatomic, weak) IBOutlet UIButton *nextTeamButton;
@property (nonatomic, weak) IBOutlet UITextField *numberText;
@property (nonatomic, weak) IBOutlet UITextField *nameTextField;
@property (nonatomic, weak) IBOutlet UITextView *notesViewField;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIButton *intakeType;
@property (nonatomic, weak) IBOutlet UITextField *minHeight;
@property (nonatomic, weak) IBOutlet UITextField *shootingLevel;
@property (nonatomic, weak) IBOutlet UITextField *maxHeight;
@property (nonatomic, weak) IBOutlet UITextField *wheelType;
@property (nonatomic, weak) IBOutlet UITextField *nwheels;
@property (nonatomic, weak) IBOutlet UITextField *wheelDiameter;
@property (nonatomic, weak) IBOutlet UIButton *driveType;
@property (nonatomic, weak) IBOutlet UITextField *cims;
@property (nonatomic, weak) IBOutlet UIButton *cameraBtn;
@property (nonatomic, strong) UIPopoverController *pictureController;

@property (nonatomic, weak) IBOutlet UITableView *matchInfo;
@property (nonatomic, weak) IBOutlet UITableView *regionalInfo;

@property (nonatomic, strong) UIImagePickerController *imagePickerController;


-(IBAction)PrevButton;
-(IBAction)NextButton;
-(void)checkDataStatus;
-(void)showTeam;
-(NSInteger)getNumberOfTeams;
-(IBAction)detailChanged:(id)sender;
-(void)setDataChange;

-(void)createRegionalHeader;
-(void)createMatchHeader;
-(void)SetTextBoxDefaults:(UITextField *)textField;
-(void)SetBigButtonDefaults:(UIButton *)currentButton;
//-(void)SetTextBoxDefaults:(UITextField *)textField;
-(MatchData *)getMatchData: (TeamScore *) teamScore;

-(void)takePhoto;
-(void)choosePhoto;
-(IBAction)photoControllerActionSheet:(id)sender;
-(void)photoTapped:(UITapGestureRecognizer *)gestureRecognizer;
-(void)getPhoto;
-(IBAction)MatchNumberChanged;

@end
