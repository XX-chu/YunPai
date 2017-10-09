//
//  SYCloudContentFrameModel.m
//  ShuoYing
//
//  Created by 硕影 on 2017/6/21.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYCloudContentFrameModel.h"
#import "SYCloudModel.h"
@implementation SYCloudContentFrameModel

/**
 重写数据模型setter方法

 @param cloudModel 数据模型
 */

- (void)setCloudModel:(SYCloudModel *)cloudModel{
    _cloudModel = cloudModel;
    
    CGFloat userinfoX = 0;
    CGFloat userinfoY = 0;
    CGFloat userinfoWidth = kScreenWidth;
    CGFloat userinfoHeight = 88;
    self.userinfoFrame = CGRectMake(userinfoX, userinfoY, userinfoWidth, userinfoHeight);
    
    CGFloat imagesX = 0;
    CGFloat imagesY = 88;
    CGFloat imagesWidth = kScreenWidth;
    CGFloat imagesHeight = (kScreenWidth - 40) / 3;
    self.imagesFrame = CGRectMake(imagesX, imagesY, imagesWidth, imagesHeight);
    
    CGFloat categaryX = 0;
    CGFloat categaryY = CGRectGetMaxY(self.imagesFrame);
    CGFloat categaryWidth = kScreenWidth;
    CGFloat categaryHeight = 42;
    self.categaryFrame = CGRectMake(categaryX, categaryY, categaryWidth, categaryHeight);
    
    CGFloat commentX = 0;
    CGFloat commentY = CGRectGetMaxY(self.categaryFrame);
    CGFloat commentWidth = kScreenWidth;
    //计算所有评论的高度

    CGFloat commentHeight = [self jisuanCommentHeightWithComments:_cloudModel.reply];
    self.commentFrame = CGRectMake(commentX, commentY, commentWidth, commentHeight);
    
    CGFloat huodongX = 0;
    CGFloat huodongY = CGRectGetMaxY(self.commentFrame);
    CGFloat huodongWidth = kScreenWidth;
    CGFloat huodongHeight = 51;
    self.hudongFrame = CGRectMake(huodongX, huodongY, huodongWidth, huodongHeight);
    
    self.cellHeight = CGRectGetMaxY(self.hudongFrame);
}

- (CGFloat)jisuanCommentHeightWithComments:(NSArray *)reply{
    CGFloat height = 0.0f;
    if (reply.count > 0) {
        for (NSDictionary *dic in reply) {
            if ([(NSNumber *)[dic objectForKey:@"r_id"] integerValue] == 0) {
                //不等于0就是有回复
                NSString *u_nick = [dic objectForKey:@"u_nick"];
                NSString *content = [dic objectForKey:@"content"];
                NSString *str = [NSString stringWithFormat:@"%@:%@",u_nick, content];
                height += [self jisuanCellHeightWithText:str];
            }else{
                NSString *u_nick = [dic objectForKey:@"u_nick"];
                NSString *content = [dic objectForKey:@"content"];
                NSString *r_nick = [dic objectForKey:@"r_nick"];
                NSString *str = [NSString stringWithFormat:@"%@回复%@:%@", r_nick, u_nick, content];
                height += [self jisuanCellHeightWithText:str];
                
            }
            height += 6;
        }
        return height + 24;
    }else{
        return 0;
    }
}

- (CGFloat)jisuanCellHeightWithText:(NSString *)text{
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:16];
    CGSize maxSize = [label sizeThatFits:CGSizeMake(kScreenWidth - 55, MAXFLOAT)];
    return maxSize.height;
}

@end
