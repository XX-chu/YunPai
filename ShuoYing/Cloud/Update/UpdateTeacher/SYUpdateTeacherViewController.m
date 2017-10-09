//
//  SYUpdateTeacherViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2016/12/29.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import "SYUpdateTeacherViewController.h"

#import "SYUserInfos.h"

#import "SYTeacherCertifiedViewController.h"
#import "SYFenZuTableViewCell.h"

#import "FTPopOverMenu.h"

#import "SYTeacherAddPhotoToStudentViewController.h"
#import "SYIDViewController.h"

#import "SYUpdatePreviewViewController.h"

#import "SYAddStudentToClassView.h"
#import "SYRenameView.h"
#import "SYEditStudentView.h"

#import "SYUpdateToClassViewController.h"

#import "SYChangeSchoolViewController.h"

@interface SYUpdateTeacherViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    SYUserInfos *_userInfos;
//    UITextField *_progressText;
    
    NSArray *_imagesArr;
    NSArray *_contentArr;
    
    NSInteger _currentSection;

}

@property (nonatomic, strong) NSMutableArray *dataSourceArr;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *classImagesArr;

@end

@implementation SYUpdateTeacherViewController


- (void)loadView{
    [super loadView];
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if ([[Tool sharedInstance] getObjectWithPath:Mobile]) {
        _userInfos = [[Tool sharedInstance] getObjectWithPath:Mobile];
        
        //根据teacher字段加载不同的view
        switch ([_userInfos.teacher integerValue]) {
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
    _imagesArr = @[@"fenzu_icon_cmm",@"fenzu_icon_jiahaoyou",@"pinliang",@"fenzu_icon_sc"];
    _contentArr = @[@"重命名",@"添加学生到班级",@"群发班级照片",@"删除该班级"];
    self.view.backgroundColor = BackGroundColor;
    
    if ([[Tool sharedInstance] getObjectWithPath:Mobile]) {
        _userInfos = [[Tool sharedInstance] getObjectWithPath:Mobile];
        if ([_userInfos.teacher integerValue] == 1) {
            [self getDataFormCache];
        }
    }
}

- (void)getDataFormCache{
    if ([XHNetworkCache cacheJsonWithURL:[NSString stringWithFormat:@"%@%@",Mobile,@"AllFenZu"]]) {
        [self.dataSourceArr removeAllObjects];
        NSDictionary *responseResult = [XHNetworkCache cacheJsonWithURL:[NSString stringWithFormat:@"%@%@",Mobile,@"AllFenZu"]];
        [self.dataSourceArr addObjectsFromArray:[responseResult objectForKey:@"data"]];
        
        [self loadView];

    }else{
        [self getData];
    }
}

//已认证
- (void)alreadyCertified{
    if (self.dataSourceArr.count == 0) {
        //说明还没有添加分组
        UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64 - 40 - 70)];
        backImageView.contentMode = UIViewContentModeScaleAspectFit;
        backImageView.image = [UIImage imageNamed:@"laoshi_nothing"];
        [self.view addSubview:backImageView];
        
        UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        addBtn.frame = CGRectMake(0, 0, 110, 50);
        addBtn.center = CGPointMake(kScreenWidth / 2, kScreenHeight - 64 - 40 - 35);
        [addBtn setImage:[UIImage imageNamed:@"tianjia_fenzu"] forState:UIControlStateNormal];
        [addBtn addTarget:self action:@selector(addFenZu:) forControlEvents:UIControlEventTouchUpInside];
        addBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:addBtn];
        [self.view bringSubviewToFront:addBtn];
        
    }else{
        UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        addBtn.frame = CGRectMake(0, 0, 110, 50);
        addBtn.center = CGPointMake(kScreenWidth / 2, kScreenHeight - 40 - 35 - 64);
        [addBtn setImage:[UIImage imageNamed:@"tianjia_fenzu"] forState:UIControlStateNormal];
        [addBtn addTarget:self action:@selector(addFenZu:) forControlEvents:UIControlEventTouchUpInside];
        addBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:addBtn];
        
        
        UIView *xingjiView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 30)];
        xingjiView.backgroundColor = BackGroundColor;
        [self.view addSubview:xingjiView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, 66, 20)];
        label.text = @"当前星级:";
        label.font = [UIFont systemFontOfSize:15];
        [xingjiView addSubview:label];
        
        UIImageView *imageVIew = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label.frame) + 5, 5, 84, 20)];
        if ([_userInfos.teacherlv integerValue] == 1) {
            imageVIew.image = [UIImage imageNamed:@"xingji-one"];
        }else if ([_userInfos.teacherlv integerValue] == 2){
            imageVIew.image = [UIImage imageNamed:@"xingji-two"];
        }else{
            imageVIew.image = [UIImage imageNamed:@"xingji-three"];
        }
        [xingjiView addSubview:imageVIew];
        
        //更换学校按钮
        UIButton *changeSchool = [UIButton buttonWithType:UIButtonTypeCustom];
        changeSchool.frame = CGRectMake(0, 0, 70, 20);
        changeSchool.center = CGPointMake(kScreenWidth - 50, 15);
        changeSchool.titleLabel.font = [UIFont systemFontOfSize:14];
        changeSchool.titleLabel.textAlignment = NSTextAlignmentRight;
        [changeSchool setTitle:@"更改学校" forState:UIControlStateNormal];
        [changeSchool setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [changeSchool addTarget:self action:@selector(changeSchool:) forControlEvents:UIControlEventTouchUpInside];
        [xingjiView addSubview:changeSchool];
        
        
        [self.view addSubview:self.tableView];
        if (self.tableView) {
            [self.tableView reloadData];
        }
        
        [self.view bringSubviewToFront:addBtn];
    }
    
}

