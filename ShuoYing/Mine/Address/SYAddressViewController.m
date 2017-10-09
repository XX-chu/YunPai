//
//  SYAddressViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2016/12/26.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import "SYAddressViewController.h"
#import "SYAddressModel.h"
#import "SYAddressTableViewCell.h"
#import "SYAddToAddressViewController.h"

@interface SYAddressViewController ()<UITableViewDelegate,UITableViewDataSource,SYAddressTableViewCellDelegate>
{
    NSURLSessionTask *_dataTask;
}

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSourceArr;

@property (nonatomic, strong) UIButton *addAddressBtn;

@end

@implementation SYAddressViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"收货地址";
    self.view.backgroundColor = BackGroundColor;
    //先从本地读取数据
    [self.view addSubview:self.addAddressBtn];
    [self.view addSubview:self.tableView];
    
    [self getDataFormCache];
    
    
    
}

- (void)getDataFormCache{
    if ([XHNetworkCache cacheJsonWithURL:[NSString stringWithFormat:@"%@%@",Mobile,@"AllAddress"]]) {
        [self.dataSourceArr removeAllObjects];
        NSDictionary *dic = [XHNetworkCache cacheJsonWithURL:[NSString stringWithFormat:@"%@%@",Mobile,@"AllAddress"]];
        NSArray *dataArr = [dic objectForKey:@"data"];
        [self.dataSourceArr addObjectsFromArray:dataArr];
        [self.tableView reloadData];
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSourceArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell";
    SYAddressTableViewCell *cell = [[NSBundle mainBundle] loadNibNamed:@"SYAddressTableViewCell" owner:nil options:nil][0];
   
    if (!cell) {
        cell = [[SYAddressTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        if (cell.contentView.subviews.count > 0) {
            for (UIView *view in cell.contentView.subviews) {
                [view removeFromSuperview];
            }
        }
    }
    
    SYAddressModel *model = [SYAddressModel addressWithDictionary:self.dataSourceArr[indexPath.section]];
    cell.addressModel = model;
    cell.delegate = self;
    cell.tag = indexPath.section;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_delegate && [_delegate respondsToSelector:@selector(selectedAddressWithAddressModel:)]) {
        NSDictionary *dic = self.dataSourceArr[indexPath.section];
        SYAddressModel *model = [SYAddressModel addressWithDictionary:dic];
        [_delegate selectedAddressWithAddressModel:model];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 130;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = BackGroundColor;
    return view;
}

#pragma mark SYAddressCellDelegate
//设置为默认地址
- (void)didSelectedIsDefaultBtn:(UIButton *)sender{
    sender.userInteractionEnabled = NO;
    NSInteger cellTag = sender.superview.superview.tag;
    //删除一个地址
    NSDictionary *dic = self.dataSourceArr[cellTag];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/address/set.html"];
    NSDictionary *param = @{@"token":UserToken,@"id":[dic objectForKey:@"id"]};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        sender.userInteractionEnabled = YES;
        NSLog(@"设为默认地址 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                //把数据保存在本地
                for (int i = 0; i < self.dataSourceArr.count; i++) {
                    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
                    [dic setDictionary:self.dataSourceArr[i]];
                    if (i == cellTag) {
                        [dic setObject:@1 forKey:@"state"];
                    }else{
                        [dic setObject:@0 forKey:@"state"];
                    }
                    [self.dataSourceArr replaceObjectAtIndex:i withObject:dic];
                }
                [self.tableView reloadData];
                
                //如果有数据 遍历转模型并把默认地址缓存在本地
                if (self.dataSourceArr.count > 0) {
                    for (NSDictionary *dic in self.dataSourceArr) {
                        if ([[dic objectForKey:@"state"] integerValue] == 1) {
                            SYAddressModel *model = [SYAddressModel addressWithDictionary:dic];
                            [[Tool sharedInstance] saveObject:model WithPath:[NSString stringWithFormat:@"%@defaultAddress",Mobile]];
                        }
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

//编辑或删除
- (void)didSelectedEditOrDeleteBtn:(UIButton *)sender{
    NSInteger cellTag = sender.superview.superview.tag;
    if ([sender.titleLabel.text isEqualToString:@"编辑"]) {
        SYAddressModel *model = [SYAddressModel addressWithDictionary:self.dataSourceArr[cellTag]];
        SYAddToAddressViewController *addAddressVC = [[SYAddToAddressViewController alloc] initWithNibName:@"SYAddToAddressViewController" bundle:nil AddressType:AddressTypeIsEdit AddressModel:model];
        addAddressVC.title = @"编辑收货地址";
        [self.navigationController pushViewController:addAddressVC animated:YES];
    }else{

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"删除地址" message:@"确定要删除该收货地址吗？" preferredStyle:UIAlertControllerStyleAlert];
        NSAttributedString *att = [[NSAttributedString alloc] initWithString:@"确定要删除该收货地址吗？" attributes:@{NSForegroundColorAttributeName : HexRGB(0xff5577), NSFontAttributeName : [UIFont systemFontOfSize:15]}];
        [alert setValue:att forKey:@"attributedMessage"];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //删除一个地址
            SYAddressModel *model = [SYAddressModel addressWithDictionary:self.dataSourceArr[cellTag]];
            NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/address/del.html"];
            NSDictionary *param = @{@"token":UserToken,@"id":model.addressId};
            _dataTask = [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
                
                NSLog(@"删除收货地址 -- %@",responseResult);
                if ([responseResult objectForKey:@"resError"]) {
                    [self showHint:@"服务器不给力，请稍后重试"];
                }else{
                    if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                        //把数据保存在本地
                        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
                        [dic addEntriesFromDictionary:[XHNetworkCache cacheJsonWithURL:[NSString stringWithFormat:@"%@%@",Mobile,@"AllAddress"]]];
                        NSArray *arr = dic[@"data"];
                        NSMutableArray *muarr = [NSMutableArray arrayWithCapacity:0];
                        for (NSDictionary *address in arr) {
                            if ([model.addressId integerValue] == [[address objectForKey:@"id"] integerValue]) {
                                break;
                            }
                            [muarr addObject:address];
                        }
                        [dic setObject:muarr forKey:@"data"];
                        [XHNetworkCache save_asyncJsonResponseToCacheFile:dic andURL:[NSString stringWithFormat:@"%@%@",Mobile,@"AllAddress"] completed:nil];
                        
                        [self.dataSourceArr removeObjectAtIndex:cellTag];
                        
                        [self.tableView reloadData];
                        
                    }else{
                        if ([responseResult objectForKey:@"msg"]) {
                            [self showHint:[responseResult objectForKey:@"msg"]];
                        }
                    }
                }
            }];
        }];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [action setValue:[UIColor blackColor] forKey:@"titleTextColor"];
        [action1 setValue:[UIColor blackColor] forKey:@"titleTextColor"];
        
        [alert addAction:action];
        [alert addAction:action1];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
}

#pragma mark - privateMethod

- (void)addAddress{
    SYAddToAddressViewController *addAddressVC = [[SYAddToAddressViewController alloc] initWithNibName:@"SYAddToAddressViewController" bundle:nil AddressType:AddressTypeIsAdd AddressModel:nil];
    addAddressVC.title = @"新增收货地址";
    [self.navigationController pushViewController:addAddressVC animated:YES];
}


#pragma mark - NetworkRequest
- (void)getData{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/address/all.html"];
    NSDictionary *param = @{@"token":UserToken};
    _dataTask = [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        NSLog(@"获取所有收货地址 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                //把数据保存在本地
                [self.dataSourceArr removeAllObjects];
                [XHNetworkCache save_asyncJsonResponseToCacheFile:responseResult andURL:[NSString stringWithFormat:@"%@%@",Mobile,@"AllAddress"] completed:nil];
                NSArray *dataArr = [responseResult objectForKey:@"data"];
                
                [self.dataSourceArr addObjectsFromArray:dataArr];
                
                [self.tableView reloadData];
                
                //如果有数据 遍历转模型并把默认地址缓存在本地
                if (dataArr.count > 0) {
                    for (NSDictionary *dic in dataArr) {
                        if ([[dic objectForKey:@"state"] integerValue] == 1) {
                            SYAddressModel *model = [SYAddressModel addressWithDictionary:dic];
                            [[Tool sharedInstance] saveObject:model WithPath:[NSString stringWithFormat:@"%@defaultAddress",Mobile]];
                        }
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

#pragma mark - layzLoad
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64 - 40) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.backgroundColor = BackGroundColor;
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

- (UIButton *)addAddressBtn{
    if (!_addAddressBtn) {
        _addAddressBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, kScreenHeight - 64 - 40, kScreenWidth, 40)];
        [_addAddressBtn setBackgroundImage:[UIImage imageWithColor:NavigationColor Size:_addAddressBtn.frame.size] forState:UIControlStateNormal];
        _addAddressBtn.adjustsImageWhenHighlighted = NO;
        [_addAddressBtn setTitle:@"新增收货地址" forState:UIControlStateNormal];
        [_addAddressBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _addAddressBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_addAddressBtn addTarget:self action:@selector(addAddress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addAddressBtn;
}

@end
