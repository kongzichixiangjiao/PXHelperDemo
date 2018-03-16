//
//  PXMainViewController.m
//  PXHelperDemo
//
//  Created by 侯佳男 on 2018/3/13.
//  Copyright © 2018年 侯佳男. All rights reserved.
//

#import "PXMainViewController.h"
#import "PXMainSplitViewController.h"
#import "PXPlayerViewController.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@interface PXMainViewController ()
@property (nonatomic, strong) AVPlayer *player; /**< 媒体播放器 */
@property (nonatomic, strong) AVPlayerViewController *playerVC; /**< 媒体播放控制器 */

@end

@implementation PXMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)goPlayVC:(id)sender {
    NSString* fullPath =
    [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]
     stringByAppendingPathComponent:@"minion_01.mp4"];
     NSString *path = [[NSBundle mainBundle] pathForResource:@"minion_01.mp4" ofType:nil];
    NSLog(@"%@", fullPath);
    NSLog(@"%@", path);
    NSURL *url1 = [NSURL URLWithString:@"http://120.25.226.186:32812/resources/videos/minion_01.mp4"];
    
    NSURL *url = [NSURL fileURLWithPath:fullPath];
    NSLog(@"%@", url);
    
    self.player = [[AVPlayer alloc] initWithURL:url];
    self.playerVC = [[AVPlayerViewController alloc] init];
    self.playerVC.player = self.player;
    [self presentViewController:self.playerVC animated:true completion:^{
        [self.playerVC.player play];
    }];
    
//    PXMainSplitViewController *split = (PXMainSplitViewController *)[self parentViewController];
//    [split showViewController:self.playerVC sender:nil];
//    [self.playerVC.player play];
}

@end
