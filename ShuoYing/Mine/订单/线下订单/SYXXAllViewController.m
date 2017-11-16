//
//  SYXSAllViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/3/31.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYXXAllViewController.h"
#import "SYShangPinTableViewCell.h"
#import "NoDataView.h"
#import "NoOrderView.h"
#import "UILabel+YBAttributeTextTapAction.h"
#import "SYChakanGrapherViewController.h"
#import "SYOrderPaymentViewController.h"
#import "DeleteOrderView.h"
#import "SYOrderPingJiaViewController.h"
#import "SYOrderModel.h"
#import "SYProductModel.h"
#import "SYBisnessInfosViewController.h"
@interface SYXXAllViewController ()<UITableViewDelegate, UITableViewDataSource, YBAttributeTapActionDelegate>
{
    NSInteger _count;
}
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSourceArr;

@property (nonatomic, strong) NoOrderView *orderView;

@property (nonatomic, strong) NoDataView *dataView;

@end

@implementation SYXXAllViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _count = 1;
    
    [self getData];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSourceArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    SYOrderModel *orderModel = self.dataSourceArr[section];
    NSArray *product = orderModel.product;
    return product.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"shangpinCell";
    SYShangPinTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"SYShangPinTableViewCell" owner:nil options:nil][0];
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    SYOrderModel *orderModel = self.dataSourceArr[indexPath.section];
    NSArray *product = orderModel.product;
    
    if (product.count > 0) {
        SYProductModel *productModel = product[indexPath.row];
        [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,productModel.img_200]] placeholderImage:[UIImage imageNamed:@"shangchuan_wode_wutupian"]];
        cell.shangpinLabel.text = productModel.name;
        if ([orderModel.type integerValue] == 5) {
            
            NSString *phone = [NSString stringWithFormat:@"手机号：%@",productModel.attr];
            NSString *label_text1 = phone;
            NSMutableAttributedString *attributedString1 = [[NSMutableAttributedString alloc]initWithString:label_text1];
            [attributedString1 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(4, phone.length - 4)];
            [attributedString1 addAttribute:NSForegroundColorAttributeName value:HexRGB(0x3dcfbb) range:NSMakeRange(4, phone.length - 4)];
            
//            cell.shangpinShuxingLabel.text = [NSString stringWithFormat:@"手机号：%@",[product[indexPath.row] objectForKey:@"attr"]];
            cell.shangpinShuxingLabel.attributedText = attributedString1;
            NSString *str11 = [phone substringWithRange:NSMakeRange(4, phone.length - 4)];
            [cell.shangpinShuxingLabel yb_addAttributeTapActionWithStrings:@[str11] delegate:self];
            
        }else{
            cell.shangpinShuxingLabel.text = [NSString stringWithFormat:@"%@",productModel.attr];
        }
        
        float price = [productModel.money floatValue] / 100;
        cell.priceLabel.text = [NSString stringWithFormat:@"¥%.2f",price];
        cell.countLabel.hidden = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"1111");
    SYOrderModel *orderModel = self.dataSourceArr[indexPath.section];
    if ([orderModel.type integerValue] == 5) {
        SYChakanGrapherViewController *gra = [[SYChakanGrapherViewController alloc] init];
        gra.userDic = @{@"id":orderModel.orderId};
        [self.navigationController pushViewController:gra animated:YES];
    }else if ([orderModel.type integerValue] == 10) {
        NSArray *product = orderModel.product;
        SYProductModel *model = product[indexPath.row];
        SYBisnessInfosViewController *infos = [[SYBisnessInfosViewController alloc] initWithIsFromXSorXXType:isFromXX shangpinID:model.productId shangjiaID:orderModel.pid];
        [self.navigationController pushViewController:infos animated:YES];
    }
}

