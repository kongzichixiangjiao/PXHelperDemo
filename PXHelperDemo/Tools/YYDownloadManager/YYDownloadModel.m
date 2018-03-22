//
//  YYDownloadModel.m
//  PXHelperDemo
//
//  Created by 侯佳男 on 2018/3/15.
//  Copyright © 2018年 侯佳男. All rights reserved.
//

#import "YYDownloadModel.h"
#import "LKDBHelper.h"

@interface YYDownloadModel()
@property(nonatomic, strong)LKDBHelper* dbHelper;
@end

@implementation YYDownloadModel


+(NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"iD":@"id", @"fileName":@"title", @"bgImageUrl":@"coverImagesPath", @"downloadUrl":@"videoPath", @"introduction":@"introduction", @"videoMessage":@"conferenceTime"};
}

- (NSString *)fileName {
    NSArray *arr = [_fileName componentsSeparatedByString:@"."];
    if ([[arr lastObject] isEqualToString:@"mp4"]) {
        return _fileName;
    }
    return [NSString stringWithFormat:@"%@.mp4", _fileName];
}

- (instancetype)initWithURLString:(NSString *)URLString
{
    return [self initWithURLString:URLString filePath:nil];
}

- (instancetype)initWithURLString:(NSString *)URLString filePath:(NSString *)filePath
{
    if (self = [self init]) {
        _downloadUrl = URLString;
        _taskDescription = filePath.stringByDeletingLastPathComponent;
        _filePath = filePath;
    }
    return self;
}

+(BOOL)saveItem:(YYDownloadModel *)model {
    return [model saveToDB];
}

+(BOOL)deleteItemWithId:(NSString*)iD {
    LKDBHelper *help = [YYDownloadModel getUsingLKDBHelper];
    NSString* where = [NSString stringWithFormat:@"iD=%@",iD];
    return [help deleteWithClass:[YYDownloadModel class] where:where];
}

+(BOOL)deleteItemWithModel: (YYDownloadModel*)model {
    return [model deleteToDB];
}

+(void)deleteItemWithModels: (NSMutableArray *)models {
    for (YYDownloadModel* model in models) {
        [model deleteToDB];
    }
    [models deleteToDB];
}

+(BOOL)deleteItemWithIDs: (NSMutableArray *)iDs {
    //    LKDBHelper *help = [YYDownloadModel getUsingLKDBHelper];
    //    NSDictionary *where = @{@"iD":iDs};
    //    return [help deleteWithClass:[YYDownloadModel class] where:where];
    return [YYDownloadModel deleteWithWhere:[NSString stringWithFormat:@"iD in %@",iDs]];
}
+ (BOOL)deleteItemWithKey: (NSString *)key andValues: (NSMutableArray *)values {
    return [YYDownloadModel deleteWithWhere:[NSString stringWithFormat:@"%@ in %@", key, values]];
}

+(void)deleteAllData {
    [LKDBHelper clearTableData: [YYDownloadModel class]];
}

+(BOOL)deleteTable {
    LKDBHelper *help = [YYDownloadModel getUsingLKDBHelper];
    return [help deleteWithClass:[YYDownloadModel class] where:nil];
}

+(BOOL)updateItem:(YYDownloadModel*)newModel WithId:(NSString*)iD {
    NSString *where = [NSString stringWithFormat:@"iD = '%@'", iD];
    return [YYDownloadModel updateToDB:newModel where:where];
}

+(BOOL)updateItem:(YYDownloadModel*)newModel WithTaskDescription:(NSString*)taskDescription {
    NSString *where = [NSString stringWithFormat:@"taskDescription = '%@'", taskDescription];
    return [YYDownloadModel updateToDB:newModel where:where];
}

+(BOOL)updateItem:(YYDownloadModel*)newModel {
    return [YYDownloadModel updateToDB:newModel where:nil];
}

+ (YYDownloadModel *)searchItemWithId:(NSString *)iD {
    LKDBHelper *help = [YYDownloadModel getUsingLKDBHelper];
    NSMutableArray *myWork =[help searchSingle:[YYDownloadModel class] where:[NSString stringWithFormat:@"iD=%@",iD] orderBy:nil];
    return myWork.firstObject;
}

+ (NSMutableArray *)searchItemWithKey: (NSString *)key andValues: (NSMutableArray *)values {
    return [YYDownloadModel searchWithWhere:[NSString stringWithFormat:@"%@ in %@",key, values]];
}

+ (NSMutableArray *)searchItemWithIDs: (NSMutableArray *)iDs {
    return [YYDownloadModel searchWithWhere:[NSString stringWithFormat:@"iD in %@",iDs]];
}

+ (NSMutableArray *)searchAll {
    return [YYDownloadModel searchWithWhere:nil orderBy:nil offset:0 count:1000];
}


+ (NSString *)getTableName {
    return @"PXSP";
}

@end

/*
 单条件:
 @"rowid = 1"  或者  @{@"rowid":@1}
 
 多条件：
 @“rowid = 1 and sex = 0"  或者    @{@"rowid":@1,@"sex":@0}
 如果是or类型的条件，则只能用字符串的形式：@"rowid = 1 or sex = 0"
 
 in条件：
 @"rowid in (1,2,3)"   或者     @{@"rowid":@[@1,@2,@3]}
 多条件带in：@"rowid in (1,2,3) and sex=0 "   或者    @{@"rowid":@[@1,@2,@3],@"sex":@0}
 
 时间也只能用字符串：
 @"date >= '2013-04-01 00:00:00'"
 
 like也只能用字符串：
 @"userName like '%%JY%%'"
 */

