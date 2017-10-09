//
//  SYPaymentInfosViewController.h
//  ShuoYing
//
//  Created by 硕影 on 2017/1/16.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYBaseViewController.h"

typedef enum : NSUInteger {
    isFromTeacher,
    isFromGrapher,
    isFromYuYueGrapher,
    isFromShouYeXiaZai,
    isFromGroup,
    isFromXSorXX
} IsFrom;

@interface SYPaymentInfosViewController : SYBaseViewController

@property (nonatomic, strong) NSDictionary *dataSourceDic;

- (instancetype)initWithType:(IsFrom)isFrom;

@end
