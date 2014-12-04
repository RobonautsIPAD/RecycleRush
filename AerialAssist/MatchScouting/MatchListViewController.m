//
//  MatchListViewController.m
// Robonauts Scouting
//
//  Created by Kris Pettinger on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MatchListViewController.h"
#import "MatchDetailViewController.h"
#import "MatchData.h"
#import "MatchUtilities.h"
#import "TeamData.h"
#import "TeamScore.h"
#import "DataManager.h"
#import "FileIOMethods.h"
#import "TournamentData.h"
#import "EnumerationDictionary.h"

@implementation MatchListViewController {
    NSIndexPath *pushedIndexPath;
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSMutableDictionary *settingsDictionary;
    NSString *previousTournament;
    NSArray *teamList;
    NSDictionary *matchTypeDictionary;
    NSDictionary *allianceDictionary;
    UIView *headerView;
    NSFetchedResultsController *fetchedResultsController;
    MatchUtilities *matchUtilities;
}

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
        self.title =  [NSString stringWithFormat:@"%@ Match List", tournamentName];
    }
    else {
        self.title = @"Match List";
    }
    [self loadSettings];

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

    matchUtilities = [[MatchUtilities alloc] init:_dataManager];
    matchTypeDictionary = [EnumerationDictionary initializeBundledDictionary:@"MatchType"];
    allianceDictionary = [EnumerationDictionary initializeBundledDictionary:@"AllianceList"];
    
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,768,50)];
    headerView.backgroundColor = [UIColor lightGrayColor];
    headerView.opaque = YES;

 	UILabel *matchLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, 200, 50)];
	matchLabel.text = @"Match";
    matchLabel.backgroundColor = [UIColor clearColor];
    [headerView addSubview:matchLabel];

 	UILabel *matchTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(82, 0, 200, 50)];
	matchTypeLabel.text = @"Type";
    matchTypeLabel.backgroundColor = [UIColor clearColor];
    [headerView addSubview:matchTypeLabel];

 	UILabel *red1Label = [[UILabel alloc] initWithFrame:CGRectMake(145, 0, 200, 50)];
	red1Label.text = @"Red 1";
    red1Label.backgroundColor = [UIColor clearColor];
    [headerView addSubview:red1Label];

    UILabel *red2Label = [[UILabel alloc] initWithFrame:CGRectMake(211, 0, 200, 50)];
	red2Label.text = @"Red 2";
    red2Label.backgroundColor = [UIColor clearColor];
    [headerView addSubview:red2Label];

    UILabel *red3Label = [[UILabel alloc] initWithFrame:CGRectMake(281, 0, 200, 50)];
	red3Label.text = @"Red 3";
    red3Label.backgroundColor = [UIColor clearColor];
    [headerView addSubview:red3Label];

    UILabel *blue1Label = [[UILabel alloc] initWithFrame:CGRectMake(387, 0, 200, 50)];
	blue1Label.text = @"Blue 1";
    blue1Label.backgroundColor = [UIColor clearColor];
    [headerView addSubview:blue1Label];
    
    UILabel *blue2Label = [[UILabel alloc] initWithFrame:CGRectMake(461, 0, 200, 50)];
	blue2Label.text = @"Blue 2";
    blue2Label.backgroundColor = [UIColor clearColor];
    [headerView addSubview:blue2Label];
    
    UILabel *blue3Label = [[UILabel alloc] initWithFrame:CGRectMake(532, 0, 200, 50)];
	blue3Label.text = @"Blue 3";
    blue3Label.backgroundColor = [UIColor clearColor];
    [headerView addSubview:blue3Label];

    UILabel *redLabel = [[UILabel alloc] initWithFrame:CGRectMake(643, 0, 200, 50)];
	redLabel.text = @"Red";
    redLabel.backgroundColor = [UIColor clearColor];
    [headerView addSubview:redLabel];

    UILabel *blueLabel = [[UILabel alloc] initWithFrame:CGRectMake(711, 0, 200, 50)];
	blueLabel.text = @"Blue";
    blueLabel.backgroundColor = [UIColor clearColor];
    [headerView addSubview:blueLabel];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self saveSettings];
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

-(void)setTeamList:(MatchData *)match {
    NSSortDescriptor *allianceSort = [NSSortDescriptor sortDescriptorWithKey:@"allianceStation" ascending:YES];
    teamList = [[match.score allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:allianceSort]];
}

-(NSString *)getTeamNumber:(NSString *)allianceStation {
    if (!teamList || ![teamList count]) return @"";
    NSNumber *teamNumber = [matchUtilities getTeamFromList:teamList forAllianceStation:[EnumerationDictionary getValueFromKey:allianceStation forDictionary:allianceDictionary]];
    if (teamNumber) return [NSString stringWithFormat:@"%d", [teamNumber intValue]];
    else return @"";
}

-(void)loadSettings {
    NSString *plistPath = [[FileIOMethods applicationLibraryDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"Preferences/MatchListSettings.plist"]];
    settingsDictionary = [[FileIOMethods getDictionaryFromPListFile:plistPath] mutableCopy];
    if (settingsDictionary) previousTournament = [settingsDictionary valueForKey:@"Tournament"];
}

