//
//  SYXSAllViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/3/31.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYXSAllViewController.h"
#import "SYShangPinTableViewCell.h"
#import "NoDataView.h"
#import "NoOrderView.h"
#import "SYOrderPaymentViewController.h"
#import "DeleteOrderView.h"
#import "SYOrderPingJiaViewController.h"
#import "SYOrderModel.h"
#import "SYProductModel.h"
#import "SYOrderInfosViewController.h"
#import "SYBisnessInfosViewController.h"

@interface SYXSAllViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSInteger _count;
}

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSourceArr;

@property (nonatomic, strong) NoOrderView *orderView;

@property (nonatomic, strong) NoDataView *dataView;

@end

@implementation SYXSAllViewController

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
        SYProductModel *proModel = product[indexPath.row];
        [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,proModel.img_200]] placeholderImage:[UIImage imageNamed:@"shangchuan_wode_wutupian"]];
        cell.shangpinLabel.text = proModel.name;
        cell.shangpinShuxingLabel.text = [NSString stringWithFormat:@"%@",proModel.attr];
        float price = [proModel.money floatValue] / 100;
        cell.priceLabel.text = [NSString stringWithFormat:@"¥%.2f",price];
        cell.countLabel.text = [NSString stringWithFormat:@"x%@",[proModel.num stringValue]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SYOrderModel *orderModel = self.dataSourceArr[indexPath.section];
    if ([orderModel.state integerValue] == 1) {
//        NSArray *product = orderModel.product;
//        SYProductModel *model = product[indexPath.row];
//        SYBisnessInfosViewController *infos = [[SYBisnessInfosViewController alloc] initWithIsFromXSorXXType:isFromXS shangpinID:model.productId shangjiaID:orderModel.pid];
//
//        [self.navigationController pushViewController:infos animated:YES];
    
        SYOrderInfosViewController *infos = [[SYOrderInfosViewController alloc] init];
        infos.param = @{@"token":UserToken, @"id":orderModel.orderId, @"state":@1};
        infos.type = OrderTypeWeiFuKuan;
        [self.navigationController pushViewController:infos animated:YES];
    }else if([orderModel.state integerValue] == 2){
        SYOrderInfosViewController *infos = [[SYOrderInfosViewController alloc] init];
        infos.param = @{@"token":UserToken, @"id":orderModel.orderId, @"state":@2};
        infos.type = OrderTypeDaiFaHuo;
        [self.navigationController pushViewController:infos animated:YES];
    }else if([orderModel.state integerValue] == 3){
        SYOrderInfosViewController *infos = [[SYOrderInfosViewController alloc] init];
        infos.param = @{@"token":UserToken, @"id":orderModel.orderId, @"state":@3};
        infos.type = OrderTypeDaiShouHuo;
        [self.navigationController pushViewController:infos animated:YES];
    }else if([orderModel.state integerValue] == 4){
        SYOrderInfosViewController *infos = [[SYOrderInfosViewController alloc] init];
        infos.param = @{@"token":UserToken, @"id":orderModel.orderId, @"state":@4};
        infos.type = OrderTypeDaiPingJia;
        [self.navigationController pushViewController:infos animated:YES];
    }else if([orderModel.state integerValue] == 5){
        SYOrderInfosViewController *infos = [[SYOrderInfosViewController alloc] init];
        infos.param = @{@"token":UserToken, @"id":orderModel.orderId, @"state":@5};
        infos.type = OrderTypeYiWanCheng;
        [self.navigationController pushViewController:infos animated:YES];
    }
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
        case 2:
        {
            //待发货
            stateLabel.text = @"待发货";
        }
            break;
        case 3:
        {
            //待收货
            stateLabel.text = @"待收货";
        }
            break;
        case 4:
        {
            //待评价
            stateLabel.text = @"待评价";
        }
            break;
        case 5:
        {
            //待评价
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
    switch ([orderModel.state integerValue]) {
        case 1:
        {
            //待付款
            return 90;
        }
            break;
        case 2:
        {
            //待发货
            return 44;
        }
            break;
        case 3:
        {
            //待收货
            return 90;
        }
            break;
        case 4:
        {
            //待评价
            return 90;
        }
            break;
        case 5:
        {
            //已完成
            return 90;
        }
            
        default:
            break;
    }
    return 0.00001f;
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
        case 2:
        {
            //待发货
            return [self daifahuoFooterViewWithOrderModel:orderModel Section:section];
        }
            break;
        case 3:
        {
            //待收货
            return [self daishouhuoFooterViewWithOrderModel:orderModel Section:section];
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
            return [self yiwanchengFooterViewWithOrderModel:orderModel Section:section];
        }
            
        default:
            break;
    }
    return nil;
}

