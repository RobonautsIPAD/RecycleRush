//
//  TeamDetailViewController.m
//  ReboundRumble
//
//  Created by Kris Pettinger on 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TeamDetailViewController.h"
#import "TeamData.h"
//#import "TeamScore.h"
#import "MatchData.h"
//#import "SpecificGameData.h"

@implementation TeamDetailViewController
@synthesize team;
@synthesize numberLabel, nameTextField, notesTextField;
@synthesize brakes, stinger, moding, orientation;
@synthesize driveTrainTextField;
@synthesize imageView, choosePhotoBtn, takePhotoBtn;
@synthesize popoverController;
@synthesize photoPath;
@synthesize dataChange;
@synthesize matchInfo, matchHeader;
@synthesize historyLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
} 

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    NSLog(@"Team Detail");
    numberLabel.font = [UIFont fontWithName:@"Helvetica" size:24.0];
    [self SetTextBoxDefaults:nameTextField];
    [self SetTextBoxDefaults:notesTextField];
    [self SetTextBoxDefaults:driveTrainTextField];
//    [takePhotoBtn setTitle:@"Take Photo" forState:UIControlStateNormal];
//    takePhotoBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:24.0];
 
    matchHeader = [[UIView alloc] initWithFrame:CGRectMake(0,0,768,50)];
    matchHeader.backgroundColor = [UIColor lightGrayColor];
    matchHeader.opaque = YES;
    
	UILabel *matchLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 50)];
	matchLabel.text = @"Match";
    matchLabel.backgroundColor = [UIColor clearColor];
    [matchHeader addSubview:matchLabel];
    
	UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(105, 0, 200, 50)];
	typeLabel.text = @"Type";
    typeLabel.backgroundColor = [UIColor clearColor];
    [matchHeader addSubview:typeLabel];
    
 	UILabel *hybridLabel = [[UILabel alloc] initWithFrame:CGRectMake(195, 0, 200, 50)];
	hybridLabel.text = @"HP";
    hybridLabel.backgroundColor = [UIColor clearColor];
    [matchHeader addSubview:hybridLabel];
    
	UILabel *teleOpLabel = [[UILabel alloc] initWithFrame:CGRectMake(260, 0, 200, 50)];
	teleOpLabel.text = @"TP";
    teleOpLabel.backgroundColor = [UIColor clearColor];
    [matchHeader addSubview:teleOpLabel];
    
	UILabel *autonAccLabel = [[UILabel alloc] initWithFrame:CGRectMake(331, 0, 200, 50)];
	autonAccLabel.text = @"Auton Accuracy";
    autonAccLabel.backgroundColor = [UIColor clearColor];
    [matchHeader addSubview:autonAccLabel];

	UILabel *teleOpAccLabel = [[UILabel alloc] initWithFrame:CGRectMake(485, 0, 200, 50)];
	teleOpAccLabel.text = @"TeleOp Accuracy";
    teleOpAccLabel.backgroundColor = [UIColor clearColor];
    [matchHeader addSubview:teleOpAccLabel];
    
    [self createSegments];
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated
{
    self.title = [NSString stringWithFormat:@"%d - %@", [team.number intValue], team.name];
    numberLabel.text = [NSString stringWithFormat:@"%d", [team.number intValue]];
    nameTextField.text = team.name;
    historyLabel.text = team.history;
    notesTextField.text = team.notes;
  //  driveTrainTextField.text = team.drivetrain;
    [self setSegments];
    NSString *path = [NSString stringWithFormat:@"Library/RobotPhotos/%@", [NSString stringWithFormat:@"%d", [team.number intValue]]];
    photoPath = [NSHomeDirectory() stringByAppendingPathComponent:path];
    [self getPhoto];
    dataChange = NO;
//    NSLog(@"Showing team = %@", team);
}

-(void)setSegments {
  /*  int value = [team.orientation intValue];
    orientation.selectedSegmentIndex = value;

    value = [team.brakes intValue];
    brakes.selectedSegmentIndex = value;

    value = [team.balance intValue];
    stinger.selectedSegmentIndex = value;

    value = [team.moding intValue];
    moding.selectedSegmentIndex = value;    */
}

-(void)getSelection:(id) sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSNumber *current;
    current = [NSNumber numberWithInt:segmentedControl.selectedSegmentIndex];

   /* if (segmentedControl == brakes) {
            team.brakes = current;
    }
    else if (segmentedControl == stinger) {
        team.balance = current;
    }
    else if (segmentedControl == moding) {
        team.moding = current;
    }
    else if (segmentedControl == orientation) {
        team.orientation = current;
    }
    dataChange = YES; */
}

