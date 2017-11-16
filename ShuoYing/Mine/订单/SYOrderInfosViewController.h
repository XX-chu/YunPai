//
//  SYOrderInfosViewController.h
//  ShuoYing
//
//  Created by 硕影 on 2017/6/3.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYBaseViewController.h"

//typedef NS_ENUM(NSUInteger, orderInfosIsFromType) {
//    isFromMyOrder,
//    isFromShopcart,
//    isFromXSGoumai
//};

typedef NS_ENUM(NSUInteger, OrderType) {
    OrderTypeWeiFuKuan,
    OrderTypeDaiFaHuo,
    OrderTypeDaiShouHuo,
    OrderTypeDaiPingJia,
    OrderTypeYiWanCheng
};

@interface SYOrderInfosViewController : SYBaseViewController

@property (nonatomic, copy) NSDictionary *param;//请求参数

@property (nonatomic, assign) OrderType type;

@end
