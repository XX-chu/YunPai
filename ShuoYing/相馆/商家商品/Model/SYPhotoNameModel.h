//
//  SYPhotoNameModel.h
//  ShuoYing
//
//  Created by 硕影 on 2017/4/24.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYPhotoNameModel : NSObject

@property (nonatomic, copy) NSString *address;

@property (nonatomic, copy) NSString *img;

@property (nonatomic, strong) NSNumber *photoNameID;

@property (nonatomic, strong) NSNumber *fuwu;

@property (nonatomic, strong) NSNumber *wuliu;

@property (nonatomic, strong) NSArray *imgs;

@property (nonatomic, strong) NSNumber *miaoshu;

@property (nonatomic, copy) NSString *tel;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *info;

@property (nonatomic, copy) NSString *longa;

@property (nonatomic, copy) NSString *lat;

+ (instancetype)photoNameWithDictionary:(NSDictionary *)dic;

@end
