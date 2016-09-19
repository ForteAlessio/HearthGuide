//
//  StoreKitManager.swift
//  Rit.Treno
//
//  Created by Daniele Chiaradia on 29/08/16.
//  Copyright © 2016 Daniele Chiaradia. All rights reserved.
//

import UIKit
import StoreKit

protocol StoreKitManagerDelegate: class {
	func acquistoEffettuato()
	func acquistoFallito()
	func acquistoPronto()
}

class StoreKitManager: NSObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {
	
	static let shared = StoreKitManager()
	
	var viewController: UIViewController!
	var delegate: StoreKitManagerDelegate? = nil

	var productId: String! 
	var list = [SKProduct]()
	var p = SKProduct()
	
	func startStoreKitManager(product: String, viewController: UIViewController) {
		
		productId = product
		
		if(SKPaymentQueue.canMakePayments()) {
			
			let productID:NSSet = NSSet(objects: productId)
			let request: SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>)
			request.delegate = self
			request.start()
			
		}
	}
	
	func acquista(product:String) {
		if FileManager.default.fileExists(atPath: "/Library/MobileSubstrate/DynamicLibraries/iap.dylib") || FileManager.default.fileExists(atPath: "/Library/MobileSubstrate/DynamicLibraries/LocalIAPStore.dylib") {
      UIAlertView(title: NSLocalizedString("PRO_CONTROLLER_CRACK_DETECTION_TITLE", comment: ""), message: NSLocalizedString("PRO_CONTROLLER_CRACK_DETECTION_MESSAGE", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("SETTING_CONTROLLER_CRACK_DETECTION_OK", comment: "")).show()
		} else {
			for prod in list {
				let prodID = prod.productIdentifier
				if(prodID == product) {
					p = prod
					
					let pay = SKPayment(product: prod)
					SKPaymentQueue.default().add(self)
					SKPaymentQueue.default().add(pay)
					break
				}
			}
		}
		
	}
	
	func ripristina() {
		if FileManager.default.fileExists(atPath: "/Library/MobileSubstrate/DynamicLibraries/iap.dylib") || FileManager.default.fileExists(atPath: "/Library/MobileSubstrate/DynamicLibraries/LocalIAPStore.dylib") {
			let alert = UIAlertController(title: NSLocalizedString("PRO_CONTROLLER_CRACK_DETECTION_TITLE", comment: ""), message: NSLocalizedString("PRO_CONTROLLER_CRACK_DETECTION_MESSAGE", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
			
			alert.addAction(UIAlertAction(title: NSLocalizedString("SETTING_CONTROLLER_CRACK_DETECTION_OK", comment: ""), style: UIAlertActionStyle.destructive, handler: { action in }))
			
			viewController.present(alert, animated: true, completion: nil)
		} else {
			SKPaymentQueue.default().add(self)
			SKPaymentQueue.default().restoreCompletedTransactions()
		}
	}
	
	//MARK: - productsRequestDelegate
	
	func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
		print("Prodotti aggiunti: ")
		
		let myProduct = response.products
		
		for product in myProduct {
			print(product.productIdentifier)
			print(product.localizedTitle)
			print(product.localizedDescription)
			print(product.price)
			print("-------")
			
			list.append(product )
		}
		delegate?.acquistoPronto()
	}
	
	//MARK: - funzioni che partono al richiamo delle funzioni acquista/ripristinaAcquisti
	func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
		for transaction:AnyObject in transactions {
			let trans = transaction as! SKPaymentTransaction
			
			switch trans.transactionState {
			case .purchased:
				let prodID = p.productIdentifier as String
				switch prodID {			//aggiungere un caso per ogni product
				case productId:
					print("Acquistato")
					delegate?.acquistoEffettuato()
				default:
					print("ERRORE! Acquisto in app non aggiunto")
				}
				
				queue.finishTransaction(trans)
				break;
			case .failed:
				print("Errore Acquisto")
				delegate?.acquistoFallito()
				queue.finishTransaction(trans)
				break;
			default:
				break;
				
			}
		}
	}
	
	func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
		for transaction in queue.transactions {
			let t: SKPaymentTransaction = transaction
			
			let prodID = t.payment.productIdentifier as String
			
			switch prodID {	//aggiungere un caso per ogni product
			case productId:
				print("Acquistato")
				delegate?.acquistoEffettuato()
			default:
				print("ERRORE! Acquisto in app non aggiunto")
			}
			
		}
	}
	
}
