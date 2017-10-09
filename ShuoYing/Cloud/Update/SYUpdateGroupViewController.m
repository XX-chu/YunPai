//
//  SYUpdateGroupViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/2/27.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYUpdateGroupViewController.h"

#import "SYUserInfos.h"
#import "SYIDViewController.h"
#import "SYGrapherCertifiedViewController.h"
#import "SYRenameView.h"
#import "SYFenZuTableViewCell.h"

#import "FTPopOverMenu.h"
#import "SYAddMemberToGroup.h"
#import "SYEditStudentView.h"
#import "SYGroupPhotoViewController.h"
#import "SYGroupPhotosViewController.h"
#import "SYTeacherAddPhotoToStudentViewController.h"
@interface SYUpdateGroupViewController ()<UITableViewDataSource, UITableViewDelegate>

{
    SYUserInfos *_userInfos;
    
    NSArray *_imagesArr;
    NSArray *_contentArr;
    NSArray *_memberImagesArr;
    NSArray *_memberContentArr;
    NSInteger _currentSection;
    
    NSURLSessionTask *_dataTask;
}

@property (nonatomic, strong) NSMutableArray *dataSourceArr;

@property (nonatomic, strong) NSMutableDictionary *allMemberDic;

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SYUpdateGroupViewController

- (void)loadView{
    [super loadView];
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if ([[Tool sharedInstance] getObjectWithPath:Mobile]) {
        _userInfos = [[Tool sharedInstance] getObjectWithPath:Mobile];
        NSLog(@"_userInfos - %@",_userInfos);
        
        switch ([_userInfos.pho integerValue]) {
            case 0:
            {//禁用
                [self jinyong];
            }
                break;
            case 1:
            {//认证通过，是老师
                [self alreadyCertified];

            }
                break;
            case 2:
            {//认证位通过，重新申请
                [self notCertified];
            }
                break;
            case 3:
            {//认证中...
                [self beingCertified];
            }
                break;
                
            default:
                break;
        }
        
        
        
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _imagesArr = @[@"fenzu_icon_cmm",@"fenzu_icon_cmm",@"fenzu_icon_jiahaoyou",@"piliang_icon_qc", @"fenzu_icon_qxc", @"fenzu_icon_sc"];
    _contentArr = @[@"更改协会名称",@"更改个人名称",@"添加成员到协会",@"群发照片",@"协会相册",@"解散协会"];
    _memberImagesArr = @[@"fenzu_icon_cmm",@"fenzu_icon_jiahaoyou",@"piliang_icon_qc",@"fenzu_icon_qxc",@"fenzu_icon_sc"];
    _memberContentArr = @[@"更改个人名称",@"添加成员到协会",@"群发照片",@"协会相册",@"退出该协会"];
    self.view.backgroundColor = BackGroundColor;
    [self getDataFormCache];
    [self getData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSourceArr.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSDictionary *dic = self.dataSourceArr[section];
    NSArray *memberArr = nil;
    if ([[dic objectForKey:@"isOpen"] boolValue]) {
        NSArray *allkeys = [self.allMemberDic allKeys];
        for (NSString *key in allkeys) {
            if ([key isEqualToString:[[dic objectForKey:@"id"] stringValue]]) {
                memberArr = [self.allMemberDic objectForKey:key];
            }
        }
        
        return memberArr.count;
    }else{
        return 0;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"fenzucell";
    SYFenZuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.qunzhuIMGWidthContrains.constant = 0;
    cell.editBtn.enabled = YES;
    [cell.editBtn setImage:[UIImage imageNamed:@"haoyou_icon_bj"] forState:UIControlStateNormal];
    
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"SYFenZuTableViewCell" owner:nil options:nil][0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSArray *memArr = nil;
    NSDictionary *dic = self.dataSourceArr[indexPath.section];
    
    if ([dic objectForKey:@"isOpen"]) {
        memArr = [self.allMemberDic objectForKey:[[dic objectForKey:@"id"] stringValue]];
    }
    
    if ([[dic objectForKey:@"state"] integerValue] == 1) {
        //是群主
        if (memArr.count > 0) {
            if ([[memArr[indexPath.row] objectForKey:@"self"] integerValue] == 1 && [[memArr[indexPath.row] objectForKey:@"state"] integerValue] == 1) {
                
                //是群主且是自己
                cell.nameLabel.text = [memArr[indexPath.row] objectForKey:@"name"];
                cell.nameLabel.textColor = RGB(248, 198, 147);
                [cell.phoneNumBtn setTitle:[memArr[indexPath.row] objectForKey:@"user"] forState:UIControlStateNormal];
//                cell.qunzhuImageView.image = [UIImage imageNamed:@"qunzhu_logo"];
//                cell.qunzhuIMGWidthContrains.constant = 20;
                cell.editBtn.enabled = NO;
                [cell.editBtn setImage:nil forState:UIControlStateNormal];
                
            }else{
                cell.nameLabel.text = [memArr[indexPath.row] objectForKey:@"name"];
                
                [cell.phoneNumBtn setTitle:[memArr[indexPath.row] objectForKey:@"user"] forState:UIControlStateNormal];
                
            }
            
        }
    }else{
        //不是群主要判断是不是群主
        if ([[memArr[indexPath.row] objectForKey:@"state"] integerValue] == 1){
            cell.nameLabel.text = [memArr[indexPath.row] objectForKey:@"name"];
            cell.nameLabel.textColor = RGB(248, 198, 147);
            [cell.phoneNumBtn setTitle:[memArr[indexPath.row] objectForKey:@"user"] forState:UIControlStateNormal];
            cell.qunzhuImageView.image = [UIImage imageNamed:@"qunzhu_logo"];
            cell.qunzhuIMGWidthContrains.constant = 20;
            cell.editBtn.enabled = NO;
            [cell.editBtn setImage:nil forState:UIControlStateNormal];
        }else if ([[memArr[indexPath.row] objectForKey:@"self"] integerValue] == 1){
            cell.nameLabel.text = [memArr[indexPath.row] objectForKey:@"name"];
            cell.nameLabel.textColor = RGB(248, 198, 147);
            [cell.phoneNumBtn setTitle:[memArr[indexPath.row] objectForKey:@"user"] forState:UIControlStateNormal];
            
            cell.editBtn.enabled = NO;
            [cell.editBtn setImage:nil forState:UIControlStateNormal];
        }else{
            cell.nameLabel.text = [memArr[indexPath.row] objectForKey:@"name"];
            [cell.phoneNumBtn setTitle:[memArr[indexPath.row] objectForKey:@"user"] forState:UIControlStateNormal];
            cell.editBtn.enabled = NO;
            [cell.editBtn setImage:nil forState:UIControlStateNormal];
        }
        
    }
    
    cell.callBlock = ^(){
        NSMutableString* str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",[memArr[indexPath.row] objectForKey:@"user"]];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    };
    
    cell.editBlock = ^(){
        SYEditStudentView *view = [[[NSBundle mainBundle] loadNibNamed:@"SYEditStudentView" owner:self options:nil] lastObject];
        view.frame = [UIScreen mainScreen].bounds;
        [view.deleteTitle setTitle:@"删除成员" forState:UIControlStateNormal];
        view.renameTF.placeholder = @"请输入新的名称";
        view.deleteLabel.text = @"确定删除该成员？";
        [view show];
        
        __weak typeof(self)waekself = self;
        
        view.block = ^(NSDictionary *dic){
            BOOL isRenameSelected = [[dic objectForKey:@"renameStudentSelected"] boolValue];
            if (isRenameSelected) {
                
                [waekself renameStudentNameWithIndexPath:indexPath Name:[dic objectForKey:@"studentName"]];
            }else{
                [waekself deleteStudentNameWithIndexPath:indexPath];
            }
        };
        
    };
    
    return cell;
}


#pragma mark - RenameMember
- (void)renameStudentNameWithIndexPath:(NSIndexPath *)indexPath Name:(NSString *)name{
    NSDictionary *dic = self.dataSourceArr[indexPath.section];
    NSArray *memberArr = [self.allMemberDic objectForKey:[[dic objectForKey:@"id"] stringValue]];
    NSNumber *qunzhuID = [memberArr[indexPath.row] objectForKey:@"id"];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/group/editmember.html"];
    NSDictionary *param = @{@"token":UserToken, @"id":qunzhuID, @"name":name};
    
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        NSLog(@"更改学生名字 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                [self getData];
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

#pragma mark - DeleteMember
//删除学生
- (void)deleteStudentNameWithIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *dic = self.dataSourceArr[indexPath.section];
    NSArray *memberArr = [self.allMemberDic objectForKey:[[dic objectForKey:@"id"] stringValue]];
    NSNumber *qunzhuID = [memberArr[indexPath.row] objectForKey:@"id"];
//    for (NSDictionary *dic in memberArr) {
//        if ([[dic objectForKey:@"self"] integerValue] == 1) {
//            //是我自己
//            qunzhuID = [dic objectForKey:@"id"];
//        }
//    }
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/group/delmember.html"];
    NSDictionary *param = @{@"token":UserToken, @"id":qunzhuID};
    
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        NSLog(@"退出或删除成员 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                [self getData];
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SYTeacherAddPhotoToStudentViewController *toMember = [[SYTeacherAddPhotoToStudentViewController alloc] initWithNibName:@"SYNewTeacherAddPhotoToStudentViewController" bundle:nil];
    
    NSDictionary *dic = self.dataSourceArr[indexPath.section];
    NSArray *memberArr = nil;
    if ([[dic objectForKey:@"isOpen"] boolValue]) {
        NSArray *allkeys = [self.allMemberDic allKeys];
        for (NSString *key in allkeys) {
            if ([key isEqualToString:[[dic objectForKey:@"id"] stringValue]]) {
                //拿到对应分区的所有好友
                memberArr = [self.allMemberDic objectForKey:key];
            }
        }
    }
    toMember.isFromGroupToMember = YES;
    toMember.dataSourceDic = memberArr[indexPath.row];
    [self.navigationController pushViewController:toMember animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.tag = section + 100;
    view.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(isOpenAction:)];
    [view addGestureRecognizer:tap];
    view.backgroundColor = [UIColor whiteColor];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, kScreenWidth, 1)];
    lineView.backgroundColor = RGB(242, 242, 242);
    [view addSubview:lineView];
    
    UIButton *arrowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    arrowBtn.frame = CGRectMake(0, 0, 40, 44);
    arrowBtn.userInteractionEnabled = NO;
    if ([[self.dataSourceArr[section] objectForKey:@"isOpen"] boolValue]) {
        [arrowBtn setImage:[UIImage imageNamed:@"shangchuan_icon_sanjiao_sel"] forState:UIControlStateNormal];
    }else{
        [arrowBtn setImage:[UIImage imageNamed:@"shangchuan_icon_sanjiao-_nor"] forState:UIControlStateNormal];
    }
    arrowBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [view addSubview:arrowBtn];
    
    UIImageView *qunzhuIMG = [[UIImageView alloc] init];
    if ([[self.dataSourceArr[section] objectForKey:@"state"] integerValue] == 1) {
        //是群主
        qunzhuIMG.frame = CGRectMake(CGRectGetMaxX(arrowBtn.frame), 0, 20, 44);
        qunzhuIMG.image = [UIImage imageNamed:@"qunzhu_logo"];
        qunzhuIMG.contentMode = UIViewContentModeCenter;
        
    }else{
        qunzhuIMG.frame = CGRectMake(CGRectGetMaxX(arrowBtn.frame), 0, 0, 44);
        qunzhuIMG.image = nil;
    }
    [view addSubview:qunzhuIMG];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(qunzhuIMG.frame), 0, kScreenWidth - 60 - 50, 44)];
    label.font = [UIFont systemFontOfSize:16];
    label.text = [self.dataSourceArr[section] objectForKey:@"name"];
    [view addSubview:label];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(kScreenWidth - 44, 0, 44, 44);
    [btn setImage:[UIImage imageNamed:@"shangchuan_icon_bj"] forState:UIControlStateNormal];
    [btn setAdjustsImageWhenHighlighted:NO];
    btn.tag = section;
    
    [btn addTarget:self action:@selector(editFenZu:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn];
    
    return view;
}

//编辑分组
- (void)editFenZu:(UIButton *)sender{
    _currentSection = sender.tag;
    NSLog(@"_currentSection - %lu",_currentSection);

    if ([[self.dataSourceArr[_currentSection] objectForKey:@"state"] integerValue] == 1) {
        //是群主
        [FTPopOverMenu showForSender:sender withMenu:_contentArr imageNameArray:_imagesArr doneBlock:^(NSInteger selectedIndex) {
            NSLog(@"selectedIndex - %ld",(long)selectedIndex);
            switch (selectedIndex) {
                case 0:
                {
                    SYRenameView *view = [[[NSBundle mainBundle] loadNibNamed:@"SYRenameView" owner:self options:nil] lastObject];
                    view.frame = [UIScreen mainScreen].bounds;
                    view.titleLabel.text = @"更改协会名称";
                    view.renameTF.placeholder = @"请输入新的协会名称";
                    [view show];
                    __weak typeof(self)waekself = self;
                    view.block = ^(NSString *rename){
                        if (rename.length < 3 || rename.length > 12) {
                            [waekself showHint:@"群名字长度3-12个字"];
                            return ;
                        }
                        [waekself renameWithsection:_currentSection NewclassName:rename];
                    };
                    
                }
                    break;
                case 1:
                {
                    //更改个人名称
                    SYRenameView *view = [[[NSBundle mainBundle] loadNibNamed:@"SYRenameView" owner:self options:nil] lastObject];
                    view.titleLabel.text = @"更改个人名称";
                    view.renameTF.placeholder = @"请输入新的名称";
                    view.frame = [UIScreen mainScreen].bounds;
                    [view show];
                    __weak typeof(self)waekself = self;
                    view.block = ^(NSString *rename){
                        if (rename.length < 1 || rename.length > 10) {
                            [waekself showHint:@"昵称长度1-10个字"];
                            return ;
                        }
                        [waekself changeMemberNameWithsection:_currentSection newName:rename];
                    };
                    
                }
                    break;
                case 2:
                {
                    //添加成员到群
                    SYAddMemberToGroup *view = [[[NSBundle mainBundle] loadNibNamed:@"SYAddMemberToGroup" owner:self options:nil] lastObject];
                    view.frame = [UIScreen mainScreen].bounds;
                    [view show];
                    __weak typeof(self)weakself = self;
                    view.block = ^(NSString *phone){
                        
                        if (phone.length == 0) {
                            [weakself showHint:@"请输入成员手机号！"];
                            return ;
                        }
                        
                        [weakself addMemberToGroupWithsection:_currentSection Tel:phone];
                        
                    };
                }
                    break;
                case 3:
                {
                    //群发照片
                    SYGroupPhotoViewController *group = [[SYGroupPhotoViewController alloc] init];
                    group.groupID = [self.dataSourceArr[_currentSection] objectForKey:@"id"];
                    [self.navigationController pushViewController:group animated:YES];
                }
                    break;
                case 4:
                {
                    //群相册
                    SYGroupPhotosViewController *groups = [[SYGroupPhotosViewController alloc] init];
                    groups.groupID = [self.dataSourceArr[_currentSection] objectForKey:@"id"];
                    [self.navigationController pushViewController:groups animated:YES];
                }
                    break;
                case 5:
                {
                    //解散群
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"解散该协会" message:@"解散该协会后，协会成员将被删除" preferredStyle:UIAlertControllerStyleAlert];
                    
                    NSAttributedString *attstr = [[NSAttributedString alloc] initWithString:@"解散该协会后，协会成员将被删除" attributes:@{NSForegroundColorAttributeName : HexRGB(0xfd6868), NSFontAttributeName :[UIFont systemFontOfSize:13]}];
                    [alertController setValue:attstr forKey:@"attributedMessage"];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        return ;
                    }];
                    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        [self deleteFenzuWithsection:sender.tag];
                    }];
                    //修改按钮
                    
                    [cancelAction setValue:[UIColor blackColor] forKey:@"titleTextColor"];
                    [otherAction setValue:[UIColor blackColor] forKey:@"titleTextColor"];
                    
                    [alertController addAction:cancelAction];
                    [alertController addAction:otherAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                }
                    break;
                    
                default:
                    break;
            }
        } dismissBlock:^{
            
        }];
        
    }else{
        [FTPopOverMenu showForSender:sender withMenu:_memberContentArr imageNameArray:_memberImagesArr doneBlock:^(NSInteger selectedIndex) {
            switch (selectedIndex) {
                case 0:
                {
                    //更改个人名称
                    SYRenameView *view = [[[NSBundle mainBundle] loadNibNamed:@"SYRenameView" owner:self options:nil] lastObject];
                    view.titleLabel.text = @"更改个人名称";
                    view.renameTF.placeholder = @"请输入新的名称";
                    view.frame = [UIScreen mainScreen].bounds;
                    [view show];
                    __weak typeof(self)waekself = self;
                    view.block = ^(NSString *rename){
                        if (rename.length < 1 || rename.length > 10) {
                            [waekself showHint:@"昵称长度1-10个字"];
                            return ;
                        }
                        [waekself changeMemberNameWithsection:_currentSection newName:rename];
                    };
                }
                    break;
                case 1:
                {
                    //添加成员到群
                    SYAddMemberToGroup *view = [[[NSBundle mainBundle] loadNibNamed:@"SYAddMemberToGroup" owner:self options:nil] lastObject];
                    view.frame = [UIScreen mainScreen].bounds;
                    view.title.text = @"添加成员到协会";
                    [view show];
                    __weak typeof(self)weakself = self;
                    view.block = ^(NSString *phone){
                        
                        if (phone.length == 0) {
                            [weakself showHint:@"请输入成员手机号！"];
                            return ;
                        }
                        
                        [weakself addMemberToGroupWithsection:_currentSection Tel:phone];
                        
                    };
                }
                    break;
                case 2:
                {
                    //群发照片
                    SYGroupPhotoViewController *group = [[SYGroupPhotoViewController alloc] init];
                    group.groupID = [self.dataSourceArr[_currentSection] objectForKey:@"id"];
                    [self.navigationController pushViewController:group animated:YES];
                }
                    break;
                case 3:
                {
                    //群相册
                    SYGroupPhotosViewController *groups = [[SYGroupPhotosViewController alloc] init];
                    groups.groupID = [self.dataSourceArr[_currentSection] objectForKey:@"id"];
                    [self.navigationController pushViewController:groups animated:YES];
                }
                    break;
                case 4:
                {
                    //解散群
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"退出该协会" message:@"退出该协会后，将无法再接收，群发照片" preferredStyle:UIAlertControllerStyleAlert];
                    NSAttributedString *attstr = [[NSAttributedString alloc] initWithString:@"退出该协会后，将无法再接收，群发照片" attributes:@{NSForegroundColorAttributeName : HexRGB(0xfd6868), NSFontAttributeName :[UIFont systemFontOfSize:13]}];
                    [alertController setValue:attstr forKey:@"attributedMessage"];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        return ;
                    }];
                    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        [self memberOutGroupWithsection:sender.tag];
                    }];
                    //修改按钮
                    
                    [cancelAction setValue:[UIColor blackColor] forKey:@"titleTextColor"];
                    [otherAction setValue:[UIColor blackColor] forKey:@"titleTextColor"];
                    
                    [alertController addAction:cancelAction];
                    [alertController addAction:otherAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                }
                    break;
                    
                default:
                    break;
            }
        } dismissBlock:^{
            
        }];
    }
    
}

