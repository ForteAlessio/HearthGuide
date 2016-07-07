//
//  BannerController.swift
//  HearthGuide
//
//  Created by Alessio Forte on 05/07/16.
//  Copyright © 2016 Alessio Forte. All rights reserved.
//

import UIKit
import GoogleMobileAds

class BannerController: UIViewController, GADBannerViewDelegate {
  
  @IBOutlet var vwContainer: UIView!
  @IBOutlet var imgBack: UIImageView!
  @IBOutlet var vwBanner: GADBannerView!
  @IBOutlet var heightCon: NSLayoutConstraint!
  @IBOutlet var topCon: NSLayoutConstraint!

  override func viewDidLoad() {
    
    //test github da cancellare 
    
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
    }  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  //Serve per impostare la Status Bar Bianca
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return UIStatusBarStyle.LightContent
  }

}