- (UIView *)daifukuaiFooterViewWithOrderModel:(SYOrderModel *)orderModel Section:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    
    UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 80, 15)];
    numLabel.textColor = HexRGB(0x434343);
    numLabel.font = [UIFont systemFontOfSize:14];
    numLabel.text = [NSString stringWithFormat:@"共%@件商品",[orderModel.count stringValue]];
    [view addSubview:numLabel];
    
    UILabel *hejiLabel = [[UILabel alloc] initWithFrame:CGRectMake(105, 15, kScreenWidth - 120, 15)];
    float money = [orderModel.money floatValue] / 100;
    NSString *moneyStr = [NSString stringWithFormat:@"合计：¥%.2f",money];
    float fee = [orderModel.fee floatValue] / 100;
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
    
    UIButton *fukuanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [fukuanBtn setAdjustsImageWhenHighlighted:NO];
    fukuanBtn.frame = CGRectMake(kScreenWidth - 15 - 58, CGRectGetMaxY(lineView.frame) + 5, 58, 35);
    [fukuanBtn setTitle:@"付款" forState:UIControlStateNormal];
    fukuanBtn.tag = section;
    fukuanBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [fukuanBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [fukuanBtn setBackgroundImage:[UIImage imageWithColor:HexRGB(0xff8402) Size:fukuanBtn.frame.size] forState:UIControlStateNormal];
    fukuanBtn.layer.cornerRadius = 6;
    fukuanBtn.layer.masksToBounds = YES;
    [fukuanBtn addTarget:self action:@selector(fukuaiAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:fukuanBtn];
    
    UIButton *cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancleBtn setAdjustsImageWhenHighlighted:NO];
    cancleBtn.frame = CGRectMake(kScreenWidth - 15 - 58 - 23 - 81, CGRectGetMaxY(lineView.frame) + 5, 81, 35);
    [cancleBtn setTitle:@"取消订单" forState:UIControlStateNormal];
    cancleBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [cancleBtn setTitleColor:HexRGB(0x3dcfbb) forState:UIControlStateNormal];
    cancleBtn.layer.cornerRadius = 6;
    cancleBtn.layer.masksToBounds = YES;
    cancleBtn.layer.borderColor = HexRGB(0x3dcfbb).CGColor;
    cancleBtn.layer.borderWidth = 1;
    cancleBtn.tag = section;
    [cancleBtn addTarget:self action:@selector(cancleDingDanAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:cancleBtn];
    
    return view;
}

- (UIView *)daifahuoFooterViewWithOrderModel:(SYOrderModel *)orderModel Section:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    
    UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 80, 15)];
    numLabel.textColor = HexRGB(0x434343);
    numLabel.font = [UIFont systemFontOfSize:14];
    numLabel.text = [NSString stringWithFormat:@"共%@件商品",[orderModel.count stringValue]];
    [view addSubview:numLabel];
    
    UILabel *hejiLabel = [[UILabel alloc] initWithFrame:CGRectMake(105, 15, kScreenWidth - 120, 15)];
    float money = [orderModel.money floatValue] / 100;
    NSString *moneyStr = [NSString stringWithFormat:@"合计：¥%.2f",money];
    float fee = [orderModel.fee floatValue] / 100;
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
    
    return view;
}

- (UIView *)daishouhuoFooterViewWithOrderModel:(SYOrderModel *)orderModel Section:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    
    UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 80, 15)];
    numLabel.textColor = HexRGB(0x434343);
    numLabel.font = [UIFont systemFontOfSize:14];
    numLabel.text = [NSString stringWithFormat:@"共%@件商品",[orderModel.count stringValue]];
    [view addSubview:numLabel];
    
    UILabel *hejiLabel = [[UILabel alloc] initWithFrame:CGRectMake(105, 15, kScreenWidth - 120, 15)];
    float money = [orderModel.money floatValue] / 100;
    NSString *moneyStr = [NSString stringWithFormat:@"合计：¥%.2f",money];
    float fee = [orderModel.fee floatValue] / 100;
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
    
    UIButton *cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancleBtn setAdjustsImageWhenHighlighted:NO];
    cancleBtn.frame = CGRectMake(kScreenWidth - 15 - 81, CGRectGetMaxY(lineView.frame) + 5, 81, 35);
    [cancleBtn setTitle:@"确认收货" forState:UIControlStateNormal];
    cancleBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [cancleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancleBtn setBackgroundImage:[UIImage imageWithColor:HexRGB(0xff8402) Size:cancleBtn.frame.size] forState:UIControlStateNormal];
    cancleBtn.layer.cornerRadius = 6;
    cancleBtn.layer.masksToBounds = YES;
    [cancleBtn addTarget:self action:@selector(querenshouhuoAction:) forControlEvents:UIControlEventTouchUpInside];
    cancleBtn.tag = section;
    [view addSubview:cancleBtn];
    
    //快递号
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(lineView.frame) + 5, kScreenWidth - 45 - 81, 35)];
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = HexRGB(0x8e8d8d);
    label.text = [NSString stringWithFormat:@"%@:%@",orderModel.company, orderModel.express];
    [view addSubview:label];
    
    return view;
}

- (UIView *)daipingjiaFooterViewWithOrderModel:(SYOrderModel *)orderModel Section:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    
    UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 80, 15)];
    numLabel.textColor = HexRGB(0x434343);
    numLabel.font = [UIFont systemFontOfSize:14];
    numLabel.text = [NSString stringWithFormat:@"共%@件商品",[orderModel.count stringValue]];
    [view addSubview:numLabel];
    
    UILabel *hejiLabel = [[UILabel alloc] initWithFrame:CGRectMake(105, 15, kScreenWidth - 120, 15)];
    float money = [orderModel.money floatValue] / 100;
    NSString *moneyStr = [NSString stringWithFormat:@"合计：¥%.2f",money];
    float fee = [orderModel.fee floatValue] / 100;
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
    
    UIButton *fukuanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [fukuanBtn setAdjustsImageWhenHighlighted:NO];
    fukuanBtn.frame = CGRectMake(kScreenWidth - 15 - 58, CGRectGetMaxY(lineView.frame) + 5, 58, 35);
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
    cancleBtn.frame = CGRectMake(kScreenWidth - 15 - 58 - 23 - 81, CGRectGetMaxY(lineView.frame) + 5, 81, 35);
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
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(lineView.frame) + 5, kScreenWidth - 15 - 58 - 23 - 81 - 30, 35)];
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = HexRGB(0x8e8d8d);
    label.text = [NSString stringWithFormat:@"%@:%@",orderModel.company, orderModel.express];
    [view addSubview:label];
    
    return view;
}

