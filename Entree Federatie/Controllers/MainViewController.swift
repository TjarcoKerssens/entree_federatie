//
//  MainViewController.swift
//  Entree Federatie
//
//  Created by Tjarco Kerssens on 15/07/2019.
//  Copyright © 2019 Kennisnet. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUsername()
    }
    
    private func setUsername(){
        let username = SessionManager.shared.username
        usernameLabel.text = "Hoi \(username),"
    }
    
    @IBAction func logout(_ sender: Any) {
        let defaults = UserDefaults.standard
        guard let keys = defaults.stringArray(forKey: "CookieKeys") else {return }
        for key in keys{
            defaults.removeObject(forKey: key)
        }
        
        defaults.removeObject(forKey: "CookieKeys")
        defaults.removeObject(forKey: "Username")
        self.dismiss(animated: true, completion: nil)
    }
}
