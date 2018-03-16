//
//  YYDownloadManager.m
//  PXHelperDemo
//
//  Created by 侯佳男 on 2018/3/14.
//  Copyright © 2018年 侯佳男. All rights reserved.
//

#import "YYDownloadManager.h"

#define kSessionConfigurationIdentifier @"YY_GA_JIANAN"
#define kMaxDownloadCount 2

@interface YYDownloadManager() <NSURLSessionDownloadDelegate>

@property (nonatomic, strong)NSURLSessionDownloadTask *task;
@property (nonatomic, strong)NSURLSession *session;
@property (nonatomic, strong)NSOperationQueue *queue;
@property (nonatomic, strong)NSMutableArray *ingArray;
@property (nonatomic, strong)NSMutableArray *willArray;
@property (nonatomic, strong)NSMutableArray *finishedArray;
@property (nonatomic, strong)NSMutableArray *errorArray;

@end

@implementation YYDownloadManager

+ (instancetype)sharedInstance {
    static YYDownloadManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (NSMutableArray *)ingArray {
    if (!_ingArray) {
        _ingArray = [NSMutableArray array];
    }
    return _ingArray;
}
- (NSMutableArray *)willArray {
    if (!_willArray) {
        _willArray = [NSMutableArray array];
    }
    return _willArray;
}
- (NSMutableArray *)errorArray {
    if (!_errorArray) {
        _errorArray = [NSMutableArray array];
    }
    return _errorArray;
}
- (NSMutableArray *)finishedArray {
    if (!_finishedArray) {
        _finishedArray = [NSMutableArray array];
    }
    return _finishedArray;
}

- (NSOperationQueue *)queue {
    if (!_queue) {
        _queue = [[NSOperationQueue alloc]init];
        _queue.maxConcurrentOperationCount = 2;
    }
    return _queue;
}

- (NSURLSession *)session {
    if (!_session) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:kSessionConfigurationIdentifier];
        _session = [NSURLSession sessionWithConfiguration:config
                                                 delegate:self
                                            delegateQueue:self.queue];
    }
    return _session;
}

- (NSURLSessionDownloadTask *)startLoadDataWithModel: (YYDownloadModel *)model {
//    [self judgeMaxDownloadCountWithModel:model];
    [self.willArray addObject:model];
    
    [self prepareDownloadWithModel: model];
    
    return _task;
}

- (void)judgeMaxDownloadCountWithModel: (YYDownloadModel *)model {
    if (self.ingArray.count == 0) {
        [self.ingArray addObject:model];
    } else {
        if (self.ingArray.count < kMaxDownloadCount) {
            [self.ingArray addObject:model];
        } else {
            [self.willArray addObject:model];
        }
    }
}

