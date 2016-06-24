//
//  AppDelegate.m
//  XMPPDemo
//
//  Created by Saheb Roy on 17/05/16.
//  Copyright © 2016 OrderOfTheLight. All rights reserved.
//

#import "AppDelegate.h"
#import "SRXMPP.h"
#import "CommonUtil.h"
#import "DDLog.h"
#import "DDTTYLogger.h"


#define DEBUG 1

#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [SRXMPP sharedInstance];
    [SRCoreData sharedInstance];
    Common_Manager.currentCode = kXMPPNormal;
    Common_Manager.currentChatDateFormat = k12Hour;
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}



- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store
    // enough application state information to restore your application to its current state in case
    // it is terminated later.
    //
    // If your application supports background execution,
    // called instead of applicationWillTerminate: when the user quits.
    
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
#if TARGET_IPHONE_SIMULATOR
    DDLogError(@"The iPhone simulator does not process background network traffic. "
               @"Inbound traffic is queued until the keepAliveTimeout:handler: fires.");
#endif
    
    if ([application respondsToSelector:@selector(setKeepAliveTimeout:handler:)])
    {
        
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    [[SRXMPP sharedInstance] teardownStream];
    [SRCoreDataManager saveContext];
}


@end
