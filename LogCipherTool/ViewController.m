//
//  ViewController.m
//  LogCipherTool
//
//  Created by yanjing on 11/26/14.
//  Copyright (c) 2014 com.baidu. All rights reserved.
//

#import "ViewController.h"
#import "LogHelper.h"
#import "DatabaseHelper.h"
#import "LogHelper+Cipher.h"
#import "PopViewController.h"
#import "LogConViewController.h"
#import "HiLog.h"
#import "DragDropTableView.h"
#import "ProcessMsgPortCon.h"
#import "ExportMenu.h"
#import "LogCipherTool-Swift.h"

@implementation ViewController

-(void)awakeFromNib{
    if (!self.done) {
        [self initControls];
    }
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    // Update the view, if already loaded.
}

/*
 controls init ,and  data init
 */
-(void)initControls{
    self.lock = [[NSLock alloc]init];
    self.isloadOk = YES;
    self.isImLog = NO;
    self.isInSearchMode = NO;
    self.logList  = [NSArray array];
    self.logLevelItems = [[NSMutableArray alloc]initWithArray:@[@"NONE",@"DEBUG",@"ERROR",@"WARNING",@"INFO"]];
    [self.logLevelPopBtn addItemsWithTitles:self.logLevelItems];
    self.logCombobox.usesDataSource = YES;
    self.logCombobox.dataSource = self;
    self.logCombobox.delegate = self;
    [self.logCombobox selectItemAtIndex:2];
    self.popViewController = [[LogConViewController alloc]initWithNibName:@"LogConViewController" bundle:nil];
    
    queOutput = dispatch_queue_create("org.baidu.output", NULL);
    __weak typeof(self) weakSelf = self;
    
    self.done = YES;

    [self.logTableView setMenu:[[ExportMenu alloc]initWithDelegate:self]];
    [self.fileListTableView setMenu:[[ExportMenu alloc]initWithDelegate:self]];
    
    // 拖拽文件夹到列表
    self.fileListTableView.dragFilesBlock = ^(NSArray * fileList){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSURL *url = [NSURL URLWithString:fileList[0]];
        
        if ([[[url.absoluteString pathExtension] lowercaseString] isEqualTo:@"tar"]) {
            NSArray *filePathList = [HiLogProcessor processorAt:url];
            
            strongSelf.filePathList = filePathList;
            [((ViewController *)strongSelf).fileListTableView reloadData];
        }else {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"文件类型错误"];
            [alert setInformativeText:@"仅支持.tar 请选择正确的文件"];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert runModal];
        }
    };
    // 拖拽文件到列表
    self.logTableView.dragFilesBlock = ^(NSArray * fileList){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if(!fileList || [fileList count] <= 0){
            return;
        }
        strongSelf.isInSearchMode = NO;
        NSString * selectFile;
        if (fileList.count > 0) {
            selectFile = [fileList objectAtIndex:0];
        }
        
        if ([[[selectFile pathExtension]lowercaseString] isEqualTo:@"log"]) {
            
            [LogHelper readDataInPortEndListening];
            strongSelf.isImLog = NO;
            [strongSelf.imLogBtn setTitle:@"实时log"];
            [strongSelf tableViewRelaod:[NSMutableArray array] strongSelf:strongSelf];
            [strongSelf loadLogDataIFile:selectFile];
        }else{
            
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"文件类型错误"];
            [alert setInformativeText:@"请选择正确的文件"];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert runModal];
        }
    };
    
    //
    
    
}
-(void)cancel:(id)sender{
    if (!self.isloadOk) {
        [[DatabaseHelper sharedInstance]rollback];
        [[DatabaseHelper sharedInstance]closeDatabase];
    }
    
}
- (void)loadLogDataIFile:(NSString *)filePath{
    
    //    [self.refreshBtn setEnabled:NO];
    self.isloadOk = NO;
    NSProgressIndicator * indicator = [[NSProgressIndicator alloc]initWithFrame:NSMakeRect(0, 0, 40, 40)];
    [indicator setStyle:NSProgressIndicatorSpinningStyle];
    
    NSAlert *alert = [NSAlert alertWithMessageText:@""
                                     defaultButton:@"取消"
                                   alternateButton:nil
                                       otherButton:nil
                         informativeTextWithFormat:@"加载数据中..."];
    [alert setAlertStyle:NSInformationalAlertStyle];
    [alert setAccessoryView:indicator];
    [indicator startAnimation:nil];
    
    
//    [alert beginSheetModalForWindow:[self.view window] modalDelegate:self didEndSelector:@selector(cancel:) contextInfo:nil];
    [alert beginSheetModalForWindow:[self.logTableView window] completionHandler:^(NSModalResponse returnCode) {
        
    }];
    
    if (filePath == nil || filePath.length == 0){
        return;
    }else{
        if ([filePath hasPrefix:@"file://"]) {
            filePath = [filePath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        }
    }
    
    [self.filePathLabel setStringValue: filePath];
    
    [[DatabaseHelper sharedInstance]createLogTable];
    __weak typeof(self) weakSelf = self;
    [LogHelper readDataInFile:filePath block:^(id data) {
        
        self.isloadOk = YES;
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            [indicator stopAnimation:nil];
            [NSApp endSheet:[alert window]];
            
            if (strongSelf) {
                if(data) {
                    [strongSelf tableViewRelaod:data strongSelf: strongSelf];
                }else{
                    NSLog(@"loading failed...");
                }
            }
            
        });
        
    }];
    
}

