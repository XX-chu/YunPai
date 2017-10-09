//
//  SYGuiGeView.m
//  ShuoYing
//
//  Created by 硕影 on 2017/4/27.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYGuiGeView.h"
#import "CollectionHeadView.h"
#import "CollectionFootView.h"
#import "CollectionLineView.h"
#import "TagCell.h"
#import "SYOneModel.h"
#import "SYTwoModel.h"
#import "SYThreeModel.h"

#define GuigeMargin 10

@interface SYGuiGeView ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

{
    SYOneModel *_selectedOneModel;
    SYTwoModel *_selectedTwoModel;
    SYThreeModel *_selectedThreeModel;
    
    NSInteger _selectedCount;
    UILabel *_countLabel;
    
    NSArray *_dataSourceArr;
    NSDictionary *_dataSourceDic;
}

@property (nonatomic, strong) UIView *backView;

@property (nonatomic, strong) UIButton *actionBtn;

@property (nonatomic, strong) NSMutableArray *oneAllModel;

@property (nonatomic, strong) NSMutableArray *twoAllModel;

@property (nonatomic, strong) NSMutableArray *threeAllModel;

@end

@implementation SYGuiGeView

- (void)show{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6];
    [window addSubview:self];
    
    [UIView animateWithDuration:.5 animations:^{
        NSDictionary *data = [_dataSourceDic objectForKey:@"data"];
        NSArray *spces = [data objectForKey:@"spces"];
        if (spces.count > 0) {
            self.backView.frame = CGRectMake(0, self.frame.size.height - 500, kScreenWidth, 500);
        }else{
            self.backView.frame = CGRectMake(0, self.frame.size.height - 200, kScreenWidth, 200);
        }
        
    }];
}

- (void)dismiss{

    [UIView animateWithDuration:.5 animations:^{
        NSDictionary *data = [_dataSourceDic objectForKey:@"data"];
        NSArray *spces = [data objectForKey:@"spces"];
        if (spces.count > 0) {
            self.backView.frame = CGRectMake(0, self.frame.size.height, kScreenWidth, 500);
        }else{
            self.backView.frame = CGRectMake(0, self.frame.size.height, kScreenWidth, 200);
        }

    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        
    }];
    
}

- (void)setImgUrl:(NSString *)imgUrl{
    _imgUrl = imgUrl;
    [self.guigeUpView.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,_imgUrl]] placeholderImage:NoPicture];
}

- (void)setMoney:(NSString *)money{
    _money = money;
    self.guigeUpView.priceLabel.text = [NSString stringWithFormat:@"¥%@",_money];
}


- (instancetype)initWithFrame:(CGRect)frame WithDataSourceArr:(NSArray *)dataSourceArr WithDataSourceDic:(NSDictionary *)dataSourceDic WithOneModel:(SYOneModel *)oneModel WithTwoModel:(SYTwoModel *)twoModel WithThreeModel:(SYThreeModel *)threeModel WithSelecteCount:(NSInteger)selecteCount{
    if (self = [super initWithFrame:frame]) {
        _dataSourceArr = dataSourceArr;
        _dataSourceDic = dataSourceDic;
        _selectedOneModel = oneModel;
        _selectedTwoModel = twoModel;
        _selectedThreeModel = threeModel;
        _selectedCount = selecteCount;
        [self initDataSource];
        [self initUI];
    }
    return self;
}

- (void)initDataSource{
    for (SYOneModel *one in _dataSourceArr) {
        [self.oneAllModel addObject:one];
        if ([one.isSelecte boolValue]) {
            _selectedOneModel = one;
        }
    }
    
    for (SYOneModel *one in _dataSourceArr) {
        for (SYTwoModel *two in one.spces) {
            [self.twoAllModel addObject:two];
            if ([two.isSelecte boolValue]) {
                _selectedTwoModel = two;
            }
        }
        
    }
    
    for (SYOneModel *one in _dataSourceArr) {
        for (SYTwoModel *two in one.spces) {
            for (SYThreeModel *three in two.spces) {
                [self.threeAllModel addObject:three];
                if ([three.isSelecte boolValue]) {
                    _selectedThreeModel = three;
                }
            }
        }
    }


    NSArray *attr = [_dataSourceDic objectForKey:@"attr"];
    if (attr.count > 0) {
        NSMutableString *muStr = [NSMutableString stringWithCapacity:0];
        for (NSString *str in attr) {
            muStr = [muStr stringByAppendingString:str];
        }
        self.guigeUpView.yixuanLabel.text = muStr;
    }
    
    
}

