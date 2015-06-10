//
//  AppsWindowController.m
//  IPAUploader
//
//  Created by Francesca Corsini on 05/06/15.
//  Copyright (c) 2015 Francesca Corsini. All rights reserved.
//

#import "AppsWindowController.h"
#import "BITHockeyAppModel.h"

@interface AppsWindowController ()
{
	NSMutableArray *data;
}

@property (nonatomic, weak) IBOutlet NSTableView *table;

@end

@implementation AppsWindowController

#pragma mark - Init

- (void)windowWillLoad
{
    [super windowWillLoad];
}

- (void)loadWindow
{
    [super loadWindow];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
	
	data = @[].mutableCopy;
    [self.window setTitle:@"HockeyApp Apps"];
	
	// set NSSortDescriptor to the colums of the table
	for (NSTableColumn *tableColumn in self.table.tableColumns)
	{
		if ([tableColumn.identifier isEqualToString:@"Name"])
		{
			NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:tableColumn.identifier ascending:YES comparator:^(BITHockeyAppModel *p_1, BITHockeyAppModel *p_2) {
				NSString *n_1 = p_1.name;
				NSString *n_2 = p_2.name;
				return [n_1 compare: n_2];
			}];
			[tableColumn setSortDescriptorPrototype:sortDescriptor];
		}
		else if ([tableColumn.identifier isEqualToString:@"BundleID"])
		{
			NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:tableColumn.identifier ascending:YES comparator:^(BITHockeyAppModel *p_1, BITHockeyAppModel *p_2) {
				NSString *n_1 = p_1.bundleID;
				NSString *n_2 = p_2.bundleID;
				return [n_1 compare: n_2];
			}];
			[tableColumn setSortDescriptorPrototype:sortDescriptor];
		}
		else if ([tableColumn.identifier isEqualToString:@"CreationDate"])
		{
			NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:tableColumn.identifier ascending:YES comparator:^(BITHockeyAppModel *p_1, BITHockeyAppModel *p_2) {
				NSDate *n_1 = p_1.creationDate;
				NSDate *n_2 = p_2.creationDate;
				return [n_1 compare: n_2];
			}];
			[tableColumn setSortDescriptorPrototype:sortDescriptor];
		}
		else if ([tableColumn.identifier isEqualToString:@"EditDate"])
		{
			NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:tableColumn.identifier ascending:YES comparator:^(BITHockeyAppModel *p_1, BITHockeyAppModel *p_2) {
				NSDate *n_1 = p_1.editDate;
				NSDate *n_2 = p_2.editDate;
				return [n_1 compare: n_2];
			}];
			[tableColumn setSortDescriptorPrototype:sortDescriptor];
		}
	}
}

- (void)reloadApps:(NSArray*)_data
{
	[data removeAllObjects];
	data = _data.mutableCopy;
	[self.table reloadData];
}

#pragma mark - NSTableView

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
	BITHockeyAppModel *model = data[row];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"dd-MM-yyyy";
	
	if( [tableColumn.identifier isEqualToString:@"Name"] )
	{
		cellView.textField.stringValue = model.name;
		return cellView;
	}
	else if( [tableColumn.identifier isEqualToString:@"BundleID"] )
	{
		cellView.textField.stringValue = model.bundleID;
		return cellView;
	}
	else if ([tableColumn.identifier isEqualToString:@"CreationDate"])
	{
		cellView.textField.stringValue = [formatter stringFromDate:model.creationDate];
		return cellView;
	}
	else if ([tableColumn.identifier isEqualToString:@"EditDate"])
	{
		cellView.textField.stringValue = [formatter stringFromDate:model.editDate];
		return cellView;
	}
	return cellView;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [data count];
}

-(void)tableView:(NSTableView *)mtableView sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
	NSTableColumn *selectedColumnn = (NSTableColumn*)self.table.tableColumns[self.table.selectedColumn];
	NSSortDescriptor *sortDescriptorPrototype = selectedColumnn.sortDescriptorPrototype;
	data = [data sortedArrayUsingComparator:sortDescriptorPrototype.comparator].mutableCopy;
	[self.table reloadData];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
}




@end
