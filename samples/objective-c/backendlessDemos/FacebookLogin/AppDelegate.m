//
//  AppDelegate.m
//  FacebookLogin
//
//  Created by Slava Vdovichenko on 8/25/15.
//  Copyright (c) 2015 BACKENDLESS.COM. All rights reserved.
//


// Facebook "Back­e­n­d­l­e­s­s­U­s­e­r­L­ogin" App ID: 1077032488973601

#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "Backendless.h"

static NSString *APP_ID = @"";
static NSString *SECRET_KEY = @"";
static NSString *VERSION_NUM = @"v1";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [DebLog setIsActive:YES];
    
    [backendless initApp:APP_ID secret:SECRET_KEY version:VERSION_NUM];
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    BOOL result = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                 openURL:url
                                                       sourceApplication:sourceApplication
                                                              annotation:annotation];
    
    FBSDKAccessToken *token = [FBSDKAccessToken currentAccessToken];
    
    NSLog(@"openURL: result = %@, url = %@\n userId: %@, token = %@, expirationDate = %@, permissions = %@", @(result), url, [token valueForKey:@"userID"], [token valueForKey:@"tokenString"], [token valueForKey:@"expirationDate"], [token valueForKey:@"permissions"]);
    
    NSDictionary *fieldsMapping = @{
                                    @"id" : @"facebookId",
                                    @"name" : @"name",
                                    @"birthday": @"birthday",
                                    @"first_name": @"fb_first_name",
                                    @"last_name" : @"fb_last_name",
                                    @"gender": @"gender",
                                    @"email": @"email"
                                    };
#if 0 // sync
    
    @try {
        BackendlessUser *user = [backendless.userService loginWithFacebookSDK:token fieldsMapping:fieldsMapping];
        NSLog(@"USER: %@", user);

        [backendless.userService logout];
        NSLog(@"LOGOUT");
}
    @catch (Fault *fault) {
        NSLog(@"openURL: %@", fault);
    
    }
    
#else // async
    
    [backendless.userService
     loginWithFacebookSDK:token
     fieldsMapping:fieldsMapping
     response:^(BackendlessUser *user) {
         NSLog(@"USER (0): %@", user);
         @try {
             [backendless.userService logout];
             NSLog(@"LOGOUT");
         }
         @catch (Fault *fault) {
             NSLog(@"%@", fault);
         }
     }
     error:^(Fault *fault) {
         NSLog(@"openURL: %@", fault);
     }];
    
#endif
    
    return result;
}

@end
