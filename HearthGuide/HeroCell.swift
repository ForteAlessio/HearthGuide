//
//  HeroCell.swift
//  HearthGuide
//
//  Created by Alessio Forte on 26/05/16.
//  Copyright © 2016 Alessio Forte. All rights reserved.
//

import UIKit

class HeroCell: UITableViewCell {

  @IBOutlet var laHero  : UILabel!
  @IBOutlet var laUpdate: UILabel!
  @IBOutlet var imgHero : UIImageView!
  @IBOutlet var vwBack  : UIView!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
