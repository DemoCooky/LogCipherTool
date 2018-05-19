//
//  AppDelegate.h
//  LogCipherTool
//
//  Created by yanjing on 11/26/14.
//  Copyright (c) 2014 com.baidu. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FMDatabase;

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property(nonatomic,strong)FMDatabase *db;


@end

