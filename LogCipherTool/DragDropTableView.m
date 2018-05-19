#import "DragDropTableView.h"

@implementation DragDropTableView
- (void) awakeFromNib
{
	// Register to accept filename drag/drop
	[self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
 	if ([self dragFilesBlock] == nil)
	{
		return NSDragOperationNone;
	}
	
	if ([[[sender draggingPasteboard] types] containsObject:NSFilenamesPboardType])
	{
		return NSDragOperationCopy;
	}
	
	return NSDragOperationNone;
}

//// Work around a bug from 10.2 onwards
//- (unsigned int)draggingSourceOperationMaskForLocal:(BOOL)isLocal
//{
//	return NSDragOperationEvery;
//}

// Stop the NSTableView implementation getting in the way
- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
	return [self draggingEntered:sender];
}

-(BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender{
    return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	NSPasteboard *pboard;
	pboard = [sender draggingPasteboard];
	if ([[pboard types] containsObject:NSFilenamesPboardType])
	{
 		NSArray *filenames = [pboard propertyListForType:NSFilenamesPboardType];
        if (self.dragFilesBlock != nil) {
            self.dragFilesBlock(filenames);
        }
		return YES;
	}
	return NO;
}	


-(void)scrolltoEnd{
    NSInteger numberOfRows = [self numberOfRows];
    if (numberOfRows > 0)
        [self scrollRowToVisible:numberOfRows - 1];
}
-(void)scrolltoSelectRow:(NSInteger)row{
    NSInteger numberOfRows = [self numberOfRows];
    if (numberOfRows > row){
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:row];
        [self selectRowIndexes:indexSet byExtendingSelection:YES];
        NSInteger scrollRow =row+2<numberOfRows?row+2:numberOfRows-1;
        [self scrollRowToVisible:scrollRow];
    }
}
@end
