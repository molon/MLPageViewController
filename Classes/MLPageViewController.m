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

typedef NS_ENUM(NSUInteger, _MLPageAppearanceTransition) {
    _MLPageAppearanceTransitionNO = 0,
    _MLPageAppearanceTransitionYES,
    _MLPageAppearanceTransitionDone,
};

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
    
    CGFloat _scrollMenuViewHeight;
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
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _autoAdjustTopAndBottomBlank = YES;
    _lastCurrentIndex = UndefinedPageIndexForMLPageViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //内部可能需要参考self.view的frame，所以还是丢在这
    _scrollMenuViewHeight = [self configureScrollMenuViewHeight];
    
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
        _scrollMenuView = [[MLScrollMenuView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, _scrollMenuViewHeight)];
        _scrollMenuView.delegate = self;
    }
    return _scrollMenuView;
}

- (_MLPageScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[_MLPageScrollView alloc]initWithFrame:CGRectMake(0, _scrollMenuViewHeight, self.view.frame.size.width, self.view.frame.size.height-_scrollMenuViewHeight)];
        _scrollView.scrollsToTop = NO;
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.directionalLockEnabled = YES;
        //TODO: iOS7下 下拉不是太好用，以后需要优化下，现在先禁掉
        if ([UIDevice currentDevice].systemVersion.doubleValue<8.0f) {
            _scrollView.scrollEnabled = NO;
        }
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
    
    [self changeScrollViewFrameTo:CGRectMake(0, baseY, width, self.view.frame.size.height-tabBarOccupyHeight-baseY)];
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

