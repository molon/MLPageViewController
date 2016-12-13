//
//  AppDelegate.m
//  MLPageViewController
//
//  Created by molon on 15/8/6.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import "AppDelegate.h"
#import "TempViewController.h"
#import "TempPageViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i=0; i<5; i++) {
        TempViewController *temp = [TempViewController new];
        temp.title = [NSString stringWithFormat:@"%ld月",i];
        [array addObject:temp];
    }
    
//    TempViewController *temp = [TempViewController new];
//    temp.title = @"0月";
//    [array addObject:temp];
//    
//    TempViewController *temp1 = [TempViewController new];
//    temp1.title = @"天南海北喵喵喵喵喵";
//    [array addObject:temp1];
//    
//    TempViewController *temp2 = [TempViewController new];
//    temp2.title = @"2月";
//    [array addObject:temp2];
    
    TempPageViewController *pageViewController = [[TempPageViewController alloc]initWithViewControllers:array];
    [pageViewController setDidChangeCurrentIndexBlock:^(NSInteger fromIndex, NSInteger toIndex, MLPageViewController *vc) {
        NSLog(@"change currentindex from %ld to:%ld ",fromIndex,toIndex);
    }];
    
    self.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:pageViewController];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
