//
//  ProcessMsgPortCon.m
//  LogCipherTool
//
//  Created by yanjing on 12/8/14.
//  Copyright (c) 2014 com.baidu. All rights reserved.
//

#import "ProcessMsgPortCon.h"
#import "LogHelper.h"

@implementation ProcessMsgPortCon
static ProcessMsgPortCon * sharedMsgport = nil;

+ (ProcessMsgPortCon *) sharedInstance
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        if (sharedMsgport == nil) {
            sharedMsgport = [[ProcessMsgPortCon alloc] init];
        }
        
    });
    return sharedMsgport;
}

-(id)init{
    self = [super init];
    if (self) {
        self.lock = [[NSLock alloc] init];
        semaphore = dispatch_semaphore_create(1);
    }
    return self;
}

#pragma mark - send msg.

//-(NSString *)sendMessage:(id)msgInfo msgID:(int)msgid
//{
//    // 生成Remote port
//    CFMessagePortRef bRemote = CFMessagePortCreateRemote(kCFAllocatorDefault, CFSTR(MACH_PORT_REMOTE));
//    if (nil == bRemote) {
//        NSLog(@"bRemote create failed");
//        return nil;
//    }
//    
//    // 构建发送数据（string）
//    NSString  *msg = [NSString stringWithFormat:@"%@",msgInfo];
////    NSLog(@"send msg is :%@",msg);
//    const char *message = [msg UTF8String];
//    CFDataRef data,recvData = nil;
//    data = CFDataCreate(NULL, (UInt8 *)message, strlen(message));
//    
//    // 执行发送操作
//    CFMessagePortSendRequest(bRemote, msgid, data, 0, 100 , kCFRunLoopDefaultMode, &recvData);
//    if (nil == recvData) {
//        NSLog(@"recvData date is nil.");
//        CFRelease(data);
//        CFMessagePortInvalidate(bRemote);
//        CFRelease(bRemote);
//        return nil;
//    }
//    
//    // 解析返回数据
//    const UInt8  * recvedMsg = CFDataGetBytePtr(recvData);
//    if (nil == recvedMsg) {
//        NSLog(@"receive date err.");
//        CFRelease(data);
//        CFMessagePortInvalidate(bRemote);
//        CFRelease(bRemote);
//        return nil;
//    }
//    
//    NSString *strMsg = [NSString stringWithCString:(char *)recvedMsg encoding:NSUTF8StringEncoding];
//    
//    CFRelease(data);
//    CFMessagePortInvalidate(bRemote);
//    CFRelease(bRemote);
//    CFRelease(recvData);
//    
//    return strMsg;
//}


-(BOOL)sendMessage:(id)msgInfo msgID:(int)msgid{
    
    CFDataRef sendData;
    SInt32 messageID = msgid;// 0x1111; // Arbitrary
    CFTimeInterval recvtimeout =  0.0;
    CFTimeInterval sendtimeout = 0.0;
    //     CFDataRef recvData = nil;
    CFMessagePortRef remoteSendPort = CFMessagePortCreateRemote(kCFAllocatorDefault, CFSTR(MACH_PORT_REMOTE));
    
    if (remoteSendPort == nil) {
#ifdef DEBUG
        NSLog(@"remotePort  is :%@",remoteSendPort);
#endif
        
        return  NO;
    }
    
    // 构建发送数据（string）
    NSString  *msg = [NSString stringWithFormat:@"%@",msgInfo];
    //    NSLog(@"send msg is :%@",msg);
    const char *message = [msg UTF8String];
    sendData = CFDataCreate(NULL, (UInt8 *)message, strlen(message));
    SInt32 status = CFMessagePortSendRequest(remoteSendPort,
                                             messageID,
                                             sendData,
                                             sendtimeout,
                                             recvtimeout,
                                             NULL,//kCFRunLoopDefaultMode,
                                             NULL);//&recvData);
    CFMessagePortInvalidate(remoteSendPort);
    CFRelease(remoteSendPort);
    CFRelease(sendData);
    
    if (status == kCFMessagePortSuccess) {
#ifdef DEBUG
        NSLog(@"---- send ok -----" );
#endif
        return YES;
    }
    return NO;
}

