//
//  PXMainTableViewController.m
//  PXHelperDemo
//
//  Created by 侯佳男 on 2018/3/13.
//  Copyright © 2018年 侯佳男. All rights reserved.
//

#import "PXMainTableViewController.h"
#import "YYDownloadManager.h"
#import "PXMainTableViewCell.h"

@interface PXMainTableViewController () <YYDownloadManagerDelegat>
@property(nonatomic, strong)dispatch_queue_t concurrentQueue;
@property(nonatomic, strong)NSOperationQueue *queue;
@property(nonatomic, strong)NSMutableArray *dataSource;
@end

@implementation PXMainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //
    self.dataSource = [NSMutableArray array];
    for (int i = 1; i<5; i++) {
        YYDownloadModel *model = [[YYDownloadModel alloc] init];
        model.fileName = [NSString stringWithFormat:@"minion_0%d.mp4", i];
        model.downloadUrl = [NSString stringWithFormat:@"http://120.25.226.186:32812/resources/videos/minion_0%d.mp4", i];;
        model.taskDescription = [NSString stringWithFormat:@"minion_0%d.mp4", i];
        model.iD = [NSString stringWithFormat:@"%d", i];
        model.isPause = false;
        model.isFinished = false;
        model.totalLength = 13;
        [self.dataSource addObject:model];
//        [YYDownloadModel saveItem:model];
    }
    
//    [YYDownloadManagerShared downloadDataWithModel:model];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PXMainTableViewCell" bundle:nil] forCellReuseIdentifier:@"PXMainTableViewCell"];
    
    //创建并发队列，传入参数为DISPATCH_QUEUE_CONCURRENT
    self.concurrentQueue = dispatch_queue_create("com.hjn.concurrent", DISPATCH_QUEUE_CONCURRENT);
    self.queue = [[NSOperationQueue alloc] init];
    self.queue.maxConcurrentOperationCount = 2;

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PXMainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PXMainTableViewCell" forIndexPath:indexPath];
    YYDownloadModel *model = self.dataSource[indexPath.row];
    model.row = indexPath.row;
    cell.model = model;
    cell.progressLabel.text = [NSString stringWithFormat:@"%f", model.progress];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    dispatch_async(self.concurrentQueue, ^{
//    });
    
    NSBlockOperation *op = [[NSBlockOperation alloc] init];
    [op addExecutionBlock:^{
        [YYDownloadManagerShared startLoadDataWithModel:self.dataSource[indexPath.row]];
        YYDownloadManagerShared.delegate = self;
    }];
    [self.queue addOperation:op];

}

- (void)completeWithTask:(NSURLSessionTask *)task andIsSuccess:(BOOL)isSuccess {
    
}

- (void)completeWithProgress: (CGFloat)progress {
    
}

- (void)downloadWithFilePath: (NSString *)filePath {
    
}

- (void)downloadWithResumeData: (NSData *)data {
    
}
- (void)downloadingWithModel: (YYDownloadModel *)model {
    self.dataSource[model.row] = model;
    [self.tableView reloadData];
}

@end
