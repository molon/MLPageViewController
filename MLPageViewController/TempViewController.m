//
//  TempViewController.m
//  MLPageViewController
//
//  Created by molon on 15/8/7.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import "TempViewController.h"
#import "MLKitDebug.h"
@interface TempViewController ()

@property (nonatomic, strong) UILabel *label;

@end

@implementation TempViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.label];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    MARK
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    MARK
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    MARK
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    MARK
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

#pragma mark - setter
- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    self.label.text = title;
}

#pragma mark - layout
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.label.frame = CGRectMake(0, 0, 100, 50);
    self.label.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
}
@end
