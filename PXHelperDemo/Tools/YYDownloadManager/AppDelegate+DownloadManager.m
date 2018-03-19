//
//  AppDelegate+DownloadManager.m
//  FinanceAssistant
//
//  Created by 侯佳男 on 2018/3/19.
//  Copyright © 2018年 PUXIN. All rights reserved.
//

#import "AppDelegate+DownloadManager.h"
#import "YYDownloadManager.h"
@implementation AppDelegate (DownloadManager)

-(void)configDownManager {
    // session在后台下载完成调用
    [YYDownloadManagerShared setBackgroundSessionDownloadCompleteBlock:^NSString *(NSString *downloadURL) {
        YYDownloadModel *model = [[YYDownloadModel alloc] initWithURLString:downloadURL];
        return model.filePath;
    }];
    [YYDownloadManagerShared configureBackroundSession];
}

// 后台下载完成调用
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier
  completionHandler:(void (^)())completionHandler {
    YYDownloadManagerShared.backgroundSessionCompletionHandler = completionHandler;
}


@end
