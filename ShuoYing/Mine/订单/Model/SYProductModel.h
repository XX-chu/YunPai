//
//  SYProductModel.h
//  ShuoYing
//
//  Created by 硕影 on 2017/4/13.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYProductModel : NSObject

@property (nonatomic, copy) NSString *attr;//商品的名字

@property (nonatomic, strong) NSNumber *productId;//商品的id

@property (nonatomic, copy) NSString *img_200;//商品的图片

@property (nonatomic, strong) NSNumber *fee;//原价

@property (nonatomic, strong) NSNumber *num;//商品购买的数量

@property (nonatomic, copy) NSString *name;//商品的名字

@property (nonatomic, strong) NSNumber *money;//现价

+ (instancetype)productWithDictionary:(NSDictionary *)dic;

@end
