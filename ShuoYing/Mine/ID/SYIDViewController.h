//
//  SYIDViewController.h
//  ShuoYing
//
//  Created by 硕影 on 2017/1/5.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYBaseViewController.h"

typedef NS_ENUM(NSUInteger, isFromState) {
    isFromTeacher,
    isFromGrapher,
    isFromGroup,
};

@interface SYIDViewController : SYBaseViewController

@property (nonatomic, assign) isFromState state;

@end