#pragma mark - rev msg

CFDataRef onRecvMessageCallBack(CFMessagePortRef local,SInt32 msgid,CFDataRef cfData, void*info)
{
     NSString *strData = nil;
    if (cfData)
    {
       	const UInt8  * recvedMsg = CFDataGetBytePtr(cfData);
        strData = [NSString stringWithCString:(char *)recvedMsg encoding:NSUTF8StringEncoding];
        /**
         实现数据解析操作
         **/
        if (callBackData != NULL) {
            callBackData(strData,msgid, nil);
        }
     }
    
    //为了测试，生成返回数据
//    NSString *returnString = [NSString stringWithFormat:@"i have receive:%@",strData];
//    const char* cStr = [returnString UTF8String];
//    NSUInteger ulen = [returnString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
//    CFDataRef sgReturn = CFDataCreate(NULL, (UInt8 *)cStr, ulen);
//    
    return nil;
}


#pragma mark - rev listenner start

-(void)startListening
{
    //    [self.lock lock];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    if (0 != mMsgPortListenner && CFMessagePortIsValid(mMsgPortListenner))
    {
//        CFMessagePortInvalidate(mMsgPortListenner);
    }else {
        mMsgPortListenner = CFMessagePortCreateLocal(kCFAllocatorDefault,CFSTR(MACH_PORT_REMOTE),onRecvMessageCallBack, NULL, NULL);
        if(mMsgPortListenner == NULL){
            return ;
        }
        CFRunLoopSourceRef source = CFMessagePortCreateRunLoopSource(kCFAllocatorDefault, mMsgPortListenner, 0);
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopCommonModes);
        NSLog(@"start listenning");
    }
    
    //    [self.lock unlock];
    dispatch_semaphore_signal(semaphore);
}


#pragma mark - rev listenner end
- (void)endLisening
{
     dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    if (0 != mMsgPortListenner && CFMessagePortIsValid(mMsgPortListenner)){
 
        CFMessagePortInvalidate(mMsgPortListenner);
        CFRelease(mMsgPortListenner);
        NSLog(@"end listenning");
    }
    dispatch_semaphore_signal(semaphore);
  
}

static void Callback(CFNotificationCenterRef center,
                     void *observer,
                     CFStringRef name,
                     const void *object,
                     CFDictionaryRef userInfo)
{
 
    NSLog(@" ---%s",object);
}
-(void)startDisNotify{
    
    CFNotificationCenterRef distributedCenter = CFNotificationCenterGetDistributedCenter();
    CFNotificationSuspensionBehavior behavior =  CFNotificationSuspensionBehaviorDeliverImmediately;
    CFNotificationCenterAddObserver(distributedCenter,
                                    NULL,
                                    Callback,
                                    CFSTR(MACH_PORT_REMOTE),
                                    NULL,
                                    behavior);
}


- (void)addNotifyListening
{
    NSDistributedNotificationCenter *center = [NSDistributedNotificationCenter defaultCenter];
    
    if( center )
    {   [center removeObserver:self name:MACH_NOTIFY_NAME object:nil];
        [center addObserver:self
                   selector:@selector(handleNotification:)
                       name:MACH_NOTIFY_NAME
                     object:nil
         suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately];
    } // if
}

-(void)handleNotification:(id)notification{
     /**
     实现数据解析操作
     **/
    NSDictionary* user_info = [notification userInfo];
   int msgid = [[user_info valueForKey:@"msgId"] intValue];
    NSString * strData = [user_info valueForKey:@"msg"];

    if (callBackData != NULL) {
       callBackData(strData,msgid, nil);
    }
}
- (void)sentNotifyMessage:(NSString *)object
{
    NSDistributedNotificationCenter *center = [NSDistributedNotificationCenter defaultCenter];
    
    if( center )
    {
        [center postNotificationName:MACH_NOTIFY_NAME object:object userInfo:nil deliverImmediately:YES];
    } // if
}

- (void)removeNotifyListening{
    NSDistributedNotificationCenter *center = [NSDistributedNotificationCenter defaultCenter];
    if( center )
    {
        [center removeObserver:self name:MACH_NOTIFY_NAME object:nil];
    } // if
}


@end
