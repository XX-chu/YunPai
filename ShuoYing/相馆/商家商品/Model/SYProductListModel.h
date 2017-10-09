//
//  SYProductListModel.h
//  ShuoYing
//
//  Created by 硕影 on 2017/4/24.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYProductListModel : NSObject

@property (nonatomic, strong) NSNumber *productID;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *img_200;

@property (nonatomic, copy) NSString *fee;

@property (nonatomic, strong) NSNumber *line;//1.线上,2.线下 

@property (nonatomic, strong) NSNumber *num;

@property (nonatomic, copy) NSString *money;

+ (instancetype)productWithDictionary:(NSDictionary *)dic;

@end
