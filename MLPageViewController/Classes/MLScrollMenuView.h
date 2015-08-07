//
//  MLScrollMenuView.h
//  MLPageViewController
//
//  Created by molon on 15/8/7.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MLScrollMenuViewDelegate <NSObject>

- (NSString*)titleForIndex:(NSInteger)index;
- (NSInteger)titleCount;

@end

#define kMLScrollMenuViewCollectionViewCellXPadding 10.0f
#define kMLScrollMenuViewIndicatorViewHeight 3.0f
@interface MLScrollMenuView : UIView

@property (nonatomic, weak) id<MLScrollMenuViewDelegate> delegate;
@property (nonatomic, assign) NSInteger currentIndex;

//可以自定义的一些样式
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *indicatorColor;


- (void)reloadData;

@end
