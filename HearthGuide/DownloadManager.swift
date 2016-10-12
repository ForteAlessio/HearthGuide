//
//  DownloadManager.swift
//  HearthGuide
//
//  Created by Alessio Forte on 17/06/16.
//  Copyright © 2016 Alessio Forte. All rights reserved.
//

import UIKit

class DownloadManager: NSObject {
  
  static let shared = DownloadManager()

  
  let group            = DispatchGroup()
  var numRequest       = 0
  var heroUpdated      = 0
  let configuration    = URLSessionConfiguration.default
  var valueBar:Float   = 0.0
  
  
  //Scarica e inserisce nel Database il Json dei Mazzo che gli passiamo
  func downloadJson(_ Heroes : [String]) {
    //importo il timeout per le request
    configuration.timeoutIntervalForRequest = 999
    
    numRequest  = 0
    heroUpdated = 0
    
    DataManager.shared.graph.watchForEntity(types: ["Mazzo"])
    DataManager.shared.Mazzi = DataManager.shared.graph.searchForEntity(types: ["Mazzo"])
    
    DataManager.shared.graph.watchForEntity(types: ["Carta"])
    DataManager.shared.Carte = DataManager.shared.graph.searchForEntity(types: ["Carta"])
    
    let hero: Array<Entity> = DataManager.shared.graph.searchForEntity(groups: ["Eroi"])
    
    if Thread.isMainThread {
      SwiftLoader.show("Update Mazzi..", animated: true)
    }else {
      DispatchQueue.main.async {
        SwiftLoader.show("Update Mazzi..", animated: true)
      }
    }
    valueBar = 0.0
    
    for x in 0..<Heroes.count {
      _ = request("http://www.puntoesteticamonteverde.it/HearthGuide/" + Heroes[x].lowercased() + ".json", method: .get).responseJSON { response in
        
        // come leggere i dati del response
        //print(response.request)  // original URL request
        //print(response.response) // URL response
        //print(response.data)     // server data
        //print(response.result)   // result of response serialization
        
        
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
          if (hero[k]["nome"] as! String).lowercased() == Heroes[x].lowercased() {
            let date = Date()
            hero[k]["update"] = date
            DataManager.shared.graph.async()
            break
          }
        }
        
        let jsonMazzi =  JSON(response.result.value!)
        
        //ciclo i mazzi
        for i in 0..<jsonMazzi.count {
          let deck: Entity = Entity(type: "Mazzo")
          
          if let deckName = jsonMazzi[i]["name_deck"].string {
            deck["nome"] = deckName
          }
          
          if let deckGuida = jsonMazzi[i]["guida"].string {
            deck["guida"] = deckGuida
          }
          
          deck["eroe"] = Heroes[x]
          
          deck.add(to: Heroes[x])
          DataManager.shared.Mazzi.append(deck)
          
          
          //SCARICO LE CARTE CHE DISTINGUONO IL MAZZO
          if let deckCards = jsonMazzi[i]["cards"].arrayObject {
            let jsonCard =  JSON(deckCards)
            
            //ciclo le carte
            for j in 0..<jsonCard.count {
              let card: Entity = Entity(type: "Carta")
              
              if Thread.isMainThread {
                self.valueBar += 0.001
                DataManager.shared.mainController.navigationController!.setProgress(self.valueBar, animated: true)
              }else {
                DispatchQueue.main.async {
                  self.valueBar += 0.001
                  DataManager.shared.mainController.navigationController!.setProgress(self.valueBar, animated: true)
                }
              }
              
              if let cardName = jsonCard[j]["name"].string {
                card["nome"] = cardName
              }
              
              if let cardId = jsonCard[j]["id"].string {
                card["id"] = cardId
              }
              
              card["mazzo"] = deck["nome"] as! String
              card["eroe"]  = Heroes[x]
              
              self.group.enter()
              
              var url = ""
              
              if (card["id"] as! String).range(of: "KAR_") != nil {
                url = "http://wow.zamimg.com/images/hearthstone/cards/enus/original/" + (card["id"] as! String) + ".png"
              }
              else {
                url = "http://wow.zamimg.com/images/hearthstone/cards/itit/original/" + (card["id"] as! String) + ".png"
              }
              
              _ = request(url, method: .get).responseJSON { response in
                
                card["immagine"] = UIImage(data: response.data!)!
                
                DataManager.shared.graph.async()
                self.group.leave()
              }
              
              DataManager.shared.Carte.append(card)
              card.add(to: deck["nome"] as! String)
            }
          }
          
          DataManager.shared.graph.async()
          
          //SCARICO LA LISTA COMPLETA DELLE CARTE
          if let listCards = jsonMazzi[i]["lista"].arrayObject {
            let jsonCard =  JSON(listCards)
            
            for j in 0..<jsonCard.count {
              let card: Entity = Entity(type: "Carta")
              
              if Thread.isMainThread {
                self.valueBar += 0.001
                DataManager.shared.mainController.navigationController!.setProgress(self.valueBar, animated: true)
              }else {
                DispatchQueue.main.async {
                  self.valueBar += 0.001
                  DataManager.shared.mainController.navigationController!.setProgress(self.valueBar, animated: true)
                }
              }
              
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
              
              self.group.enter()
             
              var url = ""
              
              if (card["id"] as! String).range(of: "KAR_") != nil {
                url = "http://wow.zamimg.com/images/hearthstone/cards/enus/original/" + (card["id"] as! String) + ".png"
              }
              else {
                url = "http://wow.zamimg.com/images/hearthstone/cards/itit/original/" + (card["id"] as! String) + ".png"
              }
              _ = request(url, method: .get).responseJSON { response in
                
                if Thread.isMainThread {
                  self.valueBar += 0.001
                  DataManager.shared.mainController.navigationController!.setProgress(self.valueBar, animated: true)
                }else {
                  DispatchQueue.main.async {
                    self.valueBar += 0.001
                    DataManager.shared.mainController.navigationController!.setProgress(self.valueBar, animated: true)
                  }
                }
                
                card["immagine"] = UIImage(data: response.data!)!
                
                DataManager.shared.graph.async()
                self.group.leave()
              }
              
              DataManager.shared.Carte.append(card)
              card.add(to: deck["nome"] as! String + "Info")
              
            }
          }
          
          DataManager.shared.graph.async()
          
          //SCARICO LE CARTE PIU' FORTI PER MAZZO
          if let topCards = jsonMazzi[i]["topcard"].arrayObject {
            let jsonCard =  JSON(topCards)
            
            //ciclo le carte per le Carte più forti del Mazzo
            for j in 0..<jsonCard.count {
              let card: Entity = Entity(type: "Carta")
              
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
              
              DataManager.shared.graph.async()
              DataManager.shared.Carte.append(card)
              card.add(to: deck["nome"] as! String + "TopCards")
            }
          }
          
        }
        DataManager.shared.graph.async()
        
        //alla fine delle 9 richieste principali fa sparire la view di caricamento
        self.group.notify(queue: DispatchQueue.main) {
          if self.numRequest == self.heroUpdated {
            
            if Thread.isMainThread {
              SwiftLoader.hide()
              DataManager.shared.mainController.navigationController!.finishProgress()
              DataManager.shared.mainController.tableView.reloadData()
            }else {
              DispatchQueue.main.async {
                SwiftLoader.hide()
                DataManager.shared.mainController.navigationController!.finishProgress()
                DataManager.shared.mainController.tableView.reloadData()
              }
            }
          
            let defaults = UserDefaults.standard
            
            defaults.set("", forKey: "alert")
            if let alr = defaults.string(forKey: "alert") {
              DataManager.shared.iconBadge(alr)
            }
            
            let alertVC = PMAlertController(title: "Aggiornamento Eseguito",
                                            description: "L'aggiornamento dei Mazzi è stato terminato correttamente.",
                                            image: #imageLiteral(resourceName: "endUpdate"), style: .alert)
            
            alertVC.addAction(PMAlertAction(title: "Ok", style: .default, action: { () -> Void in
              print("^^Fine Aggiornamento")
            }))
            
            DataManager.shared.mainController.present(alertVC, animated: true, completion: nil)

          }
          self.numRequest += 1
        }
      }
    }
  }
  
  
  //cancella tutti i dati riguardanti l'eroe che gli passiamo
  func emptyDbFromHero(_ ANome: String, last: Bool) {
    DataManager.shared.graph.watchForEntity(types: ["Mazzo"])
    DataManager.shared.Mazzi = DataManager.shared.graph.searchForEntity(types: ["Mazzo"])
    
    DataManager.shared.graph.watchForEntity(types: ["Carta"])
    DataManager.shared.Carte = DataManager.shared.graph.searchForEntity(types: ["Carta"])
    
    let val: Float = 0.0002
    
    for mazzo in DataManager.shared.Mazzi {
      DispatchQueue.main.async {
        print(DataManager.shared.mainController.navigationController!.progress + val)
        DataManager.shared.mainController.navigationController!.setProgress(DataManager.shared.mainController.navigationController!.progress + val, animated: true)
      }
      
      if (mazzo["eroe"] as! String).lowercased() == ANome.lowercased() {
        mazzo.remove(tag: ANome)
        mazzo.delete()
      }
    }
    
    for carta in DataManager.shared.Carte {
      DispatchQueue.main.async {
        print(DataManager.shared.mainController.navigationController!.progress + val)
        DataManager.shared.mainController.navigationController!.setProgress(DataManager.shared.mainController.navigationController!.progress + val, animated: true)
      }
      
      if (carta["eroe"] as! String).lowercased() == ANome.lowercased() {
        carta.remove(tag: carta["mazzo"] as! String)
        carta.delete()
      }
    }
    
    DataManager.shared.graph.async()
    
    if last {
      DispatchQueue.main.async {
        DataManager.shared.mainController.navigationController!.finishProgress()
      }
    }
  }
  
