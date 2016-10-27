//
//  MLPageViewController.h
//  MLPageViewController
//
//  Created by molon on 15/8/7.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import "MLContainerControllerForMLPage.h"
#import "MLScrollMenuView.h"

FOUNDATION_EXPORT CGFloat const DefaultMLScrollMenuViewHeightForMLPageViewController;

//TODO: 现今的childViewControllers会不断添加移除，最终只保留当前显示的那个页面，这似乎不太合理，一般不影响使用，后续优化。
@interface MLPageViewController : MLContainerControllerForMLPage

/**
 *  所绑定的scrollMenuView
 */
@property (nonatomic, strong,readonly) MLScrollMenuView *scrollMenuView;

/**
 *  页VC的views所在的scrollView
 */
@property (nonatomic, strong, readonly) UIScrollView *scrollView;

/**
 *  所绑定的页viewControllers
 */
@property (nonatomic, strong,readonly) NSArray *viewControllers;

/**
 *  自动调整上下留空以适应navigationController和tabController，默认为YES。
 */
@property (nonatomic, assign) BOOL autoAdjustTopAndBottomBlank;

/**
 *  当直接点击菜单按钮时候不滚动，默认为NO。
 */
@property (nonatomic, assign) BOOL dontScrollWhenDirectClickMenu;

/**
 *  页面切换回调
 */
@property (nonatomic, copy) void(^didChangeCurrentIndexBlock)(NSInteger fromIndex, NSInteger toIndex, MLPageViewController *pageVC);

/**
 *  初始化时候必须提供所有的viewControllers，后续不可增删
 *
 *  @param viewControllers 页viewControllers
 *
 *  @return 实例
 */
- (instancetype)initWithViewControllers:(NSArray *)viewControllers;

/**
 *  当前ViewController的index，开始默认为0
 *
 *  @return 当前ViewController的index
 */
- (NSInteger)currentIndex;

/**
 *  当前ViewController
 *
 *  @return 当前ViewController
 */
- (UIViewController*)currentViewController;

/**
 *  主动设置当前页index的方法
 *
 *  @param currentIndex 当前页index
 *  @param animated     是否动画过去
 */
- (void)setCurrentIndex:(NSInteger)currentIndex animated:(BOOL)animated;

/**
 配置scrollMenuView的高度，默认是DefaultMLScrollMenuViewHeightForMLPageViewController，如要修改请重写此方法
 */
- (CGFloat)configureScrollMenuViewHeight;

/**
 这个一般用于自定义布局时候的便捷设置scrollView新frame的方法
 
 @param frame newFrame
 */
- (void)changeScrollViewFrameTo:(CGRect)frame;

@end
