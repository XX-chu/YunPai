//
//  SYTeacherAndGrapherInfosViewController.h
//  ShuoYing
//
//  Created by 硕影 on 2017/1/11.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYBaseViewController.h"

typedef NS_ENUM(NSUInteger, UpdateHistoryType) {
    UpdateHistoryTypeTeacher,
    UpdateHistoryTypeGrapher,
    UpdateHistoryTypeOther,
};

@class SYNewAlbumModel;
@interface SYTeacherAndGrapherInfosViewController : SYBaseViewController

@property (nonatomic, strong) SYNewAlbumModel *model;

@property (nonatomic, assign) UpdateHistoryType type;

@end
