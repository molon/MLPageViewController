//
//  MLPageViewController.h
//  MLPageViewController
//
//  Created by molon on 15/8/7.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import "MLContainerController.h"

#define kDefaultMLScrollMenuViewHeight 35.0f
@class MLScrollMenuView;
@interface MLPageViewController : MLContainerController

@property (nonatomic, strong,readonly) MLScrollMenuView *scrollMenuView;
@property (nonatomic, strong,readonly) NSArray *viewControllers;
//默认为YES，可自动调整上下留空以适应导航器和tabController。
@property (nonatomic, assign) BOOL autoAdjustTopAndBottomBlank;

- (instancetype)initWithViewControllers:(NSArray *)viewControllers;


@end
