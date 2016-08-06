//
//  MLPageViewController.m
//  MLPageViewController
//
//  Created by molon on 15/8/7.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import "MLPageViewController.h"

CGFloat const DefaultMLScrollMenuViewHeightForMLPageViewController = 40.0f;
NSInteger const UndefinedPageIndexForMLPageViewController = -1;

@interface _MLPageScrollView : UIScrollView

@end

@implementation _MLPageScrollView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer isEqual:self.panGestureRecognizer]) {
        if (![otherGestureRecognizer.view isEqual:self]&&[otherGestureRecognizer.view isKindOfClass:[UIScrollView class]]) {
            //如果另外的scrollView是当前scrollView的子级
            if ([otherGestureRecognizer.view isDescendantOfView:self]) {
                UIScrollView *scrollView = (UIScrollView*)otherGestureRecognizer.view;
                //判断scrollView是否横向滚动的
                if (CGAffineTransformEqualToTransform(CGAffineTransformMakeRotation(-M_PI*0.5),scrollView.transform)||CGAffineTransformEqualToTransform(CGAffineTransformMakeRotation(M_PI*0.5),scrollView.transform)) {
                    return YES;
                }
                
                if (scrollView.contentSize.width>scrollView.frame.size.width) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

@end

@interface MLPageViewController ()<MLScrollMenuViewDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) MLScrollMenuView *scrollMenuView;
@property (nonatomic, strong) _MLPageScrollView *scrollView;
@property (nonatomic, strong) NSArray *viewControllers;

@end

@implementation MLPageViewController
{
    NSInteger _lastCurrentIndex;
    CGFloat _lastContentOffsetX;
    BOOL _ignoreSetCurrentIndex;
    BOOL _dontChangeDisplayMenuView;
    NSMutableDictionary *_viewControllerAppearanceTransitionMap;
}

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
    _lastCurrentIndex = UndefinedPageIndexForMLPageViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.view addSubview:self.scrollMenuView];
    [self.view addSubview:self.scrollView];
    
    //直接让子vc viewdidload,对性能有点好处
    for (int i = 0; i < self.viewControllers.count; i++) {
        UIViewController *vc = self.viewControllers[i];
        [vc performSelector:@selector(view) withObject:nil];
        [vc.view setNeedsLayout];
        [vc.view layoutIfNeeded];
    }
    
    //直接add第一个,至于其viewWillAppear和didAppear啥的会随着container vc传递下去
    if (self.viewControllers.count>0) {
        UIViewController *vc = [self.viewControllers firstObject];
        [self addChildViewController:vc];
        [self.scrollView addSubview:vc.view];
        [vc didMoveToParentViewController:self];
    
        _lastCurrentIndex = 0;
    }
}

#pragma mark - getter
- (MLScrollMenuView *)scrollMenuView
{
    if (!_scrollMenuView) {
        _scrollMenuView = [[MLScrollMenuView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, DefaultMLScrollMenuViewHeightForMLPageViewController)];
        _scrollMenuView.delegate = self;
    }
    return _scrollMenuView;
}

- (_MLPageScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[_MLPageScrollView alloc]initWithFrame:CGRectMake(0, DefaultMLScrollMenuViewHeightForMLPageViewController, self.view.frame.size.width, self.view.frame.size.height-DefaultMLScrollMenuViewHeightForMLPageViewController)];
        _scrollView.scrollsToTop = NO;
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.directionalLockEnabled = YES;
    }
    return _scrollView;
}

- (NSInteger)currentIndex
{
    return self.scrollMenuView.currentIndex;
}

- (UIViewController*)currentViewController
{
    if (self.scrollMenuView.currentIndex>=0&&self.scrollMenuView.currentIndex<self.viewControllers.count) {
        return self.viewControllers[self.scrollMenuView.currentIndex];
    }
    return nil;
}

#pragma mark - setter
- (void)setViewControllers:(NSArray *)viewControllers
{
    _viewControllers = viewControllers;
    
    _viewControllerAppearanceTransitionMap = [NSMutableDictionary dictionaryWithCapacity:viewControllers.count];
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
    self.scrollMenuView.frame = CGRectMake(0, baseY, width, self.scrollMenuView.frame.size.height);
    
    baseY+=self.scrollMenuView.frame.size.height;
    self.scrollView.frame = CGRectMake(0, baseY, width, self.view.frame.size.height-tabBarOccupyHeight-baseY);
    
    //这里contentOffset可能会被重置到其他位置，所以需要修正一下到当前currentIndex
    self.scrollView.contentOffset = CGPointMake(self.scrollMenuView.currentIndex*self.scrollView.frame.size.width,0);
    
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
    return ((UIViewController*)self.viewControllers[index]).title;
}