//delegate
- (void)yb_attributeTapReturnString:(NSString *)string range:(NSRange)range index:(NSInteger)index
{
    NSLog(@"打电话");
    NSMutableString* str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",string];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 114;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 46;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = BackGroundColor;
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 12, kScreenWidth, 34)];
    view1.backgroundColor = [UIColor whiteColor];
    [view addSubview:view1];
    SYOrderModel *orderModel = self.dataSourceArr[section];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 17, kScreenWidth - 100 - 40, 17)];
    
    label.text = orderModel.name;
    label.textColor = HexRGB(0x434343);
    label.font = [UIFont systemFontOfSize:17];
    [view1 addSubview:label];
    
    
    UILabel *stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 15 - 100, 17, 100, 14)];
    stateLabel.textColor = HexRGB(0x434343);
    switch ([orderModel.state integerValue]) {
        case 1:
        {
            //待付款
            stateLabel.text = @"待付款";
        }
            break;
        case 3:
        {
            //可使用
            stateLabel.text = @"可使用";
        }
            break;

        case 4:
        {
            //待评价
            if ([orderModel.type integerValue] == 5) {
                stateLabel.text = @"已使用";
            }else{
                stateLabel.text = @"待评价";
            }
            
        }
            break;
        case 5:
        {
            //已完成
            stateLabel.text = @"已完成";
            
        }
            break;
            
        default:
            break;
    }
    
    stateLabel.textAlignment = NSTextAlignmentRight;
    stateLabel.font = [UIFont systemFontOfSize:14];
    [view1 addSubview:stateLabel];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    SYOrderModel *orderModel = self.dataSourceArr[section];
    if ([orderModel.state integerValue] == 5) {
        return 0.0001f;
    }
    return 56;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    SYOrderModel *orderModel = self.dataSourceArr[section];
    switch ([orderModel.state integerValue]) {
        case 1:
        {
            //待付款
            return [self daifukuaiFooterViewWithOrderModel:orderModel Section:section];
        }
            break;
        case 3:
        {
            //待使用
            return [self keshiyongFooterViewWithOrderModel:orderModel Section:section];
        }
            break;
        case 4:
        {
            //待评价
            return [self daipingjiaFooterViewWithOrderModel:orderModel Section:section];
        }
            break;
        case 5:
        {
            //已完成
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = [UIColor whiteColor];
            return view;
        }
            break;
            
        default:
            break;
    }
    return nil;
}

- (UIView *)daifukuaiFooterViewWithOrderModel:(SYOrderModel *)orderModel Section:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    
    UIButton *fukuanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [fukuanBtn setAdjustsImageWhenHighlighted:NO];
    fukuanBtn.frame = CGRectMake(kScreenWidth - 15 - 58, 10, 58, 35);
    [fukuanBtn setTitle:@"付款" forState:UIControlStateNormal];
    fukuanBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [fukuanBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [fukuanBtn setBackgroundImage:[UIImage imageWithColor:HexRGB(0xff8402) Size:fukuanBtn.frame.size] forState:UIControlStateNormal];
    fukuanBtn.layer.cornerRadius = 6;
    fukuanBtn.layer.masksToBounds = YES;
    [fukuanBtn addTarget:self action:@selector(fukuaiAction:) forControlEvents:UIControlEventTouchUpInside];
    fukuanBtn.tag = section;
    [view addSubview:fukuanBtn];
    
    UIButton *cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancleBtn setAdjustsImageWhenHighlighted:NO];
    cancleBtn.frame = CGRectMake(kScreenWidth - 15 - 58 - 23 - 81, 10, 81, 35);
    [cancleBtn setTitle:@"取消订单" forState:UIControlStateNormal];
    cancleBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [cancleBtn setTitleColor:HexRGB(0x3dcfbb) forState:UIControlStateNormal];
    cancleBtn.layer.cornerRadius = 6;
    cancleBtn.layer.masksToBounds = YES;
    cancleBtn.layer.borderColor = HexRGB(0x3dcfbb).CGColor;
    cancleBtn.layer.borderWidth = 1;
    [cancleBtn addTarget:self action:@selector(cancleDingDanAction:) forControlEvents:UIControlEventTouchUpInside];
    cancleBtn.tag = section;
    [view addSubview:cancleBtn];
    
    //数量
    UILabel *label11 = [[UILabel alloc] initWithFrame:CGRectMake(15, 18, kScreenWidth - 15 - 58 - 23 - 81 - 20, 20)];
    if (kScreenWidth > 321) {
        label11.font = [UIFont systemFontOfSize:14];
    }else{
        label11.font = [UIFont systemFontOfSize:11];
    }
    
    label11.textColor = HexRGB(0x434343);
    NSInteger count = [orderModel.count integerValue];
    float money = [orderModel.money floatValue] / 100;
    label11.text = [NSString stringWithFormat:@"数量:%ld  合计:¥%.2f",(long)count, money];
    [view addSubview:label11];
    return view;
}

