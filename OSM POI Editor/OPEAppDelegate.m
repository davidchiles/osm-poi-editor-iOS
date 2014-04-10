//
//  OPEAppDelegate.m
//  OSM POI Editor
//
//  Created by David Chiles on 2/2/12.
//  Copyright (c) 2011 David Chiles. All rights reserved.
//
//  This file is part of POI+.
//
//  POI+ is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  POI+ is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with POI+.  If not, see <http://www.gnu.org/licenses/>.

#import "OPEAPIConstants.h"


#import "OPEAppDelegate.h"
#import "OPEViewController.h"
#import "OPEDatabaseImporter.h"
#import "OPEDatabaseManager.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "HockeySDK.h"

#import "AFOAuth1Client.h"
#import "OPEAppVersionMigration.h"

@interface OPEAppDelegate () <BITHockeyManagerDelegate>

@end


@implementation OPEAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [[BITHockeyManager sharedHockeyManager] configureWithBetaIdentifier:HOCKEY_BETA_IDENTIFIER
                                                         liveIdentifier:HOCKEY_LIVE_IDENTIFIER
                                                               delegate:self];
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
    
    application.statusBarStyle = UIStatusBarStyleLightContent;
    
    [OPEAppVersionMigration migrateToCurrentVersion];
    
    [OPEDatabaseManager createDatabaseWithError:nil];
    
    [[[OPEOSMAPIManager alloc] init] fetchCurrentUserWithComletion:nil];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    OPEDatabaseImporter * importer = [[OPEDatabaseImporter alloc] init];

    [importer import];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UIViewController *rootView = [[OPEViewController alloc] init];
    
    self.navController = [[UINavigationController alloc] initWithRootViewController:rootView];
    [[self window] setRootViewController:self.navController];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    //[OPEMRUtility deleteDownloaded];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    //[OPEMRUtility deleteDownloaded];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    NSNotification *notification = [NSNotification notificationWithName:kAFApplicationLaunchedWithURLNotification object:nil userInfo:@{kAFApplicationLaunchOptionsURLKey: url}];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    
    return YES;
}

@end
