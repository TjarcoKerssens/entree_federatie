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
    var handler: SAMLAuthenticationHandler?
    let storage = SessionStorage()
    let httpManager = HTTPManager()
    
    override init() {
        super.init()
        self.setObserver()
    }
    
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
                self.validateSession(withCookies: cookies)
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
                self.removeObserverIfDone(validSession.boolValue)
            }
        }
    }
    
    /*
        Remove this class as the observer of the cookiestore if the user is authenticated, in order to avoid
        repeated calls to the handler.
     */
    private func removeObserverIfDone(_ done: Bool){
        if done {
            DispatchQueue.main.async {
                WKWebsiteDataStore.default().httpCookieStore.remove(self)
            }
        }
    }
    
    func setObserver(){
        WKWebsiteDataStore.default().httpCookieStore.add(self)
    }
    
    func loadCookiesInto(webView: WKWebView){
        setObserver()
        if let cookies = loadCookies(){
            webView.setCookies(cookies)
        }
    }
    
    private func saveCookies(_ cookies: [HTTPCookie]){
        storage.remove()
        storage.set(cookies: cookies)
    }
    
    private func loadCookies() -> [HTTPCookie]?{
        return storage.get()?.cookies
    }
    
}

extension WKWebView{
    func setCookies(_ cookies: [HTTPCookie]){
        for cookie in cookies{
            configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
        }
    }
}

extension String {
    var boolValue: Bool {
        return NSString(string: self).boolValue
    }
}
