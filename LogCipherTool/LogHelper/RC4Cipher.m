//
//  RC4Cipher.m
//  LogCipherTool
//
//  Created by yanjing on 11/26/14.
//  Copyright (c) 2014 com.baidu. All rights reserved.
//

#import "RC4Cipher.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation RC4Cipher


+(NSString*)startRC4WithOrign:(NSString*)aInput key:(NSString*)aKey
{
    UniChar iS[256];
    UniChar iK[256];
    //NSMutableArray *iS = [[NSMutableArray alloc] initWithCapacity:256];
    //NSMutableArray *iK = [[NSMutableArray alloc] initWithCapacity:256];
    
    for (int i= 0; i<256; i++) {
        iS[i] = i;
        //[iS addObject:[NSNumber numberWithInt:i]];
    }
    
    int j=1;
    
    for (short i=0; i<256; i++) {
        
        UniChar c = [aKey characterAtIndex:i%aKey.length];
        iK[i] = c;
        //[iK addObject:[NSNumber numberWithChar:c]];
    }
    
    j=0;
    
    for (int i=0; i<255; i++) {
        //int is = [[iS objectAtIndex:i] intValue];
        int is = iS[i];
        //UniChar ik = (UniChar)[[iK objectAtIndex:i] charValue];
        UniChar ik = iK[i];
        j = (j + is + ik)%256;
        //NSNumber *temp = [iS objectAtIndex:i];
        UniChar temp = iS[i];
        iS[i] = iS[j];
        iS[j] = temp;
        //[iS replaceObjectAtIndex:i withObject:[iS objectAtIndex:j]];
        //[iS replaceObjectAtIndex:j withObject:temp];
        
    }
    
    int i=0;
    j=0;
    
    //NSString *result = aInput;
    //aInput很大的时候，有栈溢出风险
    unichar result[aInput.length];
    for (short x = 0; x<aInput.length; x++) {
        i = (i+1)%256;
        
        //int is = [[iS objectAtIndex:i] intValue];
        int is = iS[i];
        j = (j+is)%256;
        
        //int is_i = [[iS objectAtIndex:i] intValue];
        //int is_j = [[iS objectAtIndex:j] intValue];
        int is_i = iS[i];
        int is_j = iS[j];
        int t = (is_i+is_j) % 256;
        //int iY = [[iS objectAtIndex:t] intValue];
        int iY = iS[t];
        
        UniChar ch = (UniChar)[aInput characterAtIndex:x];
        UniChar ch_y = ch^iY;
        result[x] = ch_y;
        //result = [result stringByReplacingCharactersInRange:NSMakeRange(x, 1) withString:[NSString stringWithCharacters:&ch_y length:1]];
    }
    
    return [NSString stringWithCharacters:result length:aInput.length];
}

// 异或 加密 方法
+(NSString *)EnctyptOrDectyptOrign:(NSString*)aInput key:(NSString*)aKey{
    
    int keyLen = (int)aKey.length;
    
    if (keyLen == 0) {
        return aInput;
    }
    
    
    unichar result[aInput.length];
    int k = 0;
    for (short x = 0; x<aInput.length; x++,k++ ) {
        
        UniChar ch = (UniChar)[aInput characterAtIndex:x];
        //        unichar ak = [aKey characterAtIndex: (k & (keyLen - 1)) ];
        unichar ak = [aKey characterAtIndex: (k % keyLen)];
        UniChar ch_result = ch^ak;
        result[x] = ch_result;
    }
    
    return [NSString stringWithCharacters:result length:aInput.length];
    
}

+(NSString*)RC4EncryteWithOrign:(NSString*)aInput key:(NSString*)aKey{
    
    //     return [self startRC4WithOrign:aInput key:aKey];
    // 由于 rc4 加密后的数据，压缩效果不好。现在使用 异或 加密。为了不修改大量代码，这里只做简单地算法替换。
    return [self EnctyptOrDectyptOrign:aInput key:aKey];
}

+(NSString*)RC4DecryteWithOrign:(NSString*)aInput key:(NSString*)aKey{
    //  return  [self startRC4WithOrign:aInput key:aKey];
    // 由于 rc4 加密后的数据，压缩效果不好。现在使用 异或 加密。为了不修改大量代码，这里只做简单地算法替换。
    return [self EnctyptOrDectyptOrign:aInput key:aKey];
    
}

+(NSString*)RC4EncryteWithNSDataOrign:(NSData*)aInput key:(NSString*)aKey{
    NSString * inputStr = [[NSString alloc]initWithData:aInput encoding:NSUTF8StringEncoding];
    //    return [self startRC4WithOrign:inputStr key:aKey];
    // 由于 rc4 加密后的数据，压缩效果不好。现在使用 异或 加密。为了不修改大量代码，这里只做简单地算法替换。
    return [self EnctyptOrDectyptOrign:inputStr key:aKey];
    
}

+(NSString*)RC4DecryteWithNSDataOrign:(NSData*)aInput key:(NSString*)aKey{
    NSString * inputStr = [[NSString alloc]initWithData:aInput encoding:NSUTF8StringEncoding];
    //    return  [self startRC4WithOrign:inputStr key:aKey];
    // 由于 rc4 加密后的数据，压缩效果不好。现在使用 异或 加密。为了不修改大量代码，这里只做简单地算法替换。
    return [self EnctyptOrDectyptOrign:inputStr key:aKey];
}

+(NSString*)OldRC4DecryteWithNSDataOrign:(NSData*)aInput key:(NSString*)aKey{
    NSString * inputStr = [[NSString alloc]initWithData:aInput encoding:NSUTF8StringEncoding];
    return  [self startRC4WithOrign:inputStr key:aKey];
}


@end
