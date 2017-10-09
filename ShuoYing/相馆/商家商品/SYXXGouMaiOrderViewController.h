//
//  SYXXGouMaiOrderViewController.h
//  ShuoYing
//
//  Created by 硕影 on 2017/5/18.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYBaseViewController.h"
@class SYOneModel;
@class SYTwoModel;
@class SYThreeModel;
@interface SYXXGouMaiOrderViewController : SYBaseViewController

@property (nonatomic, strong) NSNumber *orderid;

@property (nonatomic, strong) NSDictionary *dataSourceDic;

@property (nonatomic, assign) NSInteger selecteCount;

@property (nonatomic, weak) SYOneModel *oneModel;

@property (nonatomic, weak) SYTwoModel *twoModel;

@property (nonatomic, weak) SYThreeModel *threeModel;

@end
