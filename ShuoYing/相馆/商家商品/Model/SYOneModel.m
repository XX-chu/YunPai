//
//  SYOneModel.m
//  ShuoYing
//
//  Created by 硕影 on 2017/4/28.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYOneModel.h"
#import "SYTwoModel.h"



@implementation SYOneModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{

}

- (instancetype)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        [muDic setObject:@NO forKey:@"isSelecte"];
        float width = [self initTagWidth:[muDic objectForKey:@"spceName"]];
        [muDic setObject:[NSNumber numberWithFloat:width] forKey:@"width"];
        if ([dic objectForKey:@"spces"]) {
            NSArray *spces = [dic objectForKey:@"spces"];
            NSMutableArray *muArr = [NSMutableArray arrayWithCapacity:0];
            for (NSDictionary *dic in spces) {
                SYTwoModel *model = [SYTwoModel twoWithDictionary:dic];
                [muArr addObject:model];
            }
            [muDic setObject:muArr forKey:@"spces"];
        }
        [self setValuesForKeysWithDictionary:muDic];
    }
    return self;
}

+ (instancetype)oneWithDictionary:(NSDictionary *)dic{
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
