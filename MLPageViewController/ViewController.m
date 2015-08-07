//
//  ViewController.m
//  MLPageViewController
//
//  Created by molon on 15/8/6.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import "ViewController.h"
#import "MLScrollMenuView.h"

@interface ViewController ()<MLScrollMenuViewDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) MLScrollMenuView *scrollMenuView;

@property (nonatomic, strong) UIButton *button;

@property (nonatomic, strong) NSArray *titles;

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor colorWithWhite:0.804 alpha:1.000];
    
    [self.view addSubview:self.button];
    
    self.titles = @[@"大杂烩",@"鞋服配饰",@"母婴",@"奢侈品",@"家居日用",@"数码电子",@"影音家电",@"交通工具",@"萌宠"];
    [self.view addSubview:self.scrollMenuView];
    
    [self.view addSubview:self.scrollView];
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
        _scrollMenuView.backgroundColor = [UIColor colorWithRed:0.996 green:1.000 blue:1.000 alpha:1.000];
        _scrollMenuView.delegate = self;
    }
    return _scrollMenuView;
}


- (UIButton *)button
{
    if (!_button) {
        UIButton *button = [[UIButton alloc]init];
        [button setTitle:@"测试" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
        
        _button = button;
    }
    return _button;
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [UIScrollView new];
        _scrollView.contentSize = CGSizeMake(self.view.frame.size.width*self.titles.count, 300);
        _scrollView.pagingEnabled = YES;
        _scrollView.backgroundColor = [UIColor colorWithRed:0.772 green:0.771 blue:0.000 alpha:1.000];
        _scrollView.delegate = self;
    }
    return _scrollView;
}

#pragma mark - layout
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
//    self.button.frame = CGRectMake(100, 300, 50, 30);
    
    self.scrollMenuView.frame = CGRectMake(0, 64, self.view.frame.size.width, 36.0f);
    
    self.scrollView.frame = CGRectMake(0, 100, self.view.frame.size.width, 300);
}

#pragma mark - event
- (void)click
{
    if (self.scrollMenuView.currentIndex==0) {
        [self.scrollMenuView setCurrentIndex:self.titles.count-1 animated:YES];
    }else{
        [self.scrollMenuView setCurrentIndex:self.scrollMenuView.currentIndex-1 animated:YES];
    }
}

#pragma mark - delegate
- (NSString*)titleForIndex:(NSInteger)index
{
    return self.titles[index];
}

- (NSInteger)titleCount
{
    return self.titles.count;
}



#pragma mark -- ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int scrollCurrentIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
    
    CGFloat oldPointX = scrollCurrentIndex * scrollView.frame.size.width;
    CGFloat ratio = (scrollView.contentOffset.x - oldPointX) / scrollView.frame.size.width;
    
    BOOL isToNextItem = (scrollView.contentOffset.x > oldPointX);
    NSInteger targetIndex = (isToNextItem) ? scrollCurrentIndex + 1 : scrollCurrentIndex - 1;
    [self.scrollMenuView displayForTargetIndex:targetIndex targetIsNext:isToNextItem ratio:fabs(ratio)];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int currentIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
    
    [self.scrollMenuView setCurrentIndex:currentIndex animated:YES];
}

@end
