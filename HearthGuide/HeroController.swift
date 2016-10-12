//
//  HeroController.swift
//  HearthGuide
//
//  Created by Alessio Forte on 26/05/16.
//  Copyright © 2016 Alessio Forte. All rights reserved.
//

import UIKit

class HeroController: UITableViewController, StoreKitManagerDelegate {
  
  
  @IBOutlet var bbRefresh: MIBadgeButton!
  @IBOutlet var bbInApp: UIBarButtonItem!
  
  var config       : SwiftLoader.Config = SwiftLoader.Config()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    //Inizializzaione dell'In App Purchase
    StoreKitManager.shared.delegate = self
    StoreKitManager.shared.startStoreKitManager(product: "NoPubblicita", viewController: self)

    configLoading()
    
    DataManager.shared.mainController = self
    
    DataManager.shared.startGraph()
    
    //controlla se ci sono aggiornamenti da fare, se si, imposta il badge sul button refresh
    let defaults = UserDefaults.standard
    let alr      = defaults.string(forKey: "alert") 
    if alr == "1" {
      DataManager.shared.iconBadge(alr!)
    }
    
    navigationController?.progressHeight    = 4
    navigationController?.progressTintColor = UIColor.white
    
    self.clearsSelectionOnViewWillAppear = true
    
    navigationController!.navigationBar.backgroundColor = UIColor(rgba: "#34AADC")
    
    navigationController!.navigationBar.barStyle = UIBarStyle.blackTranslucent
    
    navigationController!.navigationBar.tintColor = UIColor.white
    
    navigationItem.titleView = UIImageView(image: UIImage(named: "logo"))
    
    self.tableView.backgroundView = UIImageView(image:UIImage(named:"background"))
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return DataManager.shared.Eroi.count
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return ""
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HeroCell
    
    let hero = DataManager.shared.Eroi[(indexPath as NSIndexPath).row]
    
    cell.laHero.text   = hero["nome"] as? String
    cell.imgHero.image = hero["img"]  as? UIImage
  
    cell.laUpdate.text = DataManager.shared.getlastUpdate((hero["update"] as? Date)!)
    
    cell.vwBack.backgroundColor = UIColor(rgba: "#ecf0f1", alpha: 1)
    
    return cell
  }

  //CODICE PER DESELEZIONARE IL FOCUS DELLA CELLA AL RILASCIO DEL TOCCO IN MODO CHE NON RIMANGA IL FOCUS BRUTTO
  func deselectSelectedRowAnimated(_ animated: Bool) {
    if let indexPath = self.tableView.indexPathForSelectedRow {
      self.tableView.deselectRow(at: indexPath, animated: animated)
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    deselectSelectedRowAnimated(true)
  }
  
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let graph: Graph = Graph()
    
    if segue.identifier == "detail" {
      // controlliamo quale cella è stata toccata
      if let indexPath = self.tableView.indexPathForSelectedRow {
        
        let controller  = segue.destination as! DeckSlideController
        let nomeEroe    = DataManager.shared.Eroi[(indexPath as NSIndexPath).row]["nome"] as! String
        DataManager.shared.heroSelected = nomeEroe
        
        let selectedDecks: Array<Entity> = graph.searchForEntity(groups: [nomeEroe])
        controller.deckName = selectedDecks
        
        for deck in selectedDecks {
          let cards: Array<Entity> = graph.searchForEntity(groups: [(deck["nome"] as! String)])
          controller.mazzi.append(cards as AnyObject)
        }
      }
    }
  }
  
  
  @IBAction func acRefresh(_ sender: MIBadgeButton) {
    let alertVC = PMAlertController(title: "Aggiornamento Mazzi",
                                    description: "L'aggiornamento richiederà qualche minuto, attendere il completamento.\rVuoi continuare?",
                                    image: #imageLiteral(resourceName: "updateDb"), style: .alert)
    
    alertVC.addAction(PMAlertAction(title: "Annulla", style: .cancel, action: { () -> Void in
      print("Annullato")
    }))
    
    alertVC.addAction(PMAlertAction(title: "Aggiorna", style: .default, action: { () -> Void in
      DispatchQueue.global().async(execute: {
        DataManager.shared.startDataManager([])
      });
    }))
    
    present(alertVC, animated: true, completion: nil)
    
  }
  
  
  @IBAction func InAppPurchase(_ sender: UIBarButtonItem) {
    let alertVC = PMAlertController(title: "Rimuovi Pubblicità",
                                    description: "Rimuovi la pubblicità dall'App.",
                                    image: #imageLiteral(resourceName: "InAppPurchase"), style: .alert)
    
    alertVC.addAction(PMAlertAction(title: "Rimuovi Pubblicità", style: .default, action: { () -> Void in
      StoreKitManager.shared.acquista(product: "NoPubblicita")
    }))
    
    alertVC.addAction(PMAlertAction(title: "Ripristina Acquisti", style: .default, action: { () -> Void in
      StoreKitManager.shared.ripristina()
    }))
    
    alertVC.addAction(PMAlertAction(title: "Chiudi", style: .cancel, action: { () -> Void in
      print("Annullato")
    }))
    
    present(alertVC, animated: true, completion: nil)
    
  }
  
  internal func acquistoEffettuato() {
    let defaults = UserDefaults.standard
    defaults.set("99", forKey: "NoAds")
    
    DataManager.shared.viewBannerCon.constant = 0
    
    UIView.animate(withDuration: 5, animations: {
      self.view.layoutIfNeeded()
    })
  }
  
  internal func acquistoFallito() {
    
    let alertVC = PMAlertController(title: "Errore Acquisto",
                                    description: "Ci spiace ma non siamo riusciti a completare l'acquisto.",
                                    image: #imageLiteral(resourceName: "InAppDenied"), style: .alert)
    
    alertVC.addAction(PMAlertAction(title: "Chiudi", style: .default, action: { () -> Void in
      print("Acquisto Fallito")
    }))
    
    present(alertVC, animated: true, completion: nil)
    
  }
  
  
  internal func acquistoPronto() {
    //do nothing
  }
  
  
  //CONFIGURA LA VIEW CHE GIRA PER IL LOADING
  func configLoading() {
    config.size             = 140
    config.backgroundColor  = UIColor.darkGray
    config.spinnerColor     = UIColor.white
    config.titleTextColor   = UIColor.white
    config.spinnerLineWidth = 1.0
    config.foregroundColor  = UIColor.clear
    config.foregroundAlpha  = 0.5
    
    SwiftLoader.setConfig(config)
  }

}

