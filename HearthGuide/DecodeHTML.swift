//
//  DecodeHTML.swift
//
//  Created by TheFlow_ on 01/03/2015.
//  Copyright (c) 2015 TheFlow_. All rights reserved.
//

//FORMATTA UN TESTO HTML CON I VARI ATTRIBUTI PER VISUALIZZARLO FORMATTATO

import Foundation
import UIKit

extension String {
  var html2String:String {
    return try! NSAttributedString(data: dataUsingEncoding(NSUTF8StringEncoding)!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil).string
  }
}