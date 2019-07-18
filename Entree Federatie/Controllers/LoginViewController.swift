//
//  LoginViewController.swift
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
class LoginViewController: UIViewController, SAMLAuthenticationHandler, WKNavigationDelegate{
    var webView: WKWebView?
    let sessionManager = SessionManager.shared
    var authenticated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sessionManager.handler = self
    }
    
    override func loadView() {
        super.loadView()
        self.webView = WKWebView(frame: self.view.bounds)
        sessionManager.loadCookiesInto(webView: webView!)
        self.webView?.navigationDelegate = self
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
                if (!self.authenticated){
                    self.authenticated = true
                    self.openAuthPage()
                }
            }else{
                self.openAuthPage()
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if (authenticated) {
            let parser = HTMLParser(webView: self.webView!)
            parser.parseReferentie(completionHandler: { (properties) in
                self.performSegue(withIdentifier: "MainScreenSegue", sender: properties)
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MainScreenSegue" {
            let mainVc = segue.destination as! MainViewController
            mainVc.properties = sender as? ReferentieProperties
        }
    }
}
