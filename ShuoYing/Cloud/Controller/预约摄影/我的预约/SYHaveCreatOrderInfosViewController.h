//
//  SYHaveCreatOrderInfosViewController.h
//  ShuoYing
//
//  Created by chu on 2017/11/15.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYBaseViewController.h"
#import "SYYuYueOrderModel.h"
typedef NS_ENUM(NSUInteger, OrderState) {
    OrderStateYuYueZhong,
    OrderStateDaiPaiShe,
    OrderStateDaiPingJia,
    OrderStateYiWanCheng,
};
@interface SYHaveCreatOrderInfosViewController : SYBaseViewController

- (instancetype)initWithOrderid:(NSString *)orderid OrderState:(OrderState)orderState OrderModel:(SYYuYueOrderModel *)orderModel;

@end
