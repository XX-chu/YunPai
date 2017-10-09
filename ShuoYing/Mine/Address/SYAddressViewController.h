//
//  SYAddressViewController.h
//  ShuoYing
//
//  Created by 硕影 on 2016/12/26.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import "SYBaseViewController.h"
@class SYAddressModel;

@protocol SelectedAddressDelegate <NSObject>

- (void)selectedAddressWithAddressModel:(SYAddressModel *)model;

@end

@interface SYAddressViewController : SYBaseViewController

@property (nonatomic, weak) id<SelectedAddressDelegate> delegate;

@end
