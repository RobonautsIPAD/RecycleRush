//
//  MatchIntegrityViewController.m
//  AerialAssist
//
//  Created by FRC on 3/26/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "MatchIntegrityViewController.h"
#import "DataManager.h"
#import "MatchData.h"
#import "TeamScore.h"
#import "TeamData.h"

@interface MatchIntegrityViewController ()

@end

@implementation MatchIntegrityViewController {
    NSUserDefaults *prefs;
    NSString *tournamentName;
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

	UILabel *numberLabel = (UILabel *)[cell viewWithTag:10];
	numberLabel.text = [NSString stringWithFormat:@"%d", [info.number intValue]];
    
	UILabel *matchTypeLabel = (UILabel *)[cell viewWithTag:20];
    matchTypeLabel.text = [info.matchType substringToIndex:4];
   
    int nScores = 0;
    NSArray *allScores = [info.score allObjects];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"alliance = %@", @"Blue 3"];
    NSArray *alliance = [allScores filteredArrayUsingPredicate:pred];

    UILabel *blue3Label = (UILabel *)[cell viewWithTag:80];
    if ([alliance count]) {
        TeamScore *score = [alliance objectAtIndex:0];
        if ([score.results boolValue]) {
            blue3Label.text = @"";
            nScores++;
        }
        else {
            blue3Label.text = [NSString stringWithFormat:@"%d", [score.team.number intValue]];
        }
    }
    else {
        blue3Label.text = @"No Team";
    }
    pred = [NSPredicate predicateWithFormat:@"alliance = %@", @"Blue 2"];
    alliance = [allScores filteredArrayUsingPredicate:pred];
    
    UILabel *blue2Label = (UILabel *)[cell viewWithTag:70];
    if ([alliance count]) {
        TeamScore *score = [alliance objectAtIndex:0];
        if ([score.results boolValue]) {
            blue2Label.text = @"";
            nScores++;
        }
        else {
            blue2Label.text = [NSString stringWithFormat:@"%d", [score.team.number intValue]];
        }
    }
    else {
        blue2Label.text = @"No Team";
    }
    pred = [NSPredicate predicateWithFormat:@"alliance = %@", @"Blue 1"];
    alliance = [allScores filteredArrayUsingPredicate:pred];
    
    UILabel *blue1Label = (UILabel *)[cell viewWithTag:60];
    if ([alliance count]) {
        TeamScore *score = [alliance objectAtIndex:0];
        if ([score.results boolValue]) {
            blue1Label.text = @"";
            nScores++;
        }
        else {
            blue1Label.text = [NSString stringWithFormat:@"%d", [score.team.number intValue]];
        }
    }
    else {
        blue1Label.text = @"No Team";
    }
    pred = [NSPredicate predicateWithFormat:@"alliance = %@", @"Red 3"];
    alliance = [allScores filteredArrayUsingPredicate:pred];
    
    UILabel *red3Label = (UILabel *)[cell viewWithTag:50];
    if ([alliance count]) {
        TeamScore *score = [alliance objectAtIndex:0];
        if ([score.results boolValue]) {
            red3Label.text = @"";
            nScores++;
        }
        else {
            red3Label.text = [NSString stringWithFormat:@"%d", [score.team.number intValue]];
        }
    }
    else {
        red3Label.text = @"No Team";
    }
    pred = [NSPredicate predicateWithFormat:@"alliance = %@", @"Red 2"];
    alliance = [allScores filteredArrayUsingPredicate:pred];
    
    UILabel *red2Label = (UILabel *)[cell viewWithTag:40];
    if ([alliance count]) {
        TeamScore *score = [alliance objectAtIndex:0];
        if ([score.results boolValue]) {
            red2Label.text = @"";
            nScores++;
        }
        else {
            red2Label.text = [NSString stringWithFormat:@"%d", [score.team.number intValue]];
        }
    }
    else {
        red2Label.text = @"No Team";
    }
    pred = [NSPredicate predicateWithFormat:@"alliance = %@", @"Red 1"];
    alliance = [allScores filteredArrayUsingPredicate:pred];
    
    UILabel *red1Label = (UILabel *)[cell viewWithTag:30];
    if ([alliance count]) {
        TeamScore *score = [alliance objectAtIndex:0];
        if ([score.results boolValue]) {
            red1Label.text = @"";
            nScores++;
        }
        else {
            red1Label.text = [NSString stringWithFormat:@"%d", [score.team.number intValue]];
        }
    }
    else {
        red1Label.text = @"No Team";
    }
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
        NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"matchTypeSection" ascending:YES];
        NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:typeDescriptor, numberDescriptor, nil];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        // Add the search for tournament name
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"tournamentName = %@", tournamentName];
        [fetchRequest setPredicate:pred];
        [fetchRequest setFetchBatchSize:20];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController =
        [[NSFetchedResultsController alloc]
         initWithFetchRequest:fetchRequest
         managedObjectContext:_dataManager.managedObjectContext
         sectionNameKeyPath:nil
         cacheName:@"Root"];
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
