//
//  SYTeacherAndGrapherModel.h
//  ShuoYing
//
//  Created by 硕影 on 2017/1/11.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYTeacherAndGrapherModel : NSObject

@property (nonatomic, strong) NSNumber *ID;

@property (nonatomic, copy) NSString *img;

@property (nonatomic, copy) NSString *img_min;

@property (nonatomic, copy) NSString *img_200;

@property (nonatomic, copy) NSString *tel;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, strong) NSNumber *state;//0未下载 1已下载

@property (nonatomic, strong) NSNumber *isSelected; //是否选中

- (instancetype)initWithDictionary:(NSDictionary *)dic;

+ (instancetype)modelWithDictionary:(NSDictionary *)dic;

@end
