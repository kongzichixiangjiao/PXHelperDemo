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

// http://120.25.226.186:32812/resources/videos/minion_01.mp4
@protocol YYDownloadManagerDelegat <NSObject>


/**
 下载中回调
 */
- (void)downloadingWithModel: (YYDownloadModel *)model;


/**
 下载完成回调
 */
- (void)downloadFinishedWithModel: (YYDownloadModel *)model;

@end

@interface YYDownloadManager : NSObject

@property(nonatomic, weak)id<YYDownloadManagerDelegat> delegate;

// 后台下载配置
@property (nonatomic, strong) NSString *backgroundConfigure;
// 后台下载完成回调
@property (nonatomic, copy) void (^backgroundSessionCompletionHandler)(void);
// 后台下载完成后调用 返回文件保存路径filePath
@property (nonatomic, copy) NSString *(^backgroundSessionDownloadCompleteBlock)(NSString *downloadURL);


+ (instancetype)sharedInstance;
// 后台配置session
- (void)configureBackroundSession;
// 开始下载
- (NSURLSessionDownloadTask *)startLoadDataWithModel: (YYDownloadModel *)model;
// 停止下载
- (void)stopWithModel: (YYDownloadModel *)model;


@end
