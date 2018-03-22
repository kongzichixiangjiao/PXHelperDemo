//
//  YYDownloadManager.m
//  PXHelperDemo
//
//  Created by 侯佳男 on 2018/3/14.
//  Copyright © 2018年 侯佳男. All rights reserved.
//

#import "YYDownloadManager.h"

// 后台下载标识
#define kSessionConfigurationIdentifier @"YY_GA_JIANAN"
// 最大下载数
#define kMaxDownloadCount 2

@interface YYDownloadManager() <NSURLSessionDownloadDelegate>

// 下载使用的task
@property (nonatomic, strong)NSURLSessionDownloadTask *task;
// session
@property (nonatomic, strong)NSURLSession *session;
// 队列
@property (nonatomic, strong)NSOperationQueue *queue;
// 管理下载路径
@property (nonatomic, strong)NSFileManager *fileManager;
// 正在下载的数组
@property (nonatomic, strong)NSMutableArray *ingArray;
// 将要下载的数组
@property (nonatomic, strong)NSMutableArray *willArray;
// 已经下载完成的数组
@property (nonatomic, strong)NSMutableArray *finishedArray;
// 下载出错的数组
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

- (instancetype)init {
    if (self = [super init]) {
        _backgroundConfigure = kSessionConfigurationIdentifier;
    }
    return self;
}

- (NSFileManager *)fileManager
{
    if (!_fileManager) {
        _fileManager = [[NSFileManager alloc]init];
    }
    return _fileManager;
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
        if (_backgroundConfigure) {
            NSURLSessionConfiguration *configure = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:_backgroundConfigure];
            _session = [NSURLSession sessionWithConfiguration:configure delegate:self delegateQueue:self.queue];
        } else {
            _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:self.queue];
        }
    }
    return _session;
}

// 配置后台session
- (void)configureBackroundSession {
    if (!_backgroundConfigure) {
        return;
    }
    [self session];
}

/**
 开始下载调用方法

 @param model 要下载的模型
 @return 没有啥用
 */
- (NSURLSessionDownloadTask *)startLoadDataWithModel: (YYDownloadModel *)model {
    if (![self hasWillInteriorWithModel:model]) {
        [self.willArray addObject:model];
    }
    
    [self prepareDownloadWithModel: model];
    
    return _task;
}

/**
 获取将要下载的模型

 @param model 要下载的模型
 @return 将要下载的模型
 */
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
            YYDownloadModel *item = [self currentWillDownloadModelWithModel:model];
            [self.ingArray addObject:item];
            [self.willArray removeObjectAtIndex:0];
            return item;
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

/**
 获取当前将要下载的模型
 */
- (YYDownloadModel *)currentWillDownloadModelWithModel:(YYDownloadModel *)model {
    for (int i = 0; i<self.willArray.count; i++) {
        YYDownloadModel *item = self.willArray[i];
        if (model.taskDescription == item.taskDescription) {
            return item;
        }
    }
    return nil;
}


/**
 将要下载的数组中是否包含此模型
 */
- (BOOL)hasWillInteriorWithModel:(YYDownloadModel *)model {
    for (int i = 0; i<self.willArray.count; i++) {
        YYDownloadModel *item = self.willArray[i];
        if (model.taskDescription == item.taskDescription) {
            return YES;
        }
    }
    return NO;
}


/**
 获取正在下载的模型
 */
- (YYDownloadModel *)ingDownloadModelWithModel:(YYDownloadModel *)model {
    for (int i = 0; i<self.ingArray.count; i++) {
        YYDownloadModel *item = self.ingArray[i];
        if (model.taskDescription == item.taskDescription) {
            return item;
        }
    }
    return nil;
}

/**
 删除下载完成的模型从Ing数组中
 */
- (void)deleteFinishIngArrayModel: (YYDownloadModel *)model {
    for (int i = 0; i<self.ingArray.count; i++) {
        YYDownloadModel *item = self.ingArray[i];
        if (item.taskDescription == model.taskDescription) {
            [self.ingArray removeObjectAtIndex:i];
        }
    }
}


/**
 准备下载的模型
 */
- (void)prepareDownloadWithModel: (YYDownloadModel *)model {
    NSLog(@"%@", model.taskDescription);
    YYDownloadModel *item = [self willDownloadModelWithModel: model];
    if (model == nil) {
        return;
    }
    
    if (model.state == YYDownloadStatePause) {
        [self startPauseDownloadModel:item];
    } else {
        [self startNewDownloadModel:item];
    }
}


