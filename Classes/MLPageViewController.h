//
//  MLPageViewController.h
//  MLPageViewController
//
//  Created by molon on 15/8/7.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import "MLContainerController.h"

#define kDefaultMLScrollMenuViewHeight 40.0f
@class MLScrollMenuView;
@interface MLPageViewController : MLContainerController

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
 *  页面切换后的回调
 */
#warning 如果oldIndex是-1 表示第一次显示某页面，还有闪电购下，切换tab时候被说begin/end没有对应起来，还有头部菜单在数量太少的时候reloadData会有跳跃问题，还有就是会提示itemSize不合适
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
 *  当前ViewController的index
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

@end
