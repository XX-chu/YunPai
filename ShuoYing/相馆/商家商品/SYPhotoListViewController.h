//
//  SYPhotoListViewController.h
//  ShuoYing
//
//  Created by 硕影 on 2017/5/9.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYBaseViewController.h"

typedef NS_ENUM(NSUInteger, IsFromType) {
    isFromMineKongjian,
    isFromBendiTuku,
};

@interface SYPhotoListViewController : SYBaseViewController

@property (nonatomic, assign) IsFromType fromType;

@property (nonatomic, strong) NSNumber *gouwucheID;//购物车id

@property (nonatomic, assign) NSInteger canSelecteCount;

@end
