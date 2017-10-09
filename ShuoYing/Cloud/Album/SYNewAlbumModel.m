//
//  SYNewAlbumModel.m
//  ShuoYing
//
//  Created by 硕影 on 2016/12/30.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import "SYNewAlbumModel.h"

@implementation SYNewAlbumModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if ([key isEqualToString:@"id"]) {
        self.albumId = value;
    }
}

- (instancetype)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

+ (instancetype)albumWithDictionary:(NSDictionary *)dic{
    return [[self alloc] initWithDictionary:dic];
}

@end