- (void)initUI{
    NSDictionary *data = [_dataSourceDic objectForKey:@"data"];
    NSArray *spces = [data objectForKey:@"spces"];
    [self initBackView];
    [self initActionBtn];
    [self initUpView];
    
    if (spces.count > 0) {
        [self initCollectionView];
    }else{
        [self initCountView];
    }
}

- (void)initBackView{
    NSDictionary *data = [_dataSourceDic objectForKey:@"data"];
    NSArray *spces = [data objectForKey:@"spces"];
    if (spces.count > 0) {
        self.backView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, 500)];
    }else{
        self.backView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, 200)];
    }
    self.backView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.backView];
}

- (void)initUpView{
    self.guigeUpView = [[NSBundle mainBundle] loadNibNamed:@"SYGuiGeUpView" owner:self options:nil][0];
    self.guigeUpView.frame = CGRectMake(0, 0, self.frame.size.width, 87);
    [self.guigeUpView.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,_imgUrl]] placeholderImage:NoPicture];
    if (_selectedOneModel == nil) {
        NSDictionary *data = [_dataSourceDic objectForKey:@"data"];
        NSArray *spces = [data objectForKey:@"spces"];
        if (spces.count > 0) {
            self.guigeUpView.kucunLabel.text = [NSString stringWithFormat:@"库存:0"];
        }else{
            self.guigeUpView.kucunLabel.text = [NSString stringWithFormat:@"库存:%@",[[data objectForKey:@"num"] stringValue]];
        }
        self.guigeUpView.yixuanLabel.text = @"已选：";
    }else{
        NSDictionary *data = [_dataSourceDic objectForKey:@"data"];
        NSArray *spces = [data objectForKey:@"spces"];
        if (spces.count > 0) {
            if (_selectedThreeModel) {
                self.guigeUpView.kucunLabel.text = [NSString stringWithFormat:@"库存:%@",[_selectedThreeModel.num stringValue]];
            }else{
                if (_selectedTwoModel) {
                    self.guigeUpView.kucunLabel.text = [NSString stringWithFormat:@"库存:%@",[_selectedTwoModel.num stringValue]];;
                }else{
                    self.guigeUpView.kucunLabel.text = [NSString stringWithFormat:@"库存:%@",[_selectedOneModel.num stringValue]];
                }
            }
        }else{
            self.guigeUpView.kucunLabel.text = [NSString stringWithFormat:@"库存:%@",[[data objectForKey:@"num"] stringValue]];
        }
        
        NSMutableArray *yixuanMuarr = [NSMutableArray arrayWithCapacity:0];
        if (_selectedOneModel) {
            [yixuanMuarr addObject:_selectedOneModel.spceName];
        }
        if (_selectedTwoModel) {
            [yixuanMuarr addObject:_selectedTwoModel.spceName];
        }
        if (_selectedThreeModel) {
            [yixuanMuarr addObject:_selectedThreeModel.spceName];
        }
        
        NSString *yixuanStr = [yixuanMuarr componentsJoinedByString:@" "];
        self.guigeUpView.yixuanLabel.text = [NSString stringWithFormat:@"已选：%@",yixuanStr];
    }
    [self.backView addSubview:self.guigeUpView];
    __weak typeof(self)weakself = self;
    self.guigeUpView.block = ^{
        [weakself dismiss];
    };
}

