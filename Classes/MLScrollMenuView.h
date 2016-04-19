//
//  MLScrollMenuView.h
//  MLPageViewController
//
//  Created by molon on 15/8/7.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MLScrollMenuView;
@protocol MLScrollMenuViewDelegate <NSObject>

- (NSString*)titleForIndex:(NSInteger)index;
- (NSInteger)titleCount;

- (void)didChangedCurrentIndexFrom:(NSInteger)oldIndex to:(NSInteger)currentIndex scrollMenuView:(MLScrollMenuView*)scrollMenuView;

@optional
- (BOOL)shouldChangedCurrentIndexFrom:(NSInteger)oldIndex to:(NSInteger)toIndex scrollMenuView:(MLScrollMenuView*)scrollMenuView;

@end

#define kMLScrollMenuViewCollectionViewCellXPadding 10.0f
#define kMLScrollMenuViewIndicatorViewHeight 2.0f
#define kMLScrollMenuViewIndicatorViewXPadding 5.0f
@interface MLScrollMenuView : UIView

@property (nonatomic, weak) id<MLScrollMenuViewDelegate> delegate;
@property (nonatomic, assign, readonly) NSInteger currentIndex;

//可以自定义的一些样式
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *currentTitleColor;
@property (nonatomic, strong) UIColor *indicatorColor;
@property (nonatomic, strong) UIColor *indicatorBackgroundColor;

@property (nonatomic, strong, readonly) UIImageView *backgroundImageView;


- (void)reloadData;
- (void)setCurrentIndex:(NSInteger)currentIndex animated:(BOOL)animated;

//临时的显示去目标index的动画中间位置
- (void)displayFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex ratio:(double)ratio;

@end