- (void)didChangeCurrentIndexFrom:(NSInteger)oldIndex to:(NSInteger)currentIndex animated:(BOOL)animated scrollMenuView:(MLScrollMenuView *)scrollMenuView
{
    if (!_ignoreSetCurrentIndex) {
        //直接点击过来的和手动拖的完全分隔开，不用一回事
        NSInteger oldCurrentIndex = floor(self.scrollView.contentOffset.x / self.scrollView.frame.size.width);
        
        if (!self.dontScrollWhenDirectClickMenu&&animated&&self.view.window) {
            _dontChangeDisplayMenuView = YES;
            self.scrollView.userInteractionEnabled = NO;
            [self.scrollView setContentOffset:CGPointMake(currentIndex * self.scrollView.frame.size.width, 0) animated:YES];
            return;
        }
        
        //以前的disappear，新的appear
        UIViewController *oldCurrentVC = self.viewControllers[oldCurrentIndex];
        UIViewController *newCurrentVC = self.viewControllers[currentIndex];
        
        [oldCurrentVC willMoveToParentViewController:nil];
        
        if (self.view.window) {
            [oldCurrentVC beginAppearanceTransition:NO animated:NO];
            [self setLastAppearanceTransition:NO forViewController:oldCurrentVC];
        }
        
        [self addChildViewController:newCurrentVC];
        if (![newCurrentVC.view.superview isEqual:self.scrollView]) {
            [newCurrentVC.view removeFromSuperview];
            [self.scrollView addSubview:newCurrentVC.view];
        }
        if (self.view.window) {
            [newCurrentVC beginAppearanceTransition:YES animated:NO];
        }
        
        //不让触发scrollViewDidScroll
        self.scrollView.delegate = nil;
        self.scrollView.contentOffset = CGPointMake(currentIndex * self.scrollView.frame.size.width, 0);
        self.scrollView.delegate = self;
        
        if (self.view.window) {
            [newCurrentVC endAppearanceTransition];
        }
        [newCurrentVC didMoveToParentViewController:self];
        
        for (UIViewController *vc in self.childViewControllers) {
            if ([vc isEqual:newCurrentVC]) {
                continue;
            }
            if ([vc.view.superview isEqual:self.scrollView]) {
                if (self.view.window) {
                    if ([self lastAppearanceTransitionForViewController:vc]) {
                        [vc beginAppearanceTransition:NO animated:NO];
                        [self setLastAppearanceTransition:NO forViewController:vc];
                    }
                }
                [vc.view removeFromSuperview];
                [vc removeFromParentViewController];
                if (self.view.window) {
                    [vc endAppearanceTransition];
                }
            }
        }
        
        [self updateCurrentIndexTo:currentIndex];
    }
}

- (BOOL)shouldChangeCurrentIndexFrom:(NSInteger)oldIndex to:(NSInteger)toIndex scrollMenuView:(MLScrollMenuView*)scrollMenuView
{
    return !(self.scrollView.dragging);
}

