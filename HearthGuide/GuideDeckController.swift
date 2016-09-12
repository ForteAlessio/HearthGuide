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
    
    //tvGuide.text = "La Guida sarà presto disponibile."
    
    if (guide != nil) && (guide != "") {
      tvGuide.text = guide.html2String + " "
    }
    
    tvGuide.textColor         = UIColor.white
    tvGuide.backgroundColor   = UIColor.clear
    tvGuide.font              = UIFont(name: "Lato", size: 18)
    tvGuide.textAlignment     = .justified
    
    
    laNomeDeck.text                 = "Guida " + deckName
    vwNomeDeck.backgroundColor      = UIColor.clear
    self.view.backgroundColor       = UIColor(patternImage: UIImage(named: "background")!)
    vwBackCollView.backgroundColor  = UIColor(patternImage: UIImage(named: "cellBackground")!)
    vwHeader.backgroundColor        = UIColor(rgba: "#ecf0f1", alpha: 1)
    vwNoCorner.backgroundColor      = UIColor(rgba: "#ecf0f1", alpha: 1)
    bbSegue.tintColor               = UIColor.clear
    
    navigationItem.titleView = UIImageView(image: UIImage(named: DataManager.shared.heroSelected + "Logo"))
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    self.tvGuide.scrollRangeToVisible(NSMakeRange(0, 0))
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    if segue.identifier == "showCardGuideImage" {
      let InfoCardView = segue.destination
      InfoCardView.transitioningDelegate  = self
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




extension GuideDeckController: UICollectionViewDelegate, UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return TopCards.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GuideCell", for: indexPath) as! GuideCell
    
    let contenuto = TopCards[(indexPath as NSIndexPath).row] as! Entity
    
    for i in 0..<listCards.count {
      let carta = listCards[i] as! Entity
      
      if carta["nome"] as? String == contenuto["nome"] as? String {
        cell.imgCard.image = carta["immagine"] as? UIImage
        break
      }
    }
  
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let contenuto = TopCards[(indexPath as NSIndexPath).row]
    
    for i in 0..<listCards.count {
      let carta = listCards[i] as! Entity

      if carta["nome"] as? String == contenuto["nome"] as? String {
        DataManager.shared.cardSelected = (carta["immagine"] as? UIImage)!
        break
      }
    }
    
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    
    _ = storyBoard.instantiateViewController(withIdentifier: "infoCard") as? InfoCardController
    
    self.performSegue(withIdentifier: "showCardGuideImage", sender: self)
   
  }
}
