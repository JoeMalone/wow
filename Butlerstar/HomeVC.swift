//
//  HomeVC.swift
//  Butlerstar
//
//  Created by Jonas Elholm on 15/05/2017.
//  Copyright © 2017 ButlerStar. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import SwiftKeychainWrapper

class HomeVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
        let keychainResult =  KeychainWrapper.defaultKeychainWrapper.remove(key:KEY_UID)
        print("JESS: ID removed from keychain \(keychainResult)")
        try! FIRAuth.auth()?.signOut()
        GIDSignIn.sharedInstance().signOut()
        performSegue(withIdentifier: "goToSignIn", sender: nil)
    }
    
    
}