  //cancella tutti i dati nel database interno di graph
  func emptyLocalDb() {
    DataManager.shared.graph.watchForEntity(types: ["Eroe"])
    DataManager.shared.Eroi  = DataManager.shared.graph.searchForEntity(types: ["Eroe"])
    
    DataManager.shared.graph.watchForEntity(types: ["Mazzo"])
    DataManager.shared.Mazzi = DataManager.shared.graph.searchForEntity(types: ["Mazzo"])
    
    DataManager.shared.graph.watchForEntity(types: ["Carta"])
    DataManager.shared.Carte = DataManager.shared.graph.searchForEntity(types: ["Carta"])
    
    DataManager.shared.mainController.navigationController!.progress = 0.0
    let val: Float = 1 / Float(DataManager.shared.Mazzi.count + DataManager.shared.Carte.count + 20)

    for eroe in DataManager.shared.Eroi {
      eroe.remove(tag: "Eroi")
    }
    DataManager.shared.Eroi.removeAll()
    
    for mazzo in DataManager.shared.Mazzi {
      DispatchQueue.main.async {
        DataManager.shared.mainController.navigationController!.setProgress(DataManager.shared.mainController.navigationController!.progress + val, animated: true)
      }

      mazzo.remove(tag: mazzo["eroe"] as! String)
    }
    DataManager.shared.Mazzi.removeAll()
    
    for carta in DataManager.shared.Carte {
      DispatchQueue.main.async {
        DataManager.shared.mainController.navigationController!.setProgress(DataManager.shared.mainController.navigationController!.progress + val, animated: true)
      }

      carta.remove(tag: carta["mazzo"] as! String)
    }
    DataManager.shared.Carte.removeAll()
    
    DataManager.shared.graph.clear()
    
    DataManager.shared.graph.async()
    
    if val != 0.05 {
      DispatchQueue.main.async {
        DataManager.shared.mainController.navigationController!.finishProgress()
      }
    }
  }
}
