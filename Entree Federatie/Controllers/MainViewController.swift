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
        SessionManager.shared.removeSession()
        self.dismiss(animated: true, completion: nil)
    }
}
