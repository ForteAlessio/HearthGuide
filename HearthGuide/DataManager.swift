//
//  DataManager.swift
//  HearthGuide
//
//  Created by Alessio Forte on 17/06/16.
//  Copyright © 2016 Alessio Forte. All rights reserved.
//

import UIKit

class DataManager: NSObject, GraphDelegate {
  
  static let shared = DataManager()
  
  
  var Eroi            : [Entity]    = []
  var Mazzi           : [Entity]    = []
  var Carte           : [Entity]    = []
  var nomiEroi        : [String]    = []
  var readNotify      : Bool        = false
  var cardSelected    : UIImage     = UIImage()
  var heroSelected    : String      = ""
  var graph           : Graph       = Graph()
  var canLaunch       : Bool        = false
  var option          : [AnyHashable: Any]?
  var mainController  : HeroController!

  func startGraph () {
    graph.delegate = self
    
    graph.watchForEntity(types: ["Eroe"])
    graph.watchForEntity(types: ["Mazzo"])
    graph.watchForEntity(types: ["Carta"])
    
    Eroi  = graph.searchForEntity(types: ["Eroe"])
  }

  
  func startDataManager(_ updatedHero: [String]) {
    
    startGraph()
    
    //controllo se l'iPhone è stato connesso ad internet
    if !Reachability.isConnectedToNetwork() {
      let alertVC = PMAlertController(title: "Errore Connessione",
                                      description: "Per poter aggiornare i Mazzi devi essere connesso ad Internet",
                                      image: UIImage(named: "warning.png"), style: .alert)
      
      alertVC.addAction(PMAlertAction(title: "Ok", style: .default, action: { () -> Void in
        print("Nessuna Connessione")
      }))
      
      self.mainController.present(alertVC, animated: true, completion: nil)
      
      return
    }
    
    if Thread.isMainThread {
      SwiftLoader.show("Caricamento", animated: true)
    }else {
      DispatchQueue.main.sync {
        SwiftLoader.show("Caricamento", animated: true)
      }
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
    graph.async()
  }

  func creaEroi () {
    graph.delegate = self
    
    graph.watchForEntity(types: ["Eroe"])
    Eroi  = graph.searchForEntity(types: ["Eroe"])
    
    let Mage: Entity = Entity(type: "Eroe")
    Mage["nome"]     = "Mago" as AnyObject?
    Mage["img"]      = UIImage(named: "Mage")!
    Mage["update"]   = Date() as AnyObject?
    Eroi.append(Mage)
    nomiEroi.append("Mago")
    Mage.add(to: "Eroi")
    
    let Priest        = Entity(type: "Eroe")
    Priest["nome"]    = "Sacerdote" as AnyObject?
    Priest["img"]     = UIImage(named: "Priest")!
    Priest["update"]  = Date() as AnyObject?
    Eroi.append(Priest)
    nomiEroi.append("Sacerdote")
    Priest.add(to: "Eroi")
    
    let Hunter        = Entity(type: "Eroe")
    Hunter["nome"]    = "Cacciatore" as AnyObject?
    Hunter["img"]     = UIImage(named: "Hunter")!
    Hunter["update"]  = Date() as AnyObject?
    Eroi.append(Hunter)
    nomiEroi.append("Cacciatore")
    Hunter.add(to: "Eroi")

    let Warrior       = Entity(type: "Eroe")
    Warrior["nome"]   = "Guerriero" as AnyObject?
    Warrior["img"]    = UIImage(named: "Warrior")!
    Warrior["update"] = Date() as AnyObject?
    Eroi.append(Warrior)
    nomiEroi.append("Guerriero")
    Warrior.add(to: "Eroi")

    let Druid         = Entity(type: "Eroe")
    Druid["nome"]     = "Druido" as AnyObject?
    Druid["img"]      = UIImage(named: "Druid")!
    Druid["update"]   = Date() as AnyObject?
    Eroi.append(Druid)
    nomiEroi.append("Druido")
    Druid.add(to: "Eroi")
    
    let Paladin       = Entity(type: "Eroe")
    Paladin["nome"]   = "Paladino" as AnyObject?
    Paladin["img"]    = UIImage(named: "Paladin")!
    Paladin["update"] = Date() as AnyObject?
    Eroi.append(Paladin)
    nomiEroi.append("Paladino")
    Paladin.add(to: "Eroi")

    let Warlock       = Entity(type: "Eroe")
    Warlock["nome"]   = "Stregone" as AnyObject?
    Warlock["img"]    = UIImage(named: "Warlock")!
    Warlock["update"] = Date() as AnyObject?
    Eroi.append(Warlock)
    nomiEroi.append("Stregone")
    Warlock.add(to: "Eroi")
    
    let Shaman        = Entity(type: "Eroe")
    Shaman["nome"]    = "Sciamano" as AnyObject?
    Shaman["img"]     = UIImage(named: "Shaman")!
    Shaman["update"]  = Date() as AnyObject?
    Eroi.append(Shaman)
    nomiEroi.append("Sciamano")
    Shaman.add(to: "Eroi")
    
    let Rogue         = Entity(type: "Eroe")
    Rogue["nome"]     = "Ladro" as AnyObject?
    Rogue["img"]      = UIImage(named: "Rogue")!
    Rogue["update"]   = Date() as AnyObject?
    Eroi.append(Rogue)
    nomiEroi.append("Ladro")
    Rogue.add(to: "Eroi")

    graph.async()
  }
  
  func iconBadge(_ ANotify: String) {
    //ANotify = 0 : No  Badge
    //ANotify = 1 : "1" Badge
    mainController.bbRefresh.badgeString     = ANotify
    mainController.bbRefresh.badgeTextColor  = UIColor.white
    mainController.bbRefresh.badgeEdgeInsets = UIEdgeInsetsMake(18, 5, 0, 15)
  }
}