- (void)reloadLogDataIFile:(NSString *)filePath{
    
    [self loadLogDataIFile:filePath];
}

#pragma mark - table delegate

- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView
{
    if (tableView == self.fileListTableView) {
        return self.filePathList.count;
    }else {
        return self.logList.count;
    }
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 40;
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSTableCellView *cellView = nil;
    NSString *identifer = [tableColumn identifier];
    
    if (tableView == self.logTableView) {
        
        //    NSLog(@" self.logList : %ld---- row %ld ",self.logList.count,(long)row);
        if (row >self.logList.count) {
            return  cellView;
        }
        HiLog * hiLog = [self.logList objectAtIndex:row];
        
        if ([identifer isEqualToString:@"logid"]) {
            cellView = [tableView makeViewWithIdentifier:@"logidrow" owner:self];
            cellView.textField.stringValue = [NSString stringWithFormat:@"%d",hiLog.ID]?[NSString stringWithFormat:@"%d",hiLog.ID]:@"null";
        } else  if ([identifer isEqualToString:@"logtime"]) {
            cellView = [tableView makeViewWithIdentifier:@"logtimerow" owner:self];
            cellView.textField.stringValue = hiLog.logTime ? hiLog.logTime :@"null";
        } else if ([identifer isEqualToString:@"loglevel"]) {
            cellView = [tableView makeViewWithIdentifier:@"loglevelrow" owner:self];
            cellView.textField.stringValue = hiLog.logLevel ? hiLog.logLevel :@"null";
        }  else if ([identifer isEqualToString:@"logtype"]) {
            cellView = [tableView makeViewWithIdentifier:@"logtyperow" owner:self];
            cellView.textField.stringValue = hiLog.logType ? hiLog.logType :@"null";
        } else if ([identifer isEqualToString:@"threadname"]) {
            cellView = [tableView makeViewWithIdentifier:@"threadnamerow" owner:self];
            cellView.textField.stringValue = hiLog.threadName ? hiLog.threadName :@"null";
        } else if ([identifer isEqualToString:@"logcontent"]) {
            cellView = [tableView makeViewWithIdentifier:@"logcontentrow" owner:self];
            cellView.textField.stringValue = hiLog.logContent ? hiLog.logContent :@"null";
        }
    }else {
        if (row >self.filePathList.count) {
            return  cellView;
        }
        if ([identifer isEqualToString:@"filelist"]) {
            cellView = [tableView makeViewWithIdentifier:@"filelistrow" owner:self];
            NSString *filePath = [self.filePathList objectAtIndex:row];
            NSString *fileName = [[NSURL fileURLWithPath:filePath] lastPathComponent];
            cellView.textField.stringValue = fileName.length>0 ? fileName :@"null";
        }
    }
    return cellView;

}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if (tableView == _logTableView) {
        id obj = (self.logList)[row];
        if (obj == nil)
            return nil;
        
        if (![obj isKindOfClass:[NSDictionary class]])
            return obj;
        
        id v = ((NSDictionary *) obj)[[tableColumn identifier]];
        if (v == [NSNull null]) return @"";
        return v;
    }
    return @"";
}

