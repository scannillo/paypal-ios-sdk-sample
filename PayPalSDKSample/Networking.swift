import Foundation

final class Networking {

    static let sharedService = Networking()
    private init() {}
    
    public func createOrderID(orderParams: CreateOrderParams, completion: @escaping (String?) -> Void) {
        let url = URL(string: "http://localhost:8080/orders")!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        urlRequest.httpBody = try? encoder.encode(orderParams)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let _ = error {
                completion(nil)
                return
            }
            
            guard let _ = response else {
                completion(nil)
                return
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let orderID = try! decoder.decode(OrderID.self, from: data)
            return completion(orderID.id)
        }.resume()
    }

    public func fetchAccessToken(completion: @escaping (String?) -> Void) {
        let url = URL(string: "http://localhost:8080/access_tokens")!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let _ = error {
                completion(nil)
                return
            }
            
            guard let _ = response else {
                completion(nil)
                return
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let accessToken = try! decoder.decode(AccessToken.self, from: data)
            return completion(accessToken.accessToken)
        }.resume()
    }
    
}
