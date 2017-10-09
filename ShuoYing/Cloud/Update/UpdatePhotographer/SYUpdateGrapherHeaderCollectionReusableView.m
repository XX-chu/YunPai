//
//  SYUpdateGrapherHeaderCollectionReusableView.m
//  ShuoYing
//
//  Created by 硕影 on 2017/1/12.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYUpdateGrapherHeaderCollectionReusableView.h"

@implementation SYUpdateGrapherHeaderCollectionReusableView


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
        view.backgroundColor = [UIColor whiteColor];
        [self addSubview:view];
        self.timeLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 7, 100, 25)];
        self.timeLable.font = [UIFont systemFontOfSize:15];
        self.timeLable.backgroundColor = NavigationColor;
        self.timeLable.textAlignment = NSTextAlignmentCenter;
        self.timeLable.textColor = [UIColor whiteColor];
        [view addSubview:self.timeLable];
    }
    return self;
}


@end
