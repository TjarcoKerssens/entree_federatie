//
//  HTTPManager.swift
//  Entree Federatie
//
//  Created by Tjarco Kerssens on 18/07/2019.
//  Copyright © 2019 Kennisnet. All rights reserved.
//

import Foundation

class HTTPManager{
    typealias JSONObject = NSDictionary
    
    func get(url: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> ()){
        guard let session = SessionStorage().get() else {return}
        guard let url = URL(string: url) else {return}
        HTTPCookieStorage.shared.setCookies(session.cookies, for: url, mainDocumentURL: url)
        
        let urlSession = URLSession(configuration: .default)
        let dataTask = urlSession.dataTask(with: url, completionHandler: completionHandler)
        dataTask.resume()
    }
    
    func getJSON(url: String, completionHandler: @escaping (JSONObject?, Error?) -> ()){
        get(url: url) { (data, response, error) in
            if let error = error {
                completionHandler(nil, error)
            }else{
                guard let data = data else {return}
                guard let json = self.parseJSON(data: data) else {
                    completionHandler(nil, HTTPError.jsonError)
                    return
                }
               completionHandler(json, nil)
            }
        }
    }
    
    private func parseJSON(data: Data) -> JSONObject?{
        do{
           return try JSONSerialization.jsonObject(with: data, options: []) as? JSONObject
        }catch let error as NSError{
            print("Error parsing JSON: \(error.debugDescription)")
            return nil
        }
    }
}

enum HTTPError: Error{
    case jsonError
}

extension HTTPError: LocalizedError{
    public var errorDescription: String?{
        switch self {
            case .jsonError:
                return NSLocalizedString("Description of invalid JSON", comment: "Invallid JSON")
        }
    }
}