- (UIView *)keshiyongFooterViewWithOrderModel:(SYOrderModel *)orderModel Section:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    
    UIButton *fukuanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [fukuanBtn setAdjustsImageWhenHighlighted:NO];
    fukuanBtn.frame = CGRectMake(kScreenWidth - 15 - 58, 10, 58, 35);
    [fukuanBtn setTitle:@"已完成" forState:UIControlStateNormal];
    fukuanBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [fukuanBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [fukuanBtn setBackgroundImage:[UIImage imageWithColor:HexRGB(0xff8401) Size:fukuanBtn.frame.size] forState:UIControlStateNormal];
    fukuanBtn.layer.cornerRadius = 6;
    fukuanBtn.layer.masksToBounds = YES;
    [fukuanBtn addTarget:self action:@selector(yiwanchengAction:) forControlEvents:UIControlEventTouchUpInside];
    fukuanBtn.tag = section;
    if ([orderModel.type integerValue] == 5) {
        [view addSubview:fukuanBtn];
    }
    //数量
    UILabel *label11 = [[UILabel alloc] initWithFrame:CGRectMake(15, 18, kScreenWidth - 15 - 58 - 20, 20)];
    label11.font = [UIFont systemFontOfSize:14];
    label11.textColor = HexRGB(0x434343);
    NSInteger count = [orderModel.count integerValue];
    float money = [orderModel.money floatValue] / 100;
    label11.text = [NSString stringWithFormat:@"数量：%ld   合计：¥%.2f",(long)count, money];
    [view addSubview:label11];
    
    return view;
}

- (UIView *)daipingjiaFooterViewWithOrderModel:(SYOrderModel *)orderModel Section:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];

    if ([orderModel.type integerValue] == 5) {
        
        UIButton *cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancleBtn setAdjustsImageWhenHighlighted:NO];
        cancleBtn.frame = CGRectMake(kScreenWidth - 15 - 81, 10, 81, 35);
        [cancleBtn setTitle:@"删除订单" forState:UIControlStateNormal];
        cancleBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [cancleBtn setTitleColor:HexRGB(0x3dcfbb) forState:UIControlStateNormal];
        cancleBtn.layer.cornerRadius = 6;
        cancleBtn.layer.masksToBounds = YES;
        cancleBtn.layer.borderColor = HexRGB(0x3dcfbb).CGColor;
        cancleBtn.layer.borderWidth = 1;
        [cancleBtn addTarget:self action:@selector(deleteDingDanAction:) forControlEvents:UIControlEventTouchUpInside];
        cancleBtn.tag = section;
        [view addSubview:cancleBtn];
        
        //数量
        UILabel *label11 = [[UILabel alloc] initWithFrame:CGRectMake(15, 18, kScreenWidth - 15 - 81 - 20, 20)];
        label11.font = [UIFont systemFontOfSize:14];
        label11.textColor = HexRGB(0x434343);
        NSInteger count = [orderModel.count integerValue];
        float money = [orderModel.money floatValue] / 100;
        label11.text = [NSString stringWithFormat:@"数量：%ld   合计：¥%.2f",(long)count, money];
        [view addSubview:label11];
        
        return view;
    }
    
    UIButton *fukuanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [fukuanBtn setAdjustsImageWhenHighlighted:NO];
    fukuanBtn.frame = CGRectMake(kScreenWidth - 15 - 58, 10, 58, 35);
    [fukuanBtn setTitle:@"评价" forState:UIControlStateNormal];
    fukuanBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [fukuanBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [fukuanBtn setBackgroundImage:[UIImage imageWithColor:HexRGB(0xff8402) Size:fukuanBtn.frame.size] forState:UIControlStateNormal];
    fukuanBtn.layer.cornerRadius = 6;
    fukuanBtn.layer.masksToBounds = YES;
    [fukuanBtn addTarget:self action:@selector(pingjiaAction:) forControlEvents:UIControlEventTouchUpInside];
    fukuanBtn.tag = section;
    [view addSubview:fukuanBtn];
    
    UIButton *cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancleBtn setAdjustsImageWhenHighlighted:NO];
    cancleBtn.frame = CGRectMake(kScreenWidth - 15 - 58 - 23 - 81, 10, 81, 35);
    [cancleBtn setTitle:@"删除订单" forState:UIControlStateNormal];
    cancleBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [cancleBtn setTitleColor:HexRGB(0x3dcfbb) forState:UIControlStateNormal];
    cancleBtn.layer.cornerRadius = 6;
    cancleBtn.layer.masksToBounds = YES;
    cancleBtn.layer.borderColor = HexRGB(0x3dcfbb).CGColor;
    cancleBtn.layer.borderWidth = 1;
    [cancleBtn addTarget:self action:@selector(deleteDingDanAction:) forControlEvents:UIControlEventTouchUpInside];
    cancleBtn.tag = section;
    [view addSubview:cancleBtn];
    
    //数量
    UILabel *label11 = [[UILabel alloc] initWithFrame:CGRectMake(15, 18, kScreenWidth - 15 - 58 - 23 - 81 - 20, 20)];
    label11.font = [UIFont systemFontOfSize:14];
    label11.textColor = HexRGB(0x434343);
    NSInteger count = [orderModel.count integerValue];
    float money = [orderModel.money floatValue] / 100;
    label11.text = [NSString stringWithFormat:@"数量：%ld   合计：¥%.2f",(long)count, money];
    [view addSubview:label11];
    
    
    return view;
}

