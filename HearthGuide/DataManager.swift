//
//  DataManager.swift
//  HearthGuide
//
//  Created by Alessio Forte on 17/06/16.
//  Copyright © 2016 Alessio Forte. All rights reserved.
//

import UIKit
import CoreSpotlight
import MobileCoreServices
import GoogleMobileAds


class DataManager: NSObject, GraphDelegate {
  
  static let shared = DataManager()
  
  
  var Eroi            : [Entity]    = []
  var Mazzi           : [Entity]    = []
  var Carte           : [Entity]    = []
  var nomiEroi        : [String]    = []
  var oldDevice       : [String]    = ["iPhone 5", "iPhone 5c", "iPhone 5s"]
  var readNotify      : Bool        = false
  var cardSelected    : UIImage     = UIImage()
  var heroSelected    : String      = ""
  var myDevice        : String      = ""
  var graph           : Graph       = Graph()
  var SpotLightIndex  : Int         = -99
  var option          : [AnyHashable: Any]?
  let userCalendar    = Calendar.current
  var viewBannerCon   : NSLayoutConstraint!
  var mainController  : HeroController!
  var infoController  : InfoCardController!

  func startGraph () {
    graph.delegate = self
    
    graph.watchForEntity(types: ["Eroe"])
    graph.watchForEntity(types: ["Mazzo"])
    graph.watchForEntity(types: ["Carta"])
    
    Eroi  = graph.searchForEntity(types: ["Eroe"])
  }

  
  func startDataManager(_ updatedHero: [String]) {
    
    startGraph()
    
    let defaults = UserDefaults.standard
    defaults.set("5", forKey: "alert")
    
    //controllo se l'iPhone è stato connesso ad internet
    if !Reachability.isConnectedToNetwork() {
      let alertVC = PMAlertController(title: "Errore Connessione",
                                      description: "Per poter aggiornare i Mazzi devi essere connesso ad Internet",
                                      image: #imageLiteral(resourceName: "warning"), style: .alert)
      
      alertVC.addAction(PMAlertAction(title: "Chiudi", style: .default, action: { () -> Void in
        print("Nessuna Connessione")
      }))
      
      self.mainController.present(alertVC, animated: true, completion: nil)
      
      return
    }
    
    if Thread.isMainThread {
      SwiftLoader.show("Download in corso..", animated: true)
    }else {
      DispatchQueue.main.async {
        SwiftLoader.show("Download in corso..", animated: true)
      }
    }
    
    DataManager.shared.mainController.navigationController!.progress = 0.0
    
    //se la richiesta proviene da notifica Cancello i dati solo gli eroi aggiornati
    //altrimenti li elimino tutti i dati
    if updatedHero.count > 0 {
      for i in 0..<updatedHero.count {
        DownloadManager.shared.emptyDbFromHero(updatedHero[i], last: i == (updatedHero.count - 1))
      }
    }else{
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
    indicizza(Mage)
    Mage.add(to: "Eroi")
    
    let Priest        = Entity(type: "Eroe")
    Priest["nome"]    = "Sacerdote" as AnyObject?
    Priest["img"]     = UIImage(named: "Priest")!
    Priest["update"]  = Date() as AnyObject?
    Eroi.append(Priest)
    nomiEroi.append("Sacerdote")
    indicizza(Priest)
    Priest.add(to: "Eroi")
    
    let Hunter        = Entity(type: "Eroe")
    Hunter["nome"]    = "Cacciatore" as AnyObject?
    Hunter["img"]     = UIImage(named: "Hunter")!
    Hunter["update"]  = Date() as AnyObject?
    Eroi.append(Hunter)
    nomiEroi.append("Cacciatore")
    indicizza(Hunter)
    Hunter.add(to: "Eroi")

    let Warrior        = Entity(type: "Eroe")
    Warrior["nome"]    = "Guerriero" as AnyObject?
    Warrior["img"]     = UIImage(named: "Warrior")!
    Warrior["update"]  = Date() as AnyObject?
    Eroi.append(Warrior)
    nomiEroi.append("Guerriero")
    indicizza(Warrior)
    Warrior.add(to: "Eroi")

    let Druid         = Entity(type: "Eroe")
    Druid["nome"]     = "Druido" as AnyObject?
    Druid["img"]      = UIImage(named: "Druid")!
    Druid["update"]   = Date() as AnyObject?
    Eroi.append(Druid)
    nomiEroi.append("Druido")
    indicizza(Druid)
    Druid.add(to: "Eroi")
    
    let Paladin        = Entity(type: "Eroe")
    Paladin["nome"]    = "Paladino" as AnyObject?
    Paladin["img"]     = UIImage(named: "Paladin")!
    Paladin["update"]  = Date() as AnyObject?
    Eroi.append(Paladin)
    nomiEroi.append("Paladino")
    indicizza(Paladin)
    Paladin.add(to: "Eroi")

    let Warlock        = Entity(type: "Eroe")
    Warlock["nome"]    = "Stregone" as AnyObject?
    Warlock["img"]     = UIImage(named: "Warlock")!
    Warlock["update"]  = Date() as AnyObject?
    Eroi.append(Warlock)
    nomiEroi.append("Stregone")
    indicizza(Warlock)
    Warlock.add(to: "Eroi")
    
    let Shaman        = Entity(type: "Eroe")
    Shaman["nome"]    = "Sciamano" as AnyObject?
    Shaman["img"]     = UIImage(named: "Shaman")!
    Shaman["update"]  = Date() as AnyObject?
    Eroi.append(Shaman)
    nomiEroi.append("Sciamano")
    indicizza(Shaman)
    Shaman.add(to: "Eroi")
    
    let Rogue         = Entity(type: "Eroe")
    Rogue["nome"]     = "Ladro" as AnyObject?
    Rogue["img"]      = UIImage(named: "Rogue")!
    Rogue["update"]   = Date() as AnyObject?
    Eroi.append(Rogue)
    nomiEroi.append("Ladro")
    indicizza(Rogue)
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
  
  // metodo per indicizzare in spotlight gli eori
  func indicizza(_ Hero: Entity) {
    // creiamo gli attributi dell'elemento cercabile in Spotlight
    let attributi = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
    
    attributi.title = Hero["nome"] as? String
    attributi.contentDescription = "Vai ai mazzi dell'Eroe. \n"
    attributi.pageHeight = 100
    attributi.thumbnailData = UIImagePNGRepresentation((Hero["img"] as? UIImage)!)
    
    // creiamo la CSSearchableItem
    let item = CSSearchableItem(uniqueIdentifier: "Eroe." + (Hero["nome"] as? String)!,
                                domainIdentifier: "com.AlessioForte.HearthGuide",
                                attributeSet: attributi)
    
    // indicizziamo in Spotlight
    CSSearchableIndex.default().indexSearchableItems([item]) { (error:Error?) -> Void in
      //print("^^Eroe indicizzato")
    }
  }
  
  // metodo per eliminate gli Eori indicizzati
  func eliminaRicettaDaSpotlight(_ Hero: Entity) {
    // ricostruiamo l'identifier
    let identifier = "Eroe." + (Hero["nome"] as? String)!
    
    // cancelliamo da Spotlight
    CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [identifier]) { (error) -> Void in
      //print("^^Eroe cancellato")
    }
  }
  
  // metodo che riporta la stringa da visualizzare per l'aggiornamento
  func getlastUpdate(_ ADate: Date) -> String {
    let dayDifference = (userCalendar as NSCalendar).components([.day], from: ADate, to: Date(), options: [])
    
    if dayDifference.day == 0 {
      return  "Ultimo Aggiornamento: oggi"
    } else if dayDifference.day == 1 {
        return  "Ultimo Aggiornamento: ieri"
      } else {
          return  "Ultimo Aggiornamento: " + String(describing: dayDifference.day!) + " giorni fa"
        }
  }
}
