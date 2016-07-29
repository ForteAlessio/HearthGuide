//
//  DownloadManager.swift
//  HearthGuide
//
//  Created by Alessio Forte on 17/06/16.
//  Copyright © 2016 Alessio Forte. All rights reserved.
//

import UIKit

class DownloadManager: NSObject {
  
  // questo è il codice speciale che lo rende un singleton
  class var shared : DownloadManager {
    get {
      struct Static {
        static var instance : DownloadManager? = nil
        static var token : dispatch_once_t = 0
      }
      
      dispatch_once(&Static.token) { Static.instance = DownloadManager() }
      
      return Static.instance!
    }
  }
  
  let group            = dispatch_group_create()
  var numRequest       = 0
  var heroUpdated      = 0
  var alamofireManager : Manager?
  let configuration    = NSURLSessionConfiguration.defaultSessionConfiguration()
  var Messaggio        : String!
  
  
  //Scarica e inserisce nel Database il Json dei Mazzo che gli passiamo
  func downloadJson(Heroes : [String]) {
    //importo il timeout per le request
    configuration.timeoutIntervalForRequest = 999
    alamofireManager = Manager(configuration: configuration)
    
    numRequest  = 0
    heroUpdated = 0
    Messaggio   = "Caricamento."
    
    DataManager.shared.graph.watchForEntity(types: ["Mazzo"])
    DataManager.shared.Mazzi = DataManager.shared.graph.searchForEntity(types: ["Mazzo"])
    
    DataManager.shared.graph.watchForEntity(types: ["Carta"])
    DataManager.shared.Carte = DataManager.shared.graph.searchForEntity(types: ["Carta"])
    
    let hero: Array<Entity> = DataManager.shared.graph.searchForEntity(groups: ["Eroi"])
    
    for x in 0..<Heroes.count {
      alamofireManager!.request(.GET, "http://www.puntoesteticamonteverde.it/HearthGuide/" + Heroes[x].lowercaseString + ".json").responseJSON { response in
        
        if let er = response.result.error {
          print(er.localizedDescription)
        }
        
        if let _ = response.result.value {
          self.heroUpdated += 1
          self.numRequest   = 1
          print("JSON OK")
        } else {
          print("JSON NIL")
          return
        }
        
        //Aggiorno la data di ultimo aggiornamento dell'eroe
        for k in 0..<9 {
          if (hero[k]["nome"] as! String).lowercaseString == Heroes[x].lowercaseString {
            let date = NSDate()
            hero[k]["update"] = date
            DataManager.shared.graph.save()
            break
          }
        }
        
        let jsonMazzi =  JSON(response.result.value!)
        
        //ciclo i mazzi
        for i in 0..<jsonMazzi.count {
          let deck = Entity(type: "Mazzo")
          
          if let deckName = jsonMazzi[i]["name_deck"].string {
            deck["nome"] = deckName
          }
          
          if let deckGuida = jsonMazzi[i]["guida"].string {
            deck["guida"] = deckGuida
          }
          
          deck["eroe"] = Heroes[x]
          
          deck.addGroup(Heroes[x])
          DataManager.shared.Mazzi.append(deck)
          
          
          //SCARICO LE CARTE CHE DISTINGUONO IL MAZZO
          if let deckCards = jsonMazzi[i]["cards"].arrayObject {
            let jsonCard =  JSON(deckCards)
            
            //ciclo le carte
            for j in 0..<jsonCard.count {
              let card = Entity(type: "Carta")
              
              if let cardName = jsonCard[j]["name"].string {
                card["nome"] = cardName
              }
              
              if let cardId = jsonCard[j]["id"].string {
                card["id"] = cardId
              }
              
              card["mazzo"] = deck["nome"] as! String
              card["eroe"]  = Heroes[x]
              
              dispatch_group_enter(self.group)
              let url = "http://wow.zamimg.com/images/hearthstone/cards/itit/original/" + (card["id"] as! String) + ".png"
              self.alamofireManager!.request(.GET, url).response { request, response, data, error in
                
                if let er = error {
                  print(er.localizedDescription)
                }
                
                if error == nil && data != nil {
                  card["immagine"] = UIImage(data: data!)!
                  if NSThread.isMainThread() {
                    SwiftLoader.show("Carico " + (card["eroe"] as! String), animated: true)//self.formatMessage(self.Messaggio), animated: true)
                  }else {
                    dispatch_sync(dispatch_get_main_queue()) {
                      SwiftLoader.show("Carico " + (card["eroe"] as! String), animated: true)//self.formatMessage(self.Messaggio), animated: true)
                    }
                  }
                  self.Messaggio = self.formatMessage(self.Messaggio)
                }
                
                DataManager.shared.graph.save()
                dispatch_group_leave(self.group)
              }
              
              DataManager.shared.Carte.append(card)
              card.addGroup(deck["nome"] as! String)
            }
          }
          
          DataManager.shared.graph.save()
          
          //SCARICO LA LISTA COMPLETA DELLE CARTE
          if let listCards = jsonMazzi[i]["lista"].arrayObject {
            let jsonCard =  JSON(listCards)
            
            //ciclo le carte per le Info del Mazzo
            for j in 0..<jsonCard.count {
              let card = Entity(type: "Carta")
              
              if let cardName = jsonCard[j]["name"].string {
                card["nome"] = cardName
              }
              
              if let cardId = jsonCard[j]["id"].string {
                card["id"] = cardId
              }
              
              if let numCopie = jsonCard[j]["copie"].string {
                card["copie"] = numCopie
              }
              
              card["mazzo"] = deck["nome"] as! String
              card["eroe"]  = Heroes[x]
              
              dispatch_group_enter(self.group)
              let url = "http://wow.zamimg.com/images/hearthstone/cards/itit/original/" + (card["id"] as! String) + ".png"
              self.alamofireManager!.request(.GET, url).response { request, response, data, error in
                
                if let er = error {
                  print(er.localizedDescription)
                }
                
                if error == nil && data != nil {
                  card["immagine"] = UIImage(data: data!)!
                  if NSThread.isMainThread() {
                    SwiftLoader.show("Carico " + (card["eroe"] as! String), animated: true)//self.formatMessage(self.Messaggio), animated: true)
                  }else {
                    dispatch_sync(dispatch_get_main_queue()) {
                      SwiftLoader.show("Carico " + (card["eroe"] as! String), animated: true)//self.formatMessage(self.Messaggio), animated: true)
                    }
                  }
                  self.Messaggio = self.formatMessage(self.Messaggio)
                }
                
                DataManager.shared.graph.save()
                dispatch_group_leave(self.group)
              }
              
              DataManager.shared.Carte.append(card)
              card.addGroup((deck["nome"] as! String) + "Info")
              
            }
          }
          
          DataManager.shared.graph.save()
          
          //SCARICO LE CARTE PIU' FORTI PER MAZZO
          if let topCards = jsonMazzi[i]["topcard"].arrayObject {
            let jsonCard =  JSON(topCards)
            
            //ciclo le carte per le Carte più forti del Mazzo
            for j in 0..<jsonCard.count {
              let card = Entity(type: "Carta")
              
              if let cardName = jsonCard[j]["name"].string {
                card["nome"] = cardName
              }
              
              if let cardId = jsonCard[j]["id"].string {
                card["id"] = cardId
              }
              
              if let numCopie = jsonCard[j]["copie"].string {
                card["copie"] = numCopie
              }
              
              card["mazzo"] = deck["nome"] as! String
              card["eroe"]  = Heroes[x]
              
              DataManager.shared.graph.save()
              DataManager.shared.Carte.append(card)
              card.addGroup((deck["nome"] as! String) + "TopCards")
            }
          }
          
        }
        DataManager.shared.graph.save()
        
        //alla fine delle 9 richieste principali fa sparire la view di caricamento
        dispatch_group_notify(self.group, dispatch_get_main_queue()) {
          if self.numRequest == self.heroUpdated {
            if NSThread.isMainThread() {
              SwiftLoader.hide()
              DataManager.shared.mainController.tableView.reloadData()
            }else {
              dispatch_sync(dispatch_get_main_queue()) {
                SwiftLoader.hide()
                DataManager.shared.mainController.tableView.reloadData()
              }
            }
            let defaults = NSUserDefaults.standardUserDefaults()
            
            defaults.setObject("", forKey: "alert")
            if let alr = defaults.stringForKey("alert") {
              DataManager.shared.iconBadge(alr)
            }
          }
          self.numRequest += 1
        }
      }
    }
  }
  
  
  //cancella tutti i dati riguardanti l'eroe che gli passiamo
  func emptyDbFromHero(ANome: String) {
    DataManager.shared.graph.watchForEntity(types: ["Mazzo"])
    DataManager.shared.Mazzi = DataManager.shared.graph.searchForEntity(types: ["Mazzo"])
    
    DataManager.shared.graph.watchForEntity(types: ["Carta"])
    DataManager.shared.Carte = DataManager.shared.graph.searchForEntity(types: ["Carta"])
    
    for mazzo in DataManager.shared.Mazzi {
      if (mazzo["eroe"] as! String).lowercaseString == ANome.lowercaseString {
        mazzo.removeGroup(ANome)
        mazzo.delete()
      }
    }
    
    for carta in DataManager.shared.Carte {
      if (carta["eroe"] as! String).lowercaseString == ANome.lowercaseString {
        carta.removeGroup(carta["mazzo"] as! String)
        carta.delete()
      }
    }
    
    DataManager.shared.graph.save()
  }
  