#pragma mark - scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_lastContentOffsetX==scrollView.contentOffset.x) {return;}
    BOOL isScrollToRight = _lastContentOffsetX<scrollView.contentOffset.x;
    _lastContentOffsetX = scrollView.contentOffset.x;
    
    NSInteger leftIndex = floor(scrollView.contentOffset.x / scrollView.frame.size.width);
    if (leftIndex<0||leftIndex+1>self.viewControllers.count-1) {
        return;
    }
    NSInteger rightIndex = leftIndex+1;
    CGFloat leftToRightRatio = (scrollView.contentOffset.x - leftIndex * scrollView.frame.size.width) / scrollView.frame.size.width;
    
    if (!_dontChangeDisplayMenuView) {
        [self.scrollMenuView displayFromIndex:leftIndex toIndex:rightIndex ratio:fabs(leftToRightRatio)];
    }
    
    //如果为0说明实际上已经处于绝对的某页面了，这时候就不应该去处理vc will appear or disappear 状态了。而应该交给scrollViewDidEndDecelerating去处理did appear和dod disappear
    
    //如果若在某种异常情况下，leftToRightRatio直接就到了目标位置，而没有中间contentOffset变化的过程的话，就会产生目标VC没有被add的情况，scrollViewDidEndDecelerating也会啥都没做了。但这种情况正常情况下不可能遇到的。
    if (leftToRightRatio==0.0f) {
        return;
    }
    
    //处理view appear
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
                if (self.view.window) {
                    [vc endAppearanceTransition];
                }
            }
        }
        
        //将要remove
        [currentVC willMoveToParentViewController:nil];
        if (self.view.window) {
            [currentVC beginAppearanceTransition:NO animated:YES];
            [self setLastAppearanceTransition:NO forViewController:currentVC];
        }
        
        //将要add
        [self addChildViewController:targetVC];
        if (![targetVC.view.superview isEqual:self.scrollView]) {
            [targetVC.view removeFromSuperview];
            [self.scrollView addSubview:targetVC.view];
        }
        if (self.view.window) {
            [targetVC beginAppearanceTransition:YES animated:YES];
            [self setLastAppearanceTransition:YES forViewController:targetVC];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (!self.scrollView.userInteractionEnabled) {
        self.scrollView.userInteractionEnabled = YES;
    }
    if (!self.scrollMenuView.userInteractionEnabled) {
        self.scrollMenuView.userInteractionEnabled = YES;
    }
    
    NSInteger currentIndex = floor(scrollView.contentOffset.x / scrollView.frame.size.width);
    if (currentIndex<0||currentIndex>self.viewControllers.count-1) {
        return;
    }
    
    _ignoreSetCurrentIndex = YES;
    [self.scrollMenuView setCurrentIndex:currentIndex animated:YES];
    _ignoreSetCurrentIndex = NO;
    
    if (self.childViewControllers.count>1) { //这个是判断当前是否在边界往无VC的方向做无效拖动的时候
        UIViewController *currentVC = self.viewControllers[currentIndex];
        
        if (self.view.window) {
            if (![self lastAppearanceTransitionForViewController:currentVC]) {
                [currentVC beginAppearanceTransition:YES animated:YES];
                [self setLastAppearanceTransition:YES forViewController:currentVC];
            }
        }
        
        if (self.view.window) {
            [currentVC endAppearanceTransition];
        }
        
        [currentVC didMoveToParentViewController:self];
        
        for (UIViewController *vc in self.childViewControllers) {
            if ([vc isEqual:currentVC]) {
                continue;
            }
            if ([vc.view.superview isEqual:self.scrollView]) {
                
                if (self.view.window) {
                    if ([self lastAppearanceTransitionForViewController:vc]) {
                        [vc beginAppearanceTransition:NO animated:YES];
                        [self setLastAppearanceTransition:NO forViewController:vc];
                    }
                }
                
                [vc.view removeFromSuperview];
                [vc removeFromParentViewController];
                
                if (self.view.window) {
                    [vc endAppearanceTransition];
                }
            }
        }
        
        [self updateCurrentIndexTo:currentIndex];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _dontChangeDisplayMenuView = NO;
    self.scrollMenuView.userInteractionEnabled = NO;
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
    return [_viewControllerAppearanceTransitionMap[pointerString] boolValue];
}

- (void)setLastAppearanceTransition:(BOOL)appearanceTransition forViewController:(UIViewController*)vc
{
    NSString *pointerString = [NSString stringWithFormat:@"%p",vc];
    _viewControllerAppearanceTransitionMap[pointerString] = @(appearanceTransition);
}

- (void)updateCurrentIndexTo:(NSInteger)currentIndex
{
    NSInteger oldIndex = _lastCurrentIndex;
    if (oldIndex==currentIndex) {
        return;
    }
    _lastCurrentIndex = currentIndex;
    
    if (self.didChangeCurrentIndexBlock) {
        self.didChangeCurrentIndexBlock(oldIndex,currentIndex,self);
    }
}

#pragma mark - outcall
- (void)setCurrentIndex:(NSInteger)currentIndex animated:(BOOL)animated
{
    //没显示出来时候压根不需要animated
    if (!self.view.window) {
        animated = NO;
    }
    [self.scrollMenuView setCurrentIndex:currentIndex animated:animated];
}
@end
