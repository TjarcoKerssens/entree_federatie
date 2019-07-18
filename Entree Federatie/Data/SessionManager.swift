//
//  SessionManager.swift
//  Entree Federatie
//
//  Created by Tjarco Kerssens on 15/07/2019.
//  Copyright © 2019 Kennisnet. All rights reserved.
//

import Foundation
import WebKit

let UID_COOKIE = "aselect_uid"
let COOKIE_KEYS = "CookieKeys"

let VALIDATION_ENDPOINT = "https://ssoquery.aselect.entree.kennisnet.nl/openaselect/sso/ssoquery?response_url=https%3A%2F%2Freferentie.entree.kennisnet.nl&format=json"

protocol SAMLAuthenticationHandler{
    func authenticated(_ success: Bool)
}

class SessionManager: NSObject, WKHTTPCookieStoreObserver{
    
    var username = ""
    var handler: SAMLAuthenticationHandler?
    
    
    static let shared = SessionManager()
    private override init() {}
    
    func checkSavedSession(){
        if let cookies = loadCookies() {
            self.authenticate(withCookies: cookies)
        }else{
            handler?.authenticated(false)
        }
    }
    
    func removeSession(){
        let defaults = UserDefaults.standard
        guard let keys = defaults.stringArray(forKey: COOKIE_KEYS) else {return }
        for key in keys{
            defaults.removeObject(forKey: key)
        }
        
        defaults.removeObject(forKey: COOKIE_KEYS)
    }
    
    func cookiesDidChange(in cookieStore: WKHTTPCookieStore) {
        cookieStore.getAllCookies { (cookies) in
            if self.userSessionCookieIsSet(inCookies: cookies){
                self.saveCookies(cookies)
                self.setUsername(withCookies: cookies)
                self.handler?.authenticated(true)
            }
        }
    }
    
    private func authenticate(withCookies cookies: [HTTPCookie]){
        if userSessionCookieIsSet(inCookies: cookies){
            setUsername(withCookies: cookies)
            validateSession(withCookies: cookies)
        }else{
            handler?.authenticated(false)
        }
    }
    
    private func userSessionCookieIsSet(inCookies cookies: [HTTPCookie]) -> Bool{
        return cookies.contains(where: {$0.name == UID_COOKIE})
    }
    
    private func validateSession(withCookies cookies: [HTTPCookie]){
        
        guard let url = URL(string: VALIDATION_ENDPOINT) else {return}
        
        HTTPCookieStorage.shared.setCookies(cookies, for: url, mainDocumentURL: url)

        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: url) { (data, response, error) in
            guard let data = data else {return}
            do{
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else { return }
                guard let validSession = json["result"] as? String else {return}
                self.handler?.authenticated(validSession.boolValue)
            }catch let error as NSError{
                print("Error validating session: \(error.debugDescription)")
                DispatchQueue.main.async {
                    self.handler?.authenticated(false)
                }
            }
        }

        dataTask.resume()
    }
    
    private func saveCookies(_ cookies: [HTTPCookie]){
        let userDefaults = UserDefaults.standard
        let keys = cookies.map {$0.name}
        userDefaults.set(keys, forKey: COOKIE_KEYS)
        
        for cookie in cookies {
            guard let cookieArchive = cookie.archive() else {continue}
            userDefaults.set(cookieArchive, forKey: cookie.name)
        }
    }
    
    private func setUsername(withCookies cookies: [HTTPCookie]){
        guard let userId = cookies.first(where: {$0.name == UID_COOKIE})?.value else{ return }
        username = String(userId.split(separator: "@").first ?? "Unknown").replacingOccurrences(of: "\"", with: "", options: .literal, range: nil)
    }
    
    private func loadCookies() -> [HTTPCookie]?{
        let userDefaults = UserDefaults.standard
        guard let keys = userDefaults.stringArray(forKey: COOKIE_KEYS) else {return nil}
        
        var cookies: [HTTPCookie] = []
        for key in keys {
            guard let cookieData = userDefaults.data(forKey: key) else {continue}
            guard let cookie = HTTPCookie.loadCookie(using: cookieData) else {continue}
            cookies.append(cookie)
        }
        
        return cookies
    }
}

extension String {
    var boolValue: Bool {
        return NSString(string: self).boolValue
    }
}
