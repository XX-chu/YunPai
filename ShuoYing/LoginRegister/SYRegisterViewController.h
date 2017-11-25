//
//  SYRegisterViewController.h
//  ShuoYing
//
//  Created by 硕影 on 2016/12/28.
//  Copyright © 2016年 硕影. All rights reserved.
//


#import "SYBaseViewController.h"

typedef void(^RegisterSucessBlock)(NSString *phone, NSString *password);

@interface SYRegisterViewController : SYBaseViewController

@property (nonatomic, copy) RegisterSucessBlock sucessBlock;

@end
