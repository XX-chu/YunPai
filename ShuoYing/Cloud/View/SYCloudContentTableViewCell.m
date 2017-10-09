//
//  SYCloudContentTableViewCell.m
//  ShuoYing
//
//  Created by 硕影 on 2017/6/21.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYCloudContentTableViewCell.h"
#import "SYCloudContentFrameModel.h"
#import "SYCloudModel.h"
#import "SYCloudCommentContentTableViewCell.h"
@interface SYCloudContentTableViewCell ()<UITableViewDelegate, UITableViewDataSource>
{
    //用户详情视图的子控件
    UIImageView *_headerImageView;
    UILabel *_nicknameLabel;
    UILabel *_timeLabel;
    UILabel *_downloadCountLabel;
    NSInteger _guanzhuType;//0是自己发布 1是没关注 2已关注
    //发布作品类型
    UILabel *_typeLabel;
    
    //评论
    UITableView *_commentTableView;
    
    //当前选中的评论的indexpath
    NSIndexPath *_currentSelecteCommentIndexpath;
}

@property (nonatomic, copy) NSMutableArray *huodongBtnsArr;

@property (nonatomic, copy) NSMutableArray *imagesArr;

@end

@implementation SYCloudContentTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.bounds = [UIScreen mainScreen].bounds;
}

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *identifier = @"cell3";
    SYCloudContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[SYCloudContentTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews{
    [self initUserinfosView];
    [self initImagesView];
    [self initCategaryView];
    [self initCommentView];
    [self initHuodongView];
}

- (void)setFrameModel:(SYCloudContentFrameModel *)frameModel{
    _frameModel = frameModel;
    //设置Frame
    [self settingFrame];
    //赋值
    [self settingData];
}

- (void)settingFrame{
    
    self.userinfosView.frame = self.frameModel.userinfoFrame;
    self.imagesView.frame = self.frameModel.imagesFrame;
    self.categaryView.frame = self.frameModel.categaryFrame;
    self.commentView.frame = self.frameModel.commentFrame;
    self.hudongView.frame = self.frameModel.hudongFrame;

}

- (void)settingData{
    SYCloudModel *model = self.frameModel.cloudModel;
    //个人信息
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,model.head]] placeholderImage:NoPicture];
    _nicknameLabel.text = model.nick;
    _downloadCountLabel.text = model.info;
    
    NSString *str = [[Tool sharedInstance] getUTCFormateDate:model.addtime];
    _timeLabel.text = str;
    if ([model.my integerValue] == 0) {
        //不是自己发布
        if ([model.follow integerValue] == 0) {
            //没有关注
            [self.guanzhuBtn setImage:[UIImage imageNamed:@"shouye_follow"] forState:UIControlStateNormal];
            _guanzhuType = 1;
        }else{
            [self.guanzhuBtn setImage:[UIImage imageNamed:@"shouye_unfollow"] forState:UIControlStateNormal];
            _guanzhuType = 2;
        }
        
    }else{
        //是自己发布
        _guanzhuType = 0;
        [self.guanzhuBtn setImage:[UIImage imageNamed:@"shouye_myproduction_delete"] forState:UIControlStateNormal];
    }
    //图片
    for (int i = 0; i < model.imgs.count; i++) {
        UIImageView *imageView = self.imagesArr[i];
        [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,model.imgs[i]]] placeholderImage:NoPicture];
    }
    //评论
    _commentTableView.frame = CGRectMake(45, 15, kScreenWidth - 55, self.frameModel.commentFrame.size.height - 25);
    [_commentTableView reloadData];
    //类型
    _typeLabel.text = [model.type componentsJoinedByString:@" "];
    
    //互动
    if ([model.reply_count integerValue] == 0) {
        UIButton *btn = self.huodongBtnsArr[0];
        [btn setTitle:@"评论" forState:UIControlStateNormal];
    }else{
        UIButton *btn = self.huodongBtnsArr[0];
        [btn setTitle:[model.reply_count stringValue] forState:UIControlStateNormal];
    }
    
    if ([model.agree integerValue] == 0) {
        //没点赞
        UIButton *btn = self.huodongBtnsArr[1];
        if ([model.agree_count integerValue] == 0) {
            [btn setTitle:@"点赞" forState:UIControlStateNormal];
        }else{
            [btn setTitle:[model.agree_count stringValue] forState:UIControlStateNormal];
        }
        [btn setImage:[UIImage imageNamed:@"shouye_production_like_nor"] forState:UIControlStateNormal];
    }else{
        UIButton *btn = self.huodongBtnsArr[1];
        [btn setTitle:[model.agree_count stringValue] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"shouye_production_like_sel"] forState:UIControlStateNormal];
    }
    
}

