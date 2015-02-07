//
//  TeamListViewController.m
// Robonauts Scouting
//
//  Created by Kris Pettinger on 6/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TeamListViewController.h"
#import "TeamDetailViewController.h"
#import "TeamUtilities.h"
#import "TeamData.h"
#import "DataManager.h"
#import "Competitions.h"
#import "FileIOMethods.h"
#import "CalculateTeamStats.h"

@implementation TeamListViewController {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    UIView *headerView;
    NSMutableDictionary *settingsDictionary;
    NSString *previousTournament;
    CalculateTeamStats *teamStats;
}

@synthesize dataManager = _dataManager;
@synthesize fetchedResultsController = _fetchedResultsController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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

- (void)viewDidLoad
{    
    NSError *error = nil;
    if (!_dataManager) {
        _dataManager = [[DataManager alloc] init];
    }
    
    prefs = [NSUserDefaults standardUserDefaults];
    tournamentName = [prefs objectForKey:@"tournament"];
    if (tournamentName) {
        self.title =  [NSString stringWithFormat:@"%@ Team List", tournamentName];
    }
    else {
        self.title = @"Team List";
    }
    
    [self loadSettings];
    teamStats = [[CalculateTeamStats alloc] init:_dataManager];

    if (![[self fetchedResultsController] performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         abort() causes the application to generate a crash log and terminate. 
         You should not use this function in a shipping application, 
         although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
                                     
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,768,50)];
    headerView.backgroundColor = [UIColor colorWithRed:(255/255.0) green:(199/255.0) blue:(000/255.0) alpha:(100.0/100.0)];
    headerView.opaque = YES;

	UILabel *teamLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 50)];
	teamLabel.text = @"Team";
    teamLabel.backgroundColor = [UIColor clearColor];
    [headerView addSubview:teamLabel];

	UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(155, 0, 200, 50)];
	label1.text = @"Drive Train";
    label1.backgroundColor = [UIColor clearColor];
    label1.adjustsFontSizeToFitWidth = NO;
    [headerView addSubview:label1];
    
 	UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(270, 0, 200, 50)];
	label2.text = @"Can Intake";
    label2.backgroundColor = [UIColor clearColor];
    [headerView addSubview:label2];
    
	UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(375, 0, 200, 50)];
	label3.text = @"Tote Intake";
    label3.backgroundColor = [UIColor clearColor];
    [headerView addSubview:label3];
    
	UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(490, 0, 200, 50)];
	label4.text = @"Lift Type";
    label4.backgroundColor = [UIColor clearColor];
    [headerView addSubview:label4];
    
    UILabel *label5 = [[UILabel alloc] initWithFrame:CGRectMake(570, 0, 200, 50)];
	label5.text = @"Max Tote Stack";
    label5.backgroundColor = [UIColor clearColor];
    [headerView addSubview:label5];
    
    UILabel *label6 = [[UILabel alloc] initWithFrame:CGRectMake(765, 0, 200, 50)];
	label6.text = @"Speed";
    label6.backgroundColor = [UIColor clearColor];
    [headerView addSubview:label6];
    
    UILabel *label7 = [[UILabel alloc] initWithFrame:CGRectMake(690, 0, 200, 50)];
	label7.text = @"Driver";
    label7.backgroundColor = [UIColor clearColor];
    [headerView addSubview:label7];

    UILabel *label8 = [[UILabel alloc] initWithFrame:CGRectMake(830, 0, 200, 50)];
	label8.text = @"Blacklisted";
    label8.backgroundColor = [UIColor clearColor];
    [headerView addSubview:label8];
    
    UILabel *label9 = [[UILabel alloc] initWithFrame:CGRectMake(920, 0, 200, 50)];
	label9.text = @"Wow Listed";
    label9.backgroundColor = [UIColor clearColor];
    [headerView addSubview:label9];

    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self saveSettings];
    [super viewWillDisappear:animated];
}

-(void)saveSettings {
    if (!settingsDictionary) {
        settingsDictionary = [[NSMutableDictionary alloc] init];
    }
    [settingsDictionary setObject:tournamentName forKey:@"Tournament"];

    NSString *plistPath = [[FileIOMethods applicationLibraryDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"Preferences/TeamListSettings.plist"]];
    NSError *error;
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:settingsDictionary format:NSPropertyListXMLFormat_v1_0 options:nil error:&error];
    if(data) {
        [data writeToFile:plistPath atomically:YES];
    }
    else {
        NSLog(@"An error has occured %@", error);
    }
}

