//
//  SYUpdateGrapherFlowLayout.m
//  ShuoYing
//
//  Created by 硕影 on 2017/1/12.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYUpdateGrapherFlowLayout.h"

@implementation SYUpdateGrapherFlowLayout

- (void)prepareLayout{
    [super prepareLayout];
    self.minimumLineSpacing = 10;
    self.itemSize = CGSizeMake((kScreenWidth - 50) / 3, (kScreenWidth - 50) /3 + 50);
    
    self.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.headerReferenceSize = CGSizeMake(kScreenWidth, 40);
    self.footerReferenceSize = CGSizeMake(kScreenWidth, 20);
    self.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);

}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    
    return UIEdgeInsetsMake(15, 15, 5, 15);//分别为上、左、下、右
}
@end
