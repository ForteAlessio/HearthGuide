//
//  DataManager.swift
//  HearthGuide
//
//  Created by Alessio Forte on 17/06/16.
//  Copyright © 2016 Alessio Forte. All rights reserved.
//

import UIKit

class DataManager: NSObject, GraphDelegate {
  
  class var shared: DataManager {
    get {
      struct Static {
        static var instance: DataManager? = nil
        static var token: dispatch_once_t = 0
      }
      
      dispatch_once(&Static.token) { Static.instance = DataManager() }
      
      return Static.instance!
    }
  }
  
  
  var Eroi            : [Entity] = []
  var Mazzi           : [Entity] = []
  var Carte           : [Entity] = []
  var nomiEroi        : [String] = []
  var readNotify      : Bool     = false
  var option          : [NSObject: AnyObject]?
  var cardSelected    : UIImage  = UIImage()
  var heroSelected    : String   = ""
  var graph           : Graph = Graph()
  var mainController  : HeroController!
  var canLaunch       : Bool     = false

  
  func startGraph () {
    graph.delegate = self
    
    graph.watchForEntity(types: ["Eroe"])
    graph.watchForEntity(types: ["Mazzo"])
    graph.watchForEntity(types: ["Carta"])
    
    Eroi  = graph.searchForEntity(types: ["Eroe"])
  }

  
  func startDataManager(updatedHero: [String]) {
    
    startGraph()
    
    if NSThread.isMainThread() {
      SwiftLoader.show("Caricamento", animated: true)
    }else {
      dispatch_sync(dispatch_get_main_queue()) {
        SwiftLoader.show("Caricamento", animated: true)
      }
    }
    
    //controllo se l'iPhone è stato connesso ad internet
    let status = Reach().connectionStatus()
    
    switch status {
    case .Unknown, .Offline:
      let alertVC = PMAlertController(title: "Errore Connessione",
                                      description: "Per poter aggiornare i Mazzi devi essere connesso ad Internet",
                                      image: UIImage(named: "warning.png"), style: .Alert)
      
      alertVC.addAction(PMAlertAction(title: "Ok", style: .Default, action: { () -> Void in
        print("Nessuna Connessione")
      }))
      
      if NSThread.isMainThread() {
        SwiftLoader.hide()
      }else {
        dispatch_sync(dispatch_get_main_queue()) {
          SwiftLoader.hide()
        }
      }
      
      mainController.presentViewController(alertVC, animated: true, completion: nil)

      return
    default: print("")
    }
    
    //se la richiesta proviene da notifica Cancello i dati solo gli eroi aggiornati
    //altrimenti li elimino tutti i dati
    if updatedHero.count > 0 {
      for i in 0..<updatedHero.count {
        DownloadManager.shared.emptyDbFromHero(updatedHero[i])
      }
    }else {
      DownloadManager.shared.emptyLocalDb()
      
      nomiEroi.removeAll()
      
      creaEroi()
    }

    //se la richiesta proviene da notifica aggiorno solo gli eroi aggiornati
    //altrimenti li aggiorno tutti
    if updatedHero.count > 0 {
      DownloadManager.shared.downloadJson(updatedHero)
    }else {
      DownloadManager.shared.downloadJson(nomiEroi)
    }

    // salviamo il Database
    graph.save { (success: Bool, error: NSError?) in
      if let e = error {
        print(e.localizedDescription)
      }
    }
  }

  func creaEroi () {
    graph.delegate = self
    
    graph.watchForEntity(types: ["Eroe"])
    Eroi  = graph.searchForEntity(types: ["Eroe"])
    
    let Mage         = Entity(type: "Eroe")
    Mage["nome"]     = "Mago"
    Mage["img"]      = UIImage(named: "Mage")!
    Mage["update"]   = NSDate()
    Eroi.append(Mage)
    nomiEroi.append("Mago")
    Mage.addGroup("Eroi")
    
    let Priest        = Entity(type: "Eroe")
    Priest["nome"]    = "Sacerdote"
    Priest["img"]     = UIImage(named: "Priest")!
    Priest["update"]  = NSDate()
    Eroi.append(Priest)
    nomiEroi.append("Sacerdote")
    Priest.addGroup("Eroi")
    
    let Hunter        = Entity(type: "Eroe")
    Hunter["nome"]    = "Cacciatore"
    Hunter["img"]     = UIImage(named: "Hunter")!
    Hunter["update"]  = NSDate()
    Eroi.append(Hunter)
    nomiEroi.append("Cacciatore")
    Hunter.addGroup("Eroi")

    let Warrior       = Entity(type: "Eroe")
    Warrior["nome"]   = "Guerriero"
    Warrior["img"]    = UIImage(named: "Warrior")!
    Warrior["update"] = NSDate()
    Eroi.append(Warrior)
    nomiEroi.append("Guerriero")
    Warrior.addGroup("Eroi")

    let Druid         = Entity(type: "Eroe")
    Druid["nome"]     = "Druido"
    Druid["img"]      = UIImage(named: "Druid")!
    Druid["update"]   = NSDate()
    Eroi.append(Druid)
    nomiEroi.append("Druido")
    Druid.addGroup("Eroi")
    
    let Paladin       = Entity(type: "Eroe")
    Paladin["nome"]   = "Paladino"
    Paladin["img"]    = UIImage(named: "Paladin")!
    Paladin["update"] = NSDate()
    Eroi.append(Paladin)
    nomiEroi.append("Paladino")
    Paladin.addGroup("Eroi")

    let Warlock       = Entity(type: "Eroe")
    Warlock["nome"]   = "Stregone"
    Warlock["img"]    = UIImage(named: "Warlock")!
    Warlock["update"] = NSDate()
    Eroi.append(Warlock)
    nomiEroi.append("Stregone")
    Warlock.addGroup("Eroi")
    
    let Shaman        = Entity(type: "Eroe")
    Shaman["nome"]    = "Sciamano"
    Shaman["img"]     = UIImage(named: "Shaman")!
    Shaman["update"]  = NSDate()
    Eroi.append(Shaman)
    nomiEroi.append("Sciamano")
    Shaman.addGroup("Eroi")
    
    let Rogue         = Entity(type: "Eroe")
    Rogue["nome"]     = "Ladro"
    Rogue["img"]      = UIImage(named: "Rogue")!
    Rogue["update"]   = NSDate()
    Eroi.append(Rogue)
    nomiEroi.append("Ladro")
    Rogue.addGroup("Eroi")

    graph.save()
  }
  
  func iconBadge(ANotify: String) {
    //ANotify = 0 : No  Badge
    //ANotify = 1 : "1" Badge
    mainController.bbRefresh.badgeString     = ANotify
    mainController.bbRefresh.badgeTextColor  = UIColor.whiteColor()
    mainController.bbRefresh.badgeEdgeInsets = UIEdgeInsetsMake(18, 5, 0, 15)
  }
}
