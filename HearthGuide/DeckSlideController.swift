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
    
    if DataManager.shared.SpotLightIndex >= 0 {
      let graph      : Graph        = Graph()
      
      let nomeEroe    = DataManager.shared.Eroi[DataManager.shared.SpotLightIndex]["nome"] as! String
      DataManager.shared.heroSelected = nomeEroe
      
      let selectedDecks: Array<Entity> = graph.searchForEntity(groups: [nomeEroe])
      self.deckName = selectedDecks
      
      for deck in selectedDecks {
        let cards: Array<Entity> = graph.searchForEntity(groups: [(deck["nome"] as! String)])
        self.mazzi.append(cards as AnyObject)
      }
      DataManager.shared.SpotLightIndex = -99
    }
    
    navigationItem.titleView = UIImageView(image: UIImage(named: DataManager.shared.heroSelected + "Logo"))
    
    self.clearsSelectionOnViewWillAppear = true
    
    self.tableView.backgroundView = UIImageView(image:UIImage(named:"background"))
    
    bbSegue.tintColor = UIColor.clear
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return deckName.count
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return deckName[section]["nome"] as? String
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DeckSlideCell
    
    cell.collectionView.tag         = (indexPath as NSIndexPath).section
    cell.bbGuide.tag                = (indexPath as NSIndexPath).section
    cell.laDeckName.text            = deckName[(indexPath as NSIndexPath).section]["nome"] as? String
    cell.vwHeader.backgroundColor   = UIColor(rgba: "#ecf0f1", alpha: 1)
    cell.vwNoCorner.backgroundColor = UIColor(rgba: "#ecf0f1", alpha: 1)
    cell.vwBack.backgroundColor     = UIColor(patternImage: UIImage(named: "cellBackground")!)
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    
    guard let DeckSlideCell = cell as? DeckSlideCell else { return }
    
    DeckSlideCell.setCollectionViewDataSourceDelegate(self, forRow: (indexPath as NSIndexPath).section)//indexPath.row)
    DeckSlideCell.collectionViewOffset = storedOffsets[(indexPath as NSIndexPath).section] ?? 0//indexPath.row] ?? 0
  }
  
  override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    
    guard let DeckSlideCell = cell as? DeckSlideCell else { return }
    
    storedOffsets[(indexPath as NSIndexPath).row] = DeckSlideCell.collectionViewOffset
  }
  
  @objc(numberOfSectionsInCollectionView:) func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 0.0
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let graph: Graph = Graph()
    
    if segue.identifier == "showCardImage" {
      let InfoCardView = segue.destination
      InfoCardView.transitioningDelegate = self
      InfoCardView.modalPresentationStyle = .custom
    }
    
    /*
    if segue.identifier == "ListDeck" {
      let controller      = segue.destination as! ListDeckController
      let indexPath       = (sender as! UIButton).tag
      controller.deckName = deckName[indexPath]
      
      let listCards: Array<Entity> = graph.searchForEntity(groups: [deckName[indexPath]["nome"] as! String + "Info"])
      controller.mazzi = listCards
    }
    */
    if segue.identifier == "GuideDeck" {
      let controller      = segue.destination as! GuideDeckController
      let indexPath       = (sender as! UIButton).tag
      controller.deckName = deckName[indexPath]["nome"] as? String
      controller.guide    = deckName[indexPath]["guida"] as? String
    
      
      let TopCard: Array<Entity> = graph.searchForEntity(groups: [deckName[indexPath]["nome"] as! String + "TopCards"])
      controller.TopCards = TopCard
      
      let listCards: Array<Entity> = graph.searchForEntity(groups: [deckName[indexPath]["nome"] as! String + "Info"])
      controller.listCards = listCards
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




extension DeckSlideController: UICollectionViewDelegate, UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    let listaCarte = mazzi[collectionView.tag] as! [Entity]
    
    return listaCarte.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "slideCell", for: indexPath) as! CardSlideCell
    
    var CardList = mazzi[collectionView.tag] as! [Entity]
    
    let contenuto = CardList[(indexPath as NSIndexPath).row]
    
    cell.laNome.text = contenuto["nome"] as? String
    
    cell.imgCard.image = contenuto["immagine"] as? UIImage
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    var CardList = mazzi[collectionView.tag] as! [Entity]
    
    let contenuto = CardList[(indexPath as NSIndexPath).row]
    
    let imgCard = contenuto["immagine"] as? UIImage
    
    DataManager.shared.cardSelected = imgCard!
    
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    
    _ = storyBoard.instantiateViewController(withIdentifier: "infoCard") as? InfoCardController

    self.performSegue(withIdentifier: "showCardImage", sender: self)
  }
}