/**
 开始下载暂停的模型
 */
- (void)startPauseDownloadModel: (YYDownloadModel *)model {
    
    NSData *resumeData = [self resumeDataFromFileWithDownloadModel:model];
    if (resumeData == nil) {
        return;
    }
    NSURLSessionDownloadTask* downloadTask = [self.session downloadTaskWithResumeData:resumeData];
    downloadTask.taskDescription = model.taskDescription;
    [downloadTask resume];
    
    self.task = downloadTask;
    
    model.state = YYDownloadStateIng;
    model.task = self.task;
}


/**
 开始下载新的模型
 */
- (void)startNewDownloadModel: (YYDownloadModel *)model {
    NSURL *url = [NSURL URLWithString: model.downloadUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *range = [NSString stringWithFormat:@"bytes=%zd-", model.downloadEdLength];
    [request setValue:range forHTTPHeaderField:@"Range"];
    
    _task = [self.session downloadTaskWithRequest:request];
    _task.taskDescription = model.taskDescription;
    [_task resume];
    model.state = YYDownloadStateStart;
    model.task = _task;
}

- (YYDownloadModel *)getCurrentModelWithTask: (NSURLSessionDownloadTask *)task {
    for (YYDownloadModel *model in _ingArray) {
        if (model.taskDescription == task.taskDescription) {
            return model;
        }
    }
    return nil;
}

//  创建缓存目录文件
- (void)createDirectory:(NSString *)directory {
    if (![self.fileManager fileExistsAtPath:directory]) {
        [self.fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:NULL];
    }
}

// 写入数据到本地的时候会调用的方法
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    YYDownloadModel *model = [self getCurrentModelWithTask:downloadTask];

    NSString* fullPath =
    [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]
     stringByAppendingPathComponent:kYYDownloadVideoFile];
    [self createDirectory:fullPath];
    [[NSFileManager defaultManager] moveItemAtURL:location
                                            toURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", fullPath, model.fileName]]
                                            error:nil];
    model.filePath = fullPath;
    model.state = YYDownloadStateFinished;
    [self.delegate downloadFinishedWithModel:model];
}

// 实时写入文件的信息
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
    
    model.state = YYDownloadStateIng;
    if (model.progress != progress*100)  {
//        NSLog(@"%.f%%",progress*100);
        model.progress = progress;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate downloadingWithModel:model];
        });
    }
}

// 恢复下载
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {

}

// 下载完成
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    YYDownloadModel *model = [self getCurrentModelWithTask:(NSURLSessionDownloadTask *)task];
    if (model == nil) {
        return;
    }
    if (error == nil) {
        model.state = YYDownloadStateFinished;
        [self.finishedArray addObject:model];
        [self deleteFinishIngArrayModel: model];
        if (self.willArray.count > 0) {
            [self prepareDownloadWithModel:self.willArray.firstObject];
        }
        return;
    }
    model.state = YYDownloadStateError;
    [self.errorArray addObject:model];
}

// 后台session下载完成
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    if (self.backgroundSessionCompletionHandler) {
        self.backgroundSessionCompletionHandler();
    }
}

// 获取resumeData
- (NSData *)resumeDataFromFileWithDownloadModel:(YYDownloadModel *)downloadModel
{
    if (downloadModel.resumeData) {
        return downloadModel.resumeData;
    }
    NSString* fullPath =
    [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]
     stringByAppendingPathComponent:kYYDownloadVideoFile];
    NSString *resumeDataPath = [NSString stringWithFormat:@"%@/%@", fullPath, downloadModel.fileName];
    
    if ([_fileManager fileExistsAtPath:resumeDataPath]) {
        NSData *resumeData = [NSData dataWithContentsOfFile:resumeDataPath];
        return resumeData;
    }

    return nil;
}

// 暂停下载
-(void)stopWithModel:(YYDownloadModel *)model {
    NSLog(@"stopWithModel == %@", model.taskDescription);
//    [model.task suspend];
    for (int i = 0; i < _ingArray.count; i++) {
        YYDownloadModel *item = _ingArray[i];
        if (item.taskDescription == model.taskDescription) {
            [_ingArray removeObjectAtIndex:i];
        }
    }
    [model.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        model.resumeData = resumeData;
        model.state = YYDownloadStatePause;
        [self.willArray addObject:model];
        [YYDownloadModel updateItem:model WithTaskDescription:model.taskDescription];
    }];
}

- (void)dealloc {
    NSLog(@"---");
}

@end

