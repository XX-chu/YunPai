//
//  SYPhotographerView.m
//  ShuoYing
//
//  Created by 硕影 on 2017/1/9.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYPhotographerView.h"



@implementation SYPhotographerView

- (void)drawRect:(CGRect)rect{
    [self.updatePhotoBtn setTitle:@"传送照片" forState:UIControlStateNormal];
    [self.updatePhotoBtn setTitleColor:NavigationColor forState:UIControlStateNormal];

    self.updateHistoryLabel.text = @"传送历史";
    
    
    [self.setPriceBtn setTitle:@"设置价格" forState:UIControlStateNormal];
    [self.setPriceBtn setTitleColor:NavigationColor forState:UIControlStateNormal];

    
    
    [self.updateToCloudBtn setTitle:@"发布到首页" forState:UIControlStateNormal];
    [self.updateToCloudBtn setTitleColor:NavigationColor forState:UIControlStateNormal];
    
    
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
}

@end