#pragma mark - 群主删除群组
//删除该分组
- (void)deleteFenzuWithsection:(NSInteger)section{
    NSDictionary *dic = self.dataSourceArr[section];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/group/delgroup.html"];
    NSDictionary *param = @{@"token":UserToken, @"id":[dic objectForKey:@"id"]};
    
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        NSLog(@"删除群组 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                [self getData];
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
    
}

#pragma mark - 成员退出群
- (void)memberOutGroupWithsection:(NSInteger)section{
    NSDictionary *dic = self.dataSourceArr[section];
    
    NSArray *memberArr = [self.allMemberDic objectForKey:[[dic objectForKey:@"id"] stringValue]];
    NSNumber *qunzhuID = nil;
    for (NSDictionary *dic in memberArr) {
        if ([[dic objectForKey:@"self"] integerValue] == 1) {
            //是我自己
            qunzhuID = [dic objectForKey:@"id"];
        }
    }
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/group/delmember.html"];
    NSDictionary *param = @{@"token":UserToken, @"id":qunzhuID};
    
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        NSLog(@"退出群组 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                [self getData];
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
    
}


//更改群名称
- (void)renameWithsection:(NSInteger)section NewclassName:(NSString *)newclassName{
    NSDictionary *dic = self.dataSourceArr[section];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/group/editgroup.html"];
    NSDictionary *param = @{@"token":UserToken, @"id":[dic objectForKey:@"id"], @"name":newclassName};
    
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        NSLog(@"修改群名称 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                [self getData];
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

//修改个人名称
- (void)changeMemberNameWithsection:(NSInteger)section newName:(NSString *)newName{
    
    NSDictionary *dic = self.dataSourceArr[section];
    NSArray *memberArr = [self.allMemberDic objectForKey:[[dic objectForKey:@"id"] stringValue]];
    NSNumber *qunzhuID = nil;
    for (NSDictionary *dic in memberArr) {
        if ([[dic objectForKey:@"self"] integerValue] == 1) {
            //是我自己
            qunzhuID = [dic objectForKey:@"id"];
        }
    }
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/group/editmember.html"];
    NSDictionary *param = @{@"token":UserToken, @"id":qunzhuID, @"name":newName};
    
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        NSLog(@"修改个人名称 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                [self getData];
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

#pragma mark - addMemberToGroup

- (void)addMemberToGroupWithsection:(NSInteger)section Tel:(NSString *)tel{
    NSLog(@"section -- %lu",section);
    NSDictionary *dic = self.dataSourceArr[section];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/group/addmember.html"];
    NSDictionary *param = @{@"token":UserToken, @"id":[dic objectForKey:@"id"], @"mobile":tel};
   
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        NSLog(@"添加成员 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                [self getMemberWithID:[dic objectForKey:@"id"]];
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}


//展开分组
- (void)isOpenAction:(UITapGestureRecognizer *)tap{
    NSInteger tag = tap.view.tag;
    
    NSMutableDictionary *muDic = self.dataSourceArr[tag - 100];
    
    BOOL isOpen = ![[muDic objectForKey:@"isOpen"] boolValue];
    
    [self updateIsOpenWithSection:tag-100 withValue:[NSNumber numberWithBool:isOpen]];
    
    [self getDataFormCache];

}

#pragma mark - updateUserInfos
- (void)updateIsOpenWithSection:(NSInteger)section withValue:(NSNumber *)isopen{
    NSMutableDictionary *responseResult = [NSMutableDictionary dictionaryWithCapacity:0];
    [responseResult setDictionary:[XHNetworkCache cacheJsonWithURL:[NSString stringWithFormat:@"%@%@",Mobile,@"AllGroup"]]];
    
    NSMutableArray *mudata = [NSMutableArray arrayWithArray:[responseResult objectForKey:@"data"]];
    
    
    NSMutableDictionary *mudic = [NSMutableDictionary dictionaryWithCapacity:0];
    [mudic setDictionary:[responseResult objectForKey:@"data"][section]];
    
    [mudic setObject:isopen forKey:@"isOpen"];
    [mudata replaceObjectAtIndex:section withObject:mudic];
    
    [responseResult setObject:mudata forKey:@"data"];
    
    [XHNetworkCache saveJsonResponseToCacheFile:responseResult andURL:[NSString stringWithFormat:@"%@%@",Mobile,@"AllGroup"]];
}

//禁用
- (void)jinyong{
    
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 30, kScreenWidth, 200)];
    backImageView.contentMode = UIViewContentModeScaleAspectFit;
    backImageView.image = [UIImage imageNamed:@"shenfen_jinzhi"];
    [self.view addSubview:backImageView];
    
}

//未认证
- (void)notCertified{
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 200)];
    backImageView.contentMode = UIViewContentModeScaleAspectFit;
    backImageView.image = [UIImage imageNamed:@"renzheng"];
    [self.view addSubview:backImageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(backImageView.frame) + 20, kScreenWidth, 20)];
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor darkGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"亲爱哒摄影师，请先认证您的身份哟！";
    [self.view addSubview:label];
    
    UIButton *certifierBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    certifierBtn.frame = CGRectMake(kScreenWidth / 3, CGRectGetMaxY(label.frame) + 20, kScreenWidth / 3, 50);
    [certifierBtn setTitle:@"去认证" forState:UIControlStateNormal];
    [certifierBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [certifierBtn setBackgroundImage:[UIImage imageWithColor:NavigationColor Size:certifierBtn.frame.size] forState:UIControlStateNormal];
    certifierBtn.layer.cornerRadius = 5;
    certifierBtn.layer.masksToBounds = YES;
    [certifierBtn setAdjustsImageWhenHighlighted:NO];
    [certifierBtn addTarget:self action:@selector(gotoCertifierAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:certifierBtn];
    
}

//已认证
- (void)alreadyCertified{
    if (self.dataSourceArr.count == 0) {
        //说明还没有添加分组
        UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64 - 40 - 70)];
        backImageView.contentMode = UIViewContentModeScaleAspectFit;
        backImageView.image = [UIImage imageNamed:@"chuangjiangroup"];
        [self.view addSubview:backImageView];
        
        UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        addBtn.frame = CGRectMake(0, 0, 110, 50);
        addBtn.center = CGPointMake(kScreenWidth / 2, kScreenHeight - 64 - 40 - 35);
        [addBtn setImage:[UIImage imageNamed:@"laoshi_creationcrowd1"] forState:UIControlStateNormal];
        [addBtn addTarget:self action:@selector(addFenZu:) forControlEvents:UIControlEventTouchUpInside];
        addBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:addBtn];
        [self.view bringSubviewToFront:addBtn];
        
    }else{
        UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        addBtn.frame = CGRectMake(0, 0, 110, 50);
        addBtn.center = CGPointMake(kScreenWidth / 2, kScreenHeight - 40 - 35 - 64);
        [addBtn setImage:[UIImage imageNamed:@"laoshi_creationcrowd1"] forState:UIControlStateNormal];
        [addBtn addTarget:self action:@selector(addFenZu:) forControlEvents:UIControlEventTouchUpInside];
        addBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:addBtn];
        
        
        [self.view addSubview:self.tableView];
        if (self.tableView) {
            [self.tableView reloadData];
        }
        
        [self.view bringSubviewToFront:addBtn];
    }
    
}

