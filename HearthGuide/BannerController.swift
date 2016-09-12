//
//  BannerViewController.swift
//  HearthGuide
//
//  Created by Alessio Forte on 11/07/16.
//  Copyright © 2016 Alessio Forte. All rights reserved.
//

import UIKit
import GoogleMobileAds

class BannerController: UIViewController, GADBannerViewDelegate {
  
  @IBOutlet var lockBorder: UIImageView!
  @IBOutlet var topLock: UIImageView!
  @IBOutlet var bottomLock: UIImageView!
  @IBOutlet var vwBanner: GADBannerView!
  @IBOutlet var vwContainer: UIView!
  @IBOutlet var imgBack: UIImageView!
  @IBOutlet var heightCon: NSLayoutConstraint!
  @IBOutlet var topCon: NSLayoutConstraint!
  
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    vwBanner.delegate           = self
    
    imgBack.isHidden              = true
    vwBanner.adUnitID           = "ca-app-pub-3940256099942544/2934735716" // codice test da sostituire con quello vero
    vwBanner.rootViewController = self
    let request                 = GADRequest()
    
    // necessario per fare i test con il simulatore
    request.testDevices         = [kGADSimulatorID]
    
    vwBanner.load(request)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    openLock()
  }
  
  func adView(_ bannerView: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
    self.imgBack.isHidden  = false
    self.topCon.constant = 50
    
    UIView.animate(withDuration: 0.5, animations: {
      self.view.layoutIfNeeded()
    }) 
    print(error.localizedDescription)
  }
  
  func adViewDidReceiveAd(_ bannerView: GADBannerView!) {
    self.topCon.constant    = 50
    
    UIView.animate(withDuration: 0.5, animations: {
      self.view.layoutIfNeeded()
    }) 
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func openLock() {
    
    UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
      let yDelta = self.lockBorder.frame.maxY
      
      self.topLock.center.y    -= yDelta
      self.lockBorder.center.y -= yDelta
      self.bottomLock.center.y += yDelta
      
      }, completion: { _ in
        self.topLock.removeFromSuperview()
        self.lockBorder.removeFromSuperview()
        self.bottomLock.removeFromSuperview()
        self.notifyAlert ()
    })
  }
  
  //ALLO START DELL'APP CHIEDIAMO ALL'UTENTE SE VUOLE LE NOTIFICHE DI AGGIORNAMENTO
  func notifyAlert () {
    //se è il primo avvio chiediamo l'autorizzazione per le notifiche
    if DataManager.shared.Eroi.count == 0 {
      
      DataManager.shared.creaEroi()
      
      let alertVC = PMAlertController(title: "Notifiche Aggiornamenti",
                                      description: "Vuoi essere avvertito quando effettueremo un aggiornamento?\rSe non accetti, potrai aggiornare manualmente i mazzi.",
                                      image: UIImage(named: "permission.png"), style: .alert)
      
      alertVC.addAction(PMAlertAction(title: "Avanti", style: .cancel, action: { () -> Void in
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
          
          _ = OneSignal(launchOptions: DataManager.shared.option, appId: "7dbf6c05-34d0-4726-89b5-e79b4c1bf330", handleNotification: nil)
          
          DataManager.shared.startDataManager([])
        });
      }))
      
      present(alertVC, animated: true, completion: nil)
    }
    //altrimenti controlliamo se nelle impostazioni l'utente ha attivato le notifiche, se si impostiamo l'app per ricerverle
    else {
      let notificationType = UIApplication.shared.currentUserNotificationSettings!.types
      
      if notificationType != UIUserNotificationType() {
        _ = OneSignal(launchOptions: DataManager.shared.option, appId: "7dbf6c05-34d0-4726-89b5-e79b4c1bf330", handleNotification: nil)
      }
    }
  }
  
  //Serve per impostare la Status Bar Bianca
  override var preferredStatusBarStyle : UIStatusBarStyle {
    return UIStatusBarStyle.lightContent
  }
  
}
