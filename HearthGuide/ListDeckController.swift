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
  
  var deckName : Entity!
  var mazzi    : [AnyObject] = []
  
  @IBOutlet var bbSegue: UIBarButtonItem!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.collectionView!.backgroundView = UIImageView(image:UIImage(named:"background"))
    navigationItem.titleView = UIImageView(image: UIImage(named: DataManager.shared.heroSelected + "Logo"))
    
    bbSegue.tintColor = UIColor.clearColor()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
  
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return mazzi.count
  }
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("InfoCardCell", forIndexPath: indexPath) as! CardListCell
    
    let card = mazzi[indexPath.row] as! Entity
        
    cell.imgCard.image   = card["immagine"] as? UIImage
    cell.imgCopie.image  = UIImage(named: (card["copie"] as? String)!) 
    
    cell.backgroundColor = UIColor.clearColor()
    return cell
  }
  
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
    let card = mazzi[indexPath.row] as! Entity
    
    let imgCard = card["immagine"] as? UIImage
    
    DataManager.shared.cardSelected = imgCard!
    
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    
    _ = storyBoard.instantiateViewControllerWithIdentifier("infoCard") as? InfoCardController
    
    self.performSegueWithIdentifier("showCardListImage", sender: self)
  }
  
  override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {

    switch kind {
      case UICollectionElementKindSectionHeader:
        let hdCell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "ListCardHeader", forIndexPath: indexPath) as! CardListHeader
        hdCell.laNome.text            = deckName["nome"] as? String
        hdCell.vwBack.backgroundColor = UIColor.clearColor()
        return hdCell
      default:
        assert(false, "Unexpected element kind")
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showCardListImage" {
      let InfoCardView = segue.destinationViewController
      InfoCardView.transitioningDelegate = self
      InfoCardView.modalPresentationStyle = .Custom
    }
  }
  
  //Metodi per Animazione Bubble
  let transition    = BubbleTransition()
  
  func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    transition.transitionMode = .Present
    transition.startingPoint  = self.view.center
    transition.duration       = 0.35
    transition.bubbleColor    = UIColor.blackColor().colorWithAlphaComponent(0.2)
    return transition
  }
  
  func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    transition.transitionMode = .Dismiss
    transition.startingPoint  = self.view.center
    transition.bubbleColor    = UIColor.clearColor()
    return transition
  }
  
}