- (void)didChangeCurrentIndexFrom:(NSInteger)oldIndex to:(NSInteger)targetIndex animated:(BOOL)animated scrollMenuView:(MLScrollMenuView *)scrollMenuView
{
    if (!_ignoreSetCurrentIndex) {
        //直接点击过来的和手动拖的完全分隔开，不用一回事
        NSInteger currentIndex = floor(self.scrollView.contentOffset.x / self.scrollView.frame.size.width);
        
        //没window时候还没显示，不需要滚动过去，直接跳过去即可
        if (!self.dontScrollWhenDirectClickMenu&&animated&&self.view.window) {
            _dontChangeDisplayMenuView = YES;
            self.scrollView.userInteractionEnabled = NO;
            [self.scrollView setContentOffset:CGPointMake(targetIndex * self.scrollView.frame.size.width, 0) animated:YES];
            return;
        }
        
        //以前的disappear，新的appear
        UIViewController *currentVC = self.viewControllers[currentIndex];
        UIViewController *targetVC = self.viewControllers[targetIndex];
        
        [currentVC willMoveToParentViewController:nil];
        [self beginAppearanceTransition:NO animated:NO forViewController:currentVC];
        
        [self addChildViewController:targetVC];
        if (![targetVC.view.superview isEqual:self.scrollView]) {
            [targetVC.view removeFromSuperview];
            [self.scrollView addSubview:targetVC.view];
        }
        [self beginAppearanceTransition:YES animated:NO forViewController:targetVC];
        
        //只改变contentOffset
        self.scrollView.delegate = nil;
        [self.scrollView setContentOffset:CGPointMake(targetIndex * self.scrollView.frame.size.width, 0)];
        self.scrollView.delegate = self;
        
        [self endAppearanceTransitionForViewController:targetVC];
        [targetVC didMoveToParentViewController:self];
        
        for (UIViewController *vc in self.childViewControllers) {
            if ([vc isEqual:targetVC]) {
                continue;
            }
            if ([vc.view.superview isEqual:self.scrollView]) {
                if ([self lastAppearanceTransitionForViewController:vc]==_MLPageAppearanceTransitionYES) {
                    [self beginAppearanceTransition:NO animated:NO forViewController:vc];
                }
                [vc.view removeFromSuperview];
                [vc removeFromParentViewController];
                [self endAppearanceTransitionForViewController:vc];
            }
        }
        
        [self updateCurrentIndexTo:targetIndex];
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
    BOOL isScrollToLeft = _lastContentOffsetX<scrollView.contentOffset.x;
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
    NSInteger targetIndex = isScrollToLeft?rightIndex:leftIndex;
    NSInteger currentIndex = isScrollToLeft?leftIndex:rightIndex;
    
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
                [self endAppearanceTransitionForViewController:vc];
            }
        }
        
        //将要remove
        [currentVC willMoveToParentViewController:nil];
        [self beginAppearanceTransition:NO animated:YES forViewController:currentVC];
        
        //将要add
        [self addChildViewController:targetVC];
        if (![targetVC.view.superview isEqual:self.scrollView]) {
            [targetVC.view removeFromSuperview];
            [self.scrollView addSubview:targetVC.view];
        }
        [self beginAppearanceTransition:YES animated:YES forViewController:targetVC];
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
    _dontChangeDisplayMenuView = NO;
    
    NSInteger currentIndex = floor(scrollView.contentOffset.x / scrollView.frame.size.width);
    if (currentIndex<0||currentIndex>self.viewControllers.count-1) {
        return;
    }
    
    UIViewController *currentVC = self.viewControllers[currentIndex];
    
    //如果没有前置行为，这里的当然也就无效了
    if ([self lastAppearanceTransitionForViewController:currentVC]==_MLPageAppearanceTransitionDone) {
        return;
    }
    if (_lastCurrentIndex==currentIndex) {
        //保证在边界index时做无用拖动时候不处理
        if(currentIndex==0||currentIndex==self.viewControllers.count-1) {
            return;
        }
    }
    
    //设置当前index
    _ignoreSetCurrentIndex = YES;
    [self.scrollMenuView setCurrentIndex:currentIndex animated:YES];
    _ignoreSetCurrentIndex = NO;
    
    //有可能之前是willDisappear状态
    if ([self lastAppearanceTransitionForViewController:currentVC]==_MLPageAppearanceTransitionNO) {
        [self beginAppearanceTransition:YES animated:YES forViewController:currentVC];
    }
    [self endAppearanceTransitionForViewController:currentVC];
    [currentVC didMoveToParentViewController:self];
    
    for (UIViewController *vc in self.childViewControllers) {
        if ([vc isEqual:currentVC]) {
            continue;
        }
        if ([vc.view.superview isEqual:self.scrollView]) {
            if ([self lastAppearanceTransitionForViewController:vc]==_MLPageAppearanceTransitionYES) {
                [self beginAppearanceTransition:NO animated:YES forViewController:vc];
            }
            [vc.view removeFromSuperview];
            [vc removeFromParentViewController];
            [self endAppearanceTransitionForViewController:vc];
        }
    }
    
    [self updateCurrentIndexTo:currentIndex];
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
- (void)beginAppearanceTransition:(BOOL)isAppearing animated:(BOOL)animated forViewController:(UIViewController*)vc {
    if (!self.view.window) {
        return;
    }
    [vc beginAppearanceTransition:isAppearing animated:animated];
    [self setLastAppearanceTransition:isAppearing?_MLPageAppearanceTransitionYES:_MLPageAppearanceTransitionNO forViewController:vc];
}

- (void)endAppearanceTransitionForViewController:(UIViewController*)vc {
    if (!self.view.window) {
        return;
    }
    [vc endAppearanceTransition];
    [self setLastAppearanceTransition:_MLPageAppearanceTransitionDone forViewController:vc];
}

- (_MLPageAppearanceTransition)lastAppearanceTransitionForViewController:(UIViewController*)vc
{
    NSString *pointerString = [NSString stringWithFormat:@"%p",vc];
    id value = _viewControllerAppearanceTransitionMap[pointerString];
    if (!value) {
        return _MLPageAppearanceTransitionDone;
    }
    return [value integerValue];
}

