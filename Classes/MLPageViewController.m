//
//  MLPageViewController.m
//  MLPageViewController
//
//  Created by molon on 15/8/7.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import "MLPageViewController.h"
#import "MLScrollMenuView.h"

#define CHILD(childClass,object) \
((childClass *)object) \
\

@interface MLPageViewController ()<MLScrollMenuViewDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) MLScrollMenuView *scrollMenuView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) CGFloat lastContentOffsetX;

@property (nonatomic, strong) NSArray *viewControllers;

@property (nonatomic, assign) BOOL ignoreSetCurrentIndex;
@property (nonatomic, assign) BOOL dontChangeDisplayMenuView;

@property (nonatomic, strong) NSMutableDictionary *viewControllerAppearanceTransitionMap;

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
    _autoAdjustTopAndBottomBlank = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.scrollMenuView];
    [self.view addSubview:self.scrollView];
    
    //直接让子vc viewdidload,对性能有点好处
    for (int i = 0; i < self.viewControllers.count; i++) {
        UIViewController *vc = self.viewControllers[i];
        [vc performSelector:@selector(view) withObject:nil];
    }
    
    //直接add第一个,至于其viewWillAppear和didAppear啥的会随着container vc传递下去
    if (self.viewControllers.count>0) {
        UIViewController *vc = [self.viewControllers firstObject];
        [self addChildViewController:vc];
        [self.scrollView addSubview:vc.view];
        [vc didMoveToParentViewController:self];
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
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}

#pragma mark - setter
- (void)setViewControllers:(NSArray *)viewControllers
{
    _viewControllers = viewControllers;
    
    self.viewControllerAppearanceTransitionMap = [NSMutableDictionary dictionaryWithCapacity:viewControllers.count];
    for (UIViewController *vc in viewControllers) {
        [self setLastAppearanceTransition:NO forViewController:vc];
    }
}

- (void)setAutoAdjustTopAndBottomBlank:(BOOL)autoAdjustTopAndBottomBlank
{
    _autoAdjustTopAndBottomBlank = autoAdjustTopAndBottomBlank;
    [self.view setNeedsLayout];
}

#pragma mark - layout
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGFloat width = self.view.frame.size.width;
    
    //自动调整上下位置
    CGFloat navigationBarBottomOriginY = 0.0f;
    CGFloat tabBarOccupyHeight = 0.0f;
    
    if (self.autoAdjustTopAndBottomBlank) {
        if (self.navigationController&&!self.navigationController.navigationBar.translucent) {
            navigationBarBottomOriginY = 0.0f;
        }else{
            navigationBarBottomOriginY += [UIApplication sharedApplication].statusBarHidden?0.0f:20.0f;
            if (self.navigationController) {
                if (!self.navigationController.navigationBarHidden) {
                    navigationBarBottomOriginY += self.navigationController.navigationBar.intrinsicContentSize.height;
                }
            }
        }
        if (self.tabBarController&&self.tabBarController.tabBar.translucent&&!self.hidesBottomBarWhenPushed) {
            tabBarOccupyHeight += self.tabBarController.tabBar.intrinsicContentSize.height;
        }
    }
    
    CGFloat baseY = navigationBarBottomOriginY;
    self.scrollMenuView.frame = CGRectMake(0, baseY, width, kDefaultMLScrollMenuViewHeight);
    baseY+=kDefaultMLScrollMenuViewHeight;
    self.scrollView.frame = CGRectMake(0, baseY, width, self.view.frame.size.height-tabBarOccupyHeight-baseY);
    
    //设置其contentSize
    self.scrollView.contentSize = CGSizeMake(width*self.viewControllers.count, self.scrollView.frame.size.height);
    
    //设置子view的frame
    for (int i = 0; i < self.viewControllers.count; i++) {
        UIViewController *vc = self.viewControllers[i];
        vc.view.frame = CGRectMake(i*width, 0, width, self.scrollView.frame.size.height);
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
        //直接点击过来的和手动拖的完全分隔开，不用一回事
        NSInteger oldCurrentIndex = floor(self.scrollView.contentOffset.x / self.scrollView.frame.size.width);
        if (oldCurrentIndex==currentIndex) {
            return;
        }
        
        if (!self.dontScrollWhenDirectClickMenu) {
            self.dontChangeDisplayMenuView = YES;
            [self.scrollView setContentOffset:CGPointMake(currentIndex * self.scrollView.frame.size.width, 0) animated:YES];
            return;
        }
        
        //以前的disappear，新的appear
        UIViewController *oldCurrentVC = self.viewControllers[oldCurrentIndex];
        UIViewController *newCurrentVC = self.viewControllers[currentIndex];
        
        [oldCurrentVC willMoveToParentViewController:nil];
        [oldCurrentVC beginAppearanceTransition:NO animated:NO];
        [self setLastAppearanceTransition:NO forViewController:oldCurrentVC];
        
        [self addChildViewController:newCurrentVC];
        if (![newCurrentVC.view.superview isEqual:self.scrollView]) {
            [newCurrentVC.view removeFromSuperview];
            [self.scrollView addSubview:newCurrentVC.view];
        }
        [newCurrentVC beginAppearanceTransition:YES animated:NO];
        
        //不让触发scrollViewDidScroll
        self.scrollView.delegate = nil;
        self.scrollView.contentOffset = CGPointMake(currentIndex * self.scrollView.frame.size.width, 0);
        self.scrollView.delegate = self;
        
        [newCurrentVC endAppearanceTransition];
        [newCurrentVC didMoveToParentViewController:self];
        
        for (UIViewController *vc in self.childViewControllers) {
            if ([vc isEqual:newCurrentVC]) {
                continue;
            }
            if ([vc.view.superview isEqual:self.scrollView]) {
                if ([self lastAppearanceTransitionForViewController:vc]) {
                    [vc beginAppearanceTransition:NO animated:NO];
                    [self setLastAppearanceTransition:NO forViewController:vc];
                }
                [vc.view removeFromSuperview];
                [vc removeFromParentViewController];
                [vc endAppearanceTransition];
            }
        }
    }
}

