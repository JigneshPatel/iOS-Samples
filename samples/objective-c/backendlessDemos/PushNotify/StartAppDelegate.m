//
//  StartAppDelegate.m
//  PushNotify
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2012 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

#import "StartAppDelegate.h"
#import "Backendless.h"

// *** YOU SHOULD SET THE FOLLOWING VALUES FROM YOUR BACKENDLESS APPLICATION ***
// *** COPY/PASTE APP ID and SECRET KET FROM BACKENDLESS CONSOLE (use the Manage > App Settings screen) ***
// BEVideoChat
static NSString *APP_ID = @"7B92560B-91F0-E94D-FFEB-77451B0F9700";
static NSString *SECRET_KEY = @"B9D27BA8-3964-F3AE-FF26-E71FFF487300";
static NSString *VERSION_NUM = @"v1";

@implementation StartAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //[DebLog setIsActive:YES];
    
    [backendless initApp:APP_ID secret:SECRET_KEY version:VERSION_NUM];
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [backendless.messaging applicationWillTerminate];
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
    [backendless.messaging didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    [backendless.messaging didFailToRegisterForRemoteNotificationsWithError:err];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [backendless.messaging didReceiveRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler {
    
    [backendless.messaging didReceiveRemoteNotification:userInfo];
    handler(UIBackgroundFetchResultNewData);
}

@end
