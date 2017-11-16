//
//  SYMapViewController.h
//  ShuoYing
//
//  Created by chu on 2017/11/11.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYBaseViewController.h"

typedef void(^SelecteAddressBlock)(NSString *address, NSNumber *lat, NSNumber* log);

@interface SYMapViewController : SYBaseViewController

@property (nonatomic, copy) SelecteAddressBlock block;

@end
