//
//  MLPageViewController.m
//  MLPageViewController
//
//  Created by molon on 15/8/7.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import "MLPageViewController.h"
#import "MLScrollMenuView.h"
#import "UIViewController+MLKit.h"

#define CHILD(childClass,object) \
((childClass *)object) \
\

@interface MLPageViewController ()<MLScrollMenuViewDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) MLScrollMenuView *scrollMenuView;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) NSArray *viewControllers;

@property (nonatomic, assign) BOOL ignoreSetCurrentIndex;

@end

@implementation MLPageViewController

- (instancetype)initWithViewControllers:(NSArray *)viewControllers
{
    self = [self init];
    if (self) {
        self.viewControllers = viewControllers;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp
{
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.scrollMenuView];
    [self.view addSubview:self.scrollView];
    
    //直接让子vc viewdidload,对性能有好处
    for (int i = 0; i < self.viewControllers.count; i++) {
        UIViewController *vc = self.viewControllers[i];
        [vc performSelector:@selector(view) withObject:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - getter
- (MLScrollMenuView *)scrollMenuView
{
    if (!_scrollMenuView) {
        _scrollMenuView = [MLScrollMenuView new];
        _scrollMenuView.backgroundColor = [UIColor lightGrayColor];
        _scrollMenuView.delegate = self;
    }
    return _scrollMenuView;
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [UIScrollView new];
        _scrollView.scrollsToTop = NO;
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
    }
    return _scrollView;
}

#pragma mark - layout
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGFloat width = self.view.frame.size.width;
    
    CGFloat baseY = [self navigationBarBottomOriginY];
    self.scrollMenuView.frame = CGRectMake(0, baseY, width, kDefaultMLScrollMenuViewHeight);
    baseY+=kDefaultMLScrollMenuViewHeight;
    self.scrollView.frame = CGRectMake(0, baseY, width, self.view.frame.size.height-[self tabBarOccupyHeight]-baseY);
    
    //设置其contentSize
    self.scrollView.contentSize = CGSizeMake(width*self.viewControllers.count, self.scrollView.frame.size.height);
    
    //设置子view的frame
    for (int i = 0; i < self.viewControllers.count; i++) {
        UIViewController *vc = self.viewControllers[i];
        vc.view.frame = CGRectMake(i*width, 0, width, self.scrollView.frame.size.height);
#warning 测试
        vc.view.backgroundColor = i%2?[UIColor lightGrayColor]:[UIColor colorWithRed:0.888 green:1.000 blue:0.527 alpha:1.000];
    }
}

#pragma mark - scrollMenuView delegate
- (NSInteger)titleCount
{
    return self.viewControllers.count;
}

- (NSString *)titleForIndex:(NSInteger)index
{
    return CHILD(UIViewController, self.viewControllers[index]).title;
}

- (void)didChangedCurrentIndex:(NSInteger)currentIndex scrollMenuView:(MLScrollMenuView*)scrollMenuView
{
    if (!self.ignoreSetCurrentIndex) {
        [self.scrollView setContentOffset:CGPointMake(currentIndex * self.scrollView.frame.size.width, 0) animated:YES];
    }

#warning 。。。
//    [self setChildViewControllerWithCurrentIndex:index];
}

#pragma mark -- ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int scrollCurrentIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
    
    CGFloat oldOffsetX = scrollCurrentIndex * scrollView.frame.size.width;
    CGFloat ratio = (scrollView.contentOffset.x - oldOffsetX) / scrollView.frame.size.width;
    
    BOOL isToNextItem = (scrollView.contentOffset.x > oldOffsetX);
    NSInteger targetIndex = (isToNextItem) ? scrollCurrentIndex + 1 : scrollCurrentIndex - 1;
    if (targetIndex<0||targetIndex>self.viewControllers.count-1) {
        return;
    }
    UIViewController *currentVC = self.viewControllers[scrollCurrentIndex];
    UIViewController *targetVC = self.viewControllers[targetIndex];
    
#warning 有问题
    [currentVC willMoveToParentViewController:nil];
    [currentVC.view removeFromSuperview];
    [currentVC removeFromParentViewController];
    
    [self addChildViewController:targetVC];
    [self.scrollView addSubview:targetVC.view];
    [targetVC didMoveToParentViewController:self];
    
    [self.scrollMenuView displayForTargetIndex:targetIndex targetIsNext:isToNextItem ratio:fabs(ratio)];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int currentIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
    
    self.ignoreSetCurrentIndex = YES;
    [self.scrollMenuView setCurrentIndex:currentIndex animated:YES];
    self.ignoreSetCurrentIndex = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self scrollViewDidEndDecelerating:scrollView];
    }
}

#pragma mark - helper
//出发didappear和diddisappear
- (void)setDidAppearViewControllerWithIndex:(NSInteger)index
{
    for (NSInteger i=0; i<self.viewControllers.count; i++) {
        UIViewController *vc = self.viewControllers[i];
        if (index==i) {
            [vc didMoveToParentViewController:self];
        }else{
            if ([vc.parentViewController isEqual:self]) {
                [vc removeFromParentViewController];
            }
        }
    }
}

//- (void)setChildViewControllerWithCurrentIndex:(NSInteger)currentIndex
//{
//    for (int i = 0; i < self.childControllers.count; i++) {
//        id obj = self.childControllers[i];
//        if ([obj isKindOfClass:[UIViewController class]]) {
//            UIViewController *controller = (UIViewController*)obj;
//            if (i == currentIndex) {
//                [controller willMoveToParentViewController:self];
//                [self addChildViewController:controller];
//                [controller didMoveToParentViewController:self];
//            } else {
//                [controller willMoveToParentViewController:self];
//                [controller removeFromParentViewController];
//                [controller didMoveToParentViewController:self];
//            }
//        }
//    }
//}
@end
