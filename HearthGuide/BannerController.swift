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
    
    imgBack.hidden              = true
    vwBanner.adUnitID           = "ca-app-pub-3940256099942544/2934735716" // codice test da sostituire con quello vero
    vwBanner.rootViewController = self
    let request                 = GADRequest()
    
    // necessario per fare i test con il simulatore
    request.testDevices         = [kGADSimulatorID]
    
    vwBanner.loadRequest(request)
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    openLock()
  }
  
  func adView(bannerView: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
    self.imgBack.hidden  = false
    self.topCon.constant = 50
    
    UIView.animateWithDuration(0.5) {
      self.view.layoutIfNeeded()
    }
    print(error.localizedDescription)
  }
  
  func adViewDidReceiveAd(bannerView: GADBannerView!) {
    self.topCon.constant    = 50
    
    UIView.animateWithDuration(0.5) {
      self.view.layoutIfNeeded()
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func openLock() {
    
    UIView.animateWithDuration(1, delay: 0, options: [], animations: {
      
      // Open lock.
      let yDelta = self.lockBorder.frame.maxY
      
      print(yDelta)
      
      self.topLock.center.y    -= yDelta
      self.lockBorder.center.y -= yDelta
      self.bottomLock.center.y += yDelta
      }, completion: { _ in
        self.topLock.removeFromSuperview()
        self.lockBorder.removeFromSuperview()
        self.bottomLock.removeFromSuperview()
    })
  }
  
  //Serve per impostare la Status Bar Bianca
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return UIStatusBarStyle.LightContent
  }
  
}