  //cancella tutti i dati nel database interno di graph
  func emptyLocalDb() {
    DataManager.shared.graph.watchForEntity(types: ["Eroe"])
    DataManager.shared.Eroi  = DataManager.shared.graph.searchForEntity(types: ["Eroe"])
    
    DataManager.shared.graph.watchForEntity(types: ["Mazzo"])
    DataManager.shared.Mazzi = DataManager.shared.graph.searchForEntity(types: ["Mazzo"])
    
    DataManager.shared.graph.watchForEntity(types: ["Carta"])
    DataManager.shared.Carte = DataManager.shared.graph.searchForEntity(types: ["Carta"])
    
    for eroe in DataManager.shared.Eroi {
      eroe.removeGroup("Eroi")
    }
    DataManager.shared.Eroi.removeAll()
    
    for mazzo in DataManager.shared.Mazzi {
      mazzo.removeGroup(mazzo["eroe"] as! String)
    }
    DataManager.shared.Mazzi.removeAll()
    
    for carta in DataManager.shared.Carte {
      carta.removeGroup(carta["mazzo"] as! String)
    }
    DataManager.shared.Carte.removeAll()
    
    DataManager.shared.graph.clear()
    
    DataManager.shared.graph.save()
  }
  
  func formatMessage (AMessage : String) -> String {
    switch AMessage {
    case "Caricamento."  : return "Caricamento.."
    case "Caricamento.." : return "Caricamento..."
    case "Caricamento...": return "Caricamento."
      
    default: return "Caricamento."
    }
  }
}
