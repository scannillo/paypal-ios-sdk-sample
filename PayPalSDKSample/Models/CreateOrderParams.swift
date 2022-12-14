import Foundation

struct CreateOrderParams: Codable {
    let intent: String
    let purchaseUnits: [PurchaseUnit]
    let applicationContext: ApplicationContext
}

struct PurchaseUnit: Codable {
    let amount: Amount
}

struct Amount: Codable {
    let currencyCode: String
    let value: String
}

struct ApplicationContext: Codable {
    let returnUrl: String
    let cancelUrl: String
}