-(void)saveSettings {
    if (!settingsDictionary) {
        settingsDictionary = [[NSMutableDictionary alloc] init];
    }
    [settingsDictionary setObject:tournamentName forKey:@"Tournament"];
    
    NSString *plistPath = [[FileIOMethods applicationLibraryDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"Preferences/MatchListSettings.plist"]];
    NSError *error;
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:settingsDictionary format:NSPropertyListXMLFormat_v1_0 options:nil error:&error];
    if(data) {
        [data writeToFile:plistPath atomically:YES];
    }
    else {
        NSLog(@"An error has occured %@", error);
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MatchDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        pushedIndexPath = [self.tableView indexPathForCell:sender];
        [segue.destinationViewController setMatch:[fetchedResultsController objectAtIndexPath:indexPath]];
        [segue.destinationViewController setDelegate:self];
        [segue.destinationViewController setDataManager:_dataManager];
    }
    if ([segue.identifier isEqualToString:@"Add"]) {
        NSLog(@"add");
        UINavigationController *nv = (UINavigationController *)[segue destinationViewController];
        AddMatchViewController *addvc = (AddMatchViewController *)nv.topViewController;
        [addvc setDataManager:_dataManager];
        [addvc setTournamentName:tournamentName];
        [addvc setMatchTypeDictionary:matchTypeDictionary];
    }
 }

- (void)matchDetailReturned:(BOOL)dataChange {
    NSLog(@"is this needed");
    if (dataChange) {
        NSError *error;
        if (![_dataManager.managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        [self configureCell:[self.tableView cellForRowAtIndexPath:pushedIndexPath] atIndexPath:pushedIndexPath];
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
    NSInteger count = [[fetchedResultsController sections] count];
	if (count == 0) {
		count = 1;
	}
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = 
    [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSIndexPath *matchIndex = [NSIndexPath indexPathForRow:0 inSection:section];
    MatchData *matchData = [fetchedResultsController objectAtIndexPath:matchIndex];
    
    return [EnumerationDictionary getKeyFromValue:matchData.matchType forDictionary:matchTypeDictionary];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    MatchData *info = [fetchedResultsController objectAtIndexPath:indexPath];
    // Configure the cell...
    // Set a background for the cell
    //UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.frame];
    //UIImage *image = [UIImage imageNamed:@"Gold Fade.gif"];
    //imageView.image = image;
    //cell.backgroundView = imageView;
    [self setTeamList:info];
    
	UILabel *numberLabel = (UILabel *)[cell viewWithTag:10];
	numberLabel.text = [NSString stringWithFormat:@"%d", [info.number intValue]];
    
	UILabel *matchTypeLabel = (UILabel *)[cell viewWithTag:15];
    matchTypeLabel.text = [[EnumerationDictionary getKeyFromValue:info.matchType forDictionary:matchTypeDictionary] substringToIndex:4];

	UILabel *red1Label = (UILabel *)[cell viewWithTag:20];
    red1Label.text = [self getTeamNumber:@"Red 1"];

    UILabel *red2Label = (UILabel *)[cell viewWithTag:30];
    red2Label.text = [self getTeamNumber:@"Red 2"];

	UILabel *red3Label = (UILabel *)[cell viewWithTag:40];
    red3Label.text = [self getTeamNumber:@"Red 3"];

	UILabel *blue1Label = (UILabel *)[cell viewWithTag:50];
    blue1Label.text = [self getTeamNumber:@"Blue 1"];

	UILabel *blue2Label = (UILabel *)[cell viewWithTag:60];
    blue2Label.text = [self getTeamNumber:@"Blue 2"];

	UILabel *blue3Label = (UILabel *)[cell viewWithTag:70];
    blue3Label.text = [self getTeamNumber:@"Blue 3"];

	UILabel *redScoreLabel = (UILabel *)[cell viewWithTag:80];
    redScoreLabel.text = [NSString stringWithFormat:@"%d", [info.redScore intValue]];
    if ([info.redScore intValue] == -1) {
        redScoreLabel.text = @"";
    }
    else {
        redScoreLabel.text = [NSString stringWithFormat:@"%d", [info.redScore intValue]];
    }
    
	UILabel *blueScoreLabel = (UILabel *)[cell viewWithTag:90];
    blueScoreLabel.text = [NSString stringWithFormat:@"%d", [info.blueScore intValue]];
    if ([info.blueScore intValue] == -1) {
        blueScoreLabel.text = @"";
    }
    else {
        blueScoreLabel.text = [NSString stringWithFormat:@"%d", [info.blueScore intValue]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
	UITableViewCell *cell = [tableView 
                             dequeueReusableCellWithIdentifier:@"MatchList"];
    // Set up the cell...
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIColor *goldColor = [UIColor colorWithRed:(255.0/255.0) green:(190.0/255.0) blue:(0.0/255.0) alpha:(100.0/100.0)];
    cell.backgroundColor = goldColor;
    

}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

#pragma mark -
#pragma mark Match List Management

- (NSFetchedResultsController *)fetchedResultsController {
    // Set up the fetched results controller if needed.
    if (fetchedResultsController == nil) {
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"MatchData" inManagedObjectContext:_dataManager.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Edit the sort key as appropriate.
        NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"matchType" ascending:YES];
        NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:typeDescriptor, numberDescriptor, nil];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        // Add the search for tournament name
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"tournamentName = %@", tournamentName];
        [fetchRequest setPredicate:pred];
        [fetchRequest setFetchBatchSize:20];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        if (previousTournament && ![previousTournament isEqualToString:tournamentName]) {
            // NSLog(@"Clear Cache");
            [NSFetchedResultsController deleteCacheWithName:@"MatchList"];
        }

        NSFetchedResultsController *aFetchedResultsController =
        [[NSFetchedResultsController alloc] 
         initWithFetchRequest:fetchRequest 
         managedObjectContext:_dataManager.managedObjectContext
         sectionNameKeyPath:nil
         cacheName:@"MatchList"];
        aFetchedResultsController.delegate = self;
        fetchedResultsController = aFetchedResultsController;
    }
	return fetchedResultsController;
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
