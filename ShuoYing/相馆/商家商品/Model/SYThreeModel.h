//
//  SYThreeModel.h
//  ShuoYing
//
//  Created by 硕影 on 2017/4/28.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYThreeModel : NSObject

@property (nonatomic, copy) NSString *spceName;

@property (nonatomic, strong) NSNumber *num;

@property (nonatomic, strong) NSNumber *money;

@property (nonatomic, copy) NSString *spceVal;

@property (nonatomic, strong) NSNumber *fee;

@property (nonatomic, strong) NSNumber *isSelecte;//默认没选中

@property (nonatomic, strong) NSNumber *width;//文本段度

+ (instancetype)threeWithDictionary:(NSDictionary *)dic;

@end
