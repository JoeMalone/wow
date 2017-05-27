//
//  ViewController.swift
//  Butlerstar
//
//  Created by Jonas Elholm on 23/04/2017.
//  Copyright © 2017 ButlerStar. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase
import GoogleSignIn
import SwiftKeychainWrapper


class SignInVC: UIViewController, GIDSignInUIDelegate {
    
    @IBOutlet weak var emailField: LoginTextField!
    
    @IBOutlet weak var pwdField: LoginTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.completeSig),
            name: NSNotification.Name(rawValue: "googleLogin"),
            object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "googleLogin"), object: nil);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let _ = KeychainWrapper.defaultKeychainWrapper.string(forKey: KEY_UID) {
            performSegue(withIdentifier: "goToHome", sender: nil)
            print("JESS: ID found in keychain")
        }
    }
    
    
    
    
    
    @IBAction func facebookBtnTapped(_ sender: Any) {
        
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            
            if error != nil {
                print("JESS: Unable to authenticate with Facebook - \(error)")
                
            } else if result?.isCancelled == true {
                print("JESS: User cancelled Facebook authentification")
            } else {
                print("JESS: Successfullyauthentitated with Facebook")
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
            }
        }
    }
    
    func firebaseAuth(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("JESS: Unable to authenticate with Firebase - \(error)")
                var uiAlert = UIAlertController(title: "Error", message:error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                self.present(uiAlert, animated: true, completion: nil)
                
                uiAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                    print("Click of default button")
                }))
                
            } else {
                print("JESS: Successfully authenticated with Firebase")
                
                if let user = user {
                    self.completeSignIn(id: user.uid)
                    
                    // bruge KeychainWrapper.defaultKeychainWrapper.string(forKey: KEY_UID)
                    
                    //KeychainWrapper.setString(user.uid, forKey: KEY_UID)
                }
                
            }
        } )
    }
    
    @IBAction func GIDSignInButton(_ sender: Any) {
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func signInTapped(_ sender: Any) {
        
        
        if let email = emailField.text, let pwd = pwdField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion:{ (user, error) in
                if error == nil {
                    print("JESS: Email user authenticated with Firebase")
                    if let user = user {
                        self.completeSignIn(id: user.uid)
                    }
                    
                    
                } else {
                    
                    FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user, error) in
                        if error != nil {
                            print("JESS: Unable to authenticate with Firebase using email")
                            
                        } else {
                            
                            print("JESS:Successfully authenticated with Firebase")
                            if let user = user {
                                self.completeSignIn(id: user.uid)
                                
                            }
                            
                        }
                    } )
                    
                }
                
            } )
        }
        
        
    }
    
    func completeSignIn(id: String) {
        let keychainResult = KeychainWrapper.defaultKeychainWrapper.set(id, forKey: KEY_UID)
        print("JESS: Data saved to keychain \(keychainResult)")
        performSegue(withIdentifier: "goToHome", sender: nil)
    }
    
    func completeSig()
    {
        performSegue(withIdentifier: "goToHome", sender: nil)
    }
    
}
