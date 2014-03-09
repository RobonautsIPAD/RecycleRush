//
//  LucienTableViewController.m
// Robonauts Scouting
//
//  Created by FRC on 7/13/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "LucienTableViewController.h"

@interface LucienTableViewController ()
@property (nonatomic, strong) UIView *headerView;

@end

@implementation LucienTableViewController {
    int numberOfColumns;
}
@synthesize lucienNumbers = _lucienNumbers;
@synthesize headerView = _headerView;

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
    
	UILabel *lucienNumber = [[UILabel alloc] initWithFrame:CGRectMake(110, 0, 200, 50)];
	lucienNumber.text = @"Lucien";
    lucienNumber.backgroundColor = [UIColor lightGrayColor];
    [_headerView addSubview:lucienNumber];

    NSArray *Xaxis = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:170],[NSNumber numberWithInt:260],[NSNumber numberWithInt:370], [NSNumber numberWithInt:460], [NSNumber numberWithInt:550], [NSNumber numberWithInt:660], [NSNumber numberWithInt:770], [NSNumber numberWithInt:880], nil];
    
    for (int i = 1; i<[_lucienSelections count]+1; i++) {
        NSDictionary *row = [_lucienSelections objectForKey:[NSString stringWithFormat:@"%d",i]];
        NSString *header = [row objectForKey:@"name"];
        UILabel *parameterHeader = [[UILabel alloc] initWithFrame:CGRectMake([[Xaxis objectAtIndex:i-1] floatValue], 0, 200, 50)];
        parameterHeader.text = header;
        parameterHeader.backgroundColor = [UIColor lightGrayColor];
        [_headerView addSubview:parameterHeader];
    }
    if (numberOfColumns >2) numberOfColumns -= 1;
    
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
    return [_lucienNumbers count];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *info = [_lucienNumbers objectAtIndex:indexPath.row];
    // Configure the cell...
    // Set a background for the cell
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.frame];
//    UIImage *image = [UIImage imageNamed:@"Blue Fade.gif"];
//    imageView.image = image;
    UILabel *teamLabel = (UILabel *)[cell viewWithTag:10];
	teamLabel.text = [NSString stringWithFormat:@"%@", [info objectForKey:@"team"]];

    UILabel *lucienLabel = (UILabel *)[cell viewWithTag:20];
	lucienLabel.text = [NSString stringWithFormat:@"%.1f", [[info objectForKey:@"lucien"] floatValue]];

    for (int i=1; i<=[_lucienSelections count]+1; i++) {
        UILabel *lucienLabel = (UILabel *)[cell viewWithTag:20+i*10];
        NSString *key = [NSString stringWithFormat:@"%d", i];
        NSNumber *value = [info objectForKey:key];
        if (value) {
            lucienLabel.text = [NSString stringWithFormat:@"%.1f", [[info objectForKey:key] floatValue]];
        }
        else {
            lucienLabel.text = @"";
        }
    }
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

@end
