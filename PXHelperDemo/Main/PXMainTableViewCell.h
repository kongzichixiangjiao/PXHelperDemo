//
//  PXMainTableViewCell.h
//  PXHelperDemo
//
//  Created by 侯佳男 on 2018/3/14.
//  Copyright © 2018年 侯佳男. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYDownloadManager.h"

@interface PXMainTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property(nonatomic, strong)YYDownloadModel *model;
-(void)setup: (YYDownloadModel *)model;
@end
