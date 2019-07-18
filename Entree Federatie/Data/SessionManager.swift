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
    let storage = SessionStorage()
    let httpManager = HTTPManager()
    
    static let shared = SessionManager()
    private override init() {}
    
    /**
     Checks whether there is a valid session and calls the handler when this is known.
     
     First, the session is loaded from the keychain, if it does not exists, the handler is called with false.
     If it does exist, the session is validated (see `validateSession(withCookies cookies: [HTTPCookie])`).
     */
    func checkSavedSession(){
        if let cookies = loadCookies() {
            self.authenticate(withCookies: cookies)
        }else{
            handler?.authenticated(false)
        }
    }
    
    /**
        If the user id cookie is present, it can be validated.
    */
    private func authenticate(withCookies cookies: [HTTPCookie]){
        if userSessionCookieIsSet(inCookies: cookies){
            setUsername(withCookies: cookies)
            validateSession(withCookies: cookies)
        }else{
            handler?.authenticated(false)
        }
    }
    
    func removeSession(){
        storage.remove()
    }
    
    /**
        Delegate function  for the Cookie Observer. If there is a change in the cookies of the webview, this function will be called.
     */
    func cookiesDidChange(in cookieStore: WKHTTPCookieStore) {
        cookieStore.getAllCookies { (cookies) in
            if self.userSessionCookieIsSet(inCookies: cookies){
                self.saveCookies(cookies)
                self.setUsername(withCookies: cookies)
                self.handler?.authenticated(true)
            }
        }
    }
    

    
    private func userSessionCookieIsSet(inCookies cookies: [HTTPCookie]) -> Bool{
        return cookies.contains(where: {$0.name == UID_COOKIE})
    }
    
    /**
        Validate the session against an endpoint that return true if the session is valid
     
        The handler will be called with the information whether the session is valid.
     */
    private func validateSession(withCookies cookies: [HTTPCookie]){
        httpManager.getJSON(url: VALIDATION_ENDPOINT) { (json, error) in
            if let error = error {
                print("Could not validate the session: \(error.localizedDescription)")
                self.handler?.authenticated(false)
            }else{
                guard let validSession = json?["result"] as? String else {
                    self.handler?.authenticated(false)
                    return
                }
                self.handler?.authenticated(validSession.boolValue)
            }
        }
    }
    
    private func saveCookies(_ cookies: [HTTPCookie]){
        storage.set(cookies: cookies)
    }
    
    /*
        Parse the cookies to retrieve the username of the active user. The username is then accessible on this object.
     */
    private func setUsername(withCookies cookies: [HTTPCookie]){
        guard let userId = cookies.first(where: {$0.name == UID_COOKIE})?.value else{ return }
        username = String(userId.split(separator: "@").first ?? "Unknown").replacingOccurrences(of: "\"", with: "", options: .literal, range: nil)
    }
    
    private func loadCookies() -> [HTTPCookie]?{
        return storage.get()?.cookies
    }
}

extension String {
    var boolValue: Bool {
        return NSString(string: self).boolValue
    }
}
