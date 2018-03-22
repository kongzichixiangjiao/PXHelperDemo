//
//  PXDownloadVideoProgressView.h
//  FinanceAssistant
//
//  Created by 侯佳男 on 2018/3/17.
//  Copyright © 2018年 PUXIN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PXDownloadVideoProgressView : UIView

/** 进度 */
@property (nonatomic, assign) IBInspectable CGFloat progress;
/** 填充颜色 */
@property (nonatomic, strong) IBInspectable UIColor *fillColor;

/** 初始化 */
- (instancetype)initWithFrame:(CGRect)frame progress:(CGFloat)progress;

@end

