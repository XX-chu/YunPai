//
//  Tool.h
//  weiQuanKe
//
//  Created by qtkj on 16/8/5.
//  Copyright © 2016年 马天驰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@interface Tool : NSObject

+ (instancetype)sharedInstance;


/**
 计算文本高度
 
 @param value 文本内容
 @param width 限制宽度
 @param size 字号大小
 @return 计算完毕后高度
 */
- (CGFloat) heightForString:(NSString *)value andWidth:(CGFloat)width fontSize:(CGFloat)size;

- (BOOL)isMobile:(NSString *)mobileNumbel;

- (NSString *)timeWithTimeIntervalString:(NSString *)timeString WithDateFormat:(NSString *)format;

- (NSDictionary *)getCurrentTime;

//距离现在的时间
-(NSString *)getUTCFormateDate:(NSString *)newDate;
//计算label里面有几行
- (NSArray *)getLinesArrayOfStringWithString:(NSString *)string
                                        Font:(UIFont *)font1
                                        Rect:(CGRect)rect1;
//获取私有属性
- (void)getAvalibleClass:(Class)class1;
//整形判断
- (BOOL)isPureInt:(NSString *)string;

//浮点型判断
- (BOOL)isPureFloat:(NSString *)string;

//对模型对象归档保存
- (void)saveObject:(id)object WithPath:(NSString *)path;
//对象模型解档
- (id)getObjectWithPath:(NSString *)path;
//删除归档
- (void)removeObjectWithpath:(NSString *)path;
//判断一个二进制图片是什么类型
- (NSString *)typeForImageData:(NSData *)data;
//地图坐标系转换
/**
 *  @brief  世界标准地理坐标(WGS-84) 转换成 中国国测局地理坐标（GCJ-02）<火星坐标>
 *
 *  ####只在中国大陆的范围的坐标有效，以外直接返回世界标准坐标
 *
 *  @param  location    世界标准地理坐标(WGS-84)
 *
 *  @return 中国国测局地理坐标（GCJ-02）<火星坐标>
 */
+ (CLLocationCoordinate2D)wgs84ToGcj02:(CLLocationCoordinate2D)location;


/**
 *  @brief  中国国测局地理坐标（GCJ-02） 转换成 世界标准地理坐标（WGS-84）
 *
 *  ####此接口有1－2米左右的误差，需要精确定位情景慎用
 *
 *  @param  location    中国国测局地理坐标（GCJ-02）
 *
 *  @return 世界标准地理坐标（WGS-84）
 */
+ (CLLocationCoordinate2D)gcj02ToWgs84:(CLLocationCoordinate2D)location;


/**
 *  @brief  世界标准地理坐标(WGS-84) 转换成 百度地理坐标（BD-09)
 *
 *  @param  location    世界标准地理坐标(WGS-84)
 *
 *  @return 百度地理坐标（BD-09)
 */
+ (CLLocationCoordinate2D)wgs84ToBd09:(CLLocationCoordinate2D)location;


/**
 *  @brief  中国国测局地理坐标（GCJ-02）<火星坐标> 转换成 百度地理坐标（BD-09)
 *
 *  @param  location    中国国测局地理坐标（GCJ-02）<火星坐标>
 *
 *  @return 百度地理坐标（BD-09)
 */
+ (CLLocationCoordinate2D)gcj02ToBd09:(CLLocationCoordinate2D)location;


/**
 *  @brief  百度地理坐标（BD-09) 转换成 中国国测局地理坐标（GCJ-02）<火星坐标>
 *
 *  @param  location    百度地理坐标（BD-09)
 *
 *  @return 中国国测局地理坐标（GCJ-02）<火星坐标>
 */
+ (CLLocationCoordinate2D)bd09ToGcj02:(CLLocationCoordinate2D)location;


/**
 *  @brief  百度地理坐标（BD-09) 转换成 世界标准地理坐标（WGS-84）
 *
 *  ####此接口有1－2米左右的误差，需要精确定位情景慎用
 *
 *  @param  location    百度地理坐标（BD-09)
 *
 *  @return 世界标准地理坐标（WGS-84）
 */
+ (CLLocationCoordinate2D)bd09ToWgs84:(CLLocationCoordinate2D)location;
@end
