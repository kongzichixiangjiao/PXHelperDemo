//
//  YYDownloadManager.h
//  PXHelperDemo
//
//  Created by 侯佳男 on 2018/3/14.
//  Copyright © 2018年 侯佳男. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YYDownloadModel.h"

#define YYDownloadManagerShared [YYDownloadManager sharedInstance]

@protocol YYDownloadManagerDelegat <NSObject>

- (void)completeWithTask:(NSURLSessionTask *)task andIsSuccess:(BOOL)isSuccess;
- (void)completeWithProgress: (CGFloat)progress;
- (void)downloadWithFilePath: (NSString *)filePath;
- (void)downloadWithResumeData: (NSData *)data;

- (void)downloadType: (YYDownloadType)type;

- (void)downloadingWithModel: (YYDownloadModel *)model;

@end

@interface YYDownloadManager : NSObject

@property(nonatomic, weak)id<YYDownloadManagerDelegat> delegate;


+ (instancetype)sharedInstance;

- (NSURLSessionDownloadTask *)startLoadDataWithModel: (YYDownloadModel *)model;

- (void)stopWithTask: (NSURLSessionDownloadTask *)task;

- (void)restartWithTask: (NSURLSessionDownloadTask *)task;

- (void)goOnDownloadWithReumeData:(NSData *)data;

@end
