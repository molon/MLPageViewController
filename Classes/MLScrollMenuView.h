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

- (void)didChangeCurrentIndexFrom:(NSInteger)oldIndex to:(NSInteger)currentIndex animated:(BOOL)animated scrollMenuView:(MLScrollMenuView*)scrollMenuView;

@optional
- (BOOL)shouldChangeCurrentIndexFrom:(NSInteger)oldIndex to:(NSInteger)toIndex scrollMenuView:(MLScrollMenuView*)scrollMenuView;

@end

#define kMLScrollMenuViewCollectionViewCellXPadding 10.0f
#define kMLScrollMenuViewIndicatorViewHeight 2.0f
#define kMLScrollMenuViewIndicatorViewXPadding 5.0f
@interface MLScrollMenuView : UIView

@property (nonatomic, assign, readonly) NSInteger currentIndex;

//可以自定义的一些样式
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *currentTitleColor;
@property (nonatomic, strong) UIColor *indicatorColor;
@property (nonatomic, strong) UIColor *indicatorBackgroundColor;
@property (nonatomic, strong, readonly) UIImageView *backgroundImageView;

/**
 *  滚动菜单的delegate，注意在使用MLPageViewController时候即为MLPageViewController不可修改。
 */
@property (nonatomic, weak) id<MLScrollMenuViewDelegate> delegate;

/**
 *  主动设置当前页index的方法
 *
 *  @param currentIndex 当前页index
 *  @param animated     是否动画过去
 */
- (void)setCurrentIndex:(NSInteger)currentIndex animated:(BOOL)animated;

/**
 *  显示去目标index的动画中间位置，注意在使用MLPageViewController时候一般无需关心
 */
- (void)displayFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex ratio:(double)ratio;

@end
