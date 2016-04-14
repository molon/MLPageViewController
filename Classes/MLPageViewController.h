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

@property (nonatomic, strong,readonly) MLScrollMenuView *scrollMenuView;
@property (nonatomic, strong,readonly) NSArray *viewControllers;
//默认为YES，可自动调整上下留空以适应导航器和tabController。
@property (nonatomic, assign) BOOL autoAdjustTopAndBottomBlank;
@property (nonatomic, assign) BOOL dontScrollWhenDirectClickMenu; //当直接点击菜单时候不滚动

- (instancetype)initWithViewControllers:(NSArray *)viewControllers;


@end
