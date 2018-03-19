//
//  UIDevice+Category.m
//  PXHelperDemo
//
//  Created by 侯佳男 on 2018/3/19.
//  Copyright © 2018年 侯佳男. All rights reserved.
//

#import "UIDevice+Category.h"
#include <sys/param.h>
#include <sys/mount.h>

@implementation UIDevice (Category)

+ (void)yy_deviceSize {
    //可用大小
    struct statfs buf;
    long long freespace = -1;
    if(statfs("/var", &buf) >= 0){
        freespace = (long long)(buf.f_bsize * buf.f_bfree);
    }
    //总大小
    struct statfs buf1;
    long long maxspace = 0;
    if (statfs("/", &buf1) >= 0) {
        maxspace = (long long)buf1.f_bsize * buf1.f_blocks;
    }
    if (statfs("/private/var", &buf1) >= 0) {
        maxspace += (long long)buf1.f_bsize * buf1.f_blocks;
    }
    NSString * sizeStr = [NSString stringWithFormat:@"可用空间%0.2fG / 总空间%0.2fG",(double)freespace/1024/1024/1024,(double)maxspace/1024/1024/1024];
    NSLog(@"sizeStr == %@", sizeStr);
    
}

@end
