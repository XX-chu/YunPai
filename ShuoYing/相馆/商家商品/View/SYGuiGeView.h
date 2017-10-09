//
//  SYGuiGeView.h
//  ShuoYing
//
//  Created by 硕影 on 2017/4/27.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYGuiGeUpView.h"

@class SYOneModel;
@class SYTwoModel;
@class SYThreeModel;

typedef void(^AddToShopCart)(SYOneModel *one, SYTwoModel *two, SYThreeModel *three, NSInteger count);

@interface SYGuiGeView : UIView

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) SYGuiGeUpView *guigeUpView;

//@property (nonatomic, strong) NSDictionary *dataSourceDic;
//
//@property (nonatomic, strong) NSArray *dataSourceArr;//存放的对象模型

@property (nonatomic, copy) NSString *imgUrl;

@property (nonatomic, copy) NSString *money;

@property (nonatomic, copy) AddToShopCart shopcartBlock;

- (instancetype)initWithFrame:(CGRect)frame WithDataSourceArr:(NSArray *)dataSourceArr WithDataSourceDic:(NSDictionary *)dataSourceDic WithOneModel:(SYOneModel *)oneModel WithTwoModel:(SYTwoModel *)twoModel WithThreeModel:(SYThreeModel *)threeModel WithSelecteCount:(NSInteger)selecteCount;

- (void)show;

- (void)dismiss;

@end