#pragma mark - privateMethod
//付款
- (void)fukuaiAction:(UIButton *)sender{
    NSLog(@"付款");
    SYOrderModel *orderModel = self.dataSourceArr[sender.tag];
    SYOrderPaymentViewController *orderPay = [[SYOrderPaymentViewController alloc] init];
    orderPay.orderModel= orderModel;
    orderPay.isFromXX = YES;
    [self.navigationController pushViewController:orderPay animated:YES];
}
//取消订单
- (void)cancleDingDanAction:(UIButton *)sender{
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
        SYOrderModel *orderModel = self.dataSourceArr[sender.tag];
        [weakself changeOrderState:@0 OrderID:orderModel.orderId];
    };
    delete.rightBlock = ^{
        NSLog(@"right");
        [weakDelete dismiss];
    };
    [delete show];
}
//确认收货
- (void)yiwanchengAction:(UIButton *)sender{
    NSLog(@"确认收货");
    DeleteOrderView *delete = [[[NSBundle mainBundle] loadNibNamed:@"DeleteOrderView" owner:self options:nil] lastObject];
    delete.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    delete.tishiLabel.text = @"本次约拍已结束";
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
        SYOrderModel *orderModel = self.dataSourceArr[sender.tag];
        [weakself changeOrderState:@4 OrderID:orderModel.orderId];
    };
    [delete show];
}
//评价
- (void)pingjiaAction:(UIButton *)sender{
    NSLog(@"评价");
    SYOrderModel *orderModel = self.dataSourceArr[sender.tag];
    SYOrderPingJiaViewController *pingjia = [[SYOrderPingJiaViewController alloc] init];
    pingjia.orderID = orderModel.orderId;
    pingjia.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight);
    [self.navigationController pushViewController:pingjia animated:YES];
}
//删除订单
- (void)deleteDingDanAction:(UIButton *)sender{
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
        SYOrderModel *orderModel = self.dataSourceArr[sender.tag];
        [weakself changeOrderState:@5 OrderID:orderModel.orderId];
    };
    [delete show];
}

