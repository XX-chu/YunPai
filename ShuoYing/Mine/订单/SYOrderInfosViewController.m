//
//  SYOrderInfosViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/6/3.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYOrderInfosViewController.h"
#import "SYDefaultAddressTableViewCell.h"
#import "SYShangPinTableViewCell.h"
#import "OrderPayTypeView.h"
#import "SYUserInfos.h"
#import "SYBisnessInfosViewController.h"
#import "SYOrderInfosTableViewCell.h"
#import "DeleteOrderView.h"
#import "SYOrderPingJiaViewController.h"
#import "SYOrderCreatTimeTableViewCell.h"
@interface SYOrderInfosViewController ()<UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate,XLPhotoBrowserDelegate,XLPhotoBrowserDatasource>
{
    SYUserInfos *_userinfos;
    UIButton *_backBtn;
    
    NSArray *_imgsArr;
}

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy) NSMutableArray *dataSourceArr;

@property (nonatomic, strong) UITextField *liuyanTF;

@end

@implementation SYOrderInfosViewController

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    
    
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:NSClassFromString(@"SYBisnessInfosViewController")] || [vc isKindOfClass:NSClassFromString(@"SYShopcartViewController")]) {
            [self setLeftBarButtonItem];
            break;
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    self.title = @"订单详情";
    _userinfos = [[Tool sharedInstance] getObjectWithPath:Mobile];
    [self getData];
}

- (void)setLeftBarButtonItem{
    _backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [_backBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -25, 0, 25)];
    [_backBtn setImage:[UIImage imageNamed:@"wode_photo_gerenshezhi_fanhui"] forState:UIControlStateNormal];
    [_backBtn setAdjustsImageWhenHighlighted:NO];
    [_backBtn addTarget:self action:@selector(popAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_backBtn];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
}

