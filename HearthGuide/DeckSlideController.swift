//
//  DeckSlideController.swift
//  HearthGuide
//
//  Created by Alessio Forte on 27/05/16.
//  Copyright © 2016 Alessio Forte. All rights reserved.
//

import UIKit

class DeckSlideController: UITableViewController, UIViewControllerTransitioningDelegate {
  
  var mazzi         : [AnyObject] = []
  var deckName      : [Entity]    = []
  var storedOffsets = [Int: CGFloat]()
  var coordTap      : CGPoint = CGPoint()

  @IBOutlet var bbSegue: UIBarButtonItem!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.titleView = UIImageView(image: UIImage(named: DataManager.shared.heroSelected + "Logo"))
    
    self.clearsSelectionOnViewWillAppear = true
    
    self.tableView.backgroundView = UIImageView(image:UIImage(named:"background"))
    
    bbSegue.tintColor = UIColor.clearColor()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return deckName.count
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return deckName[section]["nome"] as? String
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! DeckSlideCell
    
    cell.collectionView.tag         = indexPath.section
    cell.bbGuide.tag                = indexPath.section
    cell.bbList.tag                 = indexPath.section
    cell.laDeckName.text            = deckName[indexPath.section]["nome"] as? String
    cell.vwHeader.backgroundColor   = UIColor(rgba: "#ecf0f1", alpha: 1)
    cell.vwNoCorner.backgroundColor = UIColor(rgba: "#ecf0f1", alpha: 1)
    cell.vwBack.backgroundColor     = UIColor(patternImage: UIImage(named: "cellBackground")!)
    
    return cell
  }
  
  override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    
    guard let DeckSlideCell = cell as? DeckSlideCell else { return }
    
    DeckSlideCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.section)//indexPath.row)
    DeckSlideCell.collectionViewOffset = storedOffsets[indexPath.section] ?? 0//indexPath.row] ?? 0
  }
  
  override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    
    guard let DeckSlideCell = cell as? DeckSlideCell else { return }
    
    storedOffsets[indexPath.row] = DeckSlideCell.collectionViewOffset
  }
  
  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }

  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 0.0
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let graph: Graph = Graph()
    
    if segue.identifier == "showCardImage" {
      let InfoCardView = segue.destinationViewController
      InfoCardView.transitioningDelegate = self
      InfoCardView.modalPresentationStyle = .Custom
    }
    
    if segue.identifier == "ListDeck" {
      let controller      = segue.destinationViewController as! ListDeckController
      let indexPath       = (sender as! UIButton).tag
      controller.deckName = deckName[indexPath]
      
      let listCards: Array<Entity> = graph.searchForEntity(groups: [deckName[indexPath]["nome"] as! String + "Info"])
      controller.mazzi = listCards
    }
    
    if segue.identifier == "GuideDeck" {
      let controller      = segue.destinationViewController as! GuideDeckController
      let indexPath       = (sender as! UIButton).tag
      controller.deckName = deckName[indexPath]["nome"] as? String
      controller.guide    = deckName[indexPath]["guida"] as? String
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




extension DeckSlideController: UICollectionViewDelegate, UICollectionViewDataSource {
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    let listaCarte = mazzi[collectionView.tag] as! [Entity]
    
    return listaCarte.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("slideCell", forIndexPath: indexPath) as! CardSlideCell
    
    var CardList = mazzi[collectionView.tag] as! [Entity]
    
    let contenuto = CardList[indexPath.row]
    
    cell.laNome.text = contenuto["nome"] as? String
    
    cell.imgCard.image = contenuto["immagine"] as? UIImage
    
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    var CardList = mazzi[collectionView.tag] as! [Entity]
    
    let contenuto = CardList[indexPath.row]
    
    let imgCard = contenuto["immagine"] as? UIImage
    
    DataManager.shared.cardSelected = imgCard!
    
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    
    _ = storyBoard.instantiateViewControllerWithIdentifier("infoCard") as? InfoCardController
    
    self.performSegueWithIdentifier("showCardImage", sender: self)
  }
}
