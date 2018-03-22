//
//  PXDownloadVideoProgressView.m
//  FinanceAssistant
//
//  Created by 侯佳男 on 2018/3/17.
//  Copyright © 2018年 PUXIN. All rights reserved.
//

#import "PXDownloadVideoProgressView.h"

@interface PXDownloadVideoProgressView ()
{
    /** 原点 */
    CGPoint _origin;
    /** 半径 */
    CGFloat _radius;
    /** 起始 */
    CGFloat _startAngle;
    /** 结束 */
    CGFloat _endAngle;
}

/** 进度显示 */
@property (nonatomic, strong) UILabel *progressLabel;
/** 填充layer */
@property (nonatomic, strong) CAShapeLayer *fillLayer;

@end

@implementation PXDownloadVideoProgressView

- (instancetype)initWithFrame:(CGRect)frame progress:(CGFloat)progress {
    if (self) {
        self = [super initWithFrame:frame];
        self.backgroundColor = [UIColor clearColor];
        [self setUI];
        self.progress = progress;
    }
    return self;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    [self setUI];
    self.progress = 0.0;
}

#pragma mark - 初始化页面
- (void)setUI {
    
    [self.layer addSublayer:self.fillLayer];
    [self addSubview:self.progressLabel];
    
    _origin = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    _radius = self.bounds.size.width / 2;
    
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithArcCenter:_origin radius:_radius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = borderPath.CGPath;
    self.layer.mask = maskLayer;
}

#pragma mark - 懒加载
- (UILabel *)progressLabel {
    if (!_progressLabel) {
        _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 15)];
        _progressLabel.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        _progressLabel.textColor = [UIColor whiteColor];
    }
    return _progressLabel;
}

#pragma mark - 懒加载
- (CAShapeLayer *)fillLayer {
    if (!_fillLayer) {
        _fillLayer = [CAShapeLayer layer];
    }
    return _fillLayer;
}

#pragma mark - setMethod
- (void)setProgress:(CGFloat)progress {
    
    _progress = progress;
    _progressLabel.text = [NSString stringWithFormat:@"%.0f%%",progress * 100];
    
    _startAngle = - M_PI_2;
    _endAngle = _startAngle + _progress * M_PI * 2;
    
    UIBezierPath *fillPath = [UIBezierPath bezierPathWithArcCenter:_origin radius:_radius startAngle:_startAngle endAngle:_endAngle clockwise:YES];
    [fillPath addLineToPoint:_origin];
    _fillLayer.path = fillPath.CGPath;
    _fillLayer.fillColor = _fillColor.CGColor;
}

- (void)setFillColor:(UIColor *)fillColor {
    _fillColor = fillColor;
    _fillLayer.fillColor = _fillColor.CGColor;
}

@end

