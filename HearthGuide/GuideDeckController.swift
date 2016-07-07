//
//  GuideController.swift
//  HearthGuide
//
//  Created by Alessio Forte on 24/06/16.
//  Copyright © 2016 Alessio Forte. All rights reserved.
//

import UIKit

class GuideDeckController: UIViewController {
  
  var deckName : String!
  var guide    : String!
  
  
  @IBOutlet var tvGuide: UITextView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tvGuide.text = "La Guida sarà presto disponibile."
    
    if (guide != nil) && (guide != "") {
      tvGuide.text = guide.html2String
    }
    
    tvGuide.textColor         = UIColor.whiteColor()
    tvGuide.backgroundColor   = UIColor.clearColor()
    tvGuide.font              = UIFont(name: "Lato", size: 18)
    tvGuide.textAlignment     = .Justified
    
    self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
    navigationItem.titleView = UIImageView(image: UIImage(named: DataManager.shared.heroSelected + "Logo"))
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
}
