//
//  ViewController.swift
//  WikiWijs
//
//  Created by Tjarco Kerssens on 18/07/2019.
//  Copyright © 2019 Kennisnet. All rights reserved.
//

import UIKit
import WebKit

let AUTH_ENDPOINT = "https://maken.wikiwijs.nl/"

class ViewController: UIViewController {
    var webView: WKWebView?
    let sessionManager = SessionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        super.loadView()
        self.webView = WKWebView(frame: self.view.bounds)
        sessionManager.loadCookiesInto(webView: webView!)
        self.view = webView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        openAuthPage()
    }
    
    private func openAuthPage(){
        if let url = URL(string: AUTH_ENDPOINT){
            let request = URLRequest(url: url)
            self.webView?.load(request)
        }
    }

}

