//
//  ViewController.m
//  MLPageViewController
//
//  Created by molon on 15/8/6.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import "ViewController.h"
#import "MLScrollMenuView.h"

@interface ViewController ()<MLScrollMenuViewDelegate>

@property (nonatomic, strong) MLScrollMenuView *scrollMenuView;

@property (nonatomic, strong) UIButton *button;

@property (nonatomic, strong) NSArray *titles;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor colorWithWhite:0.804 alpha:1.000];
    
//    [self.view addSubview:self.button];
    
    self.titles = @[@"大杂烩",@"鞋服配饰",@"母婴",@"奢侈品",@"家居日用",@"数码电子",@"影音家电",@"交通工具",@"萌宠"];
    [self.view addSubview:self.scrollMenuView];
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

#pragma mark - layout
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
//    
//    self.button.frame = CGRectMake(100, 300, 50, 30);
    
    self.scrollMenuView.frame = CGRectMake(0, 64, self.view.frame.size.width, 36.0f);
}


#pragma mark - event
- (void)click
{
    
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

@end
