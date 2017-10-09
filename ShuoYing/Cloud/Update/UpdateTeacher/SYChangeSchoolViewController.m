//
//  SYChangeSchoolViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/3/4.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYChangeSchoolViewController.h"

@interface SYChangeSchoolViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *schoolTF;
@property (weak, nonatomic) IBOutlet UITextField *quhaoTF;
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;

@end

@implementation SYChangeSchoolViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"更改学校";
    [self getSchoolData];
    [self.schoolTF becomeFirstResponder];
    self.schoolTF.delegate = self;
    [self setRightBar];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == self.schoolTF) {
        if (range.length == 1 && string.length == 0){
            return YES;
        }else if (self.schoolTF.text.length >= 15){
            self.schoolTF.text = [textField.text substringToIndex:15];
            return NO;
        }
    }
    return YES;
}

- (void)setRightBar{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [btn setTitle:@"提交" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 15, 0, -15)];
    [btn addTarget:self action:@selector(editNickAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *bar = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    self.navigationItem.rightBarButtonItem = bar;
}

- (void)editNickAction:(UIButton *)sender{
    [self.view endEditing:YES];
    if (self.schoolTF.text.length < 5 || self.schoolTF.text.length > 15) {
        [self showHint:@"学校名字5-15个字"];
        return;
    }
    if (self.quhaoTF.text.length == 0) {
        [self showHint:@"请输入您的区号"];
        return;
    }
    if (self.phoneTF.text.length == 0) {
        [self showHint:@"请输入您的电话"];
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/upschool.html"];
    NSDictionary *param = @{@"token":UserToken, @"school":self.schoolTF.text, @"zone":self.quhaoTF.text, @"tel":self.phoneTF.text};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        
        NSLog(@"更改学校信息 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                
                [self showHint:[responseResult objectForKey:@"msg"]];
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (void)getSchoolData{

    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/school.html"];
    NSDictionary *param = @{@"token":UserToken};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        
        NSLog(@"获取学校信息 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                NSDictionary *dic = [responseResult objectForKey:@"data"];
                if ([dic objectForKey:@"school"] && ![[dic objectForKey:@"school"] isKindOfClass:[NSNull class]]) {
                    self.schoolTF.text = [dic objectForKey:@"school"];
                }
                if ([dic objectForKey:@"tel"] && ![[dic objectForKey:@"tel"] isKindOfClass:[NSNull class]]) {
                    self.phoneTF.text = [dic objectForKey:@"tel"];
                }
                if ([dic objectForKey:@"zone"] && ![[dic objectForKey:@"zone"] isKindOfClass:[NSNull class]]) {
                    self.quhaoTF.text = [dic objectForKey:@"zone"];
                }
                
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}
 
     
@end
