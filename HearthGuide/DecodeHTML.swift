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
  var html2AttributedString: NSAttributedString? {
    guard let data = data(using: .utf8) else { return nil }
    do {
      return try NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil)
    } catch let error as NSError {
      print(error.localizedDescription)
      return  nil
    }
  }
  var html2String: String {
    return html2AttributedString?.string ?? ""
  }
}