-(void)createSegments {

    NSMutableArray *itemArray = [NSMutableArray arrayWithObjects: @"No", @"Yes", nil];
    brakes = [[UISegmentedControl alloc] initWithItems:itemArray];
    brakes.frame = CGRectMake(620, 305, 140, 44);
    [brakes addTarget:self action:@selector(getSelection:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:brakes];
    
    [itemArray replaceObjectAtIndex:0 withObject:@"None"];
    [itemArray replaceObjectAtIndex:1 withObject:@"Stinger"];
    [itemArray addObject:@"Other"];
    stinger = [[UISegmentedControl alloc] initWithItems:itemArray];
    stinger.frame = CGRectMake(396, 305, 210, 44);
    [stinger addTarget:self action:@selector(getSelection:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:stinger];

    [itemArray replaceObjectAtIndex:0 withObject:@"Long"];
    [itemArray replaceObjectAtIndex:1 withObject:@"Wide"];
    [itemArray replaceObjectAtIndex:2 withObject:@"Square"];
    [itemArray addObject:@"Other"];
    orientation = [[UISegmentedControl alloc] initWithItems:itemArray];
    orientation.frame = CGRectMake(436, 146, 280, 44);
    [orientation addTarget:self action:@selector(getSelection:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:orientation];

    [itemArray replaceObjectAtIndex:0 withObject:@"Rams"];
    [itemArray replaceObjectAtIndex:1 withObject:@"Slap"];
    [itemArray replaceObjectAtIndex:2 withObject:@"None"];
    moding = [[UISegmentedControl alloc] initWithItems:itemArray];
    moding.frame = CGRectMake(436, 393, 280, 44);
    [moding addTarget:self action:@selector(getSelection:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:moding];

}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    dataChange = YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
//    NSLog(@"team should end editing");
    if (textField == nameTextField) {
		team.name = nameTextField.text;
	}
	else if (textField == notesTextField) {
		team.notes = notesTextField.text;
	}
	/* else if (textField == driveTrainTextField) {
		team.drivetrain = driveTrainTextField.text;
	} */
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

-(IBAction) useCamera: (id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        //        imagePicker.mediaTypes = [NSArray arrayWithObjects:
        //                                  (NSString *) kUTTypeImage,
        //                                  nil];
        //        imagePicker.allowsEditing = NO;
        [self presentModalViewController:imagePicker
                                animated:YES];
        //        newMedia = YES;
    }
}

-(void)getPhoto {
    NSString  *jpgPath = [photoPath stringByAppendingPathComponent:@"/Test.jpg"];
    
    [imageView setImage:[UIImage imageWithContentsOfFile:jpgPath]];
}

- (IBAction) useCameraRoll: (id)sender
{
    if ([self.popoverController isPopoverVisible]) {
        [self.popoverController dismissPopoverAnimated:YES];
    } else {
        if ([UIImagePickerController isSourceTypeAvailable:
             UIImagePickerControllerSourceTypeSavedPhotosAlbum])
        {
            UIImagePickerController *imagePicker =
            [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.sourceType =
            UIImagePickerControllerSourceTypePhotoLibrary;
            //            imagePicker.mediaTypes = [NSArray arrayWithObjects:
            //                                      (NSString *) kUTTypeImage,
            //                                      nil];
            imagePicker.allowsEditing = NO;
            
            self.popoverController = [[UIPopoverController alloc]
                                      initWithContentViewController:imagePicker];
            
            popoverController.delegate = self;
            
            [popoverController presentPopoverFromRect:choosePhotoBtn.bounds inView:choosePhotoBtn 
                             permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            //            newMedia = NO;
        }
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo {
	imageView.image = img;
    [self savePhoto:img];
    [self.popoverController dismissPopoverAnimated:true];
    [picker dismissModalViewControllerAnimated:YES];
}

-(void)savePhoto: (UIImage *)image {
    // Check if robot directory exists, if not, create it  
    if (![[NSFileManager defaultManager] fileExistsAtPath:photoPath isDirectory:NO]) {
        if (![[NSFileManager defaultManager]createDirectoryAtPath:photoPath 
                                      withIntermediateDirectories: YES 
                                                       attributes: nil 
                                                            error: NULL]) {
            NSLog(@"Dreadful error creating directory to save photos");
            return;
        }
    }
    
    // Create paths to output images
    //    NSString  *imgName = [NSString stringWithFormat:@"%d", [team.number intValue], @"img001"];
    NSString  *pngPath = [photoPath stringByAppendingPathComponent:@"/Test.png"];
    NSString  *jpgPath = [photoPath stringByAppendingPathComponent:@"/Test.jpg"];
    
    // Write a UIImage to JPEG with minimum compression (best quality)
    // The value 'image' must be a UIImage object
    // The value '1.0' represents image compression quality as value from 0.0 to 1.0
    [UIImageJPEGRepresentation(image, 1.0) writeToFile:jpgPath atomically:YES];
    
    // Write image to PNG
    [UIImagePNGRepresentation(image) writeToFile:pngPath atomically:YES];
    
    // Let's check to see if files were successfully written...
    
    // Create file manager
    NSError *error;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    // Point to Document directory
    NSString *documentsDirectory = photoPath;
    
    // Write out the contents of home directory to console
//    NSLog(@"Library directory: %@", [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    return matchHeader;    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   /* int x = [team.matchScore count];
//    NSLog(@"Matchscore count = %d", x);
    return x; */
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
  /*  NSArray* objectsArray = [team.matchScore allObjects];
    TeamScore *score = [objectsArray objectAtIndex:indexPath.row];
    MatchData *match = [self getMatchData:score]; */
//    NSLog(@"Match Notes = %@", score.notes);
//    TeamData *info = [fetchedResultsController objectAtIndexPath:indexPath];
    // Configure the cell...
    // Set a background for the cell
//    UIImageView *tableBackground = [[UIImageView alloc] initWithFrame:cell.frame];
//    UIImage *image = [UIImage imageNamed:@"Blue Fade.gif"];
//    tableBackground.image = image;
//    cell.backgroundView = imageView;
    
	UILabel *matchNumber = (UILabel *)[cell viewWithTag:10];
//	matchNumber.text = [NSString stringWithFormat:@"%d", [match.number intValue]];
//	numberLabel.text = [NSString stringWithFormat:@"%d", [info.number intValue]];

    
	UILabel *typeLabel = (UILabel *)[cell viewWithTag:20];
  //  typeLabel.text = [match.matchType substringToIndex:4];

// int autonPoints = [score.autonScore.highBaskets intValue]*6 + [score.autonScore.midBaskets intValue]*5 + [score.autonScore.lowBaskets intValue]*4;
	UILabel *autonLabel = (UILabel *)[cell viewWithTag:30];
//	autonLabel.text = [NSString stringWithFormat:@"%d", autonPoints];

// int teleOpPoints = [score.teleOpScore.highBaskets intValue]*3 + [score.teleOpScore.midBaskets intValue]*2 + [score.teleOpScore.lowBaskets intValue];
	UILabel *teleOpLabel = (UILabel *)[cell viewWithTag:40];
//	teleOpLabel.text = [NSString stringWithFormat:@"%d", teleOpPoints];


/*    int basketsMade = [score.autonScore.highBaskets intValue] + [score.autonScore.midBaskets intValue] + [score.autonScore.lowBaskets intValue];
    int totalBaskets = basketsMade + [score.autonScore.missedBaskets intValue];
    int autonAccuracy;
    if (totalBaskets) autonAccuracy = 100 * basketsMade / (basketsMade + [score.autonScore.missedBaskets intValue]);
    else autonAccuracy = 0;
    UILabel *autonAccLabel = (UILabel *)[cell viewWithTag:50];
	autonAccLabel.text = [NSString stringWithFormat:@"%d%%", autonAccuracy];

    basketsMade = [score.teleOpScore.highBaskets intValue] + [score.teleOpScore.midBaskets intValue] + [score.teleOpScore.lowBaskets intValue];
    totalBaskets = basketsMade + [score.teleOpScore.missedBaskets intValue];
    int teleOpAccuracy;
    if (totalBaskets) teleOpAccuracy = 100 * basketsMade / (basketsMade + [score.teleOpScore.missedBaskets intValue]);
    else teleOpAccuracy = 0;
    
	UILabel *teleOpAccLabel = (UILabel *)[cell viewWithTag:60];
	teleOpAccLabel.text = [NSString stringWithFormat:@"%d%%", teleOpAccuracy]; */

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView 
                             dequeueReusableCellWithIdentifier:@"MatchSchedule"];
    // Set up the cell...
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

-(MatchData *)getMatchData: (TeamScore *) teamScore {
   /* if (teamScore.red1) return teamScore.red1;
    if (teamScore.red2) return teamScore.red2;
    if (teamScore.red3) return teamScore.red3;
    if (teamScore.blue1) return teamScore.blue1;
    if (teamScore.blue2) return teamScore.blue2;
    if (teamScore.blue3) return teamScore.blue3;
    
    return nil; */
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillDisappear:(BOOL)animated { // Called when the view is dismissed, covered or otherwise hidden. Default does nothing
    NSLog(@"view will disappear");
    if (dataChange) {
        team.saved = [NSNumber numberWithInt:1];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

-(void)SetTextBoxDefaults:(UITextField *)currentTextField {
    currentTextField.font = [UIFont fontWithName:@"Helvetica" size:24.0];
}

@end
