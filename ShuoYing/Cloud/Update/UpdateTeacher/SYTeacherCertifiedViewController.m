//
//  SYTeacherCertifiedViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/1/6.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYTeacherCertifiedViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

#import "SYUserInfos.h"

@interface SYTeacherCertifiedViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate>
{
    UIImage *_image;
    SYUserInfos *_userInfos;
}
@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet UIView *view0;


@property (weak, nonatomic) IBOutlet UIView *addImageBtn;
@property (weak, nonatomic) IBOutlet UIImageView *selectedIDImageView;

@property (weak, nonatomic) IBOutlet UIButton *updateBtn;
@property (weak, nonatomic) IBOutlet UITextField *schoolNameTF;
@property (weak, nonatomic) IBOutlet UITextField *quhaoTF;
@property (weak, nonatomic) IBOutlet UITextField *schoolPhoneTF;

@property (nonatomic, strong) NSMutableArray *selectedPhotosArr;

@property (nonatomic, strong) NSMutableArray *selectedPhotoDatasArr;

@property (nonatomic, strong) NSMutableArray *selectedPhotoModelsArr;

@property (nonatomic, strong) UIButton *deleteBtn;

@end

@implementation SYTeacherCertifiedViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.view = (UIScrollView *)self.view;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"身份认证";
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectedPhoto:)];
    self.selectedIDImageView.userInteractionEnabled = YES;
    [self.selectedIDImageView addGestureRecognizer:tap];
    
    
    [self.updateBtn setTitle:@"上传" forState:UIControlStateNormal];
    [self.updateBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.updateBtn setBackgroundImage:[UIImage imageWithColor:NavigationColor Size:self.updateBtn.frame.size] forState:UIControlStateNormal];
    self.updateBtn.layer.cornerRadius = 5;
    self.updateBtn.layer.masksToBounds = YES;
    [self.updateBtn setAdjustsImageWhenHighlighted:NO];
    
    self.view1.layer.cornerRadius = 5;
    self.view1.layer.borderColor = RGB(234, 234, 234).CGColor;
    self.view1.layer.borderWidth = 1;
    self.view1.layer.masksToBounds = YES;
    
    self.view2.layer.cornerRadius = 5;
    self.view2.layer.borderColor = RGB(234, 234, 234).CGColor;
    self.view2.layer.borderWidth = 1;
    self.view2.layer.masksToBounds = YES;
    
    self.schoolNameTF.delegate = self;
    
    _userInfos = [[Tool sharedInstance] getObjectWithPath:Mobile];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == self.schoolNameTF) {
        if (range.length == 1 && string.length == 0){
            return YES;
        }else if (self.schoolNameTF.text.length >= 15){
            self.schoolNameTF.text = [textField.text substringToIndex:15];
            return NO;
        }
    }
    return YES;
}

- (void)selectedPhoto:(UITapGestureRecognizer *)tap{
    ZLPhotoActionSheet *actionSheet = [[ZLPhotoActionSheet alloc] init];
    //设置照片最大选择数
    actionSheet.maxSelectCount = 1;
    //设置照片最大预览数
    actionSheet.maxPreviewCount = 8;
    //导航栏是否透明
    actionSheet.isTouMing = NO;
    weakify(self);
    [actionSheet showPreviewPhotoWithSender:self animate:YES lastSelectPhotoModels:nil completion:^(NSArray<UIImage *> * _Nonnull selectPhotos, NSArray<ZLSelectPhotoModel *> * _Nonnull selectPhotoModels, NSArray<NSData *> *imageDatas) {
        strongify(weakSelf);
        if (selectPhotos.count > 0) {
            _image = selectPhotos[0];
        }
        
        self.selectedIDImageView.image = _image;
        [self.selectedIDImageView addSubview:self.deleteBtn];
        
        [strongSelf.selectedPhotosArr removeAllObjects];
        [strongSelf.selectedPhotoModelsArr removeAllObjects];
        [strongSelf.selectedPhotoDatasArr removeAllObjects];
        
        [strongSelf.selectedPhotosArr addObjectsFromArray:selectPhotos];
        [strongSelf.selectedPhotoModelsArr addObjectsFromArray:selectPhotoModels];
        [strongSelf.selectedPhotoDatasArr addObjectsFromArray:imageDatas];
        
    }];

}

