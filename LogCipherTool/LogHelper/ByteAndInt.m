//
//  ByteAndInt.m
//  LogCipherTool
//
//  Created by yanjing on 11/26/14.
//  Copyright (c) 2014 com.baidu. All rights reserved.
//

#import "ByteAndInt.h"

@implementation ByteAndInt

+(byte *)startInt:(int )iValue  ToByte:(byte *)bytes
{
//    int tp = sizeof(byte);
    int size = 4;
//    byte bytes[4];
    memset(bytes,0,sizeof(byte) * size);
    bytes[0] = (byte) (0xff & iValue);
    bytes[1] = (byte) ((0xff00 & iValue) >> 8);
    bytes[2] = (byte) ((0xff0000 & iValue) >> 16);
    bytes[3] = (byte) ((0xff000000 & iValue) >> 24);
    return bytes;
}

+(int)bytesToInt:(byte* )bytes
{
//    int size = 4;
    int addr = bytes[0] & 0xFF;
    addr |= ((bytes[1] << 8) & 0xFF00);
    addr |= ((bytes[2] << 16) & 0xFF0000);
    addr |= ((bytes[3] << 24) & 0xFF000000);
    return addr;
}
+(int)BytesToInt:(Byte* )bytes{
    NSData *data  = [[NSData alloc]initWithBytes:bytes length:sizeof(bytes)];
    int res;
    [data getBytes: &res length: sizeof(res)];
    return res;
}

+(byte *)IntToByte:(int)iValue
{
    NSData *data = [NSData dataWithBytes: &iValue length: sizeof(iValue)];
    return (Byte *)[data bytes];
}
@end
