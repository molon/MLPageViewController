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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"test" style:UIBarButtonItemStylePlain target:self action:@selector(test)];
    
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
