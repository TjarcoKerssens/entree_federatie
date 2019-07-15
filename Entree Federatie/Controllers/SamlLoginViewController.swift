//
//  SamlLoginViewController.swift
//  Entree Federatie
//
//  Created by Tjarco Kerssens on 15/07/2019.
//  Copyright © 2019 Kennisnet. All rights reserved.
//

import Foundation

import UIKit
import WebKit

let AUTH_ENDPOINT = "https://referentie.entree.kennisnet.nl/saml/module.php/core/authenticate.php?as=RefSPSAML"

let SAML_SESSION_COOKIE = "SimpleSAMLSessionID"
let UID_COOKIE = "aselect_uid"

/**
    This class shows the login page for the entree application in a webview.
    When the user is authenticated, the application resumes to the next screen
 */
class SamlLoginViewController: UIViewController, WKHTTPCookieStoreObserver {
    var webView: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        super.loadView()
        WKWebsiteDataStore.default().httpCookieStore.add(self)
        
        self.webView = WKWebView(frame: self.view.bounds)
        self.view = self.webView
        
        webView?.configuration.websiteDataStore.httpCookieStore.add(self)
        
        openAuthPage()
    }
    
    private func openAuthPage(){
        if let url = URL(string: AUTH_ENDPOINT){
            let request = URLRequest(url: url)
            self.webView?.load(request)
        }
    }
    
    func cookiesDidChange(in cookieStore: WKHTTPCookieStore) {
        cookieStore.getAllCookies { (cookies) in
            if cookies.contains(where: {$0.name == SAML_SESSION_COOKIE}){
                self.authenticated(withCookies: cookies)
            }
        }
    }
    
    private func authenticated(withCookies cookies: [HTTPCookie]){
        print("User is authenticated")
        guard let userId = cookies.first(where: {$0.name == UID_COOKIE})?.value else{ return }
        let username = String(userId.split(separator: "@").first ?? "Unknown").replacingOccurrences(of: "\"", with: "", options: .literal, range: nil)
        UserDefaults.standard.set(username, forKey: "Username")
        self.performSegue(withIdentifier: "MainScreenSegue", sender: nil)
    }
}
