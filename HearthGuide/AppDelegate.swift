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
      
      DispatchQueue.global().async(execute: {
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
  
  //METODI SPOTLIGHT

  //metodo evocato al tocco della ricerca di spotlight
  func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Swift.Void) -> Bool {
    
    // estraiamo l'identificatiore dell'attività
    var nomeAct = userActivity.userInfo!["kCSSearchableItemActivityIdentifier"] as! String

    // tagliamo la parte iniziale dell'identifier
    nomeAct = nomeAct.replacingOccurrences(of: "Eroe.", with: "")
    
    print("^^Continue Activity: " + nomeAct)
    
    var contatore = 0

    for eroe in DataManager.shared.Eroi {
      
      if eroe["nome"] as! String == nomeAct {
        //Impostiamo l'indice trovato che useremo per cercare i Mazzi dell'eroe
        DataManager.shared.SpotLightIndex = contatore
        
        DataManager.shared.mainController.navigationController?.popToRootViewController(animated: false)
        DataManager.shared.mainController.performSegue(withIdentifier: "detail", sender: self)

        break
      }
      contatore += 1
    }

    return true
  }
  
  func application(_ application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
    return true
  }
  
  func application(_ application: UIApplication, didFailToContinueUserActivityWithType userActivityType: String, error: Error) {
    
    if (error as NSError).code != NSUserCancelledError {
      
      let message = "The connection to your other device may have been interrupted. Please try again. \(error.localizedDescription)"
      print("--------")
      print("")
      print(message)
      print("")
      print("--------")
    }
  }
  
  func application(_ application: UIApplication, didUpdate userActivity: NSUserActivity) {
    print("--------")
    print("")
    print("Update Activity: \(userActivity.title)")
    print("")
    print("--------")
  }
  
}

