//
//  SYAnnotation.h
//  ShuoYing
//
//  Created by 硕影 on 2017/5/10.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface SYAnnotation : NSObject

@property (nonatomic, copy)NSString *title;
@property (nonatomic, copy)NSString *subtitle;
@property (nonatomic, copy)NSString *icon;
@property (nonatomic, assign)CLLocationCoordinate2D coordinate;

/// 初始化大头针模型
+ (instancetype)q_annotationWithTitle:(NSString *)title
                             subTitle:(NSString *)subTitle
                                 icon:(NSString *)icon
                           coordinate:(CLLocationCoordinate2D)coordinate;

@end