- (void)popAction{
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:NSClassFromString(@"SYBisnessInfosViewController")] || [vc isKindOfClass:NSClassFromString(@"SYShopcartViewController")]) {
            [self.navigationController popToViewController:vc animated:YES];
            break;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }else if (section == self.dataSourceArr.count + 1){
        if (self.type == OrderTypeWeiFuKuan) {
            return 1;
        }
        return 2;
    } else{
        NSDictionary *dic = self.dataSourceArr[section - 1];
        NSArray *goods = [dic objectForKey:@"goods"];
        return goods.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        //线上
        static NSString *identifier = @"addressCell";
        SYDefaultAddressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"SYDefaultAddressTableViewCell" owner:nil options:nil][0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.noAddressLabel.hidden = YES;
            cell.arrowImageView.hidden = YES;
        }
        NSDictionary *dic = self.dataSourceArr[indexPath.section];
        cell.shouhuorenLabel.text = [dic objectForKey:@"link"];
        cell.phoneLabel.text = [dic objectForKey:@"tel"];
        cell.addressLabel.text = [dic objectForKey:@"address"];
        
        return cell;
    }else if (indexPath.section == self.dataSourceArr.count + 1){
        static NSString *identifier = @"creatcell";
        SYOrderCreatTimeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"SYOrderCreatTimeTableViewCell" owner:nil options:nil][0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        if (self.type == OrderTypeWeiFuKuan) {
            cell.leftLabel.text = @"下单时间";
        }else{
            if (indexPath.row == 0) {
                cell.leftLabel.text = @"下单时间";

            }else{
                cell.leftLabel.text = @"支付时间";

            }
        }
        
        NSDictionary *dic = [self.dataSourceArr firstObject];

        if (self.type == OrderTypeWeiFuKuan) {
            cell.rightLabel.text = [dic objectForKey:@"addtime"];
        }else{
            if (indexPath.row == 0) {
                cell.rightLabel.text = [dic objectForKey:@"addtime"];

            }else{
                cell.rightLabel.text = [dic objectForKey:@"paytime"];

            }
        }
        
        return cell;
    } else{
        static NSString *identifier = @"cell";
        SYOrderInfosTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"SYOrderInfosTableViewCell" owner:nil options:nil][0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        NSDictionary *dic = self.dataSourceArr[indexPath.section - 1];
        NSArray *goods = [dic objectForKey:@"goods"];
        NSDictionary *goodDic = goods[indexPath.row];
        
        [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,[goodDic objectForKey:@"img_200"]]] placeholderImage:NoPicture];
        
        cell.shangpinNameLabel.text = [goodDic objectForKey:@"title"];
        
        float price = [(NSNumber *)[goodDic objectForKey:@"money"] floatValue] / 100;
        cell.priceLabel.text = [NSString stringWithFormat:@"¥%.2f",price];
        NSInteger num = [(NSNumber *)[goodDic objectForKey:@"num"] integerValue];
        cell.countLabel.text = [NSString stringWithFormat:@"x%ld",num];
        cell.shuxingLabel.text = [goodDic objectForKey:@"spce"];;
        cell.block = ^{
            _imgsArr = [goodDic objectForKey:@"imgs"];
            [XLPhotoBrowser showPhotoBrowserWithCurrentImageIndex:0 imageCount:_imgsArr.count datasource:self];
        };
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section != 0) {
        NSDictionary *shangjiaDic = self.dataSourceArr[indexPath.section - 1];
        NSArray *goods = [shangjiaDic objectForKey:@"goods"];
        NSDictionary *shangpinDic = goods[indexPath.row];
        SYBisnessInfosViewController *infos = [[SYBisnessInfosViewController alloc] initWithIsFromXSorXXType:isFromXS shangpinID:[shangpinDic objectForKey:@"id"] shangjiaID:[shangjiaDic objectForKey:@"store"]];
        [self.navigationController pushViewController:infos animated:YES];
    }
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSourceArr.count + 1 + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {

        return 75;
    }
    if (indexPath.section == self.dataSourceArr.count + 1) {
        return 45;
    }
    return 150;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    if (section == 1) return 46;
    if (section == self.dataSourceArr.count + 1) {
        return 12;
    }
    return 0.00001f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (section == 1) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = BackGroundColor;
        UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 12, kScreenWidth, 34)];
        view1.backgroundColor = [UIColor whiteColor];
        [view addSubview:view1];
        
        NSDictionary *dic = self.dataSourceArr[section - 1];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 17, kScreenWidth - 100 - 40, 17)];
        label.text = [dic objectForKey:@"name"];
        label.textColor = HexRGB(0x434343);
        label.font = [UIFont systemFontOfSize:17];
        [view1 addSubview:label];
        
        return view;
    }
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = BackGroundColor;

    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{

    if (section == 1 ){
        return 88;
    }
    
    return 0.00001f;

}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{

    if (section == 1) {
        NSDictionary *dic = self.dataSourceArr[section - 1];
        NSArray *goods = [dic objectForKey:@"goods"];
        
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor whiteColor];
        
        UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 80, 15)];
        numLabel.textColor = HexRGB(0x434343);
        numLabel.font = [UIFont systemFontOfSize:14];
        NSInteger totalNum = 0;
        for (NSDictionary *dic in goods) {
            NSInteger num = [(NSNumber *)[dic objectForKey:@"num"] integerValue];
            totalNum += num;
        }
        numLabel.text = [NSString stringWithFormat:@"共%ld件商品",totalNum];
        [view addSubview:numLabel];
        
        UILabel *hejiLabel = [[UILabel alloc] initWithFrame:CGRectMake(105, 15, kScreenWidth - 120, 15)];
        float money = [(NSNumber *)[dic objectForKey:@"money"] floatValue] / 100;
        NSString *moneyStr = [NSString stringWithFormat:@"合计：¥%.2f",money];
        float fee = [(NSNumber *)[dic objectForKey:@"express"] floatValue] / 100;
        NSString *feeStr = [NSString stringWithFormat:@"(含快递：¥%.2f)",fee];
        NSString *str = [moneyStr stringByAppendingString:feeStr];
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:str];
        [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, moneyStr.length)];
        [attStr addAttribute:NSForegroundColorAttributeName value:HexRGB(0x434343) range:NSMakeRange(0, moneyStr.length)];
        [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(moneyStr.length, feeStr.length)];
        [attStr addAttribute:NSForegroundColorAttributeName value:HexRGB(0x8e8d8d) range:NSMakeRange(moneyStr.length, feeStr.length)];
        hejiLabel.attributedText = attStr;
        hejiLabel.textAlignment = NSTextAlignmentRight;
        [view addSubview:hejiLabel];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, kScreenWidth, 1)];
        lineView.backgroundColor = BackGroundColor;
        [view addSubview:lineView];
        
        UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lineView.frame), kScreenWidth, 44)];
        view1.backgroundColor = [UIColor whiteColor];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(14, 1, 70, 44)];
        label.text = @"买家留言:";
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = HexRGB(0x3f3f3f);
        [view1 addSubview:label];
        
        [view1 addSubview:self.liuyanTF];
        NSDictionary *dic11 = self.dataSourceArr[section - 1];
        self.liuyanTF.text = [dic11 objectForKey:@"msg"];
        
        [view addSubview:view1];
        
        return view;
    }
    return nil;
}


