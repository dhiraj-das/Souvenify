//
//  LoginScreenViewController.swift
//  Souvenify
//
//  Created by Dhiraj Das on 8/26/16.
//  Copyright © 2016 Dhiraj Das. All rights reserved.
//

import UIKit
import Firebase
import Google
import GoogleSignIn

class LoginScreenViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate{

    
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var LoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signInSilently()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        LoginButton.enabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func CreateAccount(sender: AnyObject) {
        
        LoginButton.enabled = false
        
        
        
        FIRAuth.auth()?.createUserWithEmail(EmailTextField.text!, password: PasswordTextField.text!, completion: {(user, error) in
        
            guard let error = error else{
                print("User Created")
                self.login()
                return
            }
            
            switch error.code{
                case 17007: print("Email is already in use")
                        self.login()
                        break
                default: print(error.code)
                        self.LoginButton.enabled = true
            }
            
        })
    }
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        let authentication = user.authentication
        let credential = FIRGoogleAuthProvider.credentialWithIDToken(authentication.idToken, accessToken: authentication.accessToken)
        let auth = FIRAuth.auth()
        auth!.signInWithCredential(credential, completion: {(user, error) in
            if error != nil {
                print(error?.localizedDescription)
                return
            }
            let MapViewControllerID = "MapVC"
            let mapViewController = self.storyboard?.instantiateViewControllerWithIdentifier(MapViewControllerID) as! MapViewController
            mapViewController.firAuthUser = auth
            self.navigationController?.pushViewController(mapViewController, animated: true)
            
            let ref = FIRDatabase.database().referenceFromURL("https://souvenify.firebaseio.com/")
            let usersReference = ref.child("users").child((auth?.currentUser?.uid)!)
            let values : [String : String] = ["name": (auth?.currentUser?.displayName)!, "email": (auth?.currentUser?.email)!]
            usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                
                if err != nil {
                    print(err?.localizedDescription)
                    return
                }
                
                self.dismissViewControllerAnimated(true, completion: nil)

            })
        })
    }
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user: GIDGoogleUser!, withError error: NSError!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        try! FIRAuth.auth()?.signOut()
    }
    
    func login() {
        
        let MapViewControllerID = "MapVC"
        let auth = FIRAuth.auth()
            auth!.signInWithEmail(EmailTextField.text!, password: PasswordTextField.text!, completion: {(user, error) in
        
            guard let error = error else{
                print("Logged In")
                let mapViewController = self.storyboard?.instantiateViewControllerWithIdentifier(MapViewControllerID) as! MapViewController
                mapViewController.firAuthUser = auth
                self.navigationController?.pushViewController(mapViewController, animated: true)
                return
            }
            
            switch error.code{
                case 17009: print("Wrong password")
                            self.LoginButton.enabled = true
                            break
                default: print(error.code)
            }

        })
    }
}

class LoginTextField : UITextField {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.borderColor = UIColor(white: 231/255, alpha: 1).CGColor
        self.layer.borderWidth = 1
    }
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 8, dy: 7)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return textRectForBounds(bounds)
    }
}