- (void)initActionBtn{
    self.actionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.actionBtn.frame = CGRectMake(0, self.backView.frame.size.height - 52, self.frame.size.width, 52);
    [self.actionBtn setTitle:@"确定" forState:UIControlStateNormal];
    [self.actionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.actionBtn setBackgroundImage:[UIImage imageWithColor:RGB(204, 204, 204) Size:self.actionBtn.frame.size] forState:UIControlStateDisabled];
    [self.actionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    [self.actionBtn setAdjustsImageWhenHighlighted:NO];
    [self.actionBtn setBackgroundImage:[UIImage imageWithColor:NavigationColor Size:self.actionBtn.frame.size] forState:UIControlStateNormal];
    [self.actionBtn addTarget:self action:@selector(jiarugouwucheAction:) forControlEvents:UIControlEventTouchUpInside];
    self.actionBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    
    self.actionBtn.enabled = [self puanduanQingDingShifouKexuan];
    
    [self.backView addSubview:self.actionBtn];
}
//没有规格的时候加载选择数量的view
- (void)initCountView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.guigeUpView.frame), kScreenWidth, 60)];
    UIButton *jia = [UIButton buttonWithType:UIButtonTypeCustom];
    jia.frame = CGRectMake(kScreenWidth - 46 - 14, 10, 46, 40);
    [jia setImage:[UIImage imageNamed:@"standard_quantity_add"] forState:UIControlStateNormal];
    [jia setAdjustsImageWhenHighlighted:NO];
    [jia addTarget:self action:@selector(jiaAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:jia];
    
    UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 46 - 14 - 58, 10, 58, 40)];
    countLabel.textColor = RGB(43, 43, 43);
    countLabel.font = [UIFont systemFontOfSize:17];
    countLabel.textAlignment = NSTextAlignmentCenter;
    countLabel.text = @"1";
    _selectedCount = 1;
    _countLabel = countLabel;
    [view addSubview:countLabel];
    
    UIButton *jian = [UIButton buttonWithType:UIButtonTypeCustom];
    [jian setAdjustsImageWhenHighlighted:NO];
    jian.frame = CGRectMake(kScreenWidth - 46 - 14 - 58 - 46, 10, 46, 40);
    [jian setImage:[UIImage imageNamed:@"standard_quantity_-minus"] forState:UIControlStateNormal];
    [jian addTarget:self action:@selector(jianAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:jian];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(14, 10, 100, 40)];
    label.text = @"购买数量";
    label.textColor = RGB(43, 43, 43);
    label.font = [UIFont systemFontOfSize:16];
    [view addSubview:label];
    
    [self.backView addSubview:view];
}

- (void)jiaAction:(UIButton *)sender{
    
    NSDictionary *data = [_dataSourceDic objectForKey:@"data"];
    NSInteger num = 1;
    if ([data objectForKey:@"num"]) {
        num = [[data objectForKey:@"num"] integerValue];
    }
    if (_selectedCount == num) {
        return;
    }
    _selectedCount ++;
    _countLabel.text = [NSString stringWithFormat:@"%ld",_selectedCount];
}

- (void)jianAction:(UIButton *)sender{
    
    if (_selectedCount == 1) {
        return;
    }
    _selectedCount --;
    _countLabel.text = [NSString stringWithFormat:@"%ld",_selectedCount];
}

//判断确定按钮是否可选
- (BOOL)puanduanQingDingShifouKexuan{
    if ([_dataSourceDic objectForKey:@"attr"]) {
        NSArray *attr = [_dataSourceDic objectForKey:@"attr"];
        if (attr.count ==  1) {
            if (_selectedOneModel) {
                return YES;
            }
        }else if (attr.count == 2){
            if (_selectedOneModel && _selectedTwoModel) {
                return YES;
            }
        }else if (attr.count == 3){
            if (_selectedOneModel && _selectedTwoModel && _selectedThreeModel) {
                return YES;
            }
        }else{
            if ([_dataSourceDic objectForKey:@"data"]) {
                NSDictionary *data = [_dataSourceDic objectForKey:@"data"];
                if ([data objectForKey:@"num"]) {
                    NSInteger num = [[data objectForKey:@"num"] integerValue];
                    if (num > 0) {
                        return YES;
                    }
                }
            }
        }
    }
    return NO;
}

