//
//  SpreadsheetViewController.m
//  RecycleRush
//
//  Created by FRC on 4/13/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import "SpreadsheetViewController.h"
#import "DataManager.h"
#import "MMGridCell.h"
#import "MMTopRowCell.h"
#import "MMLeftColumnCell.h"
#import "NSIndexPath+MMSpreadsheetView.h"

@interface SpreadsheetViewController ()
@property (nonatomic, strong) NSMutableSet *selectedGridCells;
@property (nonatomic, strong) NSMutableArray *tableData;
@property (nonatomic, strong) NSString *cellDataBuffer;

@end

@implementation SpreadsheetViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Create the spreadsheet in code.
    self.tableData = [_dataRows mutableCopy];

    self.selectedGridCells = [NSMutableSet set];
    MMSpreadsheetView *spreadSheetView = [[MMSpreadsheetView alloc] initWithNumberOfHeaderRows:1 numberOfHeaderColumns:1 frame:self.view.bounds];
    
    // Register your cell classes.
    [spreadSheetView registerCellClass:[MMGridCell class] forCellWithReuseIdentifier:@"GridCell"];
    [spreadSheetView registerCellClass:[MMTopRowCell class] forCellWithReuseIdentifier:@"TopRowCell"];
    [spreadSheetView registerCellClass:[MMLeftColumnCell class] forCellWithReuseIdentifier:@"LeftColumnCell"];
    
    // Set the delegate & datasource for the spreadsheet view.
    spreadSheetView.delegate = self;
    spreadSheetView.dataSource = self;
    
    // Add the spreadsheet view as a subview.
    [self.view addSubview:spreadSheetView];
}

- (NSInteger)numberOfRowsInSpreadsheetView:(MMSpreadsheetView *)spreadsheetView {
    NSInteger rows = [_dataRows count];
    return rows;
}

- (NSInteger)numberOfColumnsInSpreadsheetView:(MMSpreadsheetView *)spreadsheetView {
    NSArray *rowData = [self.tableData lastObject];
    if (rowData && [rowData count]) {
        return [rowData count];
    }
    else return 0;
}

#pragma mark - MMSpreadsheetViewDataSource

- (CGSize)spreadsheetView:(MMSpreadsheetView *)spreadsheetView sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat leftColumnWidth = 124.0f;
    CGFloat topRowHeight = 75.0f;
    CGFloat gridCellWidth = 220.0f;
    CGFloat gridCellHeight = 75.0f;
    
    // Upper left.
    if (indexPath.mmSpreadsheetRow == 0 && indexPath.mmSpreadsheetColumn == 0) {
        return CGSizeMake(leftColumnWidth, topRowHeight);
    }
    
    // Upper right.
    if (indexPath.mmSpreadsheetRow == 0 && indexPath.mmSpreadsheetColumn > 0) {
        return CGSizeMake(gridCellWidth, topRowHeight);
    }
    
    // Lower left.
    if (indexPath.mmSpreadsheetRow > 0 && indexPath.mmSpreadsheetColumn == 0) {
        return CGSizeMake(leftColumnWidth, gridCellHeight);
    }
    
    return CGSizeMake(gridCellWidth, gridCellHeight);
}