-(void)tableView:(NSTableView *)tableView mouseDownInHeaderOfTableColumn:(NSTableColumn *)tableColumn {
    
    
    // Do whatever else you need to do
}

///-(void)tableView:(NSTableView *)aTableView  willDisplayCell:(id)aCell  forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex{
//
//}
-(BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    if (tableView == self.logTableView) {
        if (self.logList.count > row) {
            NSDictionary * dic = [self.logList objectAtIndex:row];
            
            NSString * logTime =  [dic valueForKey:@"logTime"];
            NSString * logLevel = [dic valueForKey:@"logLevel"];
            NSString * logContent = [dic valueForKey:@"logContent"];
            NSString * logType = [dic valueForKey:@"logType"];
            NSString * threadName = [dic valueForKey:@"threadName"];
            
            [self createPopover:[NSString stringWithFormat:@"\n时间:%@ \n级别:%@ \n任务:%@ \n线程:%@ \n内容:%@\n",logTime,logLevel,logType,threadName,logContent]];
            NSRect rec = [tableView rectOfRow:row];
            [self.detailPopover showRelativeToRect:rec ofView:tableView preferredEdge:NSMinYEdge];
        }
    }else {
       if (self.filePathList.count > row) {
           NSString *filePath = [self.filePathList objectAtIndex:row];
           if ([[[filePath pathExtension] lowercaseString] isEqualTo:@"log"]) {
               
               [LogHelper readDataInPortEndListening];
               self.isImLog = NO;
               [self.imLogBtn setTitle:@"实时log"];
               [self tableViewRelaod:[NSMutableArray array] strongSelf:self];
               [self loadLogDataIFile:filePath];
               
           }else{
               
               NSAlert *alert = [[NSAlert alloc] init];
               [alert addButtonWithTitle:@"OK"];
               [alert setMessageText:@"文件类型错误"];
               [alert setInformativeText:@"请选择正确的文件"];
               [alert setAlertStyle:NSWarningAlertStyle];
               [alert runModal];
           }
       }
    }
    
    return YES;
}


#pragma mark -  btn methods
/*
 打开文件
 */
-(IBAction)openFile:(id)sender{
    
    [LogHelper readDataInPortEndListening];
    self.isImLog = NO;
    self.isInSearchMode = NO;
    [self.imLogBtn setTitle:@"实时log"];
    
    [self tableViewRelaod:[NSMutableArray array] strongSelf:self];
    
    NSOpenPanel *openFilePanel = [NSOpenPanel openPanel];
    [openFilePanel setMessage:@"Choose destination folder "];
    [openFilePanel setCanChooseDirectories:NO];
    [openFilePanel setResolvesAliases:YES];
    [openFilePanel setCanChooseFiles:YES];
    [openFilePanel setAllowsMultipleSelection:NO];
    [openFilePanel setCanCreateDirectories:YES];
    [openFilePanel setPrompt:@"Select"];
    [openFilePanel setDirectoryURL:[NSURL fileURLWithPath:[LogHelper getFileDirectory]
                                              isDirectory:YES]];
    __weak typeof(self) weakSelf = self;
    
    
    [openFilePanel beginSheetModalForWindow:self.logTableView.window completionHandler:^(NSInteger result) {
        __strong typeof(self) strongSelf = weakSelf;
        
        if (result == NSModalResponseOK) {
            for( NSURL* url in [openFilePanel URLs]){
                NSLog(@" %@ ",[url absoluteString]);
                NSString * selectFile = [[url absoluteString]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                
                if ([[[selectFile pathExtension]lowercaseString] isEqualTo:@"log"]) {
                    [strongSelf loadLogDataIFile:selectFile];
                }else{
                    NSAlert *alert = [[NSAlert alloc] init];
                    [alert addButtonWithTitle:@"OK"];
                    [alert setMessageText:@"文件类型错误"];
                    [alert setInformativeText:@"请选择正确的文件"];
                    [alert setAlertStyle:NSWarningAlertStyle];
                    [alert runModal];
                }
            }
        }
        
        
    }];
    
}

/*
 根据 logLevel 查询
 */
-(IBAction)immLogPress:(id)sender{
    self.isInSearchMode = NO;
    if (!self.isImLog) {
        self.isImLog = !self.isImLog;
        [self.imLogBtn setTitle:@"关闭实时"];
        [self tableViewRelaod:[NSMutableArray array] strongSelf:self];
        __weak typeof (self) weakSelf = self;
        [LogHelper readDataInPortWithBlock:^(id data) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (data) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf tableViewRelaod:data strongSelf: strongSelf];
                });
            }
            
        }];
    }else{
        self.isImLog = !self.isImLog;
        [LogHelper readDataInPortEndListening];
        [self.imLogBtn setTitle:@"实时log"];
        
    }
    
}
-(void)tableViewRelaod:(id)data strongSelf:(id)strongSelf{
    ((ViewController *)strongSelf).logList = [data copy];
    [((ViewController *)strongSelf).logTableView reloadData];
    [((ViewController *)strongSelf).logTableView scrolltoEnd];
    ((ViewController *)strongSelf).logCountlabel.stringValue = [NSString stringWithFormat:@"总计：%lu 条", self.logList.count];
}

