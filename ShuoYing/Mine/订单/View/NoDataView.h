//
//  NoDataView.h
//  ShuoYing
//
//  Created by 硕影 on 2017/4/1.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^reloadData)();

@interface NoDataView : UIView

//点击重新加载数据
@property (nonatomic, copy)reloadData block;

@end
