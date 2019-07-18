//
//  HTMLParser.swift
//  Entree Federatie
//
//  Created by Tjarco Kerssens on 18/07/2019.
//  Copyright © 2019 Kennisnet. All rights reserved.
//

import Foundation
import WebKit

struct JSFiles {
    static let referentie = "ReadReferentieProperties"
}

class HTMLParser {
    typealias JavaScript = String
    
    var webView: WKWebView
    
    init(webView: WKWebView) {
        self.webView = webView
    }
    
    func parseReferentie(completionHandler: @escaping (ReferentieProperties) -> ()){
        guard let js = readJavascriptFile(filename: JSFiles.referentie) else {
            return
        }
        
        webView.evaluateJavaScript(js) { (result, error) in
            if let error = error {
                print(error.localizedDescription)
            }else{
                guard var data = result as? [String: String] else {return}
                data = data.mapValues {$0.trimmingCharacters(in: .whitespacesAndNewlines)}
                let jsonData = try! JSONSerialization.data(withJSONObject: data)
                let properties = try! JSONDecoder().decode(ReferentieProperties.self, from: jsonData)
                completionHandler(properties)
            }
        }
    }
    
    private func readJavascriptFile(filename: String) -> JavaScript?{
        if let filepath = Bundle.main.path(forResource: filename, ofType: "js") {
            do {
                let contents = try String(contentsOfFile: filepath)
                return contents
            } catch {
                return nil
            }
        } else {
            return nil
        }
    }
}
