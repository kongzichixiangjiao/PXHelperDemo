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
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "UIDevice+Category.h"

@interface PXMainTableViewController () <YYDownloadManagerDelegat>
@property(nonatomic, strong)dispatch_queue_t concurrentQueue;
@property(nonatomic, strong)NSOperationQueue *queue;
@property (nonatomic, strong)NSMutableArray *dataArray;


@property (nonatomic, strong) AVPlayer *player; /**< 媒体播放器 */
@property (nonatomic, strong) AVPlayerViewController *playerVC; /**< 媒体播放控制器 */
@end

@implementation PXMainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.queue = [[NSOperationQueue alloc] init];
    
    NSMutableArray *arr = [NSMutableArray array];
    arr = [YYDownloadModel searchAll];
    
    self.dataArray = [NSMutableArray array];
    for (int i = 1; i<5; i++) {
        YYDownloadModel *model = [[YYDownloadModel alloc] init];
        model.fileName = [NSString stringWithFormat:@"minion_0%d.mp4", i];
        model.downloadUrl = [NSString stringWithFormat:@"http://120.25.226.186:32812/resources/videos/minion_0%d.mp4", i];
        model.taskDescription = [NSString stringWithFormat:@"minion_0%d.mp4", i];
        [self.dataArray addObject:model];
//        [YYDownloadModel saveItem:model];
    }
    
    for (int i = 0; i<self.dataArray.count; i++) {
        YYDownloadModel *model = self.dataArray[i];
        BOOL isSame = NO;
        int count = 0;
        for (int j = 0; j<arr.count; j++) {
            YYDownloadModel *item = arr[j];
            if (item.state == YYDownloadStateIng) {
                item.state = YYDownloadStatePause;
            }
            if ([model.taskDescription isEqualToString:item.taskDescription]) {
                isSame = YES;
                count = j;
                break;
            }
        }
        if (arr.count > 0) {
            if (isSame) {
                [self.dataArray setObject:arr[count] atIndexedSubscript:i];
            } else {
                [self.dataArray addObject:arr[count]];
                [YYDownloadModel saveItem:arr[count]];
            }
        }
    }
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PXMainTableViewCell" bundle:nil] forCellReuseIdentifier:@"PXMainTableViewCell"];
    
    [UIDevice yy_deviceSize];

}

/*
 - (void)requestData {
 
 for (YYDownloadModel* model in self.dataArray) {
 if (model.state == YYDownloadStateIng) {
 [self.collectionView.mj_header endRefreshing];
 [self.collectionView.mj_footer endRefreshing];
 return;
 }
 }
 
 NSDictionary *dic =@{@"startPage" : @(self.page), @"pageSize" : @10, @"videoType" : @"2"};
 [PXHttpRequestTool POST:PXHttpPXVideo parameters:dic success:^(id responseObject) {
 id result = responseObject[@"result"];
 NSDictionary *dic = result[@"data"];
 NSArray *models = [YYDownloadModel mj_objectArrayWithKeyValuesArray:dic];
 
 for (YYDownloadModel *model in models) {
 model.taskDescription = model.iD;
 }
 
 if (self.page != 1) {
 [self.dataArray addObjectsFromArray:models];
 } else {
 [self.dataArray setArray:models];
 }
 
 NSMutableArray *arr = [NSMutableArray array];
 arr = [YYDownloadModel searchAll];
 
 for (int i = 0; i<self.dataArray.count; i++) {
 YYDownloadModel *model = self.dataArray[i];
 BOOL isSame = NO;
 int count = 0;
 for (int j = 0; j<arr.count; j++) {
 YYDownloadModel *item = arr[j];
 if (item.state == YYDownloadStateIng) {
 item.state = YYDownloadStatePause;
 }
 if ([model.taskDescription isEqualToString:item.taskDescription]) {
 isSame = YES;
 count = j;
 break;
 }
 }
 if (arr.count > 0) {
 if (isSame) {
 [self.dataArray setObject:arr[count] atIndexedSubscript:i];
 } else {
 [self.dataArray addObject:arr[count]];
 [YYDownloadModel saveItem:arr[count]];
 }
 } else {
 [YYDownloadModel saveItem:model];
 }
 }
 
 [self.collectionView reloadData];
 [self.collectionView.mj_footer endRefreshing];
 [self.collectionView.mj_header endRefreshing];
 } failure:^(NSError *error) {
 [self.collectionView.mj_footer endRefreshing];
 [self.collectionView.mj_header endRefreshing];
 }];
 }
 */


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PXMainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PXMainTableViewCell" forIndexPath:indexPath];
    YYDownloadModel *model = self.dataArray[indexPath.row];
    model.row = indexPath.row;
    cell.model = model;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    YYDownloadModel *model = self.dataArray[indexPath.row];
    if (model.state == YYDownloadStateFinished) {
        NSString* fullPath =
        [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]
         stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@", kYYDownloadVideoFile, model.fileName]];
        NSURL *url = [NSURL fileURLWithPath:fullPath];
        //        NSString *path = [[NSBundle mainBundle] pathForResource:@"minion_01" ofType:@"mp4"];
        //        NSURL *url1 = [NSURL fileURLWithPath:path];
        self.player = [[AVPlayer alloc] initWithURL:url];
        self.playerVC = [[AVPlayerViewController alloc] init];
        
        [self presentViewController:self.playerVC animated:true completion:^{
            self.playerVC.player = self.player;
        }];
        return;
    } else if (model.state == YYDownloadStatePause) {
        [YYDownloadManagerShared startLoadDataWithModel:model];
        YYDownloadManagerShared.delegate = self;
        return;
    } else if (model.state == YYDownloadStateIng) {
        [YYDownloadManagerShared stopWithModel:model];
        YYDownloadManagerShared.delegate = self;
        return;
    }
    NSBlockOperation *op = [[NSBlockOperation alloc] init];
    [op addExecutionBlock:^{
        [YYDownloadManagerShared startLoadDataWithModel:model];
        YYDownloadManagerShared.delegate = self;
    }];
    [self.queue addOperation:op];

}

- (void)downloadingWithModel: (YYDownloadModel *)model {
    for (PXMainTableViewCell *cell in self.tableView.visibleCells) {
        if (cell.model.taskDescription == model.taskDescription) {
            [cell setup:model];
        }
    }
}

- (void)downloadFinishedWithModel:(YYDownloadModel *)model {
    [YYDownloadModel updateItem:model];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}






@end
