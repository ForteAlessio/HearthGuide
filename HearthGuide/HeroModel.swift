//
//  HeroModel.swift
//  HearthGuide
//
//  Created by Alessio Forte on 26/05/16.
//  Copyright © 2016 Alessio Forte. All rights reserved.
//

import UIKit

class HeroModel: NSObject {

  var nome     : String!
  var immagine : UIImage!
  var update   : NSDate!
  
  
  init(nomeIn:String, immagineIn:UIImage){
    nome     = nomeIn
    immagine = immagineIn
  }
  
}