- (void)chakanphoto:(UIButton *)btn{
    id first = objc_getAssociatedObject(btn, "firstObject");
    NSMutableArray *muarr = (NSMutableArray *)first;
    _imgsArr = muarr;
    [XLPhotoBrowser showPhotoBrowserWithCurrentImageIndex:0 imageCount:muarr.count datasource:self];
}

- (NSURL *)photoBrowser:(XLPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index{
    NSDictionary *dic = _imgsArr[index];
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,[dic objectForKey:@"img_min"]]];
}

- (void)getData{
    [SVProgressHUD show];
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/store/neetpay.html"];
    NSLog(@"param - %@",self.param);
    __weak typeof(self)weakself = self;
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:self.param ResponseObject:^(NSDictionary *responseResult) {
        [SVProgressHUD dismiss];

        NSLog(@"获取订单信息 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [weakself showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                NSArray *data = [responseResult objectForKey:@"data"];
                if (data.count > 0) {
                    [weakself.dataSourceArr addObjectsFromArray:data];
                }
                [weakself.view addSubview:weakself.tableView];
                [weakself initBottomView];
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [weakself showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (void)initBottomView{
    if (self.type == OrderTypeDaiFaHuo) {
        return;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 55, kScreenWidth, 55)];
    if (self.type == OrderTypeWeiFuKuan) {
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelBtn.frame = CGRectMake(0, 0, (kScreenWidth - 1) / 2, 55);
        [cancelBtn setTitle:@"取消订单" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancelBtn setBackgroundImage:[UIImage imageWithColor:NavigationColor Size:cancelBtn.frame.size] forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(cancelOrderAction:) forControlEvents:UIControlEventTouchUpInside];
        [cancelBtn setAdjustsImageWhenHighlighted:NO];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [view addSubview:cancelBtn];
        
        UIButton *zhifuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        zhifuBtn.frame = CGRectMake((kScreenWidth - 1) / 2 + 1, 0, (kScreenWidth - 1) / 2, 55);
        float money = 0.0f;
        for (NSDictionary *dic in self.dataSourceArr) {
            money += [(NSNumber *)[dic objectForKey:@"money"] floatValue] / 100;
        }
        [zhifuBtn setTitle:[NSString stringWithFormat:@"付款%.2f",money] forState:UIControlStateNormal];
        [zhifuBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [zhifuBtn setBackgroundImage:[UIImage imageWithColor:NavigationColor Size:cancelBtn.frame.size] forState:UIControlStateNormal];
        [zhifuBtn addTarget:self action:@selector(creatOrderAction:) forControlEvents:UIControlEventTouchUpInside];
        [zhifuBtn setAdjustsImageWhenHighlighted:NO];
        zhifuBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [view addSubview:zhifuBtn];
    }else if (self.type == OrderTypeDaiShouHuo){
        UIButton *shouhuoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        shouhuoBtn.frame = CGRectMake(0, 0, kScreenWidth, 55);
        [shouhuoBtn setTitle:@"确认收货" forState:UIControlStateNormal];
        [shouhuoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [shouhuoBtn setBackgroundImage:[UIImage imageWithColor:NavigationColor Size:shouhuoBtn.frame.size] forState:UIControlStateNormal];
        [shouhuoBtn addTarget:self action:@selector(querenShouhuoAction:) forControlEvents:UIControlEventTouchUpInside];
        [shouhuoBtn setAdjustsImageWhenHighlighted:NO];
        shouhuoBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [view addSubview:shouhuoBtn];
    }else if (self.type == OrderTypeDaiPingJia){
        UIButton *delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        delBtn.frame = CGRectMake(0, 0, (kScreenWidth - 1) / 2, 55);
        [delBtn setTitle:@"删除订单" forState:UIControlStateNormal];
        [delBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [delBtn setBackgroundImage:[UIImage imageWithColor:NavigationColor Size:delBtn.frame.size] forState:UIControlStateNormal];
        [delBtn addTarget:self action:@selector(deleteOrderAction:) forControlEvents:UIControlEventTouchUpInside];
        [delBtn setAdjustsImageWhenHighlighted:NO];
        delBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [view addSubview:delBtn];
        
        UIButton *pingjia = [UIButton buttonWithType:UIButtonTypeCustom];
        pingjia.frame = CGRectMake((kScreenWidth - 1) / 2 + 1, 0, (kScreenWidth - 1) / 2, 55);
  
        [pingjia setTitle:@"评价" forState:UIControlStateNormal];
        [pingjia setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [pingjia setBackgroundImage:[UIImage imageWithColor:NavigationColor Size:pingjia.frame.size] forState:UIControlStateNormal];
        [pingjia addTarget:self action:@selector(pingjiaOrderAction:) forControlEvents:UIControlEventTouchUpInside];
        [pingjia setAdjustsImageWhenHighlighted:NO];
        pingjia.titleLabel.font = [UIFont systemFontOfSize:16];
        [view addSubview:pingjia];
    }else if (self.type == OrderTypeYiWanCheng){
        UIButton *delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        delBtn.frame = CGRectMake(0, 0, kScreenWidth, 55);
        [delBtn setTitle:@"删除订单" forState:UIControlStateNormal];
        [delBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [delBtn setBackgroundImage:[UIImage imageWithColor:NavigationColor Size:delBtn.frame.size] forState:UIControlStateNormal];
        [delBtn addTarget:self action:@selector(deleteOrderAction:) forControlEvents:UIControlEventTouchUpInside];
        [delBtn setAdjustsImageWhenHighlighted:NO];
        delBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [view addSubview:delBtn];
    }

    [self.view addSubview:view];
}

#pragma mark - 取消订单
- (void)cancelOrderAction:(UIButton *)sender{
    NSLog(@"取消订单");
    DeleteOrderView *delete = [[[NSBundle mainBundle] loadNibNamed:@"DeleteOrderView" owner:self options:nil] lastObject];
    delete.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    delete.tishiLabel.text = @"真的要取消该订单吗？";
    [delete.leftBtn setTitle:@"确定" forState:UIControlStateNormal];
    [delete.rightBtn setTitle:@"取消" forState:UIControlStateNormal];
    __weak typeof(self)weakself = self;
    __weak typeof(delete)weakDelete = delete;
    delete.leftBlock = ^{
        NSLog(@"left");
        [weakDelete dismiss];
        [weakself changeOrderState:@0 OrderID:[weakself.param objectForKey:@"id"]];
    };
    delete.rightBlock = ^{
        NSLog(@"right");
        [weakDelete dismiss];
    };
    [delete show];
    
}

- (void)changeOrderState:(NSNumber *)state OrderID:(NSNumber *)orderid{
    [SVProgressHUD show];
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/order/editstate.html"];
    NSDictionary *param = @{@"token":UserToken, @"state":state, @"id":orderid};
    __weak typeof(self)weakself = self;
    [SVProgressHUD show];
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        [SVProgressHUD dismiss];
        NSLog(@"更改订单状态 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [weakself showHint:@"服务器不给力，请稍后重试"];
            
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                [weakself.navigationController popViewControllerAnimated:YES];
            }else{
                
            }
        }
    }];
}

#pragma mark - 确认收货
- (void)querenShouhuoAction:(UIButton *)sender{
    NSLog(@"确认收货");
    DeleteOrderView *delete = [[[NSBundle mainBundle] loadNibNamed:@"DeleteOrderView" owner:self options:nil] lastObject];
    delete.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    delete.tishiLabel.text = @"已收到宝贝";
    [delete.leftBtn setTitle:@"取消" forState:UIControlStateNormal];
    [delete.rightBtn setTitle:@"确定" forState:UIControlStateNormal];
    __weak typeof(self)weakself = self;
    __weak typeof(delete)weakDelete = delete;
    delete.leftBlock = ^{
        NSLog(@"left");
        [weakDelete dismiss];
        
    };
    delete.rightBlock = ^{
        NSLog(@"right");
        [weakDelete dismiss];
        [weakself changeOrderState:@4 OrderID:[weakself.param objectForKey:@"id"]];
    };
    [delete show];
    
}

#pragma mark - 删除订单
- (void)deleteOrderAction:(UIButton *)sender{
    NSLog(@"删除订单");
    DeleteOrderView *delete = [[[NSBundle mainBundle] loadNibNamed:@"DeleteOrderView" owner:self options:nil] lastObject];
    delete.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    delete.tishiLabel.text = @"确定要删除该商品吗？";
    [delete.leftBtn setTitle:@"取消" forState:UIControlStateNormal];
    [delete.rightBtn setTitle:@"确定" forState:UIControlStateNormal];
    __weak typeof(self)weakself = self;
    __weak typeof(delete)weakDelete = delete;
    delete.leftBlock = ^{
        NSLog(@"left");
        [weakDelete dismiss];
        
    };
    delete.rightBlock = ^{
        NSLog(@"right");
        [weakDelete dismiss];
        [weakself changeOrderState:@5 OrderID:[weakself.param objectForKey:@"id"]];
    };
    [delete show];
}

#pragma mark - 评价订单
- (void)pingjiaOrderAction:(UIButton *)sender{
    NSLog(@"评价");
    SYOrderPingJiaViewController *pingjia = [[SYOrderPingJiaViewController alloc] init];
    
    pingjia.orderID = [self.param objectForKey:@"id"];
    pingjia.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight);
    [self.navigationController pushViewController:pingjia animated:YES];
}

- (void)creatOrderAction:(UIButton *)sender{
    OrderPayTypeView *view = [[[NSBundle mainBundle] loadNibNamed:@"OrderPayTypeView" owner:self options:nil] lastObject];
    view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6f];
    if (_userinfos) {
        float money = [_userinfos.money floatValue] / 100;
        view.moneyLabel.text = [NSString stringWithFormat:@"余额：¥%.2f",money];
    }else{
        view.moneyLabel.text = @"";
    }
    __weak typeof(self)weakself = self;
    __weak typeof(view)weakView = view;
    view.weixin = ^{
        [weakView dismiss];
        [SVProgressHUD show];
        NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/wxpay/pay.html"];
        NSDictionary *param = @{};
        param = @{@"token":UserToken, @"id":[self.param objectForKey:@"id"], @"type":@910,@"paytype":@"APP"};
        
        [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
            [SVProgressHUD dismiss];
            NSLog(@"微信支付 -- %@",responseResult);
            
            if ([responseResult objectForKey:@"resError"]) {
                [weakself showHint:@"服务器不给力，请稍后重试"];
                
            }else{
                if (responseResult.count > 0) {
                    
                    if ([responseResult objectForKey:@"data"]) {
                        NSData *jsonData = [[responseResult objectForKey:@"data"] dataUsingEncoding:NSUTF8StringEncoding];
                        NSError *error;
                        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
                        if (error) {
                            NSLog(@"json解析失败：%@",error);
                        }else{
                            [self weixinWithResultDic:dic];
                        }
                        
                    }
                }
                
            }
        }];
        
    };
    view.zhifubao = ^{
        [weakView dismiss];
        NSString *url = @"";
        url = [NSString stringWithFormat:@"%@%@?type=%@&token=%@&id=%@&paytype=longguo",BaseUrl,@"/alpay/pay.html",@910,UserToken,[self.param objectForKey:@"id"]];
        UIWebView *webView = [[UIWebView alloc] init];
        webView.delegate = weakself;
        NSString *encodedString=[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:encodedString]];
        [SVProgressHUD show];
        [webView loadRequest:request];
        [weakself.view addSubview:webView];
    };
    view.yue = ^{
        [weakView dismiss];
        NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/yepay/pay.html"];
        NSDictionary *param = nil;
        param = @{@"token":UserToken, @"id":[self.param objectForKey:@"id"], @"type":@910};
        [SVProgressHUD show];
        [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
            NSLog(@"余额支付 -- %@",responseResult);
            [SVProgressHUD dismiss];
            if ([responseResult objectForKey:@"resError"]) {
                [weakself showHint:@"服务器不给力，请稍后重试"];
            }else{
                if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                    for (UIViewController *vc in self.navigationController.viewControllers) {
                        if ([vc isKindOfClass:NSClassFromString(@"SYBisnessInfosViewController")] || [vc isKindOfClass:NSClassFromString(@"SYShopcartViewController")]) {
                            [self.navigationController popToViewController:vc animated:YES];
                            break;
                        }
                    }
                    [weakself showHint:[responseResult objectForKey:@"msg"]];
                }else{
                    if ([responseResult objectForKey:@"msg"]) {
                        [weakself showHint:[responseResult objectForKey:@"msg"]];
                    }
                }
            }
        }];
    };
    [view show];
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    // NOTE: ------  对alipays:相关的scheme处理 -------
    // NOTE: 若遇到支付宝相关scheme，则跳转到本地支付宝App
    NSString* reqUrl = request.URL.absoluteString;
    NSLog(@"reqUrl - %@",reqUrl);
    if ([reqUrl hasPrefix:@"alipays://"] || [reqUrl hasPrefix:@"alipay://"]) {
        // NOTE: 跳转支付宝App
        BOOL bSucc = [[UIApplication sharedApplication]openURL:request.URL];
        
        // NOTE: 如果跳转失败，则跳转itune下载支付宝App
        if (!bSucc) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                           message:@"未检测到支付宝客户端，请安装后重试。"
                                                          delegate:self
                                                 cancelButtonTitle:@"确定"
                                                 otherButtonTitles:nil];
            [alert show];
        }
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [SVProgressHUD dismiss];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [SVProgressHUD dismiss];
}

