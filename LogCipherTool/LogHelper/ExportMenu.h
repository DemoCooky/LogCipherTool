//
//  ExportMenu.h
//  LogCipherTool
//
//  Created by yanjing on 7/10/15.
//  Copyright (c) 2015 com.baidu. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(int, OpMenuCode)
{
    OpViewHtml,
    OpViewContext
};

@protocol ExportMenuDelegate <NSObject>

-(BOOL)IsMenuItemWillShow:(OpMenuCode)op;
-(void)onMenuItemClick:(OpMenuCode)op;

@end

@interface ExportMenu : NSMenu

- (instancetype)initWithDelegate:(id<ExportMenuDelegate>)delegate;

@end
