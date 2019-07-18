//
//  HTTPCookieArchiving.swift
//  Entree Federatie
//
//  Created by Tjarco Kerssens on 15/07/2019.
//  Copyright © 2019 Kennisnet. All rights reserved.
//

import Foundation

extension HTTPCookie {
    
    fileprivate func save(cookieProperties: [HTTPCookiePropertyKey : Any]) -> Data {
        let data = try! NSKeyedArchiver.archivedData(withRootObject: cookieProperties, requiringSecureCoding: true)
        return data
    }
    
    static fileprivate func loadCookieProperties(from data: Data) -> [HTTPCookiePropertyKey : Any]? {
        let unarchivedDictionary = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)
        return unarchivedDictionary as? [HTTPCookiePropertyKey : Any]
    }
    
    static func loadCookie(using data: Data?) -> HTTPCookie? {
        guard let data = data,
            let properties = loadCookieProperties(from: data) else {
                return nil
        }
        return HTTPCookie(properties: properties)
        
    }
    
    func archive() -> Data? {
        guard let properties = self.properties else {
            return nil
        }
        return save(cookieProperties: properties)
    }
}
