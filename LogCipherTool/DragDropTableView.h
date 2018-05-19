/* DragDropTableView */

#import <Cocoa/Cocoa.h>

@interface DragDropTableView : NSTableView
{
}

@property (copy, nonatomic) void (^dragFilesBlock)(NSArray * fileList);

-(void)scrolltoEnd;

-(void)scrolltoSelectRow:(NSInteger)row;
@end
