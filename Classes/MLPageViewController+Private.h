//
//  MLPageViewController+Private.h
//  MLPageViewController
//
//  Created by molon on 16/5/23.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "MLPageViewController.h"

@interface MLPageViewController (Private)

/**
 *  页VC的views所在的scrollView
 */
@property (nonatomic, strong, readonly) UIScrollView *scrollView;

/**
 *  当前pageViewController若处于UITabBarController里的话，此值会是tabBar所占用的高度
 */
@property (nonatomic, assign, readonly) CGFloat tabBarOccupyHeight;

@end