- (void)addFenZu:(UIButton *)sender{
    
    SYRenameView *view = [[[NSBundle mainBundle] loadNibNamed:@"SYRenameView" owner:self options:nil] lastObject];
    view.frame = [UIScreen mainScreen].bounds;
    view.renameTF.placeholder = @"请输入群名称（协会、团体等）";
    view.titleLabel.text = @"创建云拍群";
    [view show];
    __weak typeof(self)waekself = self;
    view.block = ^(NSString *rename){
        if (rename.length < 3 || rename.length > 12) {
            [waekself showHint:@"群名字3-12个字"];
            return ;
        }
        [waekself addGroup:rename];
    };
}

//添加分组
- (void)addGroup:(NSString *)groupName{
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/group/addgroup.html"];
    NSDictionary *param = @{@"token":UserToken, @"name":groupName};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        NSLog(@"创建群组 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                [self getData];
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}



//认证中
- (void)beingCertified{
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 200)];
    backImageView.contentMode = UIViewContentModeScaleAspectFit;
    backImageView.image = [UIImage imageNamed:@"shenhe"];
    [self.view addSubview:backImageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(backImageView.frame) + 20, kScreenWidth, 20)];
    label.font = [UIFont systemFontOfSize:16];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor darkGrayColor];
    label.text = @"审核中，请耐心等待......";
    [self.view addSubview:label];
}

