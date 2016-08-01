//
//  AppDelegate.swift
//  HearthGuide
//
//  Created by Alessio Forte on 26/05/16.
//  Copyright © 2016 Alessio Forte. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    //Start del Servizio di Report Crashing
    Fabric.with([Crashlytics.self])
    
    DataManager.shared.option = launchOptions
    
    if application.applicationIconBadgeNumber == 1 {
      let defaults = NSUserDefaults.standardUserDefaults()
      defaults.setObject("1", forKey: "alert")
    }
      
    return true
  }

  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
    if notificationSettings.types != .None {
      application.registerForRemoteNotifications()
    }
  }
  
  func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
    print("Failed to register:", error)
  }

  
  func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {

    var presentedVC = self.window?.rootViewController
    
    let defaults = NSUserDefaults.standardUserDefaults()
    defaults.setObject("1", forKey: "alert")
    
    let alertVC = PMAlertController(title: "Aggiornamento Database",
                                    description: "Abbiamo aggiornato il nostro database dei mazzi, vuoi effettuare ora l'aggiornamento?",
                                    image: UIImage(named: "update.png"), style: .Alert)
    
    alertVC.addAction(PMAlertAction(title: "Annulla", style: .Cancel, action: { () -> Void in
      DataManager.shared.readNotify = false
      
      if let alr = defaults.stringForKey("alert") {
        DataManager.shared.iconBadge(alr)
      }
      
      print("Annullato")
    }))
    
    alertVC.addAction(PMAlertAction(title: "Aggiorna", style: .Default, action: { () in
      DataManager.shared.readNotify = false

      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
        var updateHero : [String] = []
        
        if let custom = userInfo["custom"] as? NSDictionary {
          if let hero = custom["a"] as? NSDictionary {
            for (key, _) in hero {
              updateHero.append(key as! String)
            }
          }
        }
        DataManager.shared.startDataManager(updateHero)
      });
    }))
    
    
    if DataManager.shared.readNotify == false {
      while (presentedVC!.presentedViewController != nil)  {
        presentedVC = presentedVC!.presentedViewController
      }
      presentedVC!.presentViewController(alertVC, animated: true, completion: nil)
      DataManager.shared.readNotify = true
    }
    
    completionHandler(.NewData)
  }
  
}

