//
//  TempPageViewController.m
//  MLPageViewController
//
//  Created by molon on 16/5/23.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "TempPageViewController.h"
#import "TempViewController.h"

@interface TempPageViewController ()

@end

@implementation TempPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.dontScrollWhenDirectClickMenu = YES;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"test" style:UIBarButtonItemStylePlain target:self action:@selector(test)];
    
    self.scrollMenuView.titleColor = [UIColor colorWithWhite:0.529 alpha:1.000];
    self.scrollMenuView.currentTitleColor = [UIColor colorWithRed:0.094 green:0.498 blue:0.941 alpha:1.000];
    self.scrollMenuView.currentIndicatorColor = self.scrollMenuView.currentTitleColor;
    self.scrollMenuView.indicatorBackgroundColor = [UIColor colorWithWhite:0.675 alpha:1.000];
    self.scrollMenuView.backgroundColor = [UIColor whiteColor];
    self.scrollMenuView.currentIndicatorViewXPadding = 160.5f;
    
    //test setting the init index
    [self setCurrentIndex:2 animated:NO];
}

- (void)test
{
    //test change page manually
    [self setCurrentIndex:1 animated:YES];
}

- (CGFloat)configureScrollMenuViewHeight {
    return 47.0f;
}
@end
