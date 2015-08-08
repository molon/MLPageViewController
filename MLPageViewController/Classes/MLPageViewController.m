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
@property (nonatomic, assign) CGFloat lastContentOffsetX;

@property (nonatomic, strong) NSArray *viewControllers;

@property (nonatomic, assign) BOOL ignoreSetCurrentIndex;


@property (nonatomic, strong) NSMutableArray *viewControllerAppearanceTransitions;

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
    
    //直接add第一个,至于其viewWillAppear和didAppear啥的会随着container vc传递下去
    if (self.viewControllers.count>0) {
        UIViewController *vc = [self.viewControllers firstObject];
        [self addChildViewController:vc];
        [self.scrollView addSubview:vc.view];
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

#pragma mark - setter
- (void)setViewControllers:(NSArray *)viewControllers
{
    _viewControllers = viewControllers;
    
    NSMutableArray *viewControllerAppearanceTransitions = [NSMutableArray arrayWithCapacity:viewControllers.count];
    
    for (NSInteger i=0; i<viewControllers.count; i++) {
        [viewControllerAppearanceTransitions addObject:@(NO)];
    }
    self.viewControllerAppearanceTransitions = viewControllerAppearanceTransitions;
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
}

#pragma mark -- ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.lastContentOffsetX==scrollView.contentOffset.x) {return;}
    BOOL isScrollToRight = self.lastContentOffsetX<scrollView.contentOffset.x;
    self.lastContentOffsetX = scrollView.contentOffset.x;
    
    
    NSInteger leftIndex = floor(scrollView.contentOffset.x / scrollView.frame.size.width);
    if (leftIndex<0||leftIndex+1>self.viewControllers.count-1) {
        return;
    }
    NSInteger rightIndex = leftIndex+1;
    CGFloat leftToRightRatio = (scrollView.contentOffset.x - leftIndex * scrollView.frame.size.width) / scrollView.frame.size.width;
    
    [self.scrollMenuView displayFromIndex:leftIndex toIndex:rightIndex ratio:fabs(leftToRightRatio)];
    
    //处理view appear
    if (leftToRightRatio==0.0f) {
        return;
    }
    
    NSInteger targetIndex = isScrollToRight?rightIndex:leftIndex;
    NSInteger currentIndex = isScrollToRight?leftIndex:rightIndex;
    
    //目的是找到目标vc，并且其没add就add，没appear就appear，至于其他的非current就diddisappear，current的没willdisappear就willdisappear
    UIViewController *currentVC = self.viewControllers[currentIndex];
    UIViewController *targetVC = self.viewControllers[targetIndex];
    
    if (![targetVC.view.superview isEqual:self.scrollView]) {
        //其他的vc disappear
        for (UIViewController *vc in self.childViewControllers) {
            if ([vc isEqual:currentVC]||[vc isEqual:targetVC]) {
                continue;
            }
            if ([vc.view.superview isEqual:self.scrollView]) {
                [vc.view removeFromSuperview];
                [vc removeFromParentViewController];
                [vc endAppearanceTransition];
            }
        }
        
        //将要add
        [self addChildViewController:targetVC];
        [self.scrollView addSubview:targetVC.view];
        [targetVC beginAppearanceTransition:YES animated:YES];
        self.viewControllerAppearanceTransitions[targetIndex] = @(YES);
        
        //将要remove
        [currentVC willMoveToParentViewController:nil];
        [currentVC beginAppearanceTransition:NO animated:YES];
        self.viewControllerAppearanceTransitions[currentIndex] = @(NO);
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int currentIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
    
    self.ignoreSetCurrentIndex = YES;
    [self.scrollMenuView setCurrentIndex:currentIndex animated:YES];
    self.ignoreSetCurrentIndex = NO;
    
    
    UIViewController *currentVC = self.viewControllers[currentIndex];
    if (![self.viewControllerAppearanceTransitions[currentIndex] boolValue]) {
        [currentVC beginAppearanceTransition:YES animated:YES];
    }
    [currentVC endAppearanceTransition];
    [currentVC didMoveToParentViewController:self];
    
    for (UIViewController *vc in self.childViewControllers) {
        if ([vc isEqual:currentVC]) {
            continue;
        }
        if ([vc.view.superview isEqual:self.scrollView]) {
            [vc.view removeFromSuperview];
            [vc removeFromParentViewController];
            if ([self.viewControllerAppearanceTransitions[[self.viewControllers indexOfObject:vc]] boolValue]) {
                [vc beginAppearanceTransition:NO animated:YES];
            }
            [vc endAppearanceTransition];
        }
    }
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
                [vc.view removeFromSuperview];
                [vc removeFromParentViewController];
            }
        }
    }
}
@end
