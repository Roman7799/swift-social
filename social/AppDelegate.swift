//
//  AppDelegate.swift
//  social
//
//  Created by Geolance on 6/12/19.
//  Copyright © 2019 Geolance. All rights reserved.
//

import UIKit

// GLOBALS
var current_user = NSMutableDictionary()
/*
 current_user possible values
 "user_id"
 "email"
 "first_name"
 "last_name"
 "birthday"
 "gender"
 "avatar" - url
 "cover" - url
 "allow_friends"
 "allow_follow"
 ! NSNull cant be stored! Use only string
 */
var current_user_avatar: UIImage? = nil

var cache_image = NSCache<NSString, UIImage>()
// GLOBALS END

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // 10.1
    //func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // 9.2
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Get saved (sessioned) user
        var stored_user = UserDefaults.standard.object(forKey: "current_user") as? NSMutableDictionary
        if(stored_user != nil){
            current_user = stored_user!.mutableCopy() as! NSMutableDictionary
        }
        print("INIT current_user = ", current_user)
        
        // Get VC from storyboard and make it root (starting)
        if(current_user["user_id"] != nil){
            let home_vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Tab_bar")
            window?.rootViewController = home_vc
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


extension UIButton {
    
    // adjust the icon and title's position
    func centerVertically(gap: CGFloat) {
        
        // adjust title's width
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: -20)
        
        // vertical position of title
        let padding = self.frame.height + gap
        
        // accessing sizes
        let imageSize = self.imageView!.frame.size
        let titleSize = self.titleLabel!.frame.size
        let totalHeight = imageSize.height + titleSize.height + padding
        
        // applying the final apperance of the icon's insets
        self.imageEdgeInsets = UIEdgeInsets(top: -(totalHeight - imageSize.height), left: 0, bottom: 0, right: -titleSize.width)
        
        // applying the final position of title by vertical
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageSize.width, bottom: -(totalHeight - titleSize.height), right: 0)
        
    }
}