- (void)deleteAction:(UIButton *)sender{
    self.selectedIDImageView.image = [UIImage imageNamed:@"shenfenzheng"];
    _image = nil;
    [self.deleteBtn removeFromSuperview];
}

- (IBAction)updatePhotoAction:(UIButton *)sender {
    if (!_image || _image == nil) {
        [self showHint:@"请上传您的身份证信息"];
        return;
    }
    if (self.schoolNameTF.text.length < 5 || self.schoolNameTF.text.length > 15) {
        [self showHint:@"学校名称5-15个字"];
        return;
    }
    if (self.quhaoTF.text.length == 0) {
        [self showHint:@"请填写学校电话区号"];
        return;
    }
    if (self.schoolPhoneTF.text.length == 0) {
        [self showHint:@"请填写您学校的办公电话"];
        return;
    }
    
    //把图片转换成base64
    
    NSMutableArray *muDatas = [NSMutableArray arrayWithCapacity:0];
    [muDatas addObjectsFromArray:self.selectedPhotoDatasArr];
    //一个一个上传 每次取第一个图片上传 成功后删除第一章图片
    NSData *data = muDatas[0];
    //判断图片类型
    NSString *mimaType = [[Tool sharedInstance] typeForImageData:data];
    NSInteger currentNum = self.selectedPhotosArr.count - muDatas.count + 1;
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/user/teacherX.html"];
    NSDictionary *param = @{@"token":UserToken, @"school":self.schoolNameTF.text, @"zone":self.quhaoTF.text, @"tel":self.schoolPhoneTF.text};
    
    
    [[XBUpdatePhotoManager sharedInstance] updatePhotosWithFile:url param:param fileData:data name:@"photo" fileName:[NSString stringWithFormat:@"photo%lu.%@",currentNum, [mimaType substringWithRange:NSMakeRange(6, mimaType.length - 6)]] mimeType:mimaType currentNumber:currentNum allNumber:self.selectedPhotosArr.count result:^(NSDictionary *dic) {
        NSLog(@"dic - %@",dic);
        
        if ([dic objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
            
        }else{
            if ([[dic objectForKey:@"result"] integerValue] == 1) {
                //修改存储在本地的信息
                _userInfos.teacher = @3;
                [[Tool sharedInstance] saveObject:_userInfos WithPath:Mobile ];
                if ([dic objectForKey:@"msg"]) {
                    [self showHint:[dic objectForKey:@"msg"]];
                }
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                
                if ([dic objectForKey:@"msg"]) {
                    [self showHint:[dic objectForKey:@"msg"]];
                }
            }
        }
        
    }];
}

- (NSMutableArray *)selectedPhotosArr{
    if (!_selectedPhotosArr) {
        _selectedPhotosArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _selectedPhotosArr;
}

- (NSMutableArray *)selectedPhotoModelsArr{
    if (!_selectedPhotoModelsArr) {
        _selectedPhotoModelsArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _selectedPhotoModelsArr;
}

- (NSMutableArray *)selectedPhotoDatasArr{
    if (!_selectedPhotoDatasArr) {
        _selectedPhotoDatasArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _selectedPhotoDatasArr;
}

- (UIButton *)deleteBtn{
    if (!_deleteBtn) {
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteBtn.frame = CGRectMake(self.selectedIDImageView.frame.size.width - 20, 0, 20, 20);
        [_deleteBtn setImage:[UIImage imageNamed:@"chuansong_shanchu"] forState:UIControlStateNormal];
        
        [_deleteBtn addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteBtn;
}

@end
