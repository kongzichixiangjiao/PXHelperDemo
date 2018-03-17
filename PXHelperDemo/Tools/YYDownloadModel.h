//
//  YYDownloadModel.h
//  PXHelperDemo
//
//  Created by 侯佳男 on 2018/3/15.
//  Copyright © 2018年 侯佳男. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    YYDownloadStatePrepare,
    YYDownloadStateStart,
    YYDownloadStateIng,
    YYDownloadStatePause,
    YYDownloadStateFinished,
    YYDownloadStateError,
    YYDownloadStateDefault,
} YYDownloadType;

@interface YYDownloadModel : NSObject

@property(nonatomic, strong)NSString *taskDescription;
@property (nonatomic, strong)NSURLSessionDownloadTask *task;
@property(nonatomic, strong)NSData *resumeData;
@property(nonatomic, strong)NSString *fileName;
@property(nonatomic, strong)NSString *filePath;
@property(nonatomic, strong)NSString *downloadUrl;
@property(nonatomic, strong)NSString *iD;
@property(nonatomic, assign)NSInteger totalLength;
@property(nonatomic, assign)NSInteger downloadEdLength;
@property(nonatomic, assign)BOOL isFinished;
@property(nonatomic, assign)BOOL isPause;
@property(nonatomic, assign)float progress;
@property(nonatomic, assign)NSInteger row;

@property(nonatomic, assign)YYDownloadType state;
@end
