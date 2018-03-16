//
//  PXDBModel.h
//  PXHelperDemo
//
//  Created by 侯佳男 on 2018/3/13.
//  Copyright © 2018年 侯佳男. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LKDBHelper.h>

@interface PXDBModel : NSObject

@property(nonatomic, strong)NSString *taskKey;
@property(nonatomic, strong)NSString *taskValue;
@property(nonatomic, strong)NSString *fileName;
@property(nonatomic, strong)NSString *downloadUrl;
@property(nonatomic, strong)NSString *iD;
@property(nonatomic, strong)NSData *data;
@property(nonatomic, assign)NSInteger totalLength;
@property(nonatomic, assign)NSInteger currentLength;
@property(nonatomic, assign)BOOL isFinished;
@property(nonatomic, assign)BOOL isPause;
@property(nonatomic, assign)float progress;

@property(nonatomic, assign)NSInteger row;

// 增
+(BOOL)saveItem:(PXDBModel *)model;
// 删
+(BOOL)deleteItemWithId:(NSString*)iD;
+(BOOL)deleteItemWithIDs: (NSMutableArray *)iDs;
+(void)deleteItemWithModels: (NSMutableArray *)models;
+ (BOOL)deleteItemWithKey: (NSString *)key andValues: (NSMutableArray *)values;
+(BOOL)deleteTable;
+(void)deleteAllData;
// 改
+(BOOL)updateItem:(PXDBModel *)newModel WithId:(NSString*)iD;
+(BOOL)updateItem:(PXDBModel*)newModel;
// 查
+ (PXDBModel *)searchItemWithId:(NSString *)iD;
+ (NSMutableArray *)searchItemWithIDs: (NSMutableArray *)iDs;
+ (NSMutableArray *)searchItemWithKey: (NSString *)key andValues: (NSMutableArray *)values;
+ (NSMutableArray *)searchAll;
@end