- (void)initUserinfosView{
    UIView *userinfos = [[UIView alloc] init];
    userinfos.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:userinfos];
    self.userinfosView = userinfos;
    
    UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15, 58, 58)];
    headerImageView.layer.cornerRadius = 58 / 2;
    headerImageView.layer.masksToBounds = YES;
    [userinfos addSubview:headerImageView];
    _headerImageView = headerImageView;
    [self.userinfosView addSubview:headerImageView];
    
    UILabel *nicknameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(headerImageView.frame) + 13, 15, kScreenWidth - 20 - 70 - 58 - 13, 17)];
    nicknameLabel.font = [UIFont systemFontOfSize:16];
    [userinfos addSubview:nicknameLabel];
    _nicknameLabel = nicknameLabel;
    [self.userinfosView addSubview:nicknameLabel];
    
    //时间imageview
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(headerImageView.frame) + 13, CGRectGetMaxY(nicknameLabel.frame) + 6, 16, 16)];
    [userinfos addSubview:imageView];
    imageView.image = [UIImage imageNamed:@"shouye_myproduction_issuetime"];
    imageView.contentMode = UIViewContentModeCenter;
    [self.userinfosView addSubview:imageView];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 5, CGRectGetMinY(imageView.frame), kScreenWidth - 20 - 70 - 58 - 13 - 21, 16)];
    timeLabel.textColor = HexRGB(0x676767);
    timeLabel.font = [UIFont systemFontOfSize:14];
    [userinfos addSubview:timeLabel];
    _timeLabel = timeLabel;
    [self.userinfosView addSubview:timeLabel];
    
    UILabel *downloadCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(headerImageView.frame) + 13, CGRectGetMaxY(imageView.frame) + 6, kScreenWidth - 20 - 58 - 13, 15)];
    downloadCountLabel.textColor = HexRGB(0x676767);
    downloadCountLabel.font = [UIFont systemFontOfSize:14];
    [userinfos addSubview:downloadCountLabel];
    _downloadCountLabel = downloadCountLabel;
    [self.userinfosView addSubview:downloadCountLabel];
    //右边按钮
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(kScreenWidth - 80, 15, 70, 30);
    [btn setAdjustsImageWhenHighlighted:NO];
    [btn addTarget:self action:@selector(shifouGuanzhuAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.userinfosView addSubview:btn];
    self.guanzhuBtn = btn;
}

#pragma mark - 是否关注
- (void)shifouGuanzhuAction:(UIButton *)sender{
    if (self.guanzhuBlock) {
        self.guanzhuBlock(_guanzhuType);
    }
}

- (void)initImagesView{
    UIView *imagesView = [[UIView alloc] init];
    imagesView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:imagesView];
    self.imagesView = imagesView;
    
    [self.imagesArr removeAllObjects];
    for (int i = 0; i < 3; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10 * i + i * ((kScreenWidth - 40) / 3) + 10, 0, (kScreenWidth - 40) / 3, (kScreenWidth - 40) / 3)];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(SelecteImagesView:)];
        [imageView addGestureRecognizer:tap];
        imageView.userInteractionEnabled = YES;
        imageView.tag = i;
        [self.imagesView addSubview:imageView];
        [self.imagesArr addObject:imageView];
    }
}