-(void)loadSettings {
    NSString *plistPath = [[FileIOMethods applicationLibraryDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"Preferences/TeamListSettings.plist"]];
    settingsDictionary = [[FileIOMethods getDictionaryFromPListFile:plistPath] mutableCopy];
    if (settingsDictionary) previousTournament = [settingsDictionary valueForKey:@"Tournament"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)teamAdded:(NSNumber *)newTeamNumber forName:(NSString *) newTeamName {
    // NSLog(@"Team Added");
    // NSLog(@"Team = [%@]", newTeamNumber);
    if (!newTeamNumber || ([newTeamNumber intValue] == 0) ) {
        // NSLog(@"blank team data");
        UIAlertView *prompt  = [[UIAlertView alloc] initWithTitle:@"Team Add Alert"
                                                          message:@"You must have a non-zero team number"
                                                         delegate:nil
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
        [prompt setAlertViewStyle:UIAlertViewStyleDefault];
        [prompt show];
        return;
    }
    NSLog(@"Team list .... Add check for adding a team that alredy exists");
    TeamUtilities *teamUtilities = [[TeamUtilities alloc] init:_dataManager];
    NSError *error;
    if ([teamUtilities addTeam:newTeamNumber forName:newTeamName forTournament:tournamentName error:&error]) [_dataManager saveContext];
    else if (error) [_dataManager writeErrorMessage:error forType:[error code]];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"TeamDetail"]) {
        NSIndexPath *indexPath = [ self.tableView indexPathForCell:sender];
        [segue.destinationViewController setDataManager:_dataManager];
        [segue.destinationViewController setFetchedResultsController:_fetchedResultsController];
        [segue.destinationViewController setTeamIndex:indexPath];
    }
    if ([segue.identifier isEqualToString:@"Add"]) {
        // NSLog(@"add");
        UINavigationController *nv = (UINavigationController *)[segue destinationViewController];
        nv.navigationBar.translucent = NO;
        AddTeamViewController *addvc = (AddTeamViewController *)nv.topViewController;
        addvc.delegate = self;
    }
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    return headerView;    
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
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = 
    [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    TeamData *info = [_fetchedResultsController objectAtIndexPath:indexPath];
    // NSLog(@"name = %@", info.name);
    // Configure the cell...
    // Set a background for the cell
    //UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.frame];
    //UIImage *image = [UIImage imageNamed:@"Blue Fade.gif"];
    //imageView.image = image;
   // cell.backgroundView = imageView;
    NSMutableDictionary *stats = [teamStats calculateMasonStats:info forTournament:tournamentName];
    
	UILabel *numberLabel = (UILabel *)[cell viewWithTag:10];
	numberLabel.text = [NSString stringWithFormat:@"%d", [info.number intValue]];
    
    
	UILabel *label1 = (UILabel *)[cell viewWithTag:20];
    label1.text = info.driveTrainType;
	UILabel *label2 = (UILabel *)[cell viewWithTag:30];
	label2.text = info.canIntake;
	UILabel *label3 = (UILabel *)[cell viewWithTag:40];
	label3.text = info.toteIntake;
    UILabel *label4 = (UILabel *)[cell viewWithTag:50];
	label4.text = info.liftType;
    UILabel *label5 = (UILabel *)[cell viewWithTag:60];
    label5.text = info.toteMaxStack;
  
    
    UILabel *label6 = (UILabel *)[cell viewWithTag:80];
	label6.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"Speed"] objectForKey:@"average"] floatValue]];

    UILabel *label7 = (UILabel *)[cell viewWithTag:90];
	label7.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"DriverSkill"] objectForKey:@"average"] floatValue]];
    
    UILabel *label8 = (UILabel *) [cell viewWithTag:100];
    label8.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"BullySkill"] objectForKey:@"average"] floatValue]];
    
    UILabel *label9 = (UILabel *) [cell viewWithTag:110];
    label9.text = [NSString stringWithFormat:@"%.1f", [[[stats objectForKey:@"BlockSkill"] objectForKey:@"average"] floatValue]];
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:60];
    nameLabel.text = info.name;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView 
                             dequeueReusableCellWithIdentifier:@"TeamList"];
    // NSLog(@"IndexPath =%@", indexPath);
    // Set up the cell...
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIColor *lightBlueColor = [UIColor colorWithRed:(120/255.0) green:(175/255.0) blue:(255/255.0) alpha:(100.0/100.0)];
    cell.backgroundColor = lightBlueColor;
    // Xcode 4.6.3 compatibility issue
    //cell.accessoryView.tintColor = [UIColor blackColor];
    
}

#pragma mark -
#pragma mark Team List Management

- (NSFetchedResultsController *)fetchedResultsController {
    // Set up the fetched results controller if needed.
    if (_fetchedResultsController == nil) {
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"TeamData" inManagedObjectContext:_dataManager.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Edit the sort key as appropriate.
        NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:numberDescriptor, nil];
        // Add the search for tournament name
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"ANY tournaments.name = %@", tournamentName];
        [fetchRequest setPredicate:pred];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setFetchBatchSize:50];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".

        if (previousTournament && ![previousTournament isEqualToString:tournamentName]) {
            // NSLog(@"Clear Cache");
            [NSFetchedResultsController deleteCacheWithName:@"TeamList"];
        }
        NSFetchedResultsController *aFetchedResultsController =
        [[NSFetchedResultsController alloc] 
         initWithFetchRequest:fetchRequest 
         managedObjectContext:_dataManager.managedObjectContext
         sectionNameKeyPath:nil 
         cacheName:@"TeamList"];
        aFetchedResultsController.delegate = self;
        self.fetchedResultsController = aFetchedResultsController;
        
    }

	return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}


@end