- (void)getData{
    //获取图片
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/group/classgroup.html"];
    NSDictionary *param = @{@"token":UserToken};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        if ([self.tableView.mj_header isRefreshing]) {
            [self.tableView.mj_header endRefreshing];
        }
        NSLog(@"获取群列表 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                if ([XHNetworkCache cacheJsonWithURL:[NSString stringWithFormat:@"%@%@",Mobile,@"AllGroup"]]) {
                    NSMutableDictionary *cacheMudic = [NSMutableDictionary dictionaryWithCapacity:0];
                    [cacheMudic setDictionary:[XHNetworkCache cacheJsonWithURL:[NSString stringWithFormat:@"%@%@",Mobile,@"AllGroup"]]];
                    
                    NSMutableDictionary *mudics = [NSMutableDictionary dictionaryWithCapacity:0];
                    [mudics setDictionary:responseResult];
                    if ([responseResult objectForKey:@"data"] && [(NSArray *)[responseResult objectForKey:@"data"] count] > 0) {
                        NSMutableArray *mudata = [NSMutableArray arrayWithArray:[responseResult objectForKey:@"data"]];
                        NSMutableArray *cachedata = [NSMutableArray arrayWithArray:[cacheMudic objectForKey:@"data"]];
                        for (int i = 0; i < mudata.count; i++) {
                            NSMutableDictionary *mudic = [NSMutableDictionary dictionaryWithCapacity:0];
                            [mudic setDictionary:[responseResult objectForKey:@"data"][i]];
                            NSNumber *number = nil;
                            if (cachedata.count > i) {
                                number = [(NSDictionary *)[cacheMudic objectForKey:@"data"][i] objectForKey:@"isOpen"];
                                if (number == nil || [number isKindOfClass:[NSNull class]]) {
                                    number = [NSNumber numberWithBool:NO];
                                }
                                //获取所有分组的好友
                                if ([number boolValue]) {
                                    [self getMemberWithID:[mudic objectForKey:@"id"]];
                                }
                                [mudic setObject:number forKey:@"isOpen"];
                                
                            }
                            
                            [mudata replaceObjectAtIndex:i withObject:mudic];
                        }
                        [mudics setObject:mudata forKey:@"data"];
                    }
                    
                    [XHNetworkCache saveJsonResponseToCacheFile:mudics andURL:[NSString stringWithFormat:@"%@%@",Mobile,@"AllGroup"]];
                }else{
                    NSMutableDictionary *mudics = [NSMutableDictionary dictionaryWithCapacity:0];
                    [mudics setDictionary:responseResult];
                    if ([responseResult objectForKey:@"data"] && [(NSArray *)[responseResult objectForKey:@"data"] count] > 0) {
                        NSMutableArray *mudata = [NSMutableArray arrayWithArray:[responseResult objectForKey:@"data"]];
                        
                        for (int i = 0; i < mudata.count; i++) {
                            NSMutableDictionary *mudic = [NSMutableDictionary dictionaryWithCapacity:0];
                            [mudic setDictionary:[responseResult objectForKey:@"data"][i]];
                            NSNumber *number = [NSNumber numberWithBool:NO];
                            [mudic setObject:number forKey:@"isOpen"];
                            [mudata replaceObjectAtIndex:i withObject:mudic];
                        }
                        [mudics setObject:mudata forKey:@"data"];
                    }
                    
                    [XHNetworkCache saveJsonResponseToCacheFile:mudics andURL:[NSString stringWithFormat:@"%@%@",Mobile,@"AllGroup"]];
                }
                
                if ([(NSArray *)[responseResult objectForKey:@"data"] count] > 0) {
                    [self getDataFormCache];
                }
            }else{
//                if ([responseResult objectForKey:@"msg"]) {
//                    [self showHint:[responseResult objectForKey:@"msg"]];
//                }
            }
        }
    }];
}