- (void)SelecteImagesView:(UITapGestureRecognizer *)tap{
    UIView *tapVoew = tap.view;
    if (self.selecteImageView) {
        self.selecteImageView(tapVoew.tag);
    }
}

- (void)initCategaryView{
    UIView *categaryView = [[UIView alloc] init];
    categaryView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:categaryView];
    self.categaryView = categaryView;
    
    //分享内容的类型
    UIImageView *typeIMG = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12, 20, 20)];
    typeIMG.image = [UIImage imageNamed:@"shouye_production_classify_label"];
    typeIMG.contentMode = UIViewContentModeCenter;
    [self.categaryView addSubview:typeIMG];
    
    UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(typeIMG.frame) + 10, 11, kScreenWidth - 50, 20)];
    typeLabel.textColor = HexRGB(0x8a8b8e);
    typeLabel.font = [UIFont systemFontOfSize:15];
    _typeLabel = typeLabel;
    [self.categaryView addSubview:typeLabel];
}

- (void)initCommentView{
    UIView *commentView = [[UIView alloc] init];
    commentView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:commentView];
    self.commentView= commentView;
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
    lineView.backgroundColor = HexRGB(0xeaeaea);
    [self.commentView addSubview:lineView];
    
    UIImageView *logo = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 25, 22)];
    logo.image = [UIImage imageNamed:@"shouye_production_comment"];
    [self.commentView addSubview:logo];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.bounces = NO;
    tableView.scrollEnabled = NO;
    [self.commentView addSubview:tableView];
    _commentTableView = tableView;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    SYCloudModel *model = self.frameModel.cloudModel;
    NSArray *reply = model.reply;
    return reply.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"commentCell";
    SYCloudCommentContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"SYCloudCommentContentTableViewCell" owner:nil options:nil][0];
    }
    
    SYCloudModel *model = self.frameModel.cloudModel;
    NSArray *reply = model.reply;
    if (reply.count > 0) {
        NSDictionary *dic = reply[indexPath.row];
        if ([(NSNumber *)[dic objectForKey:@"r_id"] integerValue] == 0) {
            //不等于0就是有回复
            NSString *u_nick = [dic objectForKey:@"u_nick"];
            NSString *content = [dic objectForKey:@"content"];
            NSString *str = [NSString stringWithFormat:@"%@:%@",u_nick, content];
            NSMutableAttributedString *muStr = [[NSMutableAttributedString alloc] initWithString:str];
            [muStr addAttribute:NSForegroundColorAttributeName value:HexRGB(0x3dcfbb) range:NSMakeRange(0, u_nick.length)];
            [muStr addAttribute:NSForegroundColorAttributeName value:HexRGB(0x434343) range:NSMakeRange(u_nick.length, 1)];
            [muStr addAttribute:NSForegroundColorAttributeName value:HexRGB(0x8a8b8e) range:NSMakeRange(u_nick.length + 1, content.length)];
            cell.commentContentLabel.attributedText = muStr;
        }else{
            NSString *u_nick = [dic objectForKey:@"u_nick"];
            NSString *content = [dic objectForKey:@"content"];
            NSString *r_nick = [dic objectForKey:@"r_nick"];
            NSString *str = [NSString stringWithFormat:@"%@回复%@:%@",  u_nick, r_nick, content];
            NSMutableAttributedString *muStr = [[NSMutableAttributedString alloc] initWithString:str];
            [muStr addAttribute:NSForegroundColorAttributeName value:HexRGB(0x3dcfbb) range:NSMakeRange(0, u_nick.length)];
            [muStr addAttribute:NSForegroundColorAttributeName value:HexRGB(0x434343) range:NSMakeRange(u_nick.length, 2)];
            [muStr addAttribute:NSForegroundColorAttributeName value:HexRGB(0x3dcfbb) range:NSMakeRange(u_nick.length + 2, r_nick.length)];
            [muStr addAttribute:NSForegroundColorAttributeName value:HexRGB(0x8a8b8e) range:NSMakeRange(u_nick.length + 2 + r_nick.length, 1)];
            [muStr addAttribute:NSForegroundColorAttributeName value:HexRGB(0x8a8b8e) range:NSMakeRange(u_nick.length + 2 + r_nick.length + 1, content.length)];
            cell.commentContentLabel.attributedText = muStr;
        }
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    SYCloudModel *model = self.frameModel.cloudModel;
    NSArray *reply = model.reply;
    CGFloat height = 0;
    if (reply.count > 0) {
        NSDictionary *dic = reply[indexPath.row];
        if ([(NSNumber *)[dic objectForKey:@"r_id"] integerValue] == 0) {
            //不等于0就是有回复
            NSString *u_nick = [dic objectForKey:@"u_nick"];
            NSString *content = [dic objectForKey:@"content"];
            NSString *str = [NSString stringWithFormat:@"%@:%@",u_nick, content];
            height = [self jisuanCellHeightWithText:str];
        }else{
            NSString *u_nick = [dic objectForKey:@"u_nick"];
            NSString *content = [dic objectForKey:@"content"];
            NSString *r_nick = [dic objectForKey:@"r_nick"];
            NSString *str = [NSString stringWithFormat:@"%@回复%@:%@", r_nick, u_nick, content];
            height = [self jisuanCellHeightWithText:str];
        }
    }
    
    return height + 6;
}

