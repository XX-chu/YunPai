//
//  SYMapViewController.m
//  ShuoYing
//
//  Created by chu on 2017/11/11.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYMapViewController.h"
#import <MapKit/MapKit.h>

@interface SYMapViewController ()<MKMapViewDelegate>
{
    NSString *_address;
    NSNumber *_lat;
    NSNumber *_log;
    
    BOOL _first;
}
@property (nonatomic, strong) MKMapView *mapView;

@property (nonatomic, strong) CLGeocoder *gecocoder;

@property (nonatomic, strong) MKPointAnnotation *annotation;

@end

@implementation SYMapViewController

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (_address && _lat && _log) {
        if (self.block) {
            self.block(_address, _lat, _log);
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"具体位置";
    [self initMapView];
}

- (void)initMapView{
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight)];
    self.mapView.mapType = MKMapTypeStandard;
    //设置地图可缩放
    self.mapView.zoomEnabled = YES;
    //设置地图可滚动
    self.mapView.scrollEnabled = YES;
    //设置地图可旋转
    self.mapView.rotateEnabled = YES;
    //设置显示用户显示位置
    self.mapView.showsUserLocation = YES;
    //为MKMapView设置delegate
    self.mapView.delegate = self;
    //    [self locateToLatitude:23.12672 longtitude:113.395];
    [self.view addSubview:self.mapView];
    
    UITapGestureRecognizer *mTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPress:)];
    [self.mapView addGestureRecognizer:mTap];
    
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView{
    NSLog(@"mapViewDidFinishLoadingMap");
    if (!_first) {
        CLLocationCoordinate2D loc = [mapView.userLocation coordinate];
        //放大地图到自身的经纬度位置。
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc, 250, 250);
        [self.mapView setRegion:region animated:YES];
        _first = YES;
    }
    
}

//MapView委托方法，当定位自身时调用
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    
}
   

- (void)tapPress:(UIGestureRecognizer*)gestureRecognizer {
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];//这里touchPoint是点击的某点在地图控件中的位置
    CLLocationCoordinate2D touchMapCoordinate =
    [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];//这里touchMapCoordinate就是该点的经纬度了
    [self.mapView removeAnnotation:self.annotation];
    self.annotation.coordinate = CLLocationCoordinate2DMake(touchMapCoordinate.latitude, touchMapCoordinate.longitude);
    
    [self.gecocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:touchMapCoordinate.latitude longitude:touchMapCoordinate.longitude]  completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        _address = [NSString stringWithFormat:@"%@%@%@", placemarks.firstObject.administrativeArea, placemarks.firstObject.locality, placemarks.firstObject.name];
        CLLocationCoordinate2D bd = [Tool gcj02ToBd09:touchMapCoordinate];
        _lat = [NSNumber numberWithFloat:bd.latitude];
        _log = [NSNumber numberWithFloat:bd.longitude];
        
        self.annotation.coordinate = touchMapCoordinate;
        
        self.annotation.title = placemarks.firstObject.name;
        [self.mapView addAnnotation:self.annotation];
        
    }];
    
//    [self.mapView addAnnotation:an];

}

-(CLGeocoder *)gecocoder{
    if (!_gecocoder) {
        _gecocoder = [[CLGeocoder alloc]init];
    }
    
    return _gecocoder;
}

- (MKPointAnnotation *)annotation{
    if (!_annotation) {
        _annotation = [[MKPointAnnotation alloc] init];
    }
    return _annotation;
}

@end
