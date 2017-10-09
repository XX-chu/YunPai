//
//  XBUpdatePhotoManager.h
//  ShuoYing
//
//  Created by 硕影 on 2016/12/30.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^UpdatePhotoResult)(NSDictionary *dic);

@interface XBUpdatePhotoManager : NSObject

+ (instancetype)sharedInstance;
//base64上传
- (void)updatePhotosWithUrl:(NSString *)url param:(NSDictionary *)param view:(UIView *)view result:(UpdatePhotoResult)result;

//以文件形式上传
- (void)updatePhotosWithFile:(NSString *)url param:(NSDictionary *)param fileData:(NSData *)filedata name:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType currentNumber:(NSInteger)currentNumber allNumber:(NSInteger)allNumber result:(UpdatePhotoResult)result;
@end