- (CGFloat)jisuanCellHeightWithText:(NSString *)text{
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:16];
    CGSize maxSize = [label sizeThatFits:CGSizeMake(kScreenWidth - 55, MAXFLOAT)];
    return maxSize.height;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _currentSelecteCommentIndexpath = indexPath;
    SYCloudModel *model = self.frameModel.cloudModel;
    NSArray *reply = model.reply;
    NSDictionary *dic = reply[indexPath.row];
    if ([model.my integerValue] == 0) {
        //不是自己发布的
        if ([self.uid integerValue] == [(NSNumber *)[dic objectForKey:@"u_id"] integerValue]) {
            //是我回复的
            SYCloudCommentContentTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            
            [cell becomeFirstResponder]; // 用于UIMenuController显示，缺一不可
            
            UIMenuItem *approve = [[UIMenuItem alloc] initWithTitle:@"删除"action:@selector(deleteComment:)];
            UIMenuController *mymenu = [UIMenuController sharedMenuController];
            [mymenu setMenuItems:[NSArray arrayWithObjects:approve, nil]];
            [mymenu setTargetRect:cell.frame inView:cell.superview];
            
            [mymenu setMenuVisible:YES animated:YES];
            [cell resignFirstResponder];
        }else{
            if (self.selectComment) {
                self.selectComment(indexPath);
            }
        }
        
    }else{
        if ([self.uid integerValue] == [(NSNumber *)[dic objectForKey:@"u_id"] integerValue]) {
            //是我回复的
            SYCloudCommentContentTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            
            [cell becomeFirstResponder]; // 用于UIMenuController显示，缺一不可

            UIMenuItem *approve = [[UIMenuItem alloc] initWithTitle:@"删除"action:@selector(deleteComment:)];
            UIMenuController *mymenu = [UIMenuController sharedMenuController];
            [mymenu setMenuItems:[NSArray arrayWithObjects:approve, nil]];
            [mymenu setTargetRect:cell.frame inView:cell.superview];
            
            [mymenu setMenuVisible:YES animated:YES];
            [cell resignFirstResponder];
        }else{
            SYCloudCommentContentTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            
            [cell becomeFirstResponder]; // 用于UIMenuController显示，缺一不可
            
            UIMenuItem *flag = [[UIMenuItem alloc] initWithTitle:@"回复"action:@selector(huifuComment:)];
            UIMenuItem *approve = [[UIMenuItem alloc] initWithTitle:@"删除"action:@selector(deleteComment:)];
            UIMenuController *mymenu = [UIMenuController sharedMenuController];
            [mymenu setMenuItems:[NSArray arrayWithObjects:flag, approve, nil]];
            [mymenu setTargetRect:cell.frame inView:cell.superview];
            
            [mymenu setMenuVisible:YES animated:YES];
            [cell resignFirstResponder];
        }
        
        
    }

}