-(void)tableViewRelaod:(id)data strongSelf:(id)strongSelf
             selectRow:(NSInteger)row{
    ((ViewController *)strongSelf).logList = [data copy];
    [((ViewController *)strongSelf).logTableView reloadData];
    [((ViewController *)strongSelf).logTableView scrolltoSelectRow:row];
    ((ViewController *)strongSelf).logCountlabel.stringValue = [NSString stringWithFormat:@"总计：%lu 条", self.logList.count];
}

-(IBAction)popBtnPress:(id)sender{
    self.isInSearchMode = NO;
    NSInteger index = [self.logLevelPopBtn indexOfSelectedItem];
    NSString * item = [self.logLevelItems objectAtIndex:index];
    [self.logLevelPopBtn setTitle:item];
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        if ([item isEqualToString:@"NONE"]) {
            
            [[DatabaseHelper sharedInstance]queryLog:^(id data) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                
                if (data) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [strongSelf tableViewRelaod:data strongSelf: strongSelf];
                        
                    });
                }
                
            }];
        }else{
            [[DatabaseHelper sharedInstance]queryLogWithLogLevel:item callback:^(id data) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                
                if (data) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [strongSelf tableViewRelaod:data strongSelf: strongSelf];
                    });
                }
            }];
            
        }
        
    });
    
}

/*
 模糊查询
 */
-(IBAction)fuzzyBtnPress:(id)sender{
    
    NSString * keyword = self.fuzzyFeild.stringValue;
    
    __weak typeof (self) weakSelf = self;
    if ( keyword.length>0) {
        [[DatabaseHelper sharedInstance]queryInFuzzy:keyword  callback:^(id data) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            if (data) {
                self.isInSearchMode = YES;
                [strongSelf tableViewRelaod:data strongSelf: strongSelf];
            }
            
        }];
    }else{
        
    }
}


/*
 撤销 查询，回到第一次打开文件时的状态
 */
-(IBAction)goBackBtnPress:(id)sender{
    self.isInSearchMode = NO;
    __weak typeof (self) weakSelf = self;
    [[DatabaseHelper sharedInstance]queryLog:^(id data) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (data) {
            [strongSelf tableViewRelaod:data strongSelf: strongSelf];
        }
    }];
}
/*
 刷新，得到最新的文件的数据
 */
-(IBAction)refreshBtnPress:(id)sender{
    
    if (!self.isImLog) {
        self.isInSearchMode = NO;
        NSString * selectFile = self.filePathLabel.stringValue;
        if (selectFile.length == 0) {
            __weak typeof (self) weakSelf = self;
            [[DatabaseHelper sharedInstance]queryLog:^(id data) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (data) {
                    [strongSelf tableViewRelaod:data strongSelf: strongSelf];
                }
            }];
            return;
        }
        
        if ([[[selectFile pathExtension]lowercaseString] isEqualTo:@"log"]) {
            
            [LogHelper readDataInPortEndListening];
            self.isImLog = NO;
            [self.imLogBtn setTitle:@"实时log"];
            [self tableViewRelaod:[NSMutableArray array] strongSelf:self];
            [self reloadLogDataIFile:selectFile];
        }else{
            
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"文件类型错误"];
            [alert setInformativeText:@"请选择正确的文件"];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert runModal];
        }
    }else{
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"提示"];
        [alert setInformativeText:@"请关闭实时log，再操作！"];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
        
    }
    
    
}


