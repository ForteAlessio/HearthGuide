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
  let userCalendar = NSCalendar.currentCalendar()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    configLoading()
    
    DataManager.shared.mainController = self
    
    DataManager.shared.startGraph()
    
    notifyAlert()
    
    //controlla se ci sono aggiornamenti da fare, se si, imposta il badge sul button refresh
    let defaults = NSUserDefaults.standardUserDefaults()
    if let alr = defaults.stringForKey("alert") {
      DataManager.shared.iconBadge(alr)
    }
    
    self.clearsSelectionOnViewWillAppear = true
    
    navigationController!.navigationBar.backgroundColor = UIColor(rgba: "#34AADC")
    
    navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent
    
    navigationController!.navigationBar.tintColor = UIColor.whiteColor()
    
    navigationItem.titleView = UIImageView(image: UIImage(named: "logo"))
    
    self.tableView.backgroundView = UIImageView(image:UIImage(named:"background"))
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return DataManager.shared.Eroi.count
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return ""
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! HeroCell
    
    let hero = DataManager.shared.Eroi[indexPath.row]
    
    cell.laHero.text   = hero["nome"] as? String
    cell.imgHero.image = hero["img"]  as? UIImage
  
    let today = NSDate()
    
    let dayCalendarUnit: NSCalendarUnit = [.Day]
    let dayDifference = userCalendar.components(
      dayCalendarUnit,
      fromDate: (hero["update"] as? NSDate)!,
      toDate: today,
      options: [])
    
    if dayDifference.day == 0 {
      cell.laUpdate.text = "Ultimo Aggiornamento: oggi"
    }
    else {
      cell.laUpdate.text = "Ultimo Aggiornamento: " + String(dayDifference.day) + " giorni fa"
    }
    
    cell.vwBack.backgroundColor = UIColor(rgba: "#ecf0f1", alpha: 1)
    
    return cell
  }

  //CODICE PER DESELEZIONARE IL FOCUS DELLA CELLA AL RILASCIO DEL TOCCO IN MODO CHE NON RIMANGA IL FOCUS BRUTTO
  func deselectSelectedRowAnimated(animated: Bool) {
    if let indexPath = self.tableView.indexPathForSelectedRow {
      self.tableView.deselectRowAtIndexPath(indexPath, animated: animated)
    }
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    deselectSelectedRowAnimated(true)
  }
  
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let graph: Graph = Graph()
    
    if segue.identifier == "detail" {
      // controlliamo quale cella è stata toccata
      if let indexPath = self.tableView.indexPathForSelectedRow {
        
        let controller  = segue.destinationViewController as! DeckSlideController
        let nomeEroe    = DataManager.shared.Eroi[indexPath.row]["nome"] as! String
        DataManager.shared.heroSelected = nomeEroe
        
        let selectedDecks: Array<Entity> = graph.searchForEntity(groups: [nomeEroe])
        controller.deckName = selectedDecks
        
        for deck in selectedDecks {
          let cards: Array<Entity> = graph.searchForEntity(groups: [(deck["nome"] as! String)])
          controller.mazzi.append(cards)
        }
      }
    }
  }
  
  
  @IBAction func acRefresh(sender: MIBadgeButton) {
    let alertVC = PMAlertController(title: "Aggiornamento Mazzi",
                                    description: "L'aggiornamento richiederà qualche minuto, non chiudere l'app.\rVuoi continuare?",
                                    image: UIImage(named: "updateDb.png"), style: .Alert)
    
    alertVC.addAction(PMAlertAction(title: "Annulla", style: .Cancel, action: { () -> Void in
      print("Annullato")
    }))
    
    alertVC.addAction(PMAlertAction(title: "Aggiorna", style: .Default, action: { () -> Void in
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
        DataManager.shared.startDataManager([])
      });
    }))
    
    presentViewController(alertVC, animated: true, completion: nil)
  }
  
  //ALLO START DELL'APP CHIEDIAMO ALL'UTENTE SE VUOLE LE NOTIFICHE DI AGGIORNAMENTO
  func notifyAlert () {
    //se è il primo avvio chiediamo l'autorizzazione per le notifiche
    if DataManager.shared.Eroi.count == 0 {
      
      DataManager.shared.creaEroi()
      
      let alertVC = PMAlertController(title: "Notifiche Aggiornamenti",
                                      description: "Vuoi essere avvertito quando effettueremo un aggiornamento?\rSe non accetti, potrai aggiornare manualmente i mazzi.",
                                      image: UIImage(named: "permission.png"), style: .Alert)
      
      alertVC.addAction(PMAlertAction(title: "Avanti", style: .Cancel, action: { () -> Void in
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
          
          _ = OneSignal(launchOptions: DataManager.shared.option, appId: "7dbf6c05-34d0-4726-89b5-e79b4c1bf330", handleNotification: nil)
          
          DataManager.shared.startDataManager([])
        });
      }))
      
      presentViewController(alertVC, animated: true, completion: nil)
    }
    //altrimenti controlliamo se nelle impostazioni l'utente ha attivato le notifiche, se si impostiamo l'app per ricerverle
    else {
      let notificationType = UIApplication.sharedApplication().currentUserNotificationSettings()!.types
      
      if notificationType != UIUserNotificationType.None {
        _ = OneSignal(launchOptions: DataManager.shared.option, appId: "7dbf6c05-34d0-4726-89b5-e79b4c1bf330", handleNotification: nil)
      }
    }
  }
  
  //CONFIGURA LA VIEW CHE GIRA PER IL LOADING 
  func configLoading() {
    config.size             = 140
    config.backgroundColor  = UIColor.darkGrayColor()
    config.spinnerColor     = UIColor.whiteColor()
    config.titleTextColor   = UIColor.whiteColor()
    config.spinnerLineWidth = 1.0
    config.foregroundColor  = UIColor.clearColor()
    config.foregroundAlpha  = 0.5
    
    SwiftLoader.setConfig(config)
  }
}