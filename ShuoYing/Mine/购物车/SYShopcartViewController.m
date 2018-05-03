//
//  SYShopcartViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/5/3.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYShopcartViewController.h"
#import "SYShopcartTableViewCell.h"
#import "SYShopcartShangjiaModel.h"
#import "SYShopcartShangpinModel.h"
#import "SYShopcartPayOrderViewController.h"
#import "DeleteOrderView.h"
@interface SYShopcartViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    BOOL _bottomSelected;
    
    UIButton *_bottomQuanXuanBtn;
    UIButton *_bottomJieSuanBtn;
    UILabel *_bottomHejiLabel;
    UILabel *_bottomYunFeiLabel;
    UIView *_bottomView;
    NSInteger _count;
    
    BOOL _isEdit;
    BOOL _editBottomSelected;
    UIButton *_editQuanXuanBtn;
    UIButton *_editDeleteBtn;
    UIView *_editBottomView;
    
    UIButton *_rightItemBtn;
}

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSourceArr;

@property (nonatomic, strong) UIView *noThingView;

@property (nonatomic, strong) NoDataView *noDataView;
@end

@implementation SYShopcartViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"self.dataSourceArr - %@",self.dataSourceArr);
    _isEdit = NO;
    _bottomSelected = NO;
    _editBottomSelected = NO;
    [self.tableView.mj_header beginRefreshing];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"购物车";
    
    _count = 1;
    [self.view addSubview:self.tableView];
}

- (UIBarButtonItem *)rightItem{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 40, kNavigationBarHeightAndStatusBarHeight);
    [btn setTitle:@"编辑" forState:UIControlStateNormal];
    [btn setTitle:@"完成" forState:UIControlStateSelected];
    
    [btn setAdjustsImageWhenHighlighted:NO];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [btn addTarget:self action:@selector(editShopCart:) forControlEvents:UIControlEventTouchUpInside];
    _rightItemBtn = btn;
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    //    self.navigationItem.rightBarButtonItem = item;
    _rightItem = item;
    return _rightItem;
}

- (void)editShopCart:(UIButton *)sender{
    if (self.dataSourceArr.count == 0) {
        return;
    }
    sender.selected = !sender.selected;
    _isEdit = sender.selected;
    for (SYShopcartShangjiaModel *shangjia in self.dataSourceArr) {
        shangjia.isSelected = @NO;
        NSArray *goods = shangjia.goods;
        for (SYShopcartShangpinModel *shangpin in goods) {
            shangpin.isSelected = @NO;
        }
    }
    if (_isEdit) {
        [self editBottom];
    }else{
        [_editBottomView removeFromSuperview];
    }
    [self reloadBottomDataSource];
    [self.tableView reloadData];
}

- (void)editBottom{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 55 - kNavigationBarHeightAndStatusBarHeight - kTabbarHeight, kScreenWidth, 55)];
    view.backgroundColor = [UIColor whiteColor];
    _editBottomView = view;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setAdjustsImageWhenHighlighted:NO];
    btn.frame = CGRectMake(kScreenWidth - 104, 0, 104, 55);
    [btn setBackgroundImage:[UIImage imageWithColor:NavigationColor Size:btn.frame.size] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageWithColor:RGB(204, 204, 204) Size:btn.frame.size] forState:UIControlStateDisabled];
    [btn setTitle:@"删除(0)" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:17];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
    btn.enabled = NO;
    [view addSubview:btn];
    _editDeleteBtn = btn;
    
    UIButton *quanxuanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [quanxuanBtn setAdjustsImageWhenHighlighted:NO];
    quanxuanBtn.frame = CGRectMake(14, 0, 70, 55);
    [quanxuanBtn setImage:[UIImage imageNamed:@"gouwuche_icon_nor"] forState:UIControlStateNormal];
    [quanxuanBtn setTitle:@"全选" forState:UIControlStateNormal];
    [quanxuanBtn setTitleColor:HexRGB(0x6c6c6c) forState:UIControlStateNormal];
    quanxuanBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [quanxuanBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    quanxuanBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [quanxuanBtn addTarget:self action:@selector(editBottomQuanXuanAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:quanxuanBtn];
    _editQuanXuanBtn = quanxuanBtn;
    
    _editBottomSelected = NO;
    [self.view addSubview:view];
    
}

#pragma mark - 删除商品
- (void)deleteAction:(UIButton *)sender{
    DeleteOrderView *delete = [[[NSBundle mainBundle] loadNibNamed:@"DeleteOrderView" owner:self options:nil] lastObject];
    delete.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    delete.tishiLabel.text = @"确定要删除该商品吗？";
    [delete.leftBtn setTitle:@"确定" forState:UIControlStateNormal];
    [delete.rightBtn setTitle:@"取消" forState:UIControlStateNormal];
    __weak typeof(self)weakself = self;
    __weak typeof(delete)weakDelete = delete;
    delete.leftBlock = ^{
        NSLog(@"left");
        [weakDelete dismiss];
        [weakself deleteGoods];
    };
    delete.rightBlock = ^{
        NSLog(@"right");
        [weakDelete dismiss];
    };
    [delete show];
}

- (void)deleteGoods{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl, @"/store/delcart.html"];
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:0];
    for (SYShopcartShangjiaModel *shangjia in self.dataSourceArr) {
        NSArray *goods = shangjia.goods;
        for (SYShopcartShangpinModel *shangpin in goods) {
            if ([shangpin.isSelected boolValue]) {
                NSString *cartId = [shangpin.shangpinid stringValue];
                [arr addObject:cartId];
            }
        }
    }
    NSString *carts = [arr componentsJoinedByString:@","];
    NSDictionary *param = @{@"id":carts, @"token":UserToken};
    [SVProgressHUD show];
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        [SVProgressHUD dismiss];
        NSLog(@"删除商品 -  %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                [self getData];

                [self reloadBottomDataSource];
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}
#pragma mark - 编辑状态底部全选按钮
- (void)editBottomQuanXuanAction:(UIButton *)sender{
    NSLog(@"1111");
    _editBottomSelected = !_editBottomSelected;
    if (_editBottomSelected) {
        for (SYShopcartShangjiaModel *shangjia in self.dataSourceArr) {
            shangjia.isSelected = @YES;
            for (SYShopcartShangpinModel *shangpin in shangjia.goods) {
                shangpin.isSelected = @YES;

            }
        }
    }else{
        for (SYShopcartShangjiaModel *shangjia in self.dataSourceArr) {
            shangjia.isSelected = @NO;
            NSArray *goods = shangjia.goods;
            for (SYShopcartShangpinModel *shangpin in goods) {
                shangpin.isSelected = @NO;
                
            }
        }
        
    }
    
    [self.tableView reloadData];
    [self reloadBottomDataSource];
}

- (void)initBottomView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 55 - kNavigationBarHeightAndStatusBarHeight - kTabbarHeight, kScreenWidth, 55)];
    view.backgroundColor = [UIColor whiteColor];
    _bottomView = view;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setAdjustsImageWhenHighlighted:NO];
    btn.frame = CGRectMake(kScreenWidth - 104, 0, 104, 55);
    [btn setBackgroundImage:[UIImage imageWithColor:NavigationColor Size:btn.frame.size] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageWithColor:RGB(204, 204, 204) Size:btn.frame.size] forState:UIControlStateDisabled];
    [btn setTitle:@"结算(0)" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:17];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(bottomJieSuanAction:) forControlEvents:UIControlEventTouchUpInside];
    btn.enabled = NO;
    [view addSubview:btn];
    _bottomJieSuanBtn = btn;
    
    UIButton *quanxuanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [quanxuanBtn setAdjustsImageWhenHighlighted:NO];
    quanxuanBtn.frame = CGRectMake(14, 0, 70, 55);
    [quanxuanBtn setImage:[UIImage imageNamed:@"gouwuche_icon_nor"] forState:UIControlStateNormal];
    [quanxuanBtn setTitle:@"全选" forState:UIControlStateNormal];
    [quanxuanBtn setTitleColor:HexRGB(0x6c6c6c) forState:UIControlStateNormal];
    quanxuanBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [quanxuanBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    quanxuanBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [quanxuanBtn addTarget:self action:@selector(bottomQuanXuanAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:quanxuanBtn];
    _bottomQuanXuanBtn = quanxuanBtn;
    
    UILabel *hejiLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 10, kScreenWidth - 80 - 104 - 29, 11)];
    hejiLabel.textAlignment = NSTextAlignmentRight;
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"合计：¥%.2f",0.00f]];
    [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(0, attStr.length)];
    [attStr addAttribute:NSForegroundColorAttributeName value:HexRGB(0x6c6c6c) range:NSMakeRange(0, 3)];
    [attStr addAttribute:NSForegroundColorAttributeName value:NavigationColor range:NSMakeRange(3, attStr.length - 3)];
    hejiLabel.attributedText = attStr;
    [view addSubview:hejiLabel];
    _bottomHejiLabel = hejiLabel;
    
    UILabel *yunfeiLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 31, kScreenWidth - 80 - 104 - 29, 11)];
    yunfeiLabel.textAlignment = NSTextAlignmentRight;
    NSMutableAttributedString *attStr1 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"含运费：¥%.2f",0.00f]];
    [attStr1 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(0, attStr1.length)];
    [attStr1 addAttribute:NSForegroundColorAttributeName value:HexRGB(0x6c6c6c) range:NSMakeRange(0, 3)];
    [attStr1 addAttribute:NSForegroundColorAttributeName value:NavigationColor range:NSMakeRange(4, attStr1.length - 4)];
    yunfeiLabel.attributedText = attStr1;
    [view addSubview:yunfeiLabel];
    _bottomYunFeiLabel = yunfeiLabel;
    
    [self.view addSubview:view];
}

#pragma mark - 购物车结算按钮
- (void)bottomJieSuanAction:(UIButton *)sender{
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/store/waitorder.html"];
    NSMutableArray *ids = [NSMutableArray arrayWithCapacity:0];
    for (SYShopcartShangjiaModel *shangjia in self.dataSourceArr) {
        for (SYShopcartShangpinModel *shangpin in shangjia.goods) {
            if ([shangpin.isSelected boolValue]) {
                [ids addObject:shangpin.shangpinid];
            }
        }
    }
    NSString *idsStr = [ids componentsJoinedByString:@","];
    NSDictionary *param = @{@"id":idsStr, @"token":UserToken};
    
    SYShopcartPayOrderViewController *payorder = [[SYShopcartPayOrderViewController alloc] init];
    payorder.allPrice = [_bottomHejiLabel.text substringWithRange:NSMakeRange(3, _bottomHejiLabel.text.length - 3)];
    NSLog(@"self.dataSourceArr - %ld",self.dataSourceArr.count);
    payorder.param = param;
    [self.navigationController pushViewController:payorder animated:YES];
    return;
    
    __weak typeof(self)weakself = self;
    [SVProgressHUD show];
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        [SVProgressHUD dismiss];
        NSLog(@"等待支付的购物车商品 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                NSArray *data = [responseResult objectForKey:@"data"];
                if (data.count > 0) {
                    NSMutableArray *shangjiaArr = [NSMutableArray arrayWithCapacity:0];
                    for (NSDictionary *dic in data) {
                        SYShopcartShangjiaModel *shangjiaModel = [SYShopcartShangjiaModel cartShangJiaWithDictionary:dic];
                        [shangjiaArr addObject:shangjiaModel];
                        
                    }
                    
                }
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];

}

- (void)bottomQuanXuanAction:(UIButton *)sender{
    NSLog(@"1111");
    _bottomSelected = !_bottomSelected;

    if (_bottomSelected) {
        for (SYShopcartShangjiaModel *shangjia in self.dataSourceArr) {
            shangjia.isSelected = @YES;
            for (SYShopcartShangpinModel *shangpin in shangjia.goods) {
                if ([shangpin.state integerValue] == 0) {
                    shangpin.isSelected = @NO;
                }else{
                    shangpin.isSelected = @YES;
                }
                
            }
        }
    }else{
        for (SYShopcartShangjiaModel *shangjia in self.dataSourceArr) {
            shangjia.isSelected = @NO;
            NSArray *goods = shangjia.goods;
            for (SYShopcartShangpinModel *shangpin in goods) {
                shangpin.isSelected = @NO;

            }
        }
        
    }
    
    [self.tableView reloadData];
    [self reloadBottomDataSource];
}

- (void)reloadBottomDataSource{
    [self panduanBottomViewShifouquanxuan];
    float fee = 0.00f;
    float yunfei = 0.00f;
    //遍历所有的商品模型 如果选中就把费用相加
    for (SYShopcartShangjiaModel *shangjia in self.dataSourceArr) {
        float express = [shangjia.express floatValue] / 100;//运费
        float free = [shangjia.free floatValue] / 100;//满多少免运费
        float shangjiaYunfei = 0.00f;//商家运费
        float shangjiaFee = 0.00f;//一个上家的价格
        for (SYShopcartShangpinModel *shangpin in shangjia.goods) {
            if ([shangpin.state integerValue] == 1) {
                //计算为失效的价格
                float shangpinFee = 0.00f;
                float shangpinYunfei = 0.00f;
                if ([shangpin.isSelected boolValue]) {
                    shangpinFee = ([shangpin.money floatValue] / 100) * [shangpin.num integerValue];
                    if (shangpinFee >= free) {
                        shangpinYunfei = 0.00f;
                    }else{
                        shangpinYunfei = express;
                    }
                    NSLog(@"shangjiaYunfei - %f",shangjiaYunfei);
                    NSLog(@"shangpinFee - %f",shangpinFee);
                    
                    //该商家的运费 费用
                    shangjiaFee += shangpinFee;
                    shangjiaYunfei = shangpinYunfei;
                    
                    NSLog(@"shangjiaFee - %f",shangjiaFee);
                    if (shangjiaFee >= free) {
                        shangjiaYunfei = 0.00f;
                    }
                }
            }
        }
        shangjiaFee += shangjiaYunfei;
        fee += shangjiaFee;
        yunfei += shangjiaYunfei;
    }

    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"合计：¥%.2f",fee]];
    [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(0, attStr.length)];
    [attStr addAttribute:NSForegroundColorAttributeName value:HexRGB(0x6c6c6c) range:NSMakeRange(0, 3)];
    [attStr addAttribute:NSForegroundColorAttributeName value:NavigationColor range:NSMakeRange(3, attStr.length - 3)];
    _bottomHejiLabel.attributedText = attStr;
    
    NSMutableAttributedString *attStr1 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"含运费：¥%.2f",yunfei]];
    [attStr1 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(0, attStr1.length)];
    [attStr1 addAttribute:NSForegroundColorAttributeName value:HexRGB(0x6c6c6c) range:NSMakeRange(0, 3)];
    [attStr1 addAttribute:NSForegroundColorAttributeName value:NavigationColor range:NSMakeRange(4, attStr1.length - 4)];
    _bottomYunFeiLabel.attributedText = attStr1;
    //全选按钮状态
    if (_isEdit) {
        if (_editBottomSelected) {
            [_editQuanXuanBtn setImage:[UIImage imageNamed:@"gouwuche_icon_sel"] forState:UIControlStateNormal];
        }else{
            [_editQuanXuanBtn setImage:[UIImage imageNamed:@"gouwuche_icon_nor"] forState:UIControlStateNormal];
        }

    }else{
        if (_bottomSelected) {
            [_bottomQuanXuanBtn setImage:[UIImage imageNamed:@"gouwuche_icon_sel"] forState:UIControlStateNormal];
        }else{
            [_bottomQuanXuanBtn setImage:[UIImage imageNamed:@"gouwuche_icon_nor"] forState:UIControlStateNormal];
        }
    }
    //计算结算的数量
    NSInteger jiesuanCount = 0;
    for (SYShopcartShangjiaModel *shangjia in self.dataSourceArr) {
        NSArray *goods = shangjia.goods;
        for (SYShopcartShangjiaModel *shangpin in goods) {
            if ([shangpin.isSelected boolValue]) {
                jiesuanCount ++;
            }
        }
    }
    if (_isEdit) {
        if (jiesuanCount > 0) {
            _editDeleteBtn.enabled = YES;
        }else{
            _editDeleteBtn.enabled = NO;
        }
        [_editDeleteBtn setTitle:[NSString stringWithFormat:@"删除(%ld)",jiesuanCount] forState:UIControlStateNormal];

    }else{
        if (jiesuanCount > 0) {
            _bottomJieSuanBtn.enabled = YES;
        }else{
            _bottomJieSuanBtn.enabled = NO;
        }
        [_bottomJieSuanBtn setTitle:[NSString stringWithFormat:@"结算(%ld)",jiesuanCount] forState:UIControlStateNormal];

    }
    
}

//判断bottom是否全选
- (void)panduanBottomViewShifouquanxuan{
    NSMutableArray *bools = [NSMutableArray arrayWithCapacity:0];
    for (SYShopcartShangjiaModel *shangjia in self.dataSourceArr) {
        [bools addObject:shangjia.isSelected];
    }
    if ([bools containsObject:@NO]) {
        _bottomSelected = NO;
        _editBottomSelected = NO;
    }else{
        _bottomSelected = YES;
        _editBottomSelected = YES;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    SYShopcartShangjiaModel *shangjia = self.dataSourceArr[section];
    NSArray *goods = shangjia.goods;
    return goods.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell";
    SYShopcartTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"SYShopcartTableViewCell" owner:nil options:nil][0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    SYShopcartShangjiaModel *shangjia = self.dataSourceArr[indexPath.section];
    if (shangjia.goods.count > 0) {
        cell.shangpinModel = shangjia.goods[indexPath.row];
        cell.isEdit = _isEdit;
    }
    __weak typeof(self)weakself = self;
    __weak typeof(indexPath)weakIP = indexPath;
    SYShopcartShangpinModel *shangpin = shangjia.goods[indexPath.row];
        
    cell.deleteBlock = ^(NSInteger tag) {
        DeleteOrderView *delete = [[[NSBundle mainBundle] loadNibNamed:@"DeleteOrderView" owner:self options:nil] lastObject];
        delete.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        delete.tishiLabel.text = @"确定要删除该商品吗？";
        [delete.leftBtn setTitle:@"确定" forState:UIControlStateNormal];
        [delete.rightBtn setTitle:@"取消" forState:UIControlStateNormal];
        __weak typeof(self)weakself = self;
        __weak typeof(delete)weakDelete = delete;
        delete.leftBlock = ^{
            NSLog(@"left");
            [weakDelete dismiss];
            [weakself changeShangPinModelCount:0 withID:shangpin.shangpinid withShangpinModel:shangpin withIndexpath:weakIP];
        };
        delete.rightBlock = ^{
            NSLog(@"right");
            [weakDelete dismiss];
        };
        [delete show];
    };
    cell.addBlock = ^(NSInteger tag) {
        NSInteger count = [shangpin.num integerValue];
        count ++;
        [weakself changeShangPinModelCount:count withID:shangpin.shangpinid withShangpinModel:shangpin withIndexpath:weakIP];
    };
    cell.minutBlock = ^(NSInteger tag) {
        NSInteger count = [shangpin.num integerValue];
        count --;
        if (count == 0) {
            return ;
        }
        [weakself changeShangPinModelCount:count withID:shangpin.shangpinid withShangpinModel:shangpin withIndexpath:weakIP];
    };
    
    return cell;
}

- (void)changeShangPinModelCount:(NSInteger)count withID:(NSNumber *)chopcartID withShangpinModel:(SYShopcartShangpinModel *)shangpin withIndexpath:(NSIndexPath *)indexpath{
    [SVProgressHUD show];
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/store/editcart.html"];
    NSDictionary *param = @{@"token":UserToken, @"id":chopcartID, @"num":[NSNumber numberWithInteger:count]};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        [SVProgressHUD dismiss];
        NSLog(@"获取购物车列表 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                if (count != 0) {
                    shangpin.num = [NSNumber numberWithInteger:count];
                    [self.tableView reloadData];
                    [self reloadBottomDataSource];
                }else{
                    
                    SYShopcartShangjiaModel *shangjia = self.dataSourceArr[indexpath.section];
                    NSMutableArray *arr = [NSMutableArray arrayWithArray:shangjia.goods];
                    [arr removeObject:shangpin];
                    shangjia.goods = arr;
                    if (shangjia.goods.count == 0) {
                        [self.dataSourceArr removeObjectAtIndex:indexpath.section];
                    }
                    if (self.dataSourceArr.count == 0) {
                        [self getData];
                    }else{
                        [self.tableView reloadData];
                    }
                    [self reloadBottomDataSource];
                }
                
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SYShopcartShangjiaModel *shangjia = self.dataSourceArr[indexPath.section];
    SYShopcartShangpinModel *shangpin = shangjia.goods[indexPath.row];
    if ([shangpin.state integerValue] == 0) {
        if (_isEdit) {
            if ([shangpin.isSelected boolValue]) {
                shangpin.isSelected = @NO;
            }else{
                shangpin.isSelected = @YES;
            }
        }else{
            shangpin.isSelected = @NO;
        }
    }else{
        if ([shangpin.isSelected boolValue]) {
            shangpin.isSelected = @NO;
        }else{
            shangpin.isSelected = @YES;
        }
    }
    [self panduanShiFouQuanxuanWith:indexPath];
}

//点击某一行的时候判断是否全部选了或者痘没选
- (void)panduanShiFouQuanxuanWith:(NSIndexPath *)indexPath{
    SYShopcartShangjiaModel *shangjia = self.dataSourceArr[indexPath.section];
    NSArray *goods = shangjia.goods;

    NSMutableArray *bools = [NSMutableArray arrayWithCapacity:0];
    for (SYShopcartShangpinModel *shangpin in goods) {
        if (_isEdit) {
            [bools addObject:shangpin.isSelected];
        }else{
            if ([shangpin.state integerValue] == 0) {
                
            }else{
                [bools addObject:shangpin.isSelected];
            }
        }
        
    }
    if ([bools containsObject:@NO]) {
        shangjia.isSelected = @NO;
    }else{
        shangjia.isSelected = @YES;
    }
    [self reloadBottomDataSource];
    [self.tableView reloadData];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSourceArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 127;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 42;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *selecteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(14, 11, 20, 20)];
    SYShopcartShangjiaModel *model = self.dataSourceArr[section];
    if ([model.isSelected boolValue]) {
        selecteImageView.image = [UIImage imageNamed:@"gouwuche_icon_sel"];
    }else{
        selecteImageView.image = [UIImage imageNamed:@"gouwuche_icon_nor"];
    }
    [view addSubview:selecteImageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(42, 11, kScreenWidth - 80, 20)];
    label.textColor = HexRGB(0x434343);
    label.font = [UIFont systemFontOfSize:17];
    label.text = model.name;
    [view addSubview:label];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 41, kScreenWidth, 1)];
    lineView.backgroundColor = HexRGB(0xeaeaea);
    [view addSubview:lineView];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, kScreenWidth, 41);
    [btn addTarget:self action:@selector(selecteShangJia:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = section;
    [view addSubview:btn];
    
    return view;
}
//选择某个商家的商品
- (void)selecteShangJia:(UIButton *)sender{
    SYShopcartShangjiaModel *model = self.dataSourceArr[sender.tag];
    if ([model.isSelected boolValue]) {
        model.isSelected = @NO;
        for (SYShopcartShangpinModel *shangpinModel in model.goods) {
            shangpinModel.isSelected = @NO;
        }
    }else{
        model.isSelected = @YES;
        for (SYShopcartShangpinModel *shangpinModel in model.goods) {
            if (_isEdit) {
                shangpinModel.isSelected = @YES;
            }else{
                if ([shangpinModel.state integerValue] == 0) {
                    //失效
                    shangpinModel.isSelected = @NO;
                }else{
                    shangpinModel.isSelected = @YES;
                }
            }
            
        }
    }
    [self.tableView reloadData];
    [self reloadBottomDataSource];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 45 + 14;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = RGB(248, 248, 248);
    
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 45)];
    view1.backgroundColor = [UIColor whiteColor];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, kScreenWidth, 1)];
    lineView.backgroundColor = HexRGB(0xeaeaea);
    [view1 addSubview:lineView];
    
    SYShopcartShangjiaModel *shangjia = self.dataSourceArr[section];
    float express = [shangjia.express floatValue] / 100;
    float free = [shangjia.free floatValue] / 100;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(14, 15, kScreenWidth - 30, 15)];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = HexRGB(0x828282);
    label.text = [NSString stringWithFormat:@"本店铺满¥%.0f免运费（¥%.2f）",free,express];
    [view1 addSubview:label];
    
    [view addSubview:view1];
    return view;
}

- (void)getData{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/store/mycart.html"];
    NSDictionary *param = @{@"token":UserToken, @"page":@1};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        if ([self.tableView.mj_header isRefreshing]) {
            [self.tableView.mj_header endRefreshing];
        }
        _count = 1;
        NSLog(@"获取购物车列表 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self.view addSubview:self.noDataView];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                if ([responseResult objectForKey:@"data"]) {
                    NSArray *data = [responseResult objectForKey:@"data"];
                    [self.dataSourceArr removeAllObjects];
                    if (data.count > 0) {
                        _editBottomSelected = NO;
                        for (NSDictionary *dic in data) {
                            NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:dic];
                            [muDic setObject:@NO forKey:@"isSelected"];
                            SYShopcartShangjiaModel *model = [SYShopcartShangjiaModel cartShangJiaWithDictionary:muDic];
                            [self.dataSourceArr addObject:model];
                        }
                        
                        [self.noDataView removeFromSuperview];
                        [self.noThingView removeFromSuperview];
//                        [self.view addSubview:self.tableView];
                        if (_isEdit) {
                            [_editBottomView removeFromSuperview];
                            _editBottomView = nil;
                            [self editBottom];
                        }else{
                            [_bottomView removeFromSuperview];
                            _bottomView = nil;
                            [self initBottomView];
                        }
                    }else{
//                        [_bottomView removeFromSuperview];
//                        [_editBottomView removeFromSuperview];
                        [self.noDataView removeFromSuperview];
//                        [self.tableView removeFromSuperview];
                        [self.view addSubview:self.noThingView];
                    }
                    
                    [self.tableView reloadData];
                }
                
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (void)getMoreData{
    _count ++;
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/store/mycart.html"];
    NSDictionary *param = @{@"token":UserToken, @"page":[NSNumber numberWithInteger:_count]};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        [SVProgressHUD dismiss];
        if ([self.tableView.mj_footer isRefreshing]) {
            [self.tableView.mj_footer endRefreshing];
        }
        NSLog(@"获取购物车列表 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self.view addSubview:self.noDataView];
            _count --;
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                if ([responseResult objectForKey:@"data"]) {
                    NSArray *data = [responseResult objectForKey:@"data"];
                    if (data.count > 0) {
                        for (NSDictionary *dic in data) {
                            NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:dic];
                            [muDic setObject:@NO forKey:@"isSelected"];
                            SYShopcartShangjiaModel *model = [SYShopcartShangjiaModel cartShangJiaWithDictionary:muDic];
                            [self.dataSourceArr addObject:model];
                        }
                        
                        [self.noDataView removeFromSuperview];
                        [self.tableView reloadData];
                    }
                }
                
            }else{
                _count --;
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 55 - kTabbarHeight) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = RGB(248, 248, 248);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self getData];
        }];
        _tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            [self getMoreData];
        }];
    }
    return _tableView;
}

- (NSMutableArray *)dataSourceArr{
    if (!_dataSourceArr) {
        _dataSourceArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSourceArr;
}

- (UIView *)noThingView{
    if (!_noThingView) {
        _noThingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - kTabbarHeight)];
        _noThingView.backgroundColor = [UIColor whiteColor];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, _noThingView.frame.size.height - 164)];
        imageView.image = [UIImage imageNamed:@"cart_nothing"];
        imageView.contentMode = UIViewContentModeCenter;
        [_noThingView addSubview:imageView];
    }
    return _noThingView;
}

- (NoDataView *)noDataView{
    if (!_noDataView) {
        __weak typeof(self)weakself = self;
        _noDataView = [[NSBundle mainBundle] loadNibNamed:@"NoDataView" owner:nil options:nil][0];
        _noDataView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - kTabbarHeight);
        _noDataView.block = ^{
            [weakself getData];
        };
    }
    return _noDataView;
}

@end
