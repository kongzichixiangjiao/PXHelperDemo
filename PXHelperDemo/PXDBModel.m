//
//  PXDBModel.m
//  PXHelperDemo
//
//  Created by 侯佳男 on 2018/3/13.
//  Copyright © 2018年 侯佳男. All rights reserved.
//


/*
 PXDBModel *model = [[PXDBModel alloc] init];
 model.name = @"jianan1";
 model.iD = @"5";
 NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1520944488227&di=05b5d329ebc36a37ec1b8f6ed75125f7&imgtype=0&src=http%3A%2F%2Fimg.taopic.com%2Fuploads%2Fallimg%2F120727%2F201995-120HG1030762.jpg"]];
 NSLog(@"%@", data);
 model.data = data;
 [PXDBModel saveItem:model];
 
 [PXDBModel deleteItemWithIDs:@[@1, @2]];
 */

#import "PXDBModel.h"

@interface PXDBModel()
@property(nonatomic, strong)NSString* filePath;
@property(nonatomic, strong)LKDBHelper* dbHelper;
@end

@implementation PXDBModel
/*
- (NSString *)filePath
{
    if (!_filePath)
    {
        // document目录下
        NSArray *documentArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
        NSString *document = [documentArray objectAtIndex:0];
        _filePath = [document stringByAppendingPathComponent:@"XPDB"];
    }
    
    NSLog(@"filePath %@", _filePath);
    
    return _filePath;
}

- (LKDBHelper *)dbHelper
{
    if (!_dbHelper)
    {
        _dbHelper = [[LKDBHelper alloc] initWithDBPath:self.filePath];
        
        [_dbHelper dropAllTable];
    }
    
    return _dbHelper;
}
*/

+(BOOL)saveItem:(PXDBModel *)model {
    return [model saveToDB];
}

+(BOOL)deleteItemWithId:(NSString*)iD {
    LKDBHelper *help = [PXDBModel getUsingLKDBHelper];
    NSString* where = [NSString stringWithFormat:@"iD=%@",iD];
    return [help deleteWithClass:[PXDBModel class] where:where];
}

+(BOOL)deleteItemWithModel: (PXDBModel*)model {
   return [model deleteToDB];
}

+(void)deleteItemWithModels: (NSMutableArray *)models {
    for (PXDBModel* model in models) {
        [model deleteToDB];
    }
    [models deleteToDB];
}

+(BOOL)deleteItemWithIDs: (NSMutableArray *)iDs {
//    LKDBHelper *help = [PXDBModel getUsingLKDBHelper];
//    NSDictionary *where = @{@"iD":iDs};
//    return [help deleteWithClass:[PXDBModel class] where:where];
    return [PXDBModel deleteWithWhere:[NSString stringWithFormat:@"iD in %@",iDs]];
}
+ (BOOL)deleteItemWithKey: (NSString *)key andValues: (NSMutableArray *)values {
    return [PXDBModel deleteWithWhere:[NSString stringWithFormat:@"%@ in %@", key, values]];
}

+(void)deleteAllData {
    [LKDBHelper clearTableData: [PXDBModel class]];
}

+(BOOL)deleteTable {
    LKDBHelper *help = [PXDBModel getUsingLKDBHelper];
    return [help deleteWithClass:[PXDBModel class] where:nil];
}

+(BOOL)updateItem:(PXDBModel*)newModel WithId:(NSString*)iD {
    NSString *where = [NSString stringWithFormat:@"iD = '%@'", iD];
    return [PXDBModel updateToDB:newModel where:where];
}

+(BOOL)updateItem:(PXDBModel*)newModel {
    return [PXDBModel updateToDB:newModel where:nil];
}

+ (PXDBModel *)searchItemWithId:(NSString *)iD {
    LKDBHelper *help = [PXDBModel getUsingLKDBHelper];
    NSMutableArray *myWork =[help searchSingle:[PXDBModel class] where:[NSString stringWithFormat:@"iD=%@",iD] orderBy:nil];
    return myWork.firstObject;
}

+ (NSMutableArray *)searchItemWithKey: (NSString *)key andValues: (NSMutableArray *)values {
     return [PXDBModel searchWithWhere:[NSString stringWithFormat:@"%@ in %@",key, values]];
}

+ (NSMutableArray *)searchItemWithIDs: (NSMutableArray *)iDs {
    return [PXDBModel searchWithWhere:[NSString stringWithFormat:@"iD in %@",iDs]];
}

+ (NSMutableArray *)searchAll {
    return [PXDBModel searchWithWhere:nil orderBy:nil offset:0 count:1000];
}


+ (NSString *)getTableName {
    return @"PXDBModel";
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
