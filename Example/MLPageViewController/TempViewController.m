//
//  TempViewController.m
//  MLPageViewController
//
//  Created by molon on 15/8/7.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import "TempViewController.h"

#define MARKTITLE    NSLog(@"\nTitle:%@ parent:%@ MARK: %s, %d",self.title,self.parentViewController, __PRETTY_FUNCTION__, __LINE__);
@interface TempViewController ()

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *button;

@end

@implementation TempViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:self.label];
    [self.view addSubview:self.button];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    MARKTITLE
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    MARKTITLE
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    MARKTITLE
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    MARKTITLE
    
}

#pragma mark - getter
- (UILabel *)label
{
    if (!_label) {
        UILabel* label = [[UILabel alloc]init];
        label.backgroundColor = [UIColor colorWithRed:1.000 green:0.475 blue:0.222 alpha:1.000];
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:24.0f];
        label.textAlignment = NSTextAlignmentCenter;
        
        _label = label;
    }
    return _label;
}

- (UIButton *)button
{
    if (!_button) {
        UIButton *button = [[UIButton alloc]init];
        button.backgroundColor = [UIColor colorWithRed:1.000 green:0.475 blue:0.222 alpha:1.000];
        [button setTitle:self.title forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
        
        _button = button;
    }
    return _button;
}


#pragma mark - setter
- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    self.label.text = title;
    [self.button  setTitle:self.title forState:UIControlStateNormal];
}

#pragma mark - layout
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.label.frame = CGRectMake(0, 0, 100, 50);
    self.label.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    
    self.button.frame = self.label.frame;
}

#pragma mark - event
- (void)click
{
    TempViewController *vc = [TempViewController new];
    vc.title = @"test";
    [self.navigationController pushViewController:vc animated:YES];
}
@end
