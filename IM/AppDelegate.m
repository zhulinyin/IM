//
//  AppDelegate.m
//  IM
//
//  Created by zhulinyin on 2019/4/22.
//  Copyright © 2019 zhulinyin. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tryLogin:) name:@"tryLogin" object:nil];

    [[UserManager getInstance] tryLogin];
    return YES;
}

- (void)tryLogin:(NSNotification *)notification{
    NSString *result = [notification object];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    if ([result isEqualToString:@"success"]) {
        //storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

        UITabBarController *tb = [[UITabBarController alloc] init];

        UIStoryboard *messageSB = [UIStoryboard storyboardWithName:@"MessagePage" bundle:nil];
        UIStoryboard *contactSB = [UIStoryboard storyboardWithName:@"ContactPage" bundle:nil];
        UIStoryboard *infoSB = [UIStoryboard storyboardWithName:@"Info" bundle:nil];
        
        UINavigationController *messageNav = [messageSB instantiateInitialViewController];
        UIViewController *messageVc = messageNav.topViewController;
        messageVc.tabBarItem.title = @"消息";
        messageVc.tabBarItem.image = [UIImage imageNamed:@"xiaoxi"];
        
        UINavigationController *contactNav = [contactSB instantiateInitialViewController];
        UIViewController *contactVc = contactNav.topViewController;
        contactVc.tabBarItem.title = @"联系人";
        contactVc.tabBarItem.image = [UIImage imageNamed:@"tongxunlu"];
        
        UINavigationController *infoNav = [infoSB instantiateInitialViewController];
        UIViewController *infoVc = infoNav.topViewController;
        infoVc.tabBarItem.title = @"个人信息";
        infoVc.tabBarItem.image = [UIImage imageNamed:@"wode"];
        
        tb.viewControllers = @[messageNav, contactNav, infoNav];
        
        self.window.rootViewController = tb;
    }
    else {
        self.window.rootViewController = [[UIStoryboard storyboardWithName:@"Index" bundle:nil] instantiateInitialViewController];
    }
    [self.window makeKeyAndVisible];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[UserManager getInstance] logout];
}


@end
