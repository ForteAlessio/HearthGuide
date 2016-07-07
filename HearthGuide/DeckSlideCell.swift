//
//  DeckSlideCell.swift
//  HearthGuide
//
//  Created by Alessio Forte on 27/05/16.
//  Copyright © 2016 Alessio Forte. All rights reserved.
//

import UIKit

class DeckSlideCell: UITableViewCell {
  
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet var laDeckName: UILabel!
  @IBOutlet var vwBack: UIView!
  @IBOutlet var vwHeader: UIView!
  @IBOutlet var vwNoCorner: UIView!
  @IBOutlet var bbGuide: UIButton!
  @IBOutlet var bbList: UIButton!
}

extension DeckSlideCell {

  func setCollectionViewDataSourceDelegate<D: protocol<UICollectionViewDataSource, UICollectionViewDelegate>>(dataSourceDelegate: D, forRow row: Int) {
        
    collectionView.delegate   = dataSourceDelegate
    collectionView.dataSource = dataSourceDelegate
    collectionView.tag        = row
    collectionView.setContentOffset(collectionView.contentOffset, animated:false)//Stops collection view if it was scrolling.
    collectionView.reloadData()
  }
  
  var collectionViewOffset: CGFloat {
    set {
      collectionView.contentOffset.x = newValue
    }
    
    get {
      return collectionView.contentOffset.x
    }
  }
}

