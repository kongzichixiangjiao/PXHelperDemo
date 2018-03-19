//
//  YYDownloadModel.h
//  PXHelperDemo
//
//  Created by 侯佳男 on 2018/3/15.
//  Copyright © 2018年 侯佳男. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    YYDownloadStateStart,
    YYDownloadStatePrepare,
    YYDownloadStateIng,
    YYDownloadStatePause,
    YYDownloadStateFinished,
    YYDownloadStateError,
    YYDownloadStateDefault,
} YYDownloadType;

@interface YYDownloadModel : NSObject

@property(nonatomic, strong)NSString *taskDescription;
@property (nonatomic, strong)NSURLSessionDownloadTask *task;
@property(nonatomic, strong)NSData *resumeData;
@property(nonatomic, strong)NSString *fileName;
@property(nonatomic, strong)NSString *filePath;
@property(nonatomic, strong)NSString *downloadUrl;
@property(nonatomic, strong)NSString *iD;
@property(nonatomic, assign)NSInteger totalLength;
@property(nonatomic, assign)NSInteger downloadEdLength;
@property(nonatomic, assign)float progress;
@property(nonatomic, assign)NSInteger row;

@property(nonatomic, assign)YYDownloadType state;



- (instancetype)initWithURLString:(NSString *)URLString;



// 增
+(BOOL)saveItem:(YYDownloadModel *)model;
// 删
+(BOOL)deleteItemWithId:(NSString*)iD;
+(BOOL)deleteItemWithIDs: (NSMutableArray *)iDs;
+(void)deleteItemWithModels: (NSMutableArray *)models;
+ (BOOL)deleteItemWithKey: (NSString *)key andValues: (NSMutableArray *)values;
+(BOOL)deleteTable;
+(void)deleteAllData;
// 改
+(BOOL)updateItem:(YYDownloadModel *)newModel WithId:(NSString*)iD;
+(BOOL)updateItem:(YYDownloadModel*)newModel WithTaskDescription:(NSString*)taskDescription;
+(BOOL)updateItem:(YYDownloadModel*)newModel;
// 查
+ (YYDownloadModel *)searchItemWithId:(NSString *)iD;
+ (NSMutableArray *)searchItemWithIDs: (NSMutableArray *)iDs;
+ (NSMutableArray *)searchItemWithKey: (NSString *)key andValues: (NSMutableArray *)values;
+ (NSMutableArray *)searchAll;
@end
