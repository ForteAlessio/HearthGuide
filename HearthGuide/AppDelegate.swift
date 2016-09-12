//
//  AppDelegate.swift
//  HearthGuide
//
//  Created by Alessio Forte on 26/05/16.
//  Copyright © 2016 Alessio Forte. All rights reserved.
//

import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    DataManager.shared.option = launchOptions as [NSObject : AnyObject]?
    
    if application.applicationIconBadgeNumber == 1 {
      let defaults = UserDefaults.standard
      defaults.set("1", forKey: "alert")
    }
      
    return true
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
    if notificationSettings.types != UIUserNotificationType() {
      application.registerForRemoteNotifications()
    }
  }
  
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("Failed to register:", error)
  }

  
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

    var presentedVC = self.window?.rootViewController
    
    let defaults = UserDefaults.standard
    defaults.set("1", forKey: "alert")
    
    let alertVC = PMAlertController(title: "Aggiornamento Database",
                                    description: "Abbiamo aggiornato il nostro database dei mazzi, vuoi effettuare ora l'aggiornamento?",
                                    image: UIImage(named: "update.png"), style: .alert)
    
    alertVC.addAction(PMAlertAction(title: "Annulla", style: .cancel, action: { () -> Void in
      DataManager.shared.readNotify = false
      
      if let alr = defaults.string(forKey: "alert") {
        DataManager.shared.iconBadge(alr)
      }
      
      print("Annullato")
    }))
    
    alertVC.addAction(PMAlertAction(title: "Aggiorna", style: .default, action: { () in
      DataManager.shared.readNotify = false

      DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
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
      presentedVC!.present(alertVC, animated: true, completion: nil)
      DataManager.shared.readNotify = true
    }
    
    completionHandler(.newData)
  }
  
}