- (UICollectionViewCell *)spreadsheetView:(MMSpreadsheetView *)spreadsheetView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;
    if (indexPath.mmSpreadsheetRow == 0 && indexPath.mmSpreadsheetColumn == 0) {
        // Upper left.
        cell = [spreadsheetView dequeueReusableCellWithReuseIdentifier:@"GridCell" forIndexPath:indexPath];
        MMGridCell *gc = (MMGridCell *)cell;
        UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mm_logo"]];
        [gc.contentView addSubview:logo];
        logo.center = gc.contentView.center;
        gc.textLabel.numberOfLines = 0;
        cell.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    }
    else if (indexPath.mmSpreadsheetRow == 0 && indexPath.mmSpreadsheetColumn > 0) {
        // Upper right.
        cell = [spreadsheetView dequeueReusableCellWithReuseIdentifier:@"TopRowCell" forIndexPath:indexPath];
        MMTopRowCell *tr = (MMTopRowCell *)cell;
        NSArray *colData = [self.tableData objectAtIndex:indexPath.mmSpreadsheetRow];
        NSString *rowData = [colData objectAtIndex:indexPath.mmSpreadsheetColumn];
        tr.textLabel.text = rowData; //[NSString stringWithFormat:@"TR: %i", indexPath.mmSpreadsheetColumn];
        cell.backgroundColor = [UIColor whiteColor];
    }
    else if (indexPath.mmSpreadsheetRow > 0 && indexPath.mmSpreadsheetColumn == 0) {
        // Lower left.
        cell = [spreadsheetView dequeueReusableCellWithReuseIdentifier:@"LeftColumnCell" forIndexPath:indexPath];
        MMLeftColumnCell *lc = (MMLeftColumnCell *)cell;
        NSArray *colData = [self.tableData objectAtIndex:indexPath.mmSpreadsheetRow];
        NSString *rowData = [colData objectAtIndex:indexPath.mmSpreadsheetColumn];
        lc.textLabel.text = rowData;//[NSString stringWithFormat:@"Left Column: %i", indexPath.mmSpreadsheetRow];
        BOOL isDarker = indexPath.mmSpreadsheetRow % 2 == 0;
        if (isDarker) {
            cell.backgroundColor = [UIColor colorWithRed:222.0f / 255.0f green:243.0f / 255.0f blue:250.0f / 255.0f alpha:1.0f];
        } else {
            cell.backgroundColor = [UIColor colorWithRed:233.0f / 255.0f green:247.0f / 255.0f blue:252.0f / 255.0f alpha:1.0f];
        }
    }
    else {
        // Lower right.
        cell = [spreadsheetView dequeueReusableCellWithReuseIdentifier:@"GridCell" forIndexPath:indexPath];
        MMGridCell *gc = (MMGridCell *)cell;
        NSArray *colData = [self.tableData objectAtIndex:indexPath.mmSpreadsheetRow];
        NSString *rowData = [colData objectAtIndex:indexPath.mmSpreadsheetColumn];
        gc.textLabel.text = rowData;
        BOOL isDarker = indexPath.mmSpreadsheetRow % 2 == 0;
        if (isDarker) {
            cell.backgroundColor = [UIColor colorWithRed:242.0f / 255.0f green:242.0f / 255.0f blue:242.0f / 255.0f alpha:1.0f];
        } else {
            cell.backgroundColor = [UIColor colorWithRed:250.0f / 255.0f green:250.0f / 255.0f blue:250.0f / 255.0f alpha:1.0f];
        }
    }
    
    return cell;
}

#pragma mark - MMSpreadsheetViewDelegate

- (void)spreadsheetView:(MMSpreadsheetView *)spreadsheetView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.selectedGridCells containsObject:indexPath]) {
        [self.selectedGridCells removeObject:indexPath];
        [spreadsheetView deselectItemAtIndexPath:indexPath animated:YES];
    } else {
        [self.selectedGridCells removeAllObjects];
        [self.selectedGridCells addObject:indexPath];
    }
}

- (BOOL)spreadsheetView:(MMSpreadsheetView *)spreadsheetView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)spreadsheetView:(MMSpreadsheetView *)spreadsheetView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    
    /*
     These are the selectors the sender (a UIMenuController) sends by default.
     
     _insertImage:
     cut:
     copy:
     select:
     selectAll:
     paste:
     delete:
     _promptForReplace:
     _showTextStyleOptions:
     _define:
     _addShortcut:
     _accessibilitySpeak:
     _accessibilitySpeakLanguageSelection:
     _accessibilityPauseSpeaking:
     makeTextWritingDirectionRightToLeft:
     makeTextWritingDirectionLeftToRight:
     
     We're only interested in 3 of them at this point
     */
    if (action == @selector(cut:) ||
        action == @selector(copy:) ||
        action == @selector(paste:)) {
        return YES;
    }
    return NO;
}

- (void)spreadsheetView:(MMSpreadsheetView *)spreadsheetView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    NSMutableArray *rowData = [self.tableData objectAtIndex:indexPath.mmSpreadsheetRow];
    if (action == @selector(cut:)) {
        self.cellDataBuffer = [rowData objectAtIndex:indexPath.row];
        [rowData replaceObjectAtIndex:indexPath.row withObject:@""];
        [spreadsheetView reloadData];
    } else if (action == @selector(copy:)) {
        self.cellDataBuffer = [rowData objectAtIndex:indexPath.row];
    } else if (action == @selector(paste:)) {
        if (self.cellDataBuffer) {
            [rowData replaceObjectAtIndex:indexPath.row withObject:self.cellDataBuffer];
            [spreadsheetView reloadData];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
