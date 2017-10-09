//
//  SYAnnotation.m
//  ShuoYing
//
//  Created by 硕影 on 2017/5/10.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYAnnotation.h"

@implementation SYAnnotation
/// 初始化大头针模型
+ (instancetype)q_annotationWithTitle:(NSString *)title
                             subTitle:(NSString *)subTitle
                                 icon:(NSString *)icon
                           coordinate:(CLLocationCoordinate2D)coordinate{
    
    SYAnnotation *annotation = [[self alloc] init];
    
    annotation.title = title;
    annotation.subtitle = subTitle;
    annotation.icon = icon;
    annotation.coordinate = coordinate;
    
    return annotation;
}
@end