#pragma mark - scrollView delegate
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
    
    if (!self.dontChangeDisplayMenuView) {
        [self.scrollMenuView displayFromIndex:leftIndex toIndex:rightIndex ratio:fabs(leftToRightRatio)];
    }
    
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
        if (![targetVC.view.superview isEqual:self.scrollView]) {
            [targetVC.view removeFromSuperview];
            [self.scrollView addSubview:targetVC.view];
        }
        [targetVC beginAppearanceTransition:YES animated:YES];
        [self setLastAppearanceTransition:YES forViewController:targetVC];
        
        //将要remove
        [currentVC willMoveToParentViewController:nil];
        [currentVC beginAppearanceTransition:NO animated:YES];
        [self setLastAppearanceTransition:NO forViewController:currentVC];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger currentIndex = floor(scrollView.contentOffset.x / scrollView.frame.size.width);
    if (currentIndex<0||currentIndex>self.viewControllers.count-1) {
        return;
    }
    
    self.ignoreSetCurrentIndex = YES;
    [self.scrollMenuView setCurrentIndex:currentIndex animated:YES];
    self.ignoreSetCurrentIndex = NO;
    
    if (self.childViewControllers.count>1) { //这个是用于边界无效拖动时候过滤
        UIViewController *currentVC = self.viewControllers[currentIndex];
        if (![self lastAppearanceTransitionForViewController:currentVC]) {
            [currentVC beginAppearanceTransition:YES animated:YES];
            [self setLastAppearanceTransition:YES forViewController:currentVC];
        }
        
        [currentVC endAppearanceTransition];
        [currentVC didMoveToParentViewController:self];
        
        for (UIViewController *vc in self.childViewControllers) {
            if ([vc isEqual:currentVC]) {
                continue;
            }
            if ([vc.view.superview isEqual:self.scrollView]) {
                if ([self lastAppearanceTransitionForViewController:vc]) {
                    [vc beginAppearanceTransition:NO animated:YES];
                    [self setLastAppearanceTransition:NO forViewController:vc];
                }
                [vc.view removeFromSuperview];
                [vc removeFromParentViewController];
                [vc endAppearanceTransition];
            }
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.dontChangeDisplayMenuView = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self scrollViewDidEndDecelerating:scrollView];
}

#pragma mark - helper
//出发didappear和diddisappear
- (BOOL)lastAppearanceTransitionForViewController:(UIViewController*)vc
{
    NSString *pointerString = [NSString stringWithFormat:@"%p",vc];
    return [self.viewControllerAppearanceTransitionMap[pointerString] boolValue];
}

- (void)setLastAppearanceTransition:(BOOL)appearanceTransition forViewController:(UIViewController*)vc
{
    NSString *pointerString = [NSString stringWithFormat:@"%p",vc];
    self.viewControllerAppearanceTransitionMap[pointerString] = @(appearanceTransition);
}
@end
