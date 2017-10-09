//
//  SYPhotoNameTableViewCell.h
//  ShuoYing
//
//  Created by 硕影 on 2017/4/24.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SYPhotoNameModel;
typedef void(^CallBlock)();
typedef void(^SelecteMap)();
typedef void(^SelecteImageViewBlock)();
@interface SYPhotoNameTableViewCell : UITableViewCell

@property (nonatomic, strong) SYPhotoNameModel *photoNameModel;


@property (nonatomic, copy) CallBlock callblock;

@property (nonatomic, copy) SelecteMap mapBlock;

@property (nonatomic, copy) SelecteImageViewBlock imgBlock;
@end
