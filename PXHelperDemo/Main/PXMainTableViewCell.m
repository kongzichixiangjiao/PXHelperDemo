//
//  PXMainTableViewCell.m
//  PXHelperDemo
//
//  Created by 侯佳男 on 2018/3/14.
//  Copyright © 2018年 侯佳男. All rights reserved.
//

#import "PXMainTableViewCell.h"
#import "YYDownloadManager.h"

@interface PXMainTableViewCell() <YYDownloadManagerDelegat>
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (nonatomic, strong)dispatch_queue_t concurrentQueue;
@end

@implementation PXMainTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


- (IBAction)start:(UIButton *)sender {
}


-(void)testConcurrentQueueWithModel:(YYDownloadModel *)model
{

}

- (IBAction)stop:(UIButton *)sender {
}

- (IBAction)goon:(UIButton *)sender {
    
}

-(void)setup: (YYDownloadModel *)model {
    _progressLabel.text = [NSString stringWithFormat:@"%f", model.progress];
}

@end
