//
//  SYAnnotationView.m
//  ShuoYing
//
//  Created by 硕影 on 2017/5/10.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYAnnotationView.h"
#import "SYAnnotation.h"
@interface SYAnnotationView ()

/// 自定义大头针子菜单图片视图
@property (nonatomic, strong) UIImageView *iconView;

@end

@implementation SYAnnotationView

#pragma mark - 创建大头针控件

/// 创建大头针控件
+ (instancetype)q_annotationViewWithMapView:(MKMapView *)mapView {
    
    SYAnnotationView *annotationView = (SYAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"qianchia"];
    
    if (annotationView == nil) {
        
        annotationView = [[self alloc] initWithAnnotation:nil reuseIdentifier:@"qianchia"];
    }
    
    return annotationView;
}

/// 重写初始化大头针控件方法
- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        
        // 显示自定义大头针的标题和子标题
        self.canShowCallout = YES;
        
        // 设置自定义大头针的子菜单左边显示一个图片
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.bounds = CGRectMake(0, 0, 40, 50);
        self.iconView = imageView;
        
        // 设置自定义大头针的子菜单左边视图
        self.leftCalloutAccessoryView = self.iconView;
    }
    return self;
}

/// 重写大头针模型的 setter 方法
- (void)setAnnotation:(SYAnnotation *)annotation{
    
    [super setAnnotation:annotation];
    
    // 设置自定义大头针图片
    self.image = [UIImage imageNamed:annotation.icon];
    
    // 设置自定义大头针的子菜单图片
    self.iconView.image = [UIImage imageNamed:annotation.icon];
}

@end