//已完成
- (UIView *)yiwanchengFooterViewWithOrderModel:(SYOrderModel *)orderModel Section:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    
    UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 80, 15)];
    numLabel.textColor = HexRGB(0x434343);
    numLabel.font = [UIFont systemFontOfSize:14];
    numLabel.text = [NSString stringWithFormat:@"共%@件商品",[orderModel.count stringValue]];
    [view addSubview:numLabel];
    
    UILabel *hejiLabel = [[UILabel alloc] initWithFrame:CGRectMake(105, 15, kScreenWidth - 120, 15)];
    float money = [orderModel.money floatValue] / 100;
    NSString *moneyStr = [NSString stringWithFormat:@"合计：¥%.2f",money];
    float fee = [orderModel.fee floatValue] / 100;
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
    
    UIButton *cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancleBtn setAdjustsImageWhenHighlighted:NO];
    cancleBtn.frame = CGRectMake(kScreenWidth - 15 - 80, 5, 80, 35);
    [cancleBtn setTitle:@"删除订单" forState:UIControlStateNormal];
    cancleBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [cancleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancleBtn.layer.cornerRadius = 6;
    cancleBtn.layer.masksToBounds = YES;
    
    [cancleBtn setBackgroundImage:[UIImage imageWithColor:HexRGB(0xff8401) Size:cancleBtn.frame.size] forState:UIControlStateNormal];
    [cancleBtn addTarget:self action:@selector(deleteDingDanAction:) forControlEvents:UIControlEventTouchUpInside];
    cancleBtn.tag = section;
    [view1 addSubview:cancleBtn];

    
    [view addSubview:view1];
    
    return view;
}


#pragma mark - privateMethod
//付款
- (void)fukuaiAction:(UIButton *)sender{
    NSLog(@"付款");
    SYOrderModel *orderModel = self.dataSourceArr[sender.tag];
    SYOrderPaymentViewController *orderPay = [[SYOrderPaymentViewController alloc] init];
    orderPay.orderModel= orderModel;
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
- (void)querenshouhuoAction:(UIButton *)sender{
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
        SYOrderModel *orderModel = self.dataSourceArr[sender.tag];
        [weakself changeOrderState:@4 OrderID:orderModel.orderId];
    };
    [delete show];
    
}
//评价
- (void)pingjiaAction:(UIButton *)sender{
    NSLog(@"评价");
    SYOrderPingJiaViewController *pingjia = [[SYOrderPingJiaViewController alloc] init];
    
    SYOrderModel *orderModel = self.dataSourceArr[sender.tag];
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
        
        [footer setTitle:@"已加载全部线上订单" forState:MJRefreshStateNoMoreData];
        _tableView.mj_footer = footer;
        
    }
    return _tableView;
}

- (void)getData{
    [SVProgressHUD show];
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/order/all.html"];
    NSDictionary *param = @{@"token":UserToken, @"state":@1, @"page":@1};
    __weak typeof(self)weakself = self;
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        [SVProgressHUD dismiss];
        if ([self.tableView.mj_header isRefreshing]) {
            [self.tableView.mj_header endRefreshing];
        }
        _count = 1;
        NSLog(@"获取线上全部订单 -- %@",responseResult);
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
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"orderUnreadMessage" object:nil userInfo:count];
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
                        SYOrderModel *model = [SYOrderModel orderWithDictionary:orderDic];
                        [weakself.dataSourceArr addObject:model];
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
    NSDictionary *param = @{@"token":UserToken, @"state":@1, @"page":[NSNumber numberWithInteger:_count]};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        if ([self.tableView.mj_footer isRefreshing]) {
            [self.tableView.mj_footer endRefreshing];
        }
        NSLog(@"获取线上全部订单 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                NSArray *data = [responseResult objectForKey:@"data"];
                if (data.count < 10) {
                    [self.tableView.mj_footer endRefreshingWithNoMoreData];
                }
                for (NSDictionary *orderDic in data) {
                    SYOrderModel *model = [SYOrderModel orderWithDictionary:orderDic];
                    [self.dataSourceArr addObject:model];
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