- (void)jiarugouwucheAction:(UIButton *)sender{
    NSLog(@"加入购物车");
    NSDictionary *data = [_dataSourceDic objectForKey:@"data"];
    NSArray *spces = nil;
    if ([data objectForKey:@"spces"]) {
        spces = [data objectForKey:@"spces"];
    }
    if (spces.count > 0) {
        if (self.shopcartBlock) {
            self.shopcartBlock(_selectedOneModel, _selectedTwoModel, _selectedThreeModel, _selectedCount);
        }
    }else{
        self.shopcartBlock(nil, nil, nil, _selectedCount);
    }
    
    
}

- (void)initCollectionView{
    UICollectionViewFlowLayout *flowLayout= [[UICollectionViewFlowLayout alloc]init];
    //修改
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.headerReferenceSize = CGSizeMake(kScreenWidth, 38);
    flowLayout.minimumInteritemSpacing = 17;
    flowLayout.minimumLineSpacing = 17;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 14, 10, 14);
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 87, self.frame.size.width, 500 - 87 - 52) collectionViewLayout:flowLayout];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerNib:[UINib nibWithNibName:@"TagCell" bundle:nil] forCellWithReuseIdentifier:@"TagCell"];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"CollectionHeadView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CollectionHeadView"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"CollectionFootView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"CollectionFootView"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"CollectionLineView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"CollectionLineView"];
    [self.backView addSubview:self.collectionView];
    
}

#pragma mark -- CollectionView delegate & dataSource

//重写--> header
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    CGSize headsize;
    headsize = CGSizeMake(self.frame.size.width, 40);
    return headsize;
}

//footer
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    NSArray *attr = [_dataSourceDic objectForKey:@"attr"];
    if (attr.count > 0) {
        if (section == attr.count - 1) {
            CGSize headsize;
            headsize = CGSizeMake(self.frame.size.width, 60);
            return headsize;
        }else{
            return CGSizeMake(self.frame.size.width, 1);
        }
    }
    return CGSizeZero;
}


//重写--> header+footer
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        //头
        CollectionHeadView *headView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"CollectionHeadView" forIndexPath:indexPath];
        
        if (!headView) {
            headView = [[CollectionHeadView alloc]init];
        }
        NSArray *attr = [_dataSourceDic objectForKey:@"attr"];
        if (attr.count > 0) {
            headView.titleLabel.text = attr[indexPath.section];
        }
        return headView;
    }
    
    if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        NSArray *attr = [_dataSourceDic objectForKey:@"attr"];
        if (attr.count > 0) {
            if (indexPath.section == attr.count - 1) {
                //头
                CollectionFootView *headView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"CollectionFootView" forIndexPath:indexPath];
                
                if (!headView) {
                    headView = [[CollectionFootView alloc]init];
                }
                if (_selectedCount) {
                    headView.countLabel.text = [NSString stringWithFormat:@"%ld",_selectedCount];
                }else{
                    headView.countLabel.text = @"1";
                }
                
                //计算库存量
                NSInteger kucun = 1;
                if (_selectedOneModel.num && _selectedOneModel.num != nil && ![_selectedOneModel.num isKindOfClass:[NSNull class]]) {
                    kucun = [_selectedOneModel.num integerValue];
                }else if (_selectedTwoModel.num && _selectedTwoModel.num != nil && ![_selectedTwoModel.num isKindOfClass:[NSNull class]]){
                    kucun = [_selectedTwoModel.num integerValue];
                }else{
                    kucun = [_selectedThreeModel.num integerValue];
                }
                if (kucun && kucun != 0) {
                    if ([headView.countLabel.text integerValue] > kucun) {
                        headView.countLabel.text = [NSString stringWithFormat:@"%ld",kucun];
                    }
                }
                
                __weak typeof(headView)weakHeadView = headView;
                headView.addBlock = ^(NSInteger count){
                    NSLog(@"count - %ld",count);
                    if (kucun && kucun != 0) {
                        if (count < kucun) {
                            count ++;
                            weakHeadView.countLabel.text = [NSString stringWithFormat:@"%ld",count];
                        }
                    }else{
                        count ++;
                        weakHeadView.countLabel.text = [NSString stringWithFormat:@"%ld",count];
                    }
                    _selectedCount = count;
                };
                headView.minutBlock = ^(NSInteger count){
                    if (count > 1) {
                        count --;
                        weakHeadView.countLabel.text = [NSString stringWithFormat:@"%ld",count];
                    }
                    _selectedCount = count;
                };
                
                return headView;
            }else{
                CollectionLineView *headView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"CollectionLineView" forIndexPath:indexPath];
                if (!headView) {
                    headView = [[CollectionLineView alloc]init];
                }
                return headView;
            }
        }
    }
    return nil;
}


