//
//  PhoneMatchListViewController.m
//  RecycleRush
//
//  Created by FRC on 2/25/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import "PhoneMatchListViewController.h"
#import "DataManager.h"
#import "FileIOMethods.h"
#import "MatchData.h"
#import "MatchAccessors.h"

@interface PhoneMatchListViewController ()

@end

@implementation PhoneMatchListViewController {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSMutableDictionary *settingsDictionary;
    NSString *previousTournament;
    NSFetchedResultsController *fetchedResultsController;
    NSDictionary *matchTypeDictionary;
    NSDictionary *allianceDictionary;
    NSNumberFormatter *formatter;
    NSNumberFormatter *matchNumberFormatter;
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
        self.title =  [NSString stringWithFormat:@"%@ Match List", tournamentName];
    }
    else {
        self.title = @"Match List";
    }
    [self loadSettings];
    
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
    
    matchTypeDictionary = _dataManager.matchTypeDictionary;
    allianceDictionary = _dataManager.allianceDictionary;
    
    formatter = [[ NSNumberFormatter alloc] init];
    [formatter setFormatWidth:7];
    [formatter setPaddingCharacter:@" "];
    matchNumberFormatter = [[ NSNumberFormatter alloc] init];
    [matchNumberFormatter setFormatWidth:4];
    [matchNumberFormatter setPaddingCharacter:@" "];
//    [formatter setFormatterBehavior:NSNumberFormatterDecimalStyle];
//    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
//    [formatter setMinimumFractionDigits:2];
//    [formatter setMaximumFractionDigits:2];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = [[fetchedResultsController sections] count];
	if (count == 0) {
		count = 1;
	}
    return count;}

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
    return [MatchAccessors getMatchTypeString:matchData.matchType fromDictionary:matchTypeDictionary];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MatchData *info = [fetchedResultsController objectAtIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MatchList" forIndexPath:indexPath];
    NSDictionary *scoreList = [MatchAccessors buildTeamList:info forAllianceDictionary:allianceDictionary];
    NSLog(@"Red 1 = %@", [scoreList objectForKey:@"Red 1"]);
    NSString *matchLabel = [NSString stringWithFormat:@"%@%@%@%@%@%@%@", [matchNumberFormatter stringFromNumber:info.number], [formatter stringFromNumber:[scoreList objectForKey:@"Red 1"]], [formatter stringFromNumber:[scoreList objectForKey:@"Red 2"]], [formatter stringFromNumber:[scoreList objectForKey:@"Red 3"]], [formatter stringFromNumber:[scoreList objectForKey:@"Blue 1"]], [formatter stringFromNumber:[scoreList objectForKey:@"Blue 2"]], [formatter stringFromNumber:[scoreList objectForKey:@"Blue 3"]]];
    cell.textLabel.text = matchLabel;
    cell.textLabel.font = [UIFont fontWithName: @"Courier" size:10];
    
    return cell;
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
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
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
         sectionNameKeyPath:@"matchType"
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
     //       [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
