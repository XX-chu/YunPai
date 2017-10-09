//
//  CollectionFootView.h
//  ShuoYing
//
//  Created by 硕影 on 2017/5/2.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^AddBlock)(NSInteger count);
typedef void(^MinutBlock)(NSInteger count);

@interface CollectionFootView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UIButton *minutBtn;

@property (nonatomic, copy) AddBlock addBlock;
@property (nonatomic, copy) MinutBlock minutBlock;

@end