//cell的大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        SYOneModel *model = _dataSourceArr[indexPath.item];
        return CGSizeMake([model.width floatValue] + 20, 40);
        
    }else if (indexPath.section == 1 && _selectedOneModel == nil){
        
        NSMutableArray *strArr = [NSMutableArray arrayWithCapacity:0];
        for (SYTwoModel *two in self.twoAllModel) {
            [strArr addObject:two.spceName];
        }
        NSMutableArray *resuleArr = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray *twoModels = [NSMutableArray arrayWithCapacity:0];
        for (int i = 0; i < strArr.count; i++) {
            if (![resuleArr containsObject:strArr[i]]) {
                [resuleArr addObject:strArr[i]];
                [twoModels addObject:self.twoAllModel[i]];
            }
        }
        
        SYTwoModel *two = twoModels[indexPath.item];
        
        return CGSizeMake([two.width floatValue] + 20, 40);

    }else if (indexPath.section == 1 && _selectedOneModel != nil){
        NSMutableArray *muArr = [NSMutableArray arrayWithCapacity:0];
        for (SYOneModel *one in self.oneAllModel) {
            if ([one.isSelecte boolValue]) {
                [muArr addObjectsFromArray:one.spces];
            }
        }
        SYTwoModel *two = muArr[indexPath.item];
        return CGSizeMake([two.width floatValue] + 20, 40);
    }else if (indexPath.section == 2 && _selectedTwoModel == nil){
        NSMutableArray *strArr = [NSMutableArray arrayWithCapacity:0];
        for (SYThreeModel *three in self.threeAllModel) {
            [strArr addObject:three.spceName];
        }
        NSMutableArray *resuleArr = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray *threeModels = [NSMutableArray arrayWithCapacity:0];
        for (int i = 0; i < strArr.count; i++) {
            if (![resuleArr containsObject:strArr[i]]) {
                [resuleArr addObject:strArr[i]];
                [threeModels addObject:self.threeAllModel[i]];
            }
        }
        
        SYThreeModel *three = threeModels[indexPath.item];
        
        return CGSizeMake([three.width floatValue] + 20, 40);
        
    }else if (indexPath.section == 2 && _selectedTwoModel != nil){
        NSMutableArray *muArr = [NSMutableArray arrayWithCapacity:0];
        for (SYTwoModel *two in self.twoAllModel) {
            if ([two.isSelecte boolValue]) {
                [muArr addObjectsFromArray:two.spces];
            }
        }

        SYThreeModel *three = muArr[indexPath.item];
        return CGSizeMake([three.width floatValue] + 20, 40);
    }
    return CGSizeMake(0, 0);
}

//组
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSArray *attr = [_dataSourceDic objectForKey:@"attr"];
    
    return attr.count;
}

//列
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (section == 0) {
        return self.oneAllModel.count;
    }
    
    if (section == 1 && _selectedOneModel == nil) {
        NSMutableArray *strArr = [NSMutableArray arrayWithCapacity:0];
        for (SYTwoModel *two in self.twoAllModel) {
            [strArr addObject:two.spceName];
        }
        NSMutableArray *resuleArr = [NSMutableArray arrayWithCapacity:0];
        for (NSString *item in strArr) {
            if (![resuleArr containsObject:item]) {
                [resuleArr addObject:item];
            }
        }
        return resuleArr.count;
    }else if(section == 1 && _selectedOneModel != nil){
        for (SYOneModel *one in _dataSourceArr) {
            if ([one.isSelecte boolValue]) {
                return one.spces.count;
            }
        }
    }
    
    if (section == 2 && _selectedTwoModel == nil) {
        NSMutableArray *strArr = [NSMutableArray arrayWithCapacity:0];
        for (SYThreeModel *two in self.threeAllModel) {
            [strArr addObject:two.spceName];
        }
        NSMutableArray *resuleArr = [NSMutableArray arrayWithCapacity:0];
        for (NSString *item in strArr) {
            if (![resuleArr containsObject:item]) {
                [resuleArr addObject:item];
            }
        }
        return resuleArr.count;
    }else if (section == 2 && _selectedTwoModel != nil){
        for (SYTwoModel *two in self.twoAllModel) {
            if ([two.isSelecte boolValue]) {
                return two.spces.count;
            }
        }
    }
    
    return 0;
}