- (void)changeOrderState:(NSNumber *)state OrderID:(NSNumber *)orderid{
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
                [weakself showHint:[responseResult objectForKey:@"msg"]];
                [weakself getData];
            }else{
                
            }
        }
    }];
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 42 - 16 - 46) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = BackGroundColor;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self getData];
        }];
        MJRefreshAutoStateFooter *footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
            [self getMoreData];
        }];
        
        [footer setTitle:@"已加载全部线下订单" forState:MJRefreshStateNoMoreData];
        _tableView.mj_footer = footer;
        
    }
    return _tableView;
}

- (void)getData{
    [SVProgressHUD show];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/order/all.html"];
    NSDictionary *param = @{@"token":UserToken, @"state":@2, @"page":@1};
    __weak typeof(self)weakself = self;
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        [SVProgressHUD dismiss];
        if ([self.tableView.mj_header isRefreshing]) {
            [self.tableView.mj_header endRefreshing];
        }
        _count = 1;
        NSLog(@"获取线下全部订单 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [weakself showHint:@"服务器不给力，请稍后重试"];
            if (weakself.dataSourceArr.count == 0) {
                [weakself.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                [weakself.view addSubview:weakself.dataView];
            }
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                [weakself.dataView removeFromSuperview];
                
                if ([responseResult objectForKey:@"count"] && [(NSDictionary *)[responseResult objectForKey:@"count"] count] > 0) {
                    if ([[responseResult objectForKey:@"count"] isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *count = [responseResult objectForKey:@"count"];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"xxorderUnreadMessage" object:nil userInfo:count];
                    }
                    
                }
                
                NSArray *data = [responseResult objectForKey:@"data"];
                if (data.count > 0) {
                    [weakself.orderView removeFromSuperview];
                    [weakself.view addSubview:weakself.tableView];
                    if (data.count < 10) {
                        [weakself.tableView.mj_footer endRefreshingWithNoMoreData];
                    }else{
                        [weakself.tableView.mj_footer resetNoMoreData];
                    }
                    
                    [weakself.dataSourceArr removeAllObjects];
                    for (NSDictionary *orderDic in data) {
                        SYOrderModel *orderModel = [SYOrderModel orderWithDictionary:orderDic];
                        [weakself.dataSourceArr addObject:orderModel];
                    }
                    [weakself.tableView reloadData];
                }else{
                    [weakself.tableView removeFromSuperview];
                    [weakself.view addSubview:weakself.orderView];
                }
                
                
            }else{
                if (weakself.dataSourceArr.count == 0) {
                    [weakself.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                    [weakself.view addSubview:weakself.dataView];
                }
                
                if ([responseResult objectForKey:@"msg"]) {
                    [weakself showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (void)getMoreData{
    _count ++;
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/order/all.html"];
    NSDictionary *param = @{@"token":UserToken, @"state":@2, @"page":[NSNumber numberWithInteger:_count]};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        if ([self.tableView.mj_footer isRefreshing]) {
            [self.tableView.mj_footer endRefreshing];
        }
        NSLog(@"获取线下全部订单 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                NSArray *data = [responseResult objectForKey:@"data"];
                if (data.count < 10) {
                    [self.tableView.mj_footer endRefreshingWithNoMoreData];
                }
                for (NSDictionary *orderDic in data) {
                    SYOrderModel *orderModel = [SYOrderModel orderWithDictionary:orderDic];
                    [self.dataSourceArr addObject:orderModel];
                }
                [self.tableView reloadData];
                
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (NSMutableArray *)dataSourceArr{
    if (!_dataSourceArr) {
        _dataSourceArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSourceArr;
}

- (NoDataView *)dataView{
    if (!_dataView) {
        _dataView = [[[NSBundle mainBundle] loadNibNamed:@"NoDataView" owner:self options:nil] lastObject];
        _dataView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 42 - 16 - 46);
        __weak typeof(self)weakself = self;
        _dataView.block = ^(){
            [weakself getData];
        };
    }
    return _dataView;
}

- (NoOrderView *)orderView{
    if (!_orderView) {
        _orderView = [[[NSBundle mainBundle] loadNibNamed:@"NoOrderView" owner:self options:nil] lastObject];
        _orderView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 42 - 16 - 46);
    }
    return _orderView;
}

@end
