//
//  HeroController.swift
//  HearthGuide
//
//  Created by Alessio Forte on 26/05/16.
//  Copyright © 2016 Alessio Forte. All rights reserved.
//

import UIKit

class HeroController: UITableViewController {

  @IBOutlet var bbRefresh: MIBadgeButton!
  
  var config       : SwiftLoader.Config = SwiftLoader.Config()
  let userCalendar = Calendar.current

  override func viewDidLoad() {
    super.viewDidLoad()
    
    configLoading()
    
    DataManager.shared.mainController = self
    
    DataManager.shared.startGraph()
    
    //controlla se ci sono aggiornamenti da fare, se si, imposta il badge sul button refresh
    let defaults = UserDefaults.standard
    if let alr = defaults.string(forKey: "alert") {
      DataManager.shared.iconBadge(alr)
    }
    
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
  
    let today = Date()
    
    let dayCalendarUnit: NSCalendar.Unit = [.day]
    let dayDifference = (userCalendar as NSCalendar).components(
      dayCalendarUnit,
      from: (hero["update"] as? Date)!,
      to: today,
      options: [])
    
    if dayDifference.day == 0 {
      cell.laUpdate.text = "Ultimo Aggiornamento: oggi"
    }
    else {
      cell.laUpdate.text = "Ultimo Aggiornamento: " + String(describing: dayDifference.day) + " giorni fa"
    }
    
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
                                    description: "L'aggiornamento richiederà qualche minuto, non chiudere l'app.\rVuoi continuare?",
                                    image: UIImage(named: "updateDb.png"), style: .alert)
    
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
 
  // questo metodo serve per aprire il dettaglio (RicettaController) via codice
  // lo usiamo per aprire la ricetta da un rislultato della ricerca di Spotlight inrenete alla nostra App
  // affinche funzioni il controller nello storyboard è stato nominato "visoreRicette" (nella carta di identità, campo Storyboard ID)
  func showDetailFromSpotlightSearch(_ index:Int) {
    let graph      : Graph        = Graph()
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    let controller = storyBoard.instantiateViewController(withIdentifier: "DeckSlide") as! DeckSlideController
    
    
    let nomeEroe    = DataManager.shared.Eroi[index]["nome"] as! String
    DataManager.shared.heroSelected = nomeEroe
    
    let selectedDecks: Array<Entity> = graph.searchForEntity(groups: [nomeEroe])
    controller.deckName = selectedDecks
    
    for deck in selectedDecks {
      let cards: Array<Entity> = graph.searchForEntity(groups: [(deck["nome"] as! String)])
      controller.mazzi.append(cards as AnyObject)
    }
    
    print(self.navigationController?.title)
    
    self.navigationController?.pushViewController(controller, animated: true)
    
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