/*
 刷新，得到最新的文件的数据
 */
-(IBAction)outputLogFile:(id)sender{
    
    if (self.logList.count <= 0) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"错误"];
        [alert setInformativeText:@"列表中无数据！"];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
        
        return;
    }
    
    
    NSSavePanel * panel = [NSSavePanel savePanel];
    [panel setNameFieldStringValue:@"Untitle.log"];
    [panel setMessage:@"Choose the path to save the document"];
    [panel setAllowsOtherFileTypes:YES];
    [panel setAllowedFileTypes:@[@"log"]];
    [panel setExtensionHidden:NO];
    [panel setCanCreateDirectories:YES];
    
    __weak typeof(self) weakSelf = self;
    
    [panel beginSheetModalForWindow:self.logTableView.window completionHandler:^(NSInteger result){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (result == NSFileHandlingPanelOKButton)
        {
            NSString *path = [[panel URL] path];
            dispatch_sync(queOutput, ^{
                if ([LogHelper prepareLogFileToWrite:path]) {
                    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:path];
                    
                    for (int  index = 0 ; index < strongSelf.logList.count; index++) {
                        HiLog * hiLog = [strongSelf.logList objectAtIndex:index];
                        NSString * logMsg = [NSString stringWithFormat:@"[%@:%@][%@][%@] %@\n",
                                             hiLog.logType,
                                             hiLog.threadName,
                                             hiLog.logTime,
                                             hiLog.logLevel,
                                             hiLog.logContent];
                        NSData * data = [logMsg dataUsingEncoding:NSUTF8StringEncoding];
                        //                        [LogHelper appendToFileWithData:data inFile:path];
                        [handle truncateFileAtOffset:[handle seekToEndOfFile]];
                        [handle writeData:data];
                        float finishNum = index;
                        float outpValue = 100 * (finishNum / (strongSelf.logList.count-1));
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [strongSelf.outputLabel setStringValue:[NSString stringWithFormat:@"文件已经导出 %.02f%%",  outpValue]];
                        });
                        
                    }
                    [handle closeFile];
                    
                }else {
                    NSAlert *alert = [[NSAlert alloc] init];
                    [alert addButtonWithTitle:@"OK"];
                    [alert setMessageText:@"错误"];
                    [alert setInformativeText:@"不能覆盖原有文件！"];
                    [alert setAlertStyle:NSWarningAlertStyle];
                    [alert runModal];
                    
                }
                
            });
        }
    }];
    
}
#pragma mark - Popover
/*
 创建 Popover
 */
- (void)createPopover:(NSString *)logText
{
    //
    //    self.logContent = logText;
    //    [self setlogText:logText];
    [self.logContentView setString:logText];
    
    NSRange range;
    range.location = [self.logContentView.string length] - 1;
    range.length = 0;
    [self.logContentView scrollRangeToVisible:range];
    
    
    //    if (self.popViewController == nil) {
    //        self.popViewController = [[LogConViewController alloc]initWithNibName:@"LogConViewController" bundle:nil];
    //    }
    //    self.popViewController.logContent = logText;
    //    [self.popViewController setlogText:logText];
    //    if (self.detailPopover == nil)
    //    {
    //        self.detailPopover = [[NSPopover alloc]init];
    //        self.detailPopover.contentViewController = self.popViewController;
    //        //self.detailPopover.appearance = NSPopoverAppearanceMinimal;
    //        self.detailPopover.animates = YES;
    //        self.detailPopover.behavior = NSPopoverBehaviorTransient;
    //        self.detailPopover.delegate = self;
    //    }
    
}

#pragma mark - ExportMenu Delegate

-(BOOL)IsMenuItemWillShow:(OpMenuCode)op
{
    if (OpViewContext==op) {
        if (self.isInSearchMode) {
            return YES;
        }
        return NO;
    }
    return YES;
}
-(void)onMenuItemClick:(OpMenuCode)op
{
    if (op==OpViewHtml) {
        [self onViewInHtmlClick];
    }
    else if (op==OpViewContext) {
        [self onViewContextClick];
    }
}

