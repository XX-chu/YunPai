//
//  SYOrderPaymentViewController.h
//  ShuoYing
//
//  Created by 硕影 on 2017/4/5.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYBaseViewController.h"
@class SYOrderModel;
@interface SYOrderPaymentViewController : SYBaseViewController

@property (nonatomic, strong) SYOrderModel *orderModel;

@property (nonatomic, assign) BOOL isFromXX;

@end
