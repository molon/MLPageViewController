//
//  TempPageViewController.m
//  MLPageViewController
//
//  Created by molon on 16/5/23.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "TempPageViewController.h"
#import "TempViewController.h"
#import <MLScrollMenuView.h>

@interface TempPageViewController ()

@end

@implementation TempPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.dontScrollWhenDirectClickMenu = YES;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"test" style:UIBarButtonItemStylePlain target:self action:@selector(test)];
    
    
    self.scrollMenuView.titleColor = [UIColor blackColor];
    self.scrollMenuView.currentTitleColor = [UIColor colorWithRed:0.996 green:0.918 blue:0.039 alpha:1.000];
    self.scrollMenuView.indicatorColor = self.scrollMenuView.currentTitleColor;
    self.scrollMenuView.indicatorBackgroundColor = [UIColor colorWithWhite:0.675 alpha:1.000];
    self.scrollMenuView.backgroundColor = [UIColor colorWithRed:1.000 green:0.330 blue:0.394 alpha:1.000];
    
    [self setCurrentIndex:5 animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)test
{
    [self setCurrentIndex:3 animated:YES];
}

@end