//更改学校
- (void)changeSchool:(UIButton *)sender{
    SYChangeSchoolViewController *change = [[SYChangeSchoolViewController alloc] initWithNibName:@"SYChangeSchoolViewController" bundle:nil];
    [self.navigationController pushViewController:change animated:YES];
}

- (void)addFenZu:(UIButton *)sender{

    SYRenameView *view = [[[NSBundle mainBundle] loadNibNamed:@"SYRenameView" owner:self options:nil] lastObject];
    view.frame = [UIScreen mainScreen].bounds;
    view.renameTF.placeholder = @"请输入班级名称";
    view.titleLabel.text = @"添加班级";
    [view show];
    __weak typeof(self)waekself = self;
    view.block = ^(NSString *rename){
        if (rename.length == 0) {
            [waekself showHint:@"请输入班级名称！"];
            return ;
        }
        [waekself addClassWithClass:rename];
    };
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
    label.text = @"亲爱哒老师，请先认证您的身份哟！";
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

- (void)gotoCertifierAction:(UIButton *)sender{
    
    if ([_userInfos.idcard integerValue] == 0) {
        //未验证身份证
        SYIDViewController *idcard = [[SYIDViewController alloc] initWithNibName:@"SYIDViewController" bundle:nil];
        idcard.state = isFromTeacher;
        [self.navigationController pushViewController:idcard animated:YES];
    }else{
        //去认证
        SYTeacherCertifiedViewController *certifi = [[SYTeacherCertifiedViewController alloc] initWithNibName:@"SYTeacherCertifiedViewController" bundle:nil];
        [self.navigationController pushViewController:certifi animated:YES];
        
    }
    
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

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSourceArr.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSDictionary *dic = self.dataSourceArr[section];
    if ([[dic objectForKey:@"isOpen"] boolValue]) {
        NSArray *arr = [dic objectForKey:@"type"];
        return arr.count;
    }else{
        return 0;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"fenzucell";
    SYFenZuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"SYFenZuTableViewCell" owner:nil options:nil][0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSArray *type = [self.dataSourceArr[indexPath.section] objectForKey:@"type"];
    if (type.count > 0) {
        cell.nameLabel.text = [type[indexPath.row] objectForKey:@"name"];
        [cell.phoneNumBtn setTitle:[type[indexPath.row] objectForKey:@"tel"] forState:UIControlStateNormal];
        cell.callBlock = ^(){
            NSMutableString* str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",[type[indexPath.row] objectForKey:@"tel"]];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        };
        cell.editBlock = ^(){
            SYEditStudentView *view = [[[NSBundle mainBundle] loadNibNamed:@"SYEditStudentView" owner:self options:nil] lastObject];
            view.frame = [UIScreen mainScreen].bounds;
            view.renameTF.placeholder = @"请输入新的名称";
            view.deleteLabel.text = @"与该学生的传送记录也将删除";
            
            [view show];
            __weak typeof(self)waekself = self;

            view.block = ^(NSDictionary *dic){
                BOOL isRenameSelected = [[dic objectForKey:@"renameStudentSelected"] boolValue];
                if (isRenameSelected) {
//                    [waekself renameWithsection:indexPath.section NewclassName:[dic objectForKey:@"studentName"]];
                    NSString *name = [dic objectForKey:@"studentName"];
                    if (name.length < 1 || name.length > 10) {
                        [self showHint:@"学生名称1-10个字！"];
                        return ;
                    }
                    [waekself renameStudentNameWithIndexPath:indexPath Name:[dic objectForKey:@"studentName"]];
                }else{
                    [waekself deleteStudentNameWithIndexPath:indexPath];
                }
            };
            
        };
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *types = [self.dataSourceArr[indexPath.section] objectForKey:@"type"];
    
    SYTeacherAddPhotoToStudentViewController *student = [[SYTeacherAddPhotoToStudentViewController alloc] initWithNibName:@"SYNewTeacherAddPhotoToStudentViewController" bundle:nil];

    student.dataSourceDic = types[indexPath.row];
    
    [self.navigationController pushViewController:student animated:YES];
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
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(arrowBtn.frame), 0, kScreenWidth - 60 - 50, 44)];
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



#pragma mark - EditFenZu
//编辑分组
- (void)editFenZu:(UIButton *)sender{
    _currentSection = sender.tag;
    [FTPopOverMenu showForSender:sender withMenu:_contentArr imageNameArray:_imagesArr doneBlock:^(NSInteger selectedIndex) {
        NSLog(@"selectedIndex - %ld",(long)selectedIndex);
        switch (selectedIndex) {
            case 0:
            {
                SYRenameView *view = [[[NSBundle mainBundle] loadNibNamed:@"SYRenameView" owner:self options:nil] lastObject];
                view.frame = [UIScreen mainScreen].bounds;
                [view show];
                __weak typeof(self)waekself = self;
                view.block = ^(NSString *rename){
                    if (rename.length < 1 || rename.length > 12) {
                        [waekself showHint:@"班级名字1-12个字！"];
                        return ;
                    }
                    [waekself renameWithsection:sender.tag NewclassName:rename];
                };
                
            }
                break;
            case 2:
            {
//                SYUpdatePreviewViewController *updateVC = [SYUpdatePreviewViewController updatePreviewWithUrl:[NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/upclassX.html"] Param:@{@"token":UserToken, @"id":[self.dataSourceArr[_currentSection] objectForKey:@"id"]}];
//                [self.navigationController pushViewController:updateVC animated:YES];
                
                SYUpdateToClassViewController *classVC = [[SYUpdateToClassViewController alloc] init];
                classVC.classID = [self.dataSourceArr[_currentSection] objectForKey:@"id"];
                [self.navigationController pushViewController:classVC animated:YES];
                
            }
                break;
            case 1:
            {
                SYAddStudentToClassView *view = [[[NSBundle mainBundle] loadNibNamed:@"SYAddStudentToClassView" owner:self options:nil] lastObject];
                view.frame = [UIScreen mainScreen].bounds;
                [view show];
                __weak typeof(self)weakself = self;
                view.block = ^(NSString *name, NSString *phone){
                    if (name.length == 0){
                        [weakself showHint:@"请输入学生姓名！"];
                        return ;
                    }
                    if (phone.length == 0) {
                        [weakself showHint:@"请输入家长手机号！"];
                        return ;
                    }
                    
                    [weakself addStudentToFenzuWithsection:sender.tag Tel:phone Name:name];
                    
                };
                
            }
                break;
            case 3:
            {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"删除班级" message:@"" preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                    return ;
                }];
                UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
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
}

//重命名
- (void)renameWithsection:(NSInteger)section NewclassName:(NSString *)newclassName{
    NSDictionary *dic = self.dataSourceArr[section];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/editclass.html"];
    NSDictionary *param = @{@"token":UserToken, @"id":[dic objectForKey:@"id"], @"name":newclassName};
    
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {

        NSLog(@"修改班级名称 -- %@",responseResult);
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
//添加学生到分组
- (void)addStudentToFenzuWithsection:(NSInteger)section Tel:(NSString *)tel Name:(NSString *)name{
    NSDictionary *dic = self.dataSourceArr[section];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/addstudent.html"];
    NSDictionary *param = @{@"token":UserToken, @"id":[dic objectForKey:@"id"], @"tel":tel, @"name":name};
    
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        NSLog(@"添加学生到分组 -- %@",responseResult);
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
//删除该分组
- (void)deleteFenzuWithsection:(NSInteger)section{
    NSDictionary *dic = self.dataSourceArr[section];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/delclass.html"];
    NSDictionary *param = @{@"token":UserToken, @"id":[dic objectForKey:@"id"]};
    
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        NSLog(@"删除班级 -- %@",responseResult);
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

#pragma mark - EditStudentInfos
//重命名学生
- (void)renameStudentNameWithIndexPath:(NSIndexPath *)indexPath Name:(NSString *)name{
    NSArray *type = [self.dataSourceArr[indexPath.section] objectForKey:@"type"];
    NSDictionary *dic = type[indexPath.row];
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/editstudent.html"];
    NSDictionary *param = @{@"token":UserToken, @"id":[dic objectForKey:@"id"], @"name":name};
    
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

//删除学生
- (void)deleteStudentNameWithIndexPath:(NSIndexPath *)indexPath{
    NSArray *type = [self.dataSourceArr[indexPath.section] objectForKey:@"type"];
    NSDictionary *dic = type[indexPath.row];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/delstudent.html"];
    NSDictionary *param = @{@"token":UserToken, @"id":[dic objectForKey:@"id"]};
    
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        NSLog(@"删除学生 -- %@",responseResult);
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

//展开分组
- (void)isOpenAction:(UITapGestureRecognizer *)tap{
    NSInteger tag = tap.view.tag;
    
    NSMutableDictionary *muDic = self.dataSourceArr[tag - 100];
    BOOL isOpen = ![[muDic objectForKey:@"isOpen"] boolValue];

    [self updateIsOpenWithSection:tag-100 withValue:[NSNumber numberWithBool:isOpen]];
    [self getDataFormCache];

}

#pragma mark - GetData
- (void)getData{
    //获取图片
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/getlist.html"];
    NSDictionary *param = @{@"token":UserToken};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        if ([self.tableView.mj_header isRefreshing]) {
            [self.tableView.mj_header endRefreshing];
        }
        NSLog(@"获取班级学生列表 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {

        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                if ([XHNetworkCache cacheJsonWithURL:[NSString stringWithFormat:@"%@%@",Mobile,@"AllFenZu"]]) {
                    NSMutableDictionary *cacheMudic = [NSMutableDictionary dictionaryWithCapacity:0];
                    [cacheMudic setDictionary:[XHNetworkCache cacheJsonWithURL:[NSString stringWithFormat:@"%@%@",Mobile,@"AllFenZu"]]];
                    
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
                                [mudic setObject:number forKey:@"isOpen"];

                            }
                            
                            [mudata replaceObjectAtIndex:i withObject:mudic];
                        }
                        [mudics setObject:mudata forKey:@"data"];
                    }
                    
                    [XHNetworkCache saveJsonResponseToCacheFile:mudics andURL:[NSString stringWithFormat:@"%@%@",Mobile,@"AllFenZu"]];
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
                    
                    [XHNetworkCache saveJsonResponseToCacheFile:mudics andURL:[NSString stringWithFormat:@"%@%@",Mobile,@"AllFenZu"]];
                }
                
                if ([(NSArray *)[responseResult objectForKey:@"data"] count] > 0) {
                    [self getDataFormCache];
                }
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}
//添加分组
- (void)addClassWithClass:(NSString *)className{
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/addclass.html"];
    NSDictionary *param = @{@"token":UserToken, @"name":className};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        NSLog(@"添加班级 -- %@",responseResult);
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

#pragma mark - updateUserInfos
- (void)updateIsOpenWithSection:(NSInteger)section withValue:(NSNumber *)isopen{
    NSMutableDictionary *responseResult = [NSMutableDictionary dictionaryWithCapacity:0];
    [responseResult setDictionary:[XHNetworkCache cacheJsonWithURL:[NSString stringWithFormat:@"%@%@",Mobile,@"AllFenZu"]]];

    NSMutableArray *mudata = [NSMutableArray arrayWithArray:[responseResult objectForKey:@"data"]];
    

    NSMutableDictionary *mudic = [NSMutableDictionary dictionaryWithCapacity:0];
    [mudic setDictionary:[responseResult objectForKey:@"data"][section]];
        
    [mudic setObject:isopen forKey:@"isOpen"];
    [mudata replaceObjectAtIndex:section withObject:mudic];

    [responseResult setObject:mudata forKey:@"data"];
    
    [XHNetworkCache saveJsonResponseToCacheFile:responseResult andURL:[NSString stringWithFormat:@"%@%@",Mobile,@"AllFenZu"]];
}

#pragma mark - LazyLoad
- (NSMutableArray *)dataSourceArr{
    if (!_dataSourceArr) {
        _dataSourceArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSourceArr;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 30, kScreenWidth, kScreenHeight - 64 - 40 - 30) style:UITableViewStylePlain];
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


- (NSMutableArray *)classImagesArr{
    if (!_classImagesArr) {
        _classImagesArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _classImagesArr;
}

@end
