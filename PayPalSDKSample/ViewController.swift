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
    
    // MARK: - Properties
    
    let clientID = "AUiHPkr1LO7TzZH0Q5_aE8aGNmTiXZh6kKErYFrtXNYSDv13FrN2NElXabVV4fNrZol7LAaVb1gJj9lr"
    var accessToken: String?
    var orderID: String?
    
    // MARK: - IBOutlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var cardCheckoutButton: UIButton!
    @IBOutlet weak var statusTextField: UITextField!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.hidesWhenStopped = true
        cardCheckoutButton.isEnabled = false
        
        // 1. Get AccessToken
        fetchAccessToken()
        
        // 2. Get OrderID
        fetchOrderID()
    }
    
    // MARK: - PayPal SDK Implementation
    
    func fetchAccessToken() {
        activityIndicator.startAnimating()
        Networking.sharedService.fetchAccessToken { [weak self] accessToken in
            guard let self = self else { return }
            
            print("Fetched accessToken: \(String(describing: accessToken))")
            self.accessToken = accessToken
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    func fetchOrderID() {
        activityIndicator.startAnimating()
        let orderParams = CreateOrderParams(
            intent: "AUTHORIZE",
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
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.cardCheckoutButton.isEnabled = true
            }
        }
    }
    
    func postAuthorizeOrder(orderID: String) {
        Networking.sharedService.postAuthorizeOrder(orderID: orderID) { result in
            print("Authorized OrderID: \(orderID)")
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    @IBAction func cardCheckoutTapped(_ sender: Any) {
        let config = CoreConfig(clientID: clientID, accessToken: accessToken!, environment: .sandbox)
        
        let card = Card(
            number: "4005519200000004",
            expirationMonth: "01",
            expirationYear: "2025",
            securityCode: "123",
            cardHolderName: "Jane Smith",
            billingAddress: Address(
                addressLine1: "123 Main St.",
                addressLine2: "Apt. 1A",
                locality: "city",
                region: "IL",
                postalCode: "12345",
                countryCode: "US"
            )
        )
        
        let cardClient = CardClient(config: config)
        cardClient.delegate = self
        
        let cardRequest = CardRequest(orderID: self.orderID!, card: card)
        cardClient.approveOrder(request: cardRequest, context: self)
        updateStatus("Approving card ...")
    }
    
    func updateStatus(_ text: String) {
        DispatchQueue.main.async {
            self.statusTextField.text = text
        }
    }
    
    
}

// MARK: - CardDelegate

extension ViewController: CardDelegate {
    
    func card(_ cardClient: CardClient, didFinishWithResult result: CardResult) {
        updateStatus("didFinishWithResult")
        postAuthorizeOrder(orderID: self.orderID!)
        
        // order was successfully approved and is ready to be captured/authorized (see step 8)
    }
    
    func card(_ cardClient: CardClient, didFinishWithError error: CoreSDKError) {
        print(error)
        updateStatus("didFinishWithError")
        // handle the error by accessing `error.localizedDescription`
    }
    
    func cardDidCancel(_ cardClient: CardClient) {
        updateStatus("cardDidCancel")
        // 3D Secure auth was canceled by the user
    }
    
    func cardThreeDSecureWillLaunch(_ cardClient: CardClient) {
        updateStatus("cardThreeDSecureWillLaunch")
        // 3D Secure auth will launch
    }
    
    func cardThreeDSecureDidFinish(_ cardClient: CardClient) {
        updateStatus("cardThreeDSecureDidFinish")
        // 3D Secure auth did finish successfully
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
