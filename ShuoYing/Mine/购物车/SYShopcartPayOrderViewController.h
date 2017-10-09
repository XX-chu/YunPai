//
//  SYShopcartPayOrderViewController.h
//  ShuoYing
//
//  Created by 硕影 on 2017/5/4.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYBaseViewController.h"

@class SYShopcartShangjiaModel;
@interface SYShopcartPayOrderViewController : SYBaseViewController

//@property (nonatomic, strong) NSArray<SYShopcartShangjiaModel *> *dataSourceArr1;

@property (nonatomic, copy) NSString *allPrice;

@property (nonatomic, strong) NSNumber *orderId;

@property (nonatomic, strong) NSDictionary *param;

@end