-(void)onViewContextClick
{
    NSInteger row = self.logTableView.clickedRow;
    HiLog * hiLog = [self.logList objectAtIndex:row];
    self.isInSearchMode = NO;
    __weak typeof (self) weakSelf = self;
    [[DatabaseHelper sharedInstance]queryLog:^(id data) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (data) {
            [strongSelf tableViewRelaod:data strongSelf: strongSelf selectRow:hiLog.ID-1];
        }
    }];
}

- (void)onViewInHtmlClick
{
    NSString *data = [self genHtml];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd-HHmmss"];
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",[dateFormatter stringFromDate:[NSDate date]],@"export.html"]];
    [data writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:path]];
}


- (NSString *)genHtml
{
    NSMutableString *data = [NSMutableString string];
    NSArray *cols = self.logTableView.tableColumns;
    NSInteger rowCount = self.logTableView.numberOfRows;
    //[data appendString:@"\357\273\277"];
    [data appendFormat:@"<!DOCTYPE HTML>\
     <html>\
     <head>\
     <meta http-equiv='Content-Type' content='text/html; charset=utf-8'/>\
     <script src='http://libs.baidu.com/jquery/2.0.0/jquery.min.js'></script>\
     <script src='http://cdn.datatables.net/1.10.7/js/jquery.dataTables.min.js'></script>\
     <script>\
     $(document).ready(function () {\
     $('#resultTb').dataTable({\
     'paging': false,\
     'info': false\
     });\
     });\
     </script>\
     <link href='http://cdn.datatables.net/1.10.7/css/jquery.dataTables.css' rel='stylesheet'>\
     <style type='text/css'>\
     td {\
     max-width: 400px;\
     word-wrap:break-word;\
     }\
     </style>\
     </head>\
     <body><h1>%@</h1>\
     <div>\
     <table id='resultTb' class='display cell-border' cellspacing='0' width=100%%> \
     <thead>\
     <tr>\
     ", self.logTableView.window.title];
    for (NSTableColumn *col in cols) {
        [data appendFormat:@"<th>%@</th>", [self stringByEncodingXMLEntities:[col.headerCell title]]];
    }
    [data appendString:@"</tr></thead><tbody>"];
    for (int i = 0; i < rowCount; i++) {
        [data appendString:@"<tr>"];
        for (NSTableColumn *col in cols) {
            HiLog * cell = [self.logTableView.dataSource tableView:self.logTableView objectValueForTableColumn:col row:i];
            
            NSString * tmp ;
            if ([col.identifier isEqualToString:@"logid"]) {
                tmp = [NSString stringWithFormat:@"%d",cell.ID] ;
                
            }else if ([col.identifier isEqualToString:@"logtime"]){
                tmp = [NSString stringWithFormat:@"%@",cell.logTime] ;
                
            }else if ([col.identifier isEqualToString:@"threadname"]){
                tmp = [NSString stringWithFormat:@"%@",cell.threadName] ;
                
            }else if ([col.identifier isEqualToString: @"logtype"]){
                tmp = [NSString stringWithFormat:@"%@",cell.logType] ;
                
            }else if ([col.identifier isEqualToString:@"logcontent"]){
                tmp = [NSString stringWithFormat:@"%@",cell.logContent] ;
                
            }else if ([col.identifier isEqualToString:@"loglevel"]){
                tmp = [NSString stringWithFormat:@"%@",cell.logLevel] ;
            }
            [data appendFormat:@"<td>%@</td>", [self stringByEncodingXMLEntities:tmp]];
            
        }
        [data appendString:@"</tr>"];
    }
    [data appendString:@"</tbody></table></div></body></html>"];
    return [data copy];
}

- (NSString *)stringByEncodingXMLEntities:(NSString *)str
{
    if (nil == str || str.length == 0)
        return @"";
    NSMutableString *result = [NSMutableString stringWithString:str];
    [result replaceOccurrencesOfString:@"&" withString:@"&amp;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"'" withString:@"&apos;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"<" withString:@"&lt;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@">" withString:@"&gt;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
    return result;
}

@end
