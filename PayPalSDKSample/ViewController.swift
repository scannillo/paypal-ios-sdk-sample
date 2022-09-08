//
//  ViewController.swift
//  PayPalSDKSample
//
//  Created by Samantha Cannillo on 9/1/22.
//

import UIKit
import AuthenticationServices
import Card
import PaymentsCore

class ViewController: UIViewController {
    
    let clientID = "AUiHPkr1LO7TzZH0Q5_aE8aGNmTiXZh6kKErYFrtXNYSDv13FrN2NElXabVV4fNrZol7LAaVb1gJj9lr"
    var accessToken: String?
    var orderID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Get AccessToken
        Networking.sharedService.fetchAccessToken { [weak self] accessToken in
            guard let self = self else { return }
            
            print("Fetched accessToken: \(String(describing: accessToken))")
            self.accessToken = accessToken
            
            // 2. Get OrderID
            let orderParams = CreateOrderParams(
                intent: "CAPTURE",
                purchaseUnits: [
                    PurchaseUnit(
                        amount: Amount(
                            currencyCode: "USD",
                            value: "10.00")
                    )],
                applicationContext: ApplicationContext(
                    returnUrl: "https://example.com/returnUrl",
                    cancelUrl: "https://example.com/cancelUrl"
                )
            )
            Networking.sharedService.createOrderID(orderParams: orderParams) { orderID in
                print("Fetched OrderID: \(String(describing: orderID))")
                self.orderID = orderID
            }
        }
    }

    func createCardClient() {
        let config = CoreConfig(clientID: clientID, accessToken: accessToken!, environment: .sandbox)
        let cardClient = CardClient(config: config)
    }
    
}

// MARK: - ASWebAuthenticationPresentationContextProviding

extension ViewController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication
            .shared
            .connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .first { $0.isKeyWindow }
        ?? ASPresentationAnchor()
    }
}