//cell样式
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    TagCell *cell = [TagCell cellWithCollectionView:collectionView andIndexPath:indexPath];
    cell.backgroundColor = RGB(242, 242, 242);
    cell.tagLabel.textColor = HexRGB(0x717171);
    
    if (indexPath.section == 0) {
        
        SYOneModel *one = _dataSourceArr[indexPath.item];
        if ([one.isSelecte boolValue]) {
            cell.backgroundColor = NavigationColor;
            cell.tagLabel.textColor = [UIColor whiteColor];
        }else{
            cell.backgroundColor = RGB(242, 242, 242);
            cell.tagLabel.textColor = HexRGB(0x717171);
        }
        cell.tagLabel.text = one.spceName;
        
    }else if (indexPath.section == 1 && _selectedOneModel == nil){
        NSMutableArray *strArr = [NSMutableArray arrayWithCapacity:0];
        for (SYTwoModel *two in self.twoAllModel) {
            [strArr addObject:two.spceName];
        }
        NSMutableArray *resuleArr = [NSMutableArray arrayWithCapacity:0];
        for (NSString *item in strArr) {
            if (![resuleArr containsObject:item]) {
                [resuleArr addObject:item];
            }
        }
 
        cell.tagLabel.text = resuleArr[indexPath.item];

    }else if (indexPath.section == 1 && _selectedOneModel != nil) {
        NSMutableArray *muArr = [NSMutableArray arrayWithCapacity:0];
        for (SYOneModel *one in self.oneAllModel) {
            if (one == _selectedOneModel) {
                [muArr addObjectsFromArray:one.spces];
            }
        }
        SYTwoModel *two = muArr[indexPath.item];
        if ([two.isSelecte boolValue]) {
            cell.backgroundColor = NavigationColor;
            cell.tagLabel.textColor = [UIColor whiteColor];
        }else{
            cell.backgroundColor = RGB(242, 242, 242);
            cell.tagLabel.textColor = HexRGB(0x717171);
        }
        cell.tagLabel.text = two.spceName;
    }else if (indexPath.section == 2 && _selectedTwoModel == nil){
        NSMutableArray *strArr = [NSMutableArray arrayWithCapacity:0];
        for (SYThreeModel *two in self.threeAllModel) {
            [strArr addObject:two.spceName];
        }
        NSMutableArray *resuleArr = [NSMutableArray arrayWithCapacity:0];
        for (NSString *item in strArr) {
            if (![resuleArr containsObject:item]) {
                [resuleArr addObject:item];
            }
        }
        
        cell.tagLabel.text = resuleArr[indexPath.item];
    }else if (indexPath.section == 2 && _selectedTwoModel != nil){
        NSMutableArray *muArr = [NSMutableArray arrayWithCapacity:0];
        for (SYTwoModel *two in self.twoAllModel) {
            if (two == _selectedTwoModel) {
                [muArr addObjectsFromArray:two.spces];
            }
        }
        SYThreeModel *three = muArr[indexPath.item];
        if ([three.isSelecte boolValue]) {
            cell.backgroundColor = NavigationColor;
            cell.tagLabel.textColor = [UIColor whiteColor];
        }else{
            cell.backgroundColor = RGB(242, 242, 242);
            cell.tagLabel.textColor = HexRGB(0x717171);
        }
        cell.tagLabel.text = three.spceName;
    }

    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        for (int i = 0; i < self.oneAllModel.count; i++) {
            SYOneModel *one = self.oneAllModel[i];
            if (i == indexPath.item) {
                one.isSelecte = @YES;
                _selectedOneModel = one;
            }else{
                one.isSelecte = @NO;
            }
        }
        for (SYTwoModel *two in self.twoAllModel) {
            two.isSelecte = @NO;
        }
        for (SYThreeModel *three in self.threeAllModel) {
            three.isSelecte = @NO;
        }
        _selectedTwoModel = nil;
        _selectedThreeModel = nil;
        if (_selectedOneModel.money && _selectedOneModel.money != nil && ![_selectedOneModel.money isKindOfClass:[NSNull class]]) {
            float money = [_selectedOneModel.money floatValue] / 100;
            self.guigeUpView.priceLabel.text = [NSString stringWithFormat:@"¥%.2f",money];
        }
        if (_selectedOneModel.num && _selectedOneModel.num != nil && ![_selectedOneModel.num isKindOfClass:[NSNull class]]) {
            NSInteger num = [_selectedOneModel.num integerValue];
            self.guigeUpView.kucunLabel.text = [NSString stringWithFormat:@"库存%ld件",num];
        }
        if (_selectedOneModel.spceName && _selectedOneModel.spceName != nil && ![_selectedOneModel.spceName isKindOfClass:[NSNull class]]) {
            self.guigeUpView.yixuanLabel.text = [NSString stringWithFormat:@"已选：""%@""",_selectedOneModel.spceName];
        }
        [self.collectionView reloadData];
    }else if (indexPath.section == 1 && _selectedOneModel != nil){
        for (SYOneModel *one in _dataSourceArr) {
            if (one == _selectedOneModel) {
                for (int i = 0; i < one.spces.count; i++) {
                    SYTwoModel *two = one.spces[i];
                    if (i == indexPath.item) {
                        two.isSelecte = @YES;
                        _selectedTwoModel = two;
                    }else{
                        two.isSelecte = @NO;
                    }
                }
            }else{
                for (int i = 0; i < one.spces.count; i++) {
                    SYTwoModel *two = one.spces[i];
                    two.isSelecte = @NO;
                }
            }
        }
        for (SYThreeModel *three in self.threeAllModel) {
            three.isSelecte = @NO;
        }
        
        if (_selectedTwoModel.money && _selectedTwoModel.money != nil && ![_selectedTwoModel.money isKindOfClass:[NSNull class]]) {
            float money = [_selectedTwoModel.money floatValue] / 100;
            self.guigeUpView.priceLabel.text = [NSString stringWithFormat:@"¥%.2f",money];
        }
        if (_selectedTwoModel.num && _selectedTwoModel.num != nil && ![_selectedTwoModel.num isKindOfClass:[NSNull class]]) {
            NSInteger num = [_selectedTwoModel.num integerValue];
            self.guigeUpView.kucunLabel.text = [NSString stringWithFormat:@"库存%ld件",num];
        }
        if (_selectedTwoModel.spceName && _selectedTwoModel.spceName != nil && ![_selectedTwoModel.spceName isKindOfClass:[NSNull class]]) {
            self.guigeUpView.yixuanLabel.text = [NSString stringWithFormat:@"已选：""%@"" ""%@""",_selectedOneModel.spceName, _selectedTwoModel.spceName];
        }
        
        _selectedThreeModel = nil;
        [self.collectionView reloadData];
    }else if(indexPath.section == 2 && _selectedTwoModel != nil){
        for (SYOneModel *one in _dataSourceArr) {
            if (one == _selectedOneModel) {
                for (int i = 0; i < one.spces.count; i++) {
                    NSArray *twoSpces = one.spces;
                    for (SYTwoModel *two in twoSpces) {
                        if (two == _selectedTwoModel) {
                            NSArray *threeSpces = two.spces;
                            for (int j = 0; j < threeSpces.count; j++) {
                                SYThreeModel *three = threeSpces[j];
                                if (j == indexPath.item) {
                                    three.isSelecte = @YES;
                                    _selectedThreeModel = three;
                                }else{
                                    three.isSelecte = @NO;
                                }
                            }
                        }
                    }
                }
            }else{
                NSArray *twoSpces = one.spces;
                for (SYTwoModel *two in twoSpces) {
                    NSArray *threeSpces = two.spces;
                    for (SYThreeModel *three in threeSpces) {
                        three.isSelecte = @NO;
                    }
                }
            }
        }
        
        if (_selectedThreeModel.money && _selectedThreeModel.money != nil && ![_selectedThreeModel.money isKindOfClass:[NSNull class]]) {
            float money = [_selectedThreeModel.money floatValue] / 100;
            self.guigeUpView.priceLabel.text = [NSString stringWithFormat:@"¥%.2f",money];
        }
        if (_selectedThreeModel.num && _selectedThreeModel.num != nil && ![_selectedThreeModel.num isKindOfClass:[NSNull class]]) {
            NSInteger num = [_selectedThreeModel.num integerValue];
            self.guigeUpView.kucunLabel.text = [NSString stringWithFormat:@"库存%ld件",num];
        }
        if (_selectedThreeModel.spceName && _selectedThreeModel.spceName != nil && ![_selectedThreeModel.spceName isKindOfClass:[NSNull class]]) {
            self.guigeUpView.yixuanLabel.text = [NSString stringWithFormat:@"已选：""%@"" ""%@"" ""%@""",_selectedOneModel.spceName, _selectedTwoModel.spceName, _selectedThreeModel.spceName];
        }
        
        
        [self.collectionView reloadData];
    }else if (indexPath.section == 1 && _selectedOneModel == nil){
        if ([_dataSourceDic objectForKey:@"attr"]) {
            NSArray *attr = [_dataSourceDic objectForKey:@"attr"];
            if (attr.count > 0) {
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"请先选择%@",attr[0]]];
            }
        }
    }else if (indexPath.section == 2 && _selectedOneModel == nil){
        if ([_dataSourceDic objectForKey:@"attr"]) {
            NSArray *attr = [_dataSourceDic objectForKey:@"attr"];
            if (attr.count > 0) {
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"请先选择%@",attr[0]]];
            }
        }
    }else if (indexPath.section == 2 && _selectedTwoModel == nil){
        if ([_dataSourceDic objectForKey:@"attr"]) {
            NSArray *attr = [_dataSourceDic objectForKey:@"attr"];
            if (attr.count > 1) {
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"请先选择%@",attr[1]]];
            }
        }
    }
    
    self.actionBtn.enabled = [self puanduanQingDingShifouKexuan];
}

- (NSMutableArray *)oneAllModel{
    if (!_oneAllModel) {
        _oneAllModel = [NSMutableArray arrayWithCapacity:0];
    }
    return _oneAllModel;
}

- (NSMutableArray *)twoAllModel{
    if (!_twoAllModel) {
        _twoAllModel = [NSMutableArray arrayWithCapacity:0];
    }
    return _twoAllModel;
}

- (NSMutableArray *)threeAllModel{
    if (!_threeAllModel) {
        _threeAllModel = [NSMutableArray arrayWithCapacity:0];
    }
    return _threeAllModel;
}

@end
