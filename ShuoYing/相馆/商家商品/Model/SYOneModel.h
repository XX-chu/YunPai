//
//  SYOneModel.h
//  ShuoYing
//
//  Created by 硕影 on 2017/4/28.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SYTwoModel;
@interface SYOneModel : NSObject

@property (nonatomic, copy) NSString *spceVal;

@property (nonatomic, strong) NSArray<SYTwoModel *> *spces;

@property (nonatomic, copy) NSString *spceName;

@property (nonatomic, strong) NSNumber *fee;

@property (nonatomic, strong) NSNumber *isSelecte;//默认没选中

@property (nonatomic, strong) NSNumber *width;//文本段度

@property (nonatomic, strong) NSNumber *num;//库存

@property (nonatomic, strong) NSNumber *money;

+ (instancetype)oneWithDictionary:(NSDictionary *)dic;

@end
