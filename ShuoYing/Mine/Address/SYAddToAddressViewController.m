//
//  SYAddToAddressViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2016/12/28.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import "SYAddToAddressViewController.h"
#import "OSAddressPickerView.h"
#import "SYAddressModel.h"
@interface SYAddToAddressViewController ()<UITextFieldDelegate>
{
    OSAddressPickerView *_pickerview;
    NSURLSessionTask *_dataTask;
    NSString *_name;
    NSString *_phone;
    NSString *_zone;
    NSString *_address;
    AddressType _addressType;
    SYAddressModel *_addressModel;
}

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *zoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;

@property (weak, nonatomic) IBOutlet UIButton *saveBtn;


@end

@implementation SYAddToAddressViewController


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil AddressType:(AddressType)addressType AddressModel:(SYAddressModel *)addressModel{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _addressType = addressType;
        _addressModel = addressModel;
        if (_addressModel) {
            _name = _addressModel.name;
            _phone = _addressModel.tel;
            _zone = _addressModel.zone;
            _address = _addressModel.address;
        }else{
            _name = @"";
            _phone = @"";
            _zone = @"";
            _address = @"";
        }
        
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGB(249, 249, 249);
    
    self.nameTextField.text = _name;
    self.phoneTextField.text = _phone;
    self.zoneTextField.text = _zone;
    self.addressTextField.text = _address;
    
    self.nameTextField.delegate = self;
    self.phoneTextField.delegate = self;
    self.zoneTextField.delegate = self;
    self.addressTextField.delegate = self;
    [self.saveBtn setBackgroundImage:[UIImage imageWithColor:NavigationColor Size:self.saveBtn.frame.size] forState:UIControlStateNormal];
    self.saveBtn.layer.cornerRadius = 5;
    self.saveBtn.layer.masksToBounds = YES;
    [self.saveBtn setAdjustsImageWhenHighlighted:NO];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField.tag == 111) {
        _name = textField.text;
    }else if (textField.tag == 222){
        _phone = textField.text;
    }else if (textField.tag == 333){
        _zone = textField.text;
    }else{
        _address = textField.text;
    }
}

//保存地址 包括修改和新增
- (IBAction)saveAction:(UIButton *)sender {
    
    if ([_name stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0) {
        [self showHint:@"请填写收件人姓名"];
        return;
    }
    if ([_phone stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0) {
        [self showHint:@"请填写手机号"];
        return;
    }
    if (![[Tool sharedInstance] isMobile:_phone]) {
        [self showHint:@"您填写的手机号格式不正确"];
        return;
    }
    if ([_zone stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0) {
        [self showHint:@"请填写收货地址"];
        return;
    }
    if ([_address stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0) {
        [self showHint:@"请填写详细地址"];
        return;
    }
    if (_addressType == AddressTypeIsAdd) {
        NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/address/add.html"];
        NSDictionary *param = @{@"token":UserToken, @"name":_name, @"tel":_phone, @"zone":_zone, @"address":_address};
        _dataTask = [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
            
            NSLog(@"添加收货地址 -- %@",responseResult);
            if ([responseResult objectForKey:@"resError"]) {
                [self showHint:@"服务器不给力，请稍后重试"];
            }else{
                if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                    //把数据保存在本地
                    [self.navigationController popViewControllerAnimated:YES];
                    
                }else{
                    if ([responseResult objectForKey:@"msg"]) {
                        [self showHint:[responseResult objectForKey:@"msg"]];
                    }
                }
            }
        }];

    }else{
        NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/address/edit.html"];
        NSDictionary *param = @{@"token":UserToken, @"name":_name, @"tel":_phone, @"zone":_zone, @"address":_address, @"id":_addressModel.addressId};
        _dataTask = [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
            
            NSLog(@"修改收货地址 -- %@",responseResult);
            if ([responseResult objectForKey:@"resError"]) {
                [self showHint:@"服务器不给力，请稍后重试"];
            }else{
                if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                    [self.navigationController popViewControllerAnimated:YES];
                    
                    
                }else{
                    if ([responseResult objectForKey:@"msg"]) {
                        [self showHint:[responseResult objectForKey:@"msg"]];
                    }
                }
            }
        }];
    }
    
}

- (IBAction)selectAddress:(UIButton *)sender {
    [self.view endEditing:YES];
    
    _pickerview = [OSAddressPickerView shareInstance];
    [_pickerview showBottomView];
    [self.view addSubview:_pickerview];
    [self.view bringSubviewToFront:_pickerview];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    __weak typeof(self)weakself = self;
    _pickerview.block = ^(NSString *province,NSString *city,NSString *district)
    {
        weakself.zoneTextField.text =[NSString stringWithFormat:@"%@ %@ %@",province,city,district];
        _zone = [NSString stringWithFormat:@"%@ %@ %@",province,city,district];
        [defaults setObject:[NSString stringWithFormat:@"%@ %@ %@",province,city,district] forKey:@"address"];
    };
    
}


@end
