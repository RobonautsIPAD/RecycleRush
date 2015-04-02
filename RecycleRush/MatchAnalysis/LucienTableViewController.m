//
//  LucienTableViewController.m
// Robonauts Scouting
//
//  Created by FRC on 7/13/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "LucienTableViewController.h"
#import "TeamDetailViewController.h"
#import "TeamData.h"
#import "TeamAccessors.h"
#import "DataManager.h"

@interface LucienTableViewController ()
@property (nonatomic, strong) UIView *headerView;

@end

@implementation LucienTableViewController {
    int numberOfColumns;
}

TeamData *currentteam;
@synthesize lucienNumbers = _lucienNumbers;
@synthesize headerView = _headerView;
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

- (void)viewDidLoad
{
    NSSortDescriptor *highestToLowest = [[NSSortDescriptor alloc] initWithKey:@"lucien" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:highestToLowest, nil];
    _lucienNumbers = [_lucienNumbers sortedArrayUsingDescriptors:sortDescriptors];
 
    
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,768,50)];
    _headerView.backgroundColor = [UIColor lightGrayColor];
    _headerView.opaque = YES;
    
	UILabel *teamLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 50)];
	teamLabel.text = @"Team";
    teamLabel.backgroundColor = [UIColor lightGrayColor];
    [_headerView addSubview:teamLabel];
    
	UILabel *teamnumber = [[UILabel alloc] initWithFrame:CGRectMake(150, 0, 200, 50)];
	teamnumber.text = @"Team #";
    teamnumber.backgroundColor = [UIColor lightGrayColor];
    [_headerView addSubview:teamnumber];
    
    UILabel *language = [[UILabel alloc] initWithFrame:CGRectMake(300, 0, 200, 50)];
	language.text = @"Language";
    language.backgroundColor = [UIColor lightGrayColor];
    [_headerView addSubview:language];
    
    UILabel *weight = [[UILabel alloc] initWithFrame:CGRectMake(400, 0, 200, 50)];
	weight.text = @"Weight";
    weight.backgroundColor = [UIColor lightGrayColor];
    [_headerView addSubview:weight];
    
    UILabel *length = [[UILabel alloc] initWithFrame:CGRectMake(500, 0, 200, 50)];
	length.text = @"Length";
    length.backgroundColor = [UIColor lightGrayColor];
    [_headerView addSubview:length];
    
    UILabel *width = [[UILabel alloc] initWithFrame:CGRectMake(600, 0, 200, 50)];
	width.text = @"Width";
    width.backgroundColor = [UIColor lightGrayColor];
    [_headerView addSubview:width];
    
    UILabel *highth = [[UILabel alloc] initWithFrame:CGRectMake(700, 0, 200, 50)];
	highth.text = @"Highth";
    highth.backgroundColor = [UIColor lightGrayColor];
    [_headerView addSubview:highth];

    
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Team"]) {
        NSIndexPath *indexPath = [ self.tableView indexPathForCell:sender];
        TeamDetailViewController *detailViewController = [segue destinationViewController];
        [segue.destinationViewController setDataManager:_dataManager];
        // NSLog(@"Team = %@", [_teamList objectAtIndex:indexPath.row]);
        NSDictionary *info = [_lucienNumbers objectAtIndex:indexPath.row];
        TeamData *team = [TeamAccessors getTeam:[info objectForKey:@"team"] fromDataManager:_dataManager];
        detailViewController.team = team;
       // [_teamInfo deselectRowAtIndexPath:indexPath animated:YES];
    
    }
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    return _headerView;
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
    NSDictionary *info = [_lucienNumbers objectAtIndex:indexPath.row];
    TeamData *_info = [_fetchedResultsController objectAtIndexPath:indexPath];
    // Configure the cell...
    // Set a background for the cell
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.frame];
//    UIImage *image = [UIImage imageNamed:@"Blue Fade.gif"];
//    imageView.image = image;
    
    UILabel *teamLabel = (UILabel *)[cell viewWithTag:10];
	teamLabel.text = [NSString stringWithFormat:@"%@", [info objectForKey:@"ProjectBane"]];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
 	UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:@"LucienList"];
    // NSLog(@"IndexPath =%@", indexPath);
    // Set up the cell...
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIColor *goldColor = [UIColor colorWithRed:(0.0/255.0) green:(100.0/255.0) blue:(255.0/255.0) alpha:(100.0/100.0)];
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
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}


- (NSFetchedResultsController *)fetchedResultsController {
    // Set up the fetched results controller if needed.
    if (_fetchedResultsController == nil) {
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"LucienNumberFields" inManagedObjectContext:_dataManager.managedObjectContext];
        [fetchRequest setEntity:entity];
    }
}

@end
