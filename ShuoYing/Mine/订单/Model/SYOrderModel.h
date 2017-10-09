//
//  SYOrderModel.h
//  ShuoYing
//
//  Created by 硕影 on 2017/4/13.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SYProductModel;

@interface SYOrderModel : NSObject

@property (nonatomic, copy) NSString *name;//店铺名字

@property (nonatomic, strong) NSArray<SYProductModel *> *product;//订单产品数组

@property (nonatomic, strong) NSNumber *money;//订单价格

@property (nonatomic, strong) NSNumber *orderId;//订单id

@property (nonatomic, strong) NSNumber *company;//物流公司

@property (nonatomic, strong) NSNumber *count;//订单产品数量

@property (nonatomic, strong) NSNumber *fee;//邮费

@property (nonatomic, strong) NSNumber *type;//data.type 订单类型(5.预约摄影师，9.线上订单(待付款、待发货、待收货、待评价等)，10.线下订单(待付款、待消费等))

@property (nonatomic, copy) NSString *express;//data.express 线上订单为快递单号，线下消费和摄影师为空

@property (nonatomic, strong) NSNumber *state;//data.state状态(待付款、待发货等)

@property (nonatomic, strong) NSNumber *pid;//data.pid 收钱方id(用户或商家id)

+ (instancetype)orderWithDictionary:(NSDictionary *)dic;

@end
