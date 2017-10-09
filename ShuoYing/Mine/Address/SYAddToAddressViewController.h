//
//  SYAddToAddressViewController.h
//  ShuoYing
//
//  Created by 硕影 on 2016/12/28.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import "SYBaseViewController.h"

@class SYAddressModel;
typedef enum : NSUInteger {
    AddressTypeIsAdd = 0,
    AddressTypeIsEdit,
} AddressType;

@interface SYAddToAddressViewController : SYBaseViewController

@property (nonatomic, strong) SYAddressModel *addressModel;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil AddressType:(AddressType)addressType AddressModel:(SYAddressModel *)addressModel;

@end