- (YYDownloadModel *)willDownloadModelWithModel:(YYDownloadModel *)model {
    if (self.ingArray.count < kMaxDownloadCount) {
        if (self.willArray.count > 0) {
            if (model.state == YYDownloadStatePause) {
                for (int i = 0; i<self.willArray.count; i++) {
                    YYDownloadModel *item = self.willArray[i];
                    if (model.taskDescription == item.taskDescription) {
                        [self.ingArray addObject:model];
                        [self.willArray removeObjectAtIndex:i];
                        return model;
                    }
                }
            }
            YYDownloadModel *model = self.willArray.firstObject;
            [self.ingArray addObject:model];
            [self.willArray removeObjectAtIndex:0];
            return model;
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

- (void)deleteFinishIngArrayModel: (YYDownloadModel *)model {
    for (int i = 0; i<self.ingArray.count; i++) {
        YYDownloadModel *item = self.ingArray[i];
        if (item.taskDescription == model.taskDescription) {
            [self.ingArray removeObjectAtIndex:i];
        }
    }
}

- (BOOL)judgeCurrentItemIsPauseWithModel: (YYDownloadModel *)model {
    return model.isPause;
}

- (void)prepareDownloadWithModel: (YYDownloadModel *)model {
    YYDownloadModel *item = [self willDownloadModelWithModel: model];
    if (model == nil) {
        return;
    }
    NSLog(@"prepareDownload fileName == %@", item.fileName);
    if (model.isPause) {
        [self startPauseDownloadModel:item];
    } else {
        [self startNewDownloadModel:item];
    }
}

- (void)startPauseDownloadModel: (YYDownloadModel *)model {
    NSURLSessionDownloadTask* task = [_session downloadTaskWithResumeData:model.resumeData];
    [task resume];
    _task = task;
    model.state = YYDownloadStateStart;
    model.task = task;
}

- (void)startNewDownloadModel: (YYDownloadModel *)model {
    NSLog(@"%@", model.taskDescription);
    NSURL *url = [NSURL URLWithString: model.downloadUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *range = [NSString stringWithFormat:@"bytes=%zd-", 0];
    [request setValue:range forHTTPHeaderField:@"Range"];
    
    _task = [self.session downloadTaskWithRequest:request];
    _task.taskDescription = model.taskDescription;
    [_task resume];
    model.state = YYDownloadStateStart;
    model.task = _task;
}

- (YYDownloadModel *)getCurrentModelWithTask: (NSURLSessionDownloadTask *)task {
    NSLog(@"%@", task.taskDescription);
    for (YYDownloadModel *model in _ingArray) {
        if (model.taskDescription == task.taskDescription) {
            return model;
        }
    }
    return nil;
}

// 写入数据到本地的时候会调用的方法
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    YYDownloadModel *model = [self getCurrentModelWithTask:downloadTask];
    NSLog(@"fileName == %@", model.fileName);
    NSString* fullPath =
    [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]
     stringByAppendingPathComponent:model.fileName];
    
    [[NSFileManager defaultManager] moveItemAtURL:location
                                            toURL:[NSURL fileURLWithPath:fullPath]
                                            error:nil];
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    YYDownloadModel *model = [self getCurrentModelWithTask:downloadTask];
    model.totalLength = totalBytesExpectedToWrite;
    model.downloadEdLength = totalBytesWritten;
    // 下载进度
    CGFloat progress = 1.0 * totalBytesWritten / totalBytesExpectedToWrite;
    NSLog(@"%.f%%",progress*100);
    model.progress = progress*100;
    model.state = YYDownloadStateIng;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"fileName == %@", model.fileName);
        [self.delegate downloadingWithModel:model];
    });
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    YYDownloadModel *model = [self getCurrentModelWithTask:downloadTask];
    [downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        model.resumeData = resumeData;
        model.isPause = true;
        model.state = YYDownloadStatePause;
        [self.willArray addObject:model];
        [self.delegate downloadWithResumeData:resumeData];
    }];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    YYDownloadModel *model = [self getCurrentModelWithTask:(NSURLSessionDownloadTask *)task];
    if (model == nil) {
        return;
    }
    if (error == nil) {
        model.isPause = false;
        model.isFinished = true;
        model.state = YYDownloadStateFinished;
        [self.finishedArray addObject:model];
        [self deleteFinishIngArrayModel: model];
        [self.delegate completeWithTask:task andIsSuccess:true];
        if (self.willArray.count > 0) {
            [self prepareDownloadWithModel:self.willArray.firstObject];
        }
        return;
    }
    model.state = YYDownloadStateError;
    [self.errorArray addObject:model];
    [self.delegate completeWithTask:task andIsSuccess:false];
}

- (void)goOnDownloadWithReumeData:(NSData *)data {
    NSURLSessionDownloadTask* downloadTask = [self.session downloadTaskWithResumeData:data];
    [downloadTask resume];
    self.task = downloadTask;
}

- (void)stopWithTask: (NSURLSessionDownloadTask *)task {
    [task suspend];
}

- (void)restartWithTask: (NSURLSessionDownloadTask *)task {
    [task resume];
}

@end

