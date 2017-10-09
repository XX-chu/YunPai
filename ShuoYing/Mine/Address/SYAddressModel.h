//
//  SYAddressModel.h
//  ShuoYing
//
//  Created by 硕影 on 2016/12/28.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYAddressModel : NSObject

@property (nonatomic, copy) NSString *address;//详细地址

@property (nonatomic, strong) NSNumber *addressId;//地址id

@property (nonatomic, strong) NSNumber *state;//是否默认 1是默认

@property (nonatomic, copy) NSString *name;//收货人姓名

@property (nonatomic, copy) NSString *zone;//市县区

@property (nonatomic, copy) NSString *tel;//电话

- (instancetype)initWithDictionary:(NSDictionary *)dic;

+ (instancetype)addressWithDictionary:(NSDictionary *)dic;

@end
