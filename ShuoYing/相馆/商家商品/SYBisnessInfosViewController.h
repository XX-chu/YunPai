//
//  SYBisnessInfosViewController.h
//  ShuoYing
//
//  Created by 硕影 on 2017/4/26.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYBaseViewController.h"

typedef NS_ENUM(NSUInteger, IsFromXSorXXType) {
    isFromXS,
    isFromXX
};

@interface SYBisnessInfosViewController : SYBaseViewController

//@property (nonatomic, strong) NSNumber *shangpinID;//商品id
//
//@property (nonatomic, strong) NSNumber *shangjiaID;//商家id

- (instancetype)initWithIsFromXSorXXType:(IsFromXSorXXType)type shangpinID:(NSNumber *)shangpin shangjiaID:(NSNumber *)shangjia;

@end