//获取群租成员
- (void)getMemberWithID:(NSNumber *)groupID{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/group/listgroup.html"];
    NSDictionary *param = @{@"token":UserToken, @"id":groupID};
    __weak typeof(self)weakself = self;
    _dataTask = [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        NSLog(@"获取群租成员 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                //把获取的成员根据群租id保存在本地
                
                [XHNetworkCache saveJsonResponseToCacheFile:responseResult andURL:[NSString stringWithFormat:@"%@%@%@",Mobile,@"AllGroup",[groupID stringValue]]];
                [self getMemberFromChcheWithGroupID:groupID];
                
                
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [weakself showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (void)getDataFormCache{
    if ([XHNetworkCache cacheJsonWithURL:[NSString stringWithFormat:@"%@%@",Mobile,@"AllGroup"]]) {
        [self.dataSourceArr removeAllObjects];
        
        NSDictionary *responseResult = [XHNetworkCache cacheJsonWithURL:[NSString stringWithFormat:@"%@%@",Mobile,@"AllGroup"]];
        [self.dataSourceArr addObjectsFromArray:[responseResult objectForKey:@"data"]];
        for (NSDictionary *dic in self.dataSourceArr) {
            if ([dic objectForKey:@"isOpen"]) {
                [self getMemberFromChcheWithGroupID:[dic objectForKey:@"id"]];
            }
        }
        
        [self loadView];
        
    }else{
        [self getData];
    }
}

- (void)getMemberFromChcheWithGroupID:(NSNumber *)groupID{
    if ([XHNetworkCache cacheJsonWithURL:[NSString stringWithFormat:@"%@%@%@",Mobile,@"AllGroup",[groupID stringValue]]]) {
        
        
        NSDictionary *responseResult = [XHNetworkCache cacheJsonWithURL:[NSString stringWithFormat:@"%@%@%@",Mobile,@"AllGroup",[groupID stringValue]]];
        NSArray *data = [responseResult objectForKey:@"data"];
        [self.allMemberDic setValue:data forKey:[groupID stringValue]];
        
        [self.tableView reloadData];
    }else{
        [self getMemberWithID:groupID];
    }
}

#pragma mark - PrivateMethod
- (void)gotoCertifierAction:(UIButton *)sender{
    //根据teacher字段加载不同的view
    if ([_userInfos.idcard integerValue] == 0) {
        //未验证身份证
        SYIDViewController *idcard = [[SYIDViewController alloc] initWithNibName:@"SYIDViewController" bundle:nil];
        idcard.state = isFromGroup;
        [self.navigationController pushViewController:idcard animated:YES];
    }else{
        SYGrapherCertifiedViewController *grapher = [[SYGrapherCertifiedViewController alloc] initWithNibName:@"SYGrapherCertifiedViewController" bundle:nil];
        [self.navigationController pushViewController:grapher animated:YES];
        
    }
    
}

- (NSMutableArray *)dataSourceArr{
    if (!_dataSourceArr) {
        _dataSourceArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSourceArr;
}


- (NSMutableDictionary *)allMemberDic{
    if (!_allMemberDic) {
        _allMemberDic = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _allMemberDic;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64 - 40) style:UITableViewStylePlain];
        _tableView.backgroundColor = BackGroundColor;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self getData];
        }];
    }
    return _tableView;
}

@end
