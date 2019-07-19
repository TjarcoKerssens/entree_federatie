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
    @IBOutlet weak var uidLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var mailLabel: UILabel!
    @IBOutlet weak var eduPersonIdLabel: UILabel!
    
    var properties: ReferentieProperties?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setProperties()
    }
    
    private func setProperties(){
        guard let properties = properties else {return}
        usernameLabel.text = "Hi \(properties.givenName)!"
        uidLabel.text = "uid: \(properties.uid)"
        fullNameLabel.text = "Full name: \(properties.givenName ) \(properties.sn)"
        mailLabel.text = "Mail: \(properties.mail)"
        eduPersonIdLabel.text = "nlEduPersonRealId: \(properties.nlEduPersonRealId)"
    }
    
    @IBAction func logout(_ sender: Any) {
        SessionManager().removeSession()
        performSegue(withIdentifier: "LogoutSegue", sender: self)
    }
}
