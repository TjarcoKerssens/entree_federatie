//
//  SessionStorage.swift
//  Entree Federatie
//
//  Created by Tjarco Kerssens on 18/07/2019.
//  Copyright © 2019 Kennisnet. All rights reserved.
//

import Foundation
import KeychainSwift

/**
 Data object to wrap a list of `HTTPCookie` objects in order to convert them to raw data and back. 
 */
struct Session{
    var cookies: [HTTPCookie]
    
    init(cookies: [HTTPCookie]) {
        self.cookies = cookies
    }
    
    func archive() -> Data?{
        let cookieData = cookies.compactMap {$0.archive()}
        do {
            return try NSKeyedArchiver.archivedData(withRootObject: cookieData, requiringSecureCoding: true)
        } catch {
            return nil
        }
     }
    
    static func from(_ data: Data) -> Session?{
        do {
            let cookiesData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)
            guard let cookieDataArray = cookiesData as? [Data] else {return nil}
            let cookies = cookieDataArray.compactMap {HTTPCookie.loadCookie(using: $0)}
            return Session(cookies: cookies)
        } catch {
            return nil
        }
    
    }
}

let SESSION_KEY = "EntreeFederatieSession"

/**
    Manages persitence of a session
 */
class SessionStorage{
    let keychain = KeychainSwift()
    
    init() {
        keychain.accessGroup = "HBX6JETZQ9.kennisnet.Entree-Federatie" // Allows the session to be shared amongst applications
        keychain.synchronizable = true // Allows the session to be shared between multiple devices
    }
    
    /**
     Convinience function for setting the Session. See `set(session: Session)`
     
     - Parameter cookies: An array of cookies received when logging in. Will be stored as a `Session` object.
    */
    func set(cookies: [HTTPCookie]){
        self.set(session: Session(cookies: cookies))
    }
    
    /**
     Saves a session to the keychain of the user. The session will be stored in the domain of the application, while other applications
     with the same accessGroup can access the session. This allows Single Sign On for the different applications using Entree Federatie
     
     - Parameter session: A session object containing the cookies received when logging in.
    */
    func set(session: Session){
        guard let sessionData = session.archive() else {return}
        if !keychain.set(sessionData, forKey: SESSION_KEY){
            print("SessionStorate: error saving session: \(keychain.lastResultCode)")
        }
    }
    
    /**
     Reads the session from the Keychain, possibly set by another application.
     
     - Returns: A `Session` object containing the cookies of the session, or nil when no session has been set.
    */
    func get() -> Session? {
        guard let sessionData = keychain.getData(SESSION_KEY) else {return nil}
        return Session.from(sessionData)
    }
    
    /**
     Removes the session object from the keychain and therefore requiring a new login.
    */
    func remove(){
        keychain.clear()
    }
}
