//
//  ListDeckController.swift
//  HearthGuide
//
//  Created by Alessio Forte on 24/06/16.
//  Copyright © 2016 Alessio Forte. All rights reserved.
//

import UIKit

private let reuseIdentifier = "InfoCardCell"

class ListDeckController: UICollectionViewController, UIViewControllerTransitioningDelegate {
  
  var deckName : String!
  var mazzi    : [AnyObject] = []
  
  @IBOutlet var bbSegue: UIBarButtonItem!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.collectionView!.backgroundView = UIImageView(image:UIImage(named:"background"))
    navigationItem.titleView = UIImageView(image: UIImage(named: DataManager.shared.heroSelected + "Logo"))
    
    bbSegue.tintColor = UIColor.clear
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return mazzi.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InfoCardCell", for: indexPath) as! CardListCell
    
    let card = mazzi[(indexPath as NSIndexPath).row] as! Entity
        
    cell.imgCard.image   = card["immagine"] as? UIImage
    cell.imgCopie.image  = UIImage(named: (card["copie"] as? String)!) 
    
    cell.backgroundColor = UIColor.clear
    return cell
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    let card = mazzi[(indexPath as NSIndexPath).row] as! Entity
    
    let imgCard = card["immagine"] as? UIImage
    
    DataManager.shared.cardSelected = imgCard!
    
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    
    _ = storyBoard.instantiateViewController(withIdentifier: "infoCard") as? InfoCardController
    
    self.performSegue(withIdentifier: "showCardListImage", sender: self)
  }
 
  override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    switch kind {
    case UICollectionElementKindSectionHeader:
      let hdCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ListCardHeader", for: indexPath) as! CardListHeader
      hdCell.laNome.text            = "Lista " + deckName
      hdCell.vwBack.backgroundColor = UIColor.clear
      return hdCell
    default:
       let hdCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ListCardHeader", for: indexPath)
      return hdCell
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showCardListImage" {
      let InfoCardView = segue.destination
      InfoCardView.transitioningDelegate = self
      InfoCardView.modalPresentationStyle = .custom
    }
  }
  
  //Metodi per Animazione Bubble
  let transition    = BubbleTransition()
  
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    transition.transitionMode = .present
    transition.startingPoint  = self.view.center
    transition.duration       = 0.35
    transition.bubbleColor    = UIColor.black.withAlphaComponent(0.2)
    return transition
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    transition.transitionMode = .dismiss
    transition.startingPoint  = self.view.center
    transition.bubbleColor    = UIColor.clear
    return transition
  }
  
}
