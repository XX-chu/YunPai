//
//  QTSearchBar.m
//  ReadingClub
//
//  Created by qtkj on 16/8/9.
//  Copyright © 2016年 qtkj. All rights reserved.
//

#import "QTSearchBar.h"

@implementation QTSearchBar

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = frame.size.height / 2;
        self.layer.masksToBounds = YES;
        self.font = [UIFont systemFontOfSize:13];
        self.textColor = RGB(155, 155, 155);
        self.placeholder = @"请搜索关键字";
        self.returnKeyType = UIReturnKeySearch;
        self.delegate = self;
        
        UIImageView *searchIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.height, self.frame.size.height)];
        searchIcon.image = [UIImage imageNamed:@"shouye_icon_sousuo"];
        // contentMode：default is UIViewContentModeScaleToFill，要设置为UIViewContentModeCenter：使图片居中，防止图片填充整个imageView
        searchIcon.contentMode = UIViewContentModeCenter;
        
        self.leftView = searchIcon;

        self.leftViewMode = UITextFieldViewModeAlways;
    }
    return self;
}

+ (instancetype)searchBarWith:(CGRect)frame{
    return [[self alloc] initWithFrame:frame];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (_searchDelegate && [_searchDelegate respondsToSelector:@selector(keyBoardSearchWithText:)]) {
        [_searchDelegate keyBoardSearchWithText:textField.text];
    }

    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    if (_searchDelegate && [_searchDelegate respondsToSelector:@selector(textFieldShouldClearText)]) {
        [_searchDelegate textFieldShouldClearText];
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (_searchDelegate && [_searchDelegate respondsToSelector:@selector(textFieldShouldBeginEdit)]) {
        [_searchDelegate textFieldShouldBeginEdit];
    }
    
    return YES;
}

@end
