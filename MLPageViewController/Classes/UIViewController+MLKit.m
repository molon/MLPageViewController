//
//  UIViewController+MLKit.m
//  Pods
//
//  Created by molon on 15/7/29.
//
//

#import "UIViewController+MLKit.h"

@implementation UIViewController (MLKit)

+ (CGFloat)statusBarHeight
{
    //    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    //    return [UIApplication sharedApplication].statusBarHidden?0.0f:MIN(statusBarSize.width, statusBarSize.height);
    return 20.0f; //写死是20.0f吧。如果热点开启或者来电话时候 这个值其实应该是40，但是程序里例如设置tableView的头部inset，以40为准的话会有空隙。所以写死20是绝对OK的
}

- (CGFloat)navigationBarBottomOriginY
{
    if (![self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        return 0;
    }
    if (!self.navigationController) {
        return [UIViewController statusBarHeight];
    }
    return [UIViewController statusBarHeight] + (self.navigationController.navigationBarHidden ? 0 : self.navigationController.navigationBar.intrinsicContentSize.height);
}

- (CGFloat)tabBarOccupyHeight
{
    if (![self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        return 0.0f;
    }
    if (!self.tabBarController) {
        return 0.0f;
    }
    if (!self.tabBarController.tabBar.translucent) {
        return 0.0f;
    }
    if (self.hidesBottomBarWhenPushed) {
        return 0.0f;
    }
    return self.tabBarController.tabBar.intrinsicContentSize.height;
}


@end
