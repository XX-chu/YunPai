//
//  SYShopcartTableViewCell.h
//  ShuoYing
//
//  Created by 硕影 on 2017/5/3.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SYShopcartShangpinModel;

typedef void(^DeleteBolck)(NSInteger tag);
typedef void(^AddBlock)(NSInteger tag);
typedef void(^MinutBlock)(NSInteger tag);

@interface SYShopcartTableViewCell : UITableViewCell

@property (nonatomic, strong) SYShopcartShangpinModel *shangpinModel;

@property (nonatomic, copy) DeleteBolck deleteBlock;
@property (nonatomic, copy) AddBlock addBlock;
@property (nonatomic, copy) MinutBlock minutBlock;

@property (nonatomic, assign) BOOL isEdit;
@end
