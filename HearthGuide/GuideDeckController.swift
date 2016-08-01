//
//  GuideController.swift
//  HearthGuide
//
//  Created by Alessio Forte on 24/06/16.
//  Copyright © 2016 Alessio Forte. All rights reserved.
//

import UIKit

class GuideDeckController: UIViewController, UIViewControllerTransitioningDelegate {
  
  var deckName  : String!
  var guide     : String!
  var TopCards  : [AnyObject] = []
  var listCards : [AnyObject] = []
  
  
  @IBOutlet var vwBackCollView: UIView!
  @IBOutlet var tvGuide: UITextView!
  @IBOutlet var CollectionView: UICollectionView!
  @IBOutlet var laNomeDeck: UILabel!
  @IBOutlet var vwNoCorner: UIView!
  @IBOutlet var vwHeader: UIView!
  @IBOutlet var vwNomeDeck: UIView!
  @IBOutlet var bbSegue: UIBarButtonItem!

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
    
    
    laNomeDeck.text                 = "Guida " + deckName
    vwNomeDeck.backgroundColor      = UIColor.clearColor()
    self.view.backgroundColor       = UIColor(patternImage: UIImage(named: "background")!)
    vwBackCollView.backgroundColor  = UIColor(patternImage: UIImage(named: "cellBackground")!)
    vwHeader.backgroundColor        = UIColor(rgba: "#ecf0f1", alpha: 1)
    vwNoCorner.backgroundColor      = UIColor(rgba: "#ecf0f1", alpha: 1)
    bbSegue.tintColor               = UIColor.clearColor()
    
    navigationItem.titleView = UIImageView(image: UIImage(named: DataManager.shared.heroSelected + "Logo"))
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func viewDidAppear(animated: Bool) {
    self.tvGuide.scrollRangeToVisible(NSMakeRange(0, 0))
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    if segue.identifier == "showCardGuideImage" {
      let InfoCardView = segue.destinationViewController
      InfoCardView.transitioningDelegate  = self
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




extension GuideDeckController: UICollectionViewDelegate, UICollectionViewDataSource {
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return TopCards.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GuideCell", forIndexPath: indexPath) as! GuideCell
    
    let contenuto = TopCards[indexPath.row]
    
    
    for carta in listCards {
      if carta["nome"] as? String == contenuto["nome"] as? String {
        cell.imgCard.image = carta["immagine"] as? UIImage
        break
      }
    }
  
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let contenuto = TopCards[indexPath.row]
    
    for carta in listCards {
      if carta["nome"] as? String == contenuto["nome"] as? String {
        DataManager.shared.cardSelected = (carta["immagine"] as? UIImage)!
        break
      }
    }
    
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    
    _ = storyBoard.instantiateViewControllerWithIdentifier("infoCard") as? InfoCardController
    
    self.performSegueWithIdentifier("showCardGuideImage", sender: self)
   
  }
}
