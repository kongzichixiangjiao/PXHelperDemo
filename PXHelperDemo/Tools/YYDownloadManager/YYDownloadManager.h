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
#define kYYDownloadVideoFile @"JFSP"


@protocol YYDownloadManagerDelegat <NSObject>

- (void)downloadingWithModel: (YYDownloadModel *)model;

- (void)downloadFinishedWithModel: (YYDownloadModel *)model;
@end

@interface YYDownloadManager : NSObject

@property(nonatomic, weak)id<YYDownloadManagerDelegat> delegate;

@property (nonatomic, strong) NSString *backgroundConfigure;
@property (nonatomic, copy) void (^backgroundSessionCompletionHandler)(void);
// 后台下载完成后调用 返回文件保存路径filePath
@property (nonatomic, copy) NSString *(^backgroundSessionDownloadCompleteBlock)(NSString *downloadURL);


+ (instancetype)sharedInstance;

- (void)configureBackroundSession;

- (NSURLSessionDownloadTask *)startLoadDataWithModel: (YYDownloadModel *)model;

- (void)stopWithModel: (YYDownloadModel *)model;


@end
