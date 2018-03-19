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
@property (nonatomic, strong)NSFileManager *fileManager;
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


- (void)configureBackroundSession {
    
}

- (NSURLSessionDownloadTask *)startLoadDataWithModel: (YYDownloadModel *)model {
    if (![self hasWillInteriorWithModel:model]) {
        [self.willArray addObject:model];
    }
    
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

- (YYDownloadModel *)currentWillDownloadModelWithModel:(YYDownloadModel *)model {
    for (int i = 0; i<self.willArray.count; i++) {
        YYDownloadModel *item = self.willArray[i];
        if (model.taskDescription == item.taskDescription) {
            return item;
        }
    }
    return nil;
}

- (BOOL)hasWillInteriorWithModel:(YYDownloadModel *)model {
    for (int i = 0; i<self.willArray.count; i++) {
        YYDownloadModel *item = self.willArray[i];
        if (model.taskDescription == item.taskDescription) {
            return YES;
        }
    }
    return NO;
}

- (YYDownloadModel *)ingDownloadModelWithModel:(YYDownloadModel *)model {
    for (int i = 0; i<self.ingArray.count; i++) {
        YYDownloadModel *item = self.ingArray[i];
        if (model.taskDescription == item.taskDescription) {
            return item;
        }
    }
    return nil;
}

- (void)deleteFinishIngArrayModel: (YYDownloadModel *)model {
    for (int i = 0; i<self.ingArray.count; i++) {
        YYDownloadModel *item = self.ingArray[i];
        if (item.taskDescription == model.taskDescription) {
            [self.ingArray removeObjectAtIndex:i];
        }
    }
}

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

