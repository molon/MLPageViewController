//
//  MLScrollMenuView.h
//  MLPageViewController
//
//  Created by molon on 15/8/7.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MLScrollMenuView;
@class MLScrollMenuCollectionViewCell;
@protocol MLScrollMenuViewDelegate <NSObject>

- (NSString*)titleForIndex:(NSInteger)index;
- (NSInteger)titleCount;

- (void)didChangeCurrentIndexFrom:(NSInteger)oldIndex to:(NSInteger)toIndex animated:(BOOL)animated scrollMenuView:(MLScrollMenuView*)scrollMenuView;

@optional
- (BOOL)shouldChangeCurrentIndexFrom:(NSInteger)oldIndex to:(NSInteger)toIndex scrollMenuView:(MLScrollMenuView*)scrollMenuView;
- (NSString*)extraSignForIndex:(NSInteger)index;
- (void)afterLayoutWithCell:(MLScrollMenuCollectionViewCell*)cell index:(NSInteger)index;

@end

FOUNDATION_EXPORT CGFloat const DefaultMLScrollMenuViewCollectionViewCellXPadding;
FOUNDATION_EXPORT CGFloat const DefaultMLScrollMenuViewIndicatorViewHeight;
FOUNDATION_EXPORT CGFloat const DefaultMLScrollMenuViewIndicatorViewXPadding;

@interface MLScrollMenuCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *extraSignLabel;

@end

@interface MLScrollMenuView : UIView

@property (nonatomic, assign, readonly) NSInteger currentIndex;

//可以自定义的一些样式
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIFont *extraSignFont;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *currentTitleColor;
@property (nonatomic, strong) UIColor *currentIndicatorColor;
@property (nonatomic, strong) UIColor *indicatorBackgroundColor;
@property (nonatomic, strong, readonly) UIImageView *backgroundImageView;

@property (nonatomic, assign) CGFloat indicatorViewHeight; //默认为DefaultMLScrollMenuViewIndicatorViewHeight，指示器的高度
@property (nonatomic, assign) CGFloat collectionViewCellXPadding; //默认为DefaultMLScrollMenuViewCollectionViewCellXPadding，代表每个标题所占cell的左右内边距
@property (nonatomic, assign) CGFloat currentIndicatorViewXPadding; //默认为DefaultMLScrollMenuViewIndicatorViewXPadding，代表指示器的左右内边距(即为比文本长度多那么一点的那些距离)
@property (nonatomic, assign) UIOffset currentIndicatorViewOffset; //可自定义稍修正下indicatorView的位置

@property (nonatomic, assign) BOOL animating; //处于动画中，其实也就是在setCurrentIndex:animated:YES 动画开始和完成之间为YES,其他时候都为NO

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

/**
 reload display
 */
- (void)reloadDisplay;

@end
