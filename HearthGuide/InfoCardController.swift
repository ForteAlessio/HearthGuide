//
//  InfoCardController.swift
//  HearthGuide
//
//  Created by Alessio Forte on 17/06/16.
//  Copyright © 2016 Alessio Forte. All rights reserved.
//

import UIKit

class InfoCardController: UIViewController {
  
  @IBOutlet var imgCard: UIImageView!
  @IBOutlet var vwBack: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
    
    imgCard.image = DataManager.shared.cardSelected
    
    DataManager.shared.infoController = self
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  
  @IBAction func acTapClose(_ sender: AnyObject) {
    self.dismiss(animated: true, completion: {});
  }
  
}
