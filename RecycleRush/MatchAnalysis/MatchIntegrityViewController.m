//
//  MatchIntegrityViewController.m
//  RecycleRush
//
//  Created by FRC on 3/26/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "MatchIntegrityViewController.h"
#import "DataManager.h"
#import "MatchData.h"
#import "TeamScore.h"
#import "TeamData.h"
#import "FileIOMethods.h"
#import "EnumerationDictionary.h"

@interface MatchIntegrityViewController ()

@end

@implementation MatchIntegrityViewController {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSMutableDictionary *settingsDictionary;
    NSString *previousTournament;
    NSDictionary *matchDictionary;
    NSDictionary *allianceDictionary;
    NSArray *scoreList;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    prefs = [NSUserDefaults standardUserDefaults];
    tournamentName = [prefs objectForKey:@"tournament"];
    if (tournamentName) {
        self.title =  [NSString stringWithFormat:@"%@ Match Integrity Page", tournamentName];
    }
    else {
        self.title = @"Match Integrity Page";
    }

    [self loadSettings];
    matchDictionary = [EnumerationDictionary initializeBundledDictionary:@"MatchType"];
    allianceDictionary = [EnumerationDictionary initializeBundledDictionary:@"AllianceList"];
/*    NSError *error1;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"TeamScore" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"tournamentName = %@ AND alliance = %@", tournamentName, @"Red 2"];
    [fetchRequest setPredicate:pred];
    
    NSArray *scoreData = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error1];
    
    for (TeamScore *score in scoreData) {
        NSLog(@"Match = %@, Team = %@, Results = %@", score.match.number, score.team.number, score.results);
    }
*/
    NSError *error = nil;
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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(NSString *)getTeamNumber:(NSString *)allianceStation {
    NSString *value = @"";
    if (!scoreList || ![scoreList count]) return value;
    NSNumber *alliance = [EnumerationDictionary getValueFromKey:allianceStation forDictionary:allianceDictionary];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"allianceStation = %@", alliance];
    NSArray *scoreData = [scoreList filteredArrayUsingPredicate:pred];
    if (scoreData && [scoreData count]) {
        TeamScore *score = [scoreData objectAtIndex:0];
        if (![score.results boolValue]) {
            value = [NSString stringWithFormat:@"%d", [score.teamNumber intValue]];
        }
    }
    else {
        value = @"No Team";
    }
    return value;
}

-(void)loadSettings {
    NSString *plistPath = [[FileIOMethods applicationLibraryDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"Preferences/MatchIntegritySettings.plist"]];
    settingsDictionary = [[FileIOMethods getDictionaryFromPListFile:plistPath] mutableCopy];
    if (settingsDictionary) previousTournament = [settingsDictionary valueForKey:@"Tournament"];
}

-(void)saveSettings {
    if (!settingsDictionary) {
        settingsDictionary = [[NSMutableDictionary alloc] init];
    }
    [settingsDictionary setObject:tournamentName forKey:@"Tournament"];
    
    NSString *plistPath = [[FileIOMethods applicationLibraryDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"Preferences/MatchIntegritySettings.plist"]];
    NSError *error;
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:settingsDictionary format:NSPropertyListXMLFormat_v1_0 options:nil error:&error];
    if(data) {
        [data writeToFile:plistPath atomically:YES];
    }
    else {
        NSLog(@"An error has occured %@", error);
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self saveSettings];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    NSInteger count = [[_fetchedResultsController sections] count];
	if (count == 0) {
		count = 1;
	}
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo =
    [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    MatchData *info = [_fetchedResultsController objectAtIndexPath:indexPath];
    //    red3Label.text = [self getTeamNumber:@"Red 3"];

	UILabel *numberLabel = (UILabel *)[cell viewWithTag:10];
	numberLabel.text = [NSString stringWithFormat:@"%d", [info.number intValue]];
    
	UILabel *matchTypeLabel = (UILabel *)[cell viewWithTag:20];
    matchTypeLabel.text = [[EnumerationDictionary getKeyFromValue:info.matchType forDictionary:matchDictionary] substringToIndex:4];
   
    int nScores = 0;

    scoreList = [info.score allObjects];
    UILabel *red1Label = (UILabel *)[cell viewWithTag:30];
    red1Label.text = [self getTeamNumber:@"Red 1"];
    if ([red1Label.text isEqualToString:@""]) nScores++;

    UILabel *red2Label = (UILabel *)[cell viewWithTag:40];
    red2Label.text = [self getTeamNumber:@"Red 2"];
    if ([red2Label.text isEqualToString:@""]) nScores++;
    
    UILabel *red3Label = (UILabel *)[cell viewWithTag:50];
    red3Label.text = [self getTeamNumber:@"Red 3"];
    if ([red3Label.text isEqualToString:@""]) nScores++;

    UILabel *blue1Label = (UILabel *)[cell viewWithTag:60];
    blue1Label.text = [self getTeamNumber:@"Blue 1"];
    if ([blue1Label.text isEqualToString:@""]) nScores++;
 
    UILabel *blue2Label = (UILabel *)[cell viewWithTag:70];
    blue2Label.text = [self getTeamNumber:@"Blue 2"];
    if ([blue2Label.text isEqualToString:@""]) nScores++;
 
    UILabel *blue3Label = (UILabel *)[cell viewWithTag:80];
    blue3Label.text = [self getTeamNumber:@"Blue 3"];
    if ([blue3Label.text isEqualToString:@""]) nScores++;
 
    if (nScores == 6) {
        red1Label.text = @"Complete";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure the cell...
 	UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:@"MatchList"];
    [self configureCell:cell atIndexPath:indexPath];
   
    return cell;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the managed object for the given index path
		[_dataManager.managedObjectContext deleteObject:[_fetchedResultsController objectAtIndexPath:indexPath]];
		
		// Save the context.
        NSError *error;
        if (![_dataManager.managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
}

#pragma mark -
#pragma mark Match List Management

- (NSFetchedResultsController *)fetchedResultsController {
    // Set up the fetched results controller if needed.
    if (_fetchedResultsController == nil) {
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
        if (previousTournament && ![previousTournament isEqualToString:tournamentName]) {
            // NSLog(@"Clear Cache");
            [NSFetchedResultsController deleteCacheWithName:@"MatchIntegrity"];
        }
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController =
        [[NSFetchedResultsController alloc]
         initWithFetchRequest:fetchRequest
         managedObjectContext:_dataManager.managedObjectContext
         sectionNameKeyPath:nil
         cacheName:@"MatchIntegrity"];
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
