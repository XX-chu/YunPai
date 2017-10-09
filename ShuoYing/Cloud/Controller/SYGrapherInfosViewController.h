//
//  SYGrapherInfosViewController.h
//  ShuoYing
//
//  Created by 硕影 on 2017/1/13.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYBaseViewController.h"
@class SYCloudContentFrameModel;
@interface SYGrapherInfosViewController : SYBaseViewController

@property (nonatomic, strong) NSNumber *grapherID;

@property (nonatomic, assign) BOOL isFirst;

@property (nonatomic, assign) BOOL isFromShouye;

@property (nonatomic, strong) SYCloudContentFrameModel *frameModel;

@property (nonatomic, strong) NSNumber *uid;//回复人的id
@end
