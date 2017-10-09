//
//  SYThreeModel.m
//  ShuoYing
//
//  Created by 硕影 on 2017/4/28.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYThreeModel.h"

@implementation SYThreeModel
- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

- (instancetype)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        [muDic setObject:@NO forKey:@"isSelecte"];
        float width = [self initTagWidth:[muDic objectForKey:@"spceName"]];
        [muDic setObject:[NSNumber numberWithFloat:width] forKey:@"width"];
        
        [self setValuesForKeysWithDictionary:muDic];
    }
    return self;
}

+ (instancetype)threeWithDictionary:(NSDictionary *)dic{
    return [[self alloc] initWithDictionary:dic];
}

- (float)initTagWidth:(NSString *)str{
    UILabel *label = [[UILabel alloc] init];
    label.text = str;
    label.font = [UIFont systemFontOfSize:16];
    label.numberOfLines = 1;
    CGSize maxSize = [label sizeThatFits:CGSizeMake(MAXFLOAT, 40)];
    return maxSize.width;
}

@end
