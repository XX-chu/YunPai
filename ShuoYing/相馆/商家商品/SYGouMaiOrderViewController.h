//
//  SYGouMaiOrderViewController.h
//  ShuoYing
//
//  Created by 硕影 on 2017/5/6.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYBaseViewController.h"
@class SYOneModel;
@class SYTwoModel;
@class SYThreeModel;
@interface SYGouMaiOrderViewController : SYBaseViewController

@property (nonatomic, strong) NSDictionary *dataSourceDic;

@property (nonatomic, assign) NSInteger selecteCount;

@property (nonatomic, copy) NSString *shangpinShuxing;

@property (nonatomic, weak) SYOneModel *oneModel;

@property (nonatomic, weak) SYTwoModel *twoModel;

@property (nonatomic, weak) SYThreeModel *threeModel;

@property (nonatomic, weak) NSNumber *gouwucheID;
@end
