//
//  HLAppDelegate.m
//  HLGACrashExample
//
//  Created by Jamie Swain on 11/6/13.
//

#import "HLAppDelegate.h"
#import "GAI.h"


@implementation HLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    NSString *trackingID = @"UA-00000000-0";

    if (!trackingID) {
        NSLog(@"ERROR trackingID needed.");
        NSAssert(NO, @"ERROR trackingID needed.");
    }

    [GAI sharedInstance].trackUncaughtExceptions = NO;
    [GAI sharedInstance].dispatchInterval = 20;
    [[GAI sharedInstance] trackerWithTrackingId:trackingID];  // HL DEV ACCOUNT
    [[[GAI sharedInstance] defaultTracker] setSessionTimeout:1800]; // 30 minutes
    
    
    [GAI sharedInstance].debug = YES;
    


    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSString * const userDefaultsKey = @"queued_GA_exceptions";
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:userDefaultsKey]) {

        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:userDefaultsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];

        NSLog(@"sending the exceptions...");
        NSData *descData = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"html-error-response" withExtension:@"txt"]];
        NSString *desc = [[NSString alloc] initWithData:descData encoding:NSUTF8StringEncoding];    
        NSAssert([desc isKindOfClass:[NSString class]] , @"must be string");
        NSAssert([desc length] > 0, @"must have length");
        
        double delayInSeconds = 5.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            for (int i = 0; i < 5; i++) {
                [[[GAI sharedInstance] defaultTracker] sendException:NO withDescription:desc];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:userDefaultsKey object:self];
        });
    }
    else {
        NSLog(@"already sent exceptions, will continue with normal launch...");
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



@end