- (void)setLastAppearanceTransition:(_MLPageAppearanceTransition)appearanceTransition forViewController:(UIViewController*)vc
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

- (void)changeScrollViewFrameTo:(CGRect)frame
{
    //此时目的仅仅是修正下位置罢了
    self.scrollView.delegate = nil;
    
    CGRect oldFrame = self.scrollView.frame;
    
    self.scrollView.frame = frame;
    
    if (!CGSizeEqualToSize(frame.size, oldFrame.size)) {
        CGFloat width = frame.size.width;
        
        //设置其contentSize
        self.scrollView.contentSize = CGSizeMake(width*self.viewControllers.count, self.scrollView.frame.size.height);
        
        //这里contentOffset可能会被重置到其他位置，所以需要修正一下到当前currentIndex
        [self.scrollView setContentOffset:CGPointMake(self.scrollMenuView.currentIndex*self.scrollView.frame.size.width,0)];
        
        //设置子view的frame
        for (int i = 0; i < self.viewControllers.count; i++) {
            UIViewController *vc = self.viewControllers[i];
            vc.view.frame = CGRectMake(i*width, 0, width, self.scrollView.frame.size.height);
        }
    }
    
    self.scrollView.delegate = self;
}

#pragma mark - for orverride
- (CGFloat)configureScrollMenuViewHeight {
    return DefaultMLScrollMenuViewHeightForMLPageViewController;
}

#pragma mark - container view controller
- (BOOL)shouldAutomaticallyForwardAppearanceMethods{
    return NO;
}

- (BOOL)shouldAutomaticallyForwardRotationMethods{
    return NO;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSArray *viewControllers = [self childViewControllersWithAppearanceCallbackAutoForward];
    for (UIViewController *viewController in viewControllers) {
        [viewController beginAppearanceTransition:YES animated:animated];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    NSArray *viewControllers = [self childViewControllersWithAppearanceCallbackAutoForward];
    for (UIViewController *viewController in viewControllers) {
        [viewController endAppearanceTransition];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    NSArray *viewControllers = [self childViewControllersWithAppearanceCallbackAutoForward];
    for (UIViewController *viewController in viewControllers) {
        [viewController beginAppearanceTransition:NO animated:animated];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    NSArray *viewControllers = [self childViewControllersWithAppearanceCallbackAutoForward];
    for (UIViewController *viewController in viewControllers) {
        [viewController endAppearanceTransition];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    NSArray *viewControllers = [self childViewControllersWithRotationCallbackAutoForward];
    for (UIViewController *viewController in viewControllers) {
        [viewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    NSArray *viewControllers = [self childViewControllersWithRotationCallbackAutoForward];
    for (UIViewController *viewController in viewControllers) {
        [viewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    NSArray *viewControllers = [self childViewControllersWithRotationCallbackAutoForward];
    for (UIViewController *viewController in viewControllers) {
        [viewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    }
}

- (BOOL)shouldAutorotate{
    NSArray *viewControllers = [self childViewControllersWithRotationCallbackAutoForward];
    BOOL shouldAutorotate = YES;
    for (UIViewController *viewController in viewControllers) {
        shouldAutorotate = shouldAutorotate &&  [viewController shouldAutorotate];
    }
    
    return shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    NSUInteger supportedInterfaceOrientations = UIInterfaceOrientationMaskAll;
    
    NSArray *viewControllers = [self childViewControllersWithRotationCallbackAutoForward];
    for (UIViewController *viewController in viewControllers) {
        supportedInterfaceOrientations = supportedInterfaceOrientations & [viewController supportedInterfaceOrientations];
    }
    
    return supportedInterfaceOrientations;
}

- (NSArray *)childViewControllersWithAppearanceCallbackAutoForward{
    return self.childViewControllers;
}

- (NSArray *)childViewControllersWithRotationCallbackAutoForward{
    return self.childViewControllers;
}

@end
