//
//  QTSearchBar.h
//  ReadingClub
//
//  Created by qtkj on 16/8/9.
//  Copyright © 2016年 qtkj. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QTSearchBarDelegate <NSObject>

- (void)keyBoardSearchWithText:(NSString *)text;

- (void)textFieldShouldClearText;

- (void)textFieldShouldBeginEdit;

@end

@interface QTSearchBar : UITextField<UITextFieldDelegate>

+ (instancetype)searchBarWith:(CGRect)frame;

@property (nonatomic, weak) id<QTSearchBarDelegate> searchDelegate;

@end
