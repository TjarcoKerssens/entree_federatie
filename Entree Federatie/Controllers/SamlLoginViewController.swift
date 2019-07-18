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

/**
    This class shows the login page for the entree application in a webview.
    When the user is authenticated, the application resumes to the next screen
 */
class SamlLoginViewController: UIViewController, SAMLAuthenticationHandler{
    var webView: WKWebView?
    let sessionManager = SessionManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sessionManager.handler = self
    }
    
    override func loadView() {
        super.loadView()
        WKWebsiteDataStore.default().httpCookieStore.add(sessionManager)

        self.webView = WKWebView(frame: self.view.bounds)
        self.view = self.webView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        sessionManager.checkSavedSession()
    }
    
    private func openAuthPage(){
        if let url = URL(string: AUTH_ENDPOINT){
            let request = URLRequest(url: url)
            self.webView?.load(request)
        }
    }
    
    func authenticated(_ success: Bool) {
        DispatchQueue.main.async {
            if success {
                self.performSegue(withIdentifier: "MainScreenSegue", sender: nil)
            }else{
                self.openAuthPage()
            }
        }
    }
}