- (void)weixinWithResultDic:(NSDictionary *)dic{
    //微信支付
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weixinPayResp:) name:@"weixinPayResp" object:nil];
    
    PayReq *request = [[PayReq alloc] init];
    
    request.openID = @"wx3fa3352427c88e20";
    
    request.partnerId = [dic objectForKey:@"partnerid"];
    
    request.prepayId = [dic objectForKey:@"prepayid"];
    
    request.package = [dic objectForKey:@"package"];
    
    request.nonceStr = [dic objectForKey:@"noncestr"];
    
    request.timeStamp = [[dic objectForKey:@"timestamp"] unsignedIntValue];
    
    DataMD5 *md5 = [[DataMD5 alloc] init];
    
    request.sign = [md5 createMD5SingForPay:request.openID partnerid:request.partnerId prepayid:request.prepayId package:request.package noncestr:request.nonceStr timestamp:request.timeStamp];
    
    [WXApi sendReq:request];
}

//微信支付回调
- (void)weixinPayResp:(NSNotification *)notification {
    NSLog(@"notification - %@",notification.userInfo);
    //0代表成功; －1代表错误; －2代表用户取消.
    
    
    if ([notification.object intValue] == 0) {
        
        [self showHint:@"支付成功"];
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    
    if ([notification.object intValue] == -1) {
        
        [self showHint:@"支付失败"];
    }
    
    if ([notification.object intValue] == -2) {
        
        [self showHint:@"取消支付"];
    }
    
}


- (UITableView *)tableView{
    if (!_tableView) {
        if (self.type == OrderTypeDaiFaHuo) {
            _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight) style:UITableViewStyleGrouped];

        }else{
            _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 55) style:UITableViewStyleGrouped];
        }
        _tableView.backgroundColor = HexRGB(0xf3f3f3);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (NSMutableArray *)dataSourceArr{
    if (!_dataSourceArr) {
        _dataSourceArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSourceArr;
}

- (UITextField *)liuyanTF{
    if (!_liuyanTF) {
        _liuyanTF = [[UITextField alloc] initWithFrame:CGRectMake(89, 7, kScreenWidth - 98, 30)];
        _liuyanTF.placeholder = @"对卖家有什么想说的写在这里吧";
        _liuyanTF.font = [UIFont systemFontOfSize:14];
        _liuyanTF.enabled = NO;
    }
    return _liuyanTF;
}


@end
