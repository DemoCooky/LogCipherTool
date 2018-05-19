//
//  ExportMenu.m
//  LogCipherTool
//
//  Created by yanjing on 7/10/15.
//  Copyright (c) 2015 com.baidu. All rights reserved.
//

#import "ExportMenu.h"
#import "HiLog.h"


@interface ExportMenu ()
@property(weak) id<ExportMenuDelegate> mdelegate;
@end

@implementation ExportMenu

- (instancetype)initWithDelegate:(id<ExportMenuDelegate>)delegate
{
    if (self = [super init]) {
        _mdelegate = delegate;
        {
            NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"网页形式查看" action:@selector(onMenuClick:) keyEquivalent:@""];
            item.tag = OpViewHtml;
            item.target = self;
            [self addItem:item];
        }
        
        {
            NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"查看上下文" action:@selector(onMenuClick:) keyEquivalent:@""];
            item.tag = OpViewContext;
            item.target = self;
            [self addItem:item];
        }
    }
    return self;
}

-(void)update
{
    [super update];
    if (self.mdelegate) {
        for (NSMenuItem *item in self.itemArray) {
            if (self.mdelegate) {
                BOOL result = [self.mdelegate IsMenuItemWillShow:item.tag];
                [item setHidden:!result];
            }
        }
    }
}

- (void)onMenuClick:(NSMenuItem *)sender
{
    NSLog(@"click: %ld", sender.tag);
    if (self.mdelegate) {
        [self.mdelegate onMenuItemClick:sender.tag];
    }
}

@end
