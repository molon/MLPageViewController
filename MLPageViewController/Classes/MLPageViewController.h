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
@property (nonatomic, strong,readonly) UIScrollView *scrollView;
@property (nonatomic, strong,readonly) NSArray *viewControllers;

- (instancetype)initWithViewControllers:(NSArray *)viewControllers;

@end