- (void)huifuComment:(UIMenuController *)sender{
    if (self.selectComment) {
        self.selectComment(_currentSelecteCommentIndexpath);
    }
}

- (void)deleteComment:(UIMenuController *)sender{
    if (self.deleteComment) {
        self.deleteComment(_currentSelecteCommentIndexpath);
    }
}

// 用于UIMenuController显示，缺一不可
-(BOOL)canBecomeFirstResponder{
    
    return YES;
    
}
// 用于UIMenuController显示，缺一不可
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    
    if (action ==@selector(huifuComment:) || action ==@selector(deleteComment:)){
        
        return YES;
        
    }
    
    return NO;//隐藏系统默认的菜单项
}

#pragma mark - initHudongView
- (void)initHuodongView{
    UIView *huodongView = [[UIView alloc] init];
    huodongView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:huodongView];
    self.hudongView= huodongView;
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
    lineView.backgroundColor = HexRGB(0xeaeaea);
    [self.hudongView addSubview:lineView];
    
    
    [self.huodongBtnsArr removeAllObjects];
    NSArray *texts = @[@"评论", @"点赞", @"分享"];
    NSArray *images = @[@"shouye_production_comment", @"shouye_production_like_nor", @"shouye_production_share"];
    for (int i = 0; i < 3; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(((kScreenWidth - 2) / 3) * i + i * 1, 0, (kScreenWidth - 2) / 3, 50);
        btn.tag = i;
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, -5)];
        [btn setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 5)];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        [btn setTitleColor:HexRGB(0x8a8b8e) forState:UIControlStateNormal];
        
        [btn setTitle:texts[i] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
        [btn setAdjustsImageWhenHighlighted:NO];
        [btn addTarget:self action:@selector(hudongAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.hudongView addSubview:btn];
        [self.huodongBtnsArr addObject:btn];
        if (i == 1) {
            self.zanBtn = btn;
        }
    }
    
    for (int i = 1; i < 3; i ++) {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(((kScreenWidth - 2) / 3) * i, 10, 1, 30)];
        lineView.backgroundColor = HexRGB(0xeaeaea);
        [self.hudongView addSubview:lineView];
    }
}

- (void)hudongAction:(UIButton *)sender{
    if (self.hudongType) {
        self.hudongType(sender.tag);
    }
}

- (void)zanShowAnimation{
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake((kScreenWidth / 3) * 1, -20, kScreenWidth / 3, 50);
    label.text = @"+1";
    label.textColor = NavigationColor;
    label.textAlignment = NSTextAlignmentCenter;
    [self.hudongView addSubview:label];
    
    [UIView animateWithDuration:1 animations:^{
        label.alpha = 0;
        label.frame = CGRectMake((kScreenWidth / 3) * 1, -50, kScreenWidth / 3, 50);
    } completion:^(BOOL finished) {
        [label removeFromSuperview];
    }];
}

- (NSMutableArray *)huodongBtnsArr{
    if (!_huodongBtnsArr) {
        _huodongBtnsArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _huodongBtnsArr;
}

- (NSMutableArray *)imagesArr{
    if (!_imagesArr) {
        _imagesArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _imagesArr;
}

- (CGSize)sizeThatFits:(CGSize)size{
    CGFloat totalHeight = 0;
    totalHeight += [self.userinfosView sizeThatFits:size].height;
    totalHeight += [self.imagesView sizeThatFits:size].height;
    totalHeight += [self.categaryView sizeThatFits:size].height;
    totalHeight += [self.hudongView sizeThatFits:size].height;
    totalHeight += 40;
    return CGSizeMake(size.width, totalHeight);
}

@end
