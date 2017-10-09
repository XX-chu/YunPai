//
//  SYAnnotationView.h
//  ShuoYing
//
//  Created by 硕影 on 2017/5/10.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface SYAnnotationView : MKAnnotationView
/// 创建大头针控件
+ (instancetype)q_annotationViewWithMapView:(MKMapView *)mapView;
@end
