//
//  ViewController.swift
//  Tunely-Demo
//
//  Created by Tracy Nham on 10/15/15.
//  Copyright © 2015 Tracy Nham. All rights reserved.
//


import UIKit

class ViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            // User is already logged in, do work such as go to next view controller.
        }
        // Do any additional setup after loading the view, typically from a nib.
        else {
            let loginButton : FBSDKLoginButton = FBSDKLoginButton()
            self.view.addSubview(loginButton)
            loginButton.center = self.view.center
            loginButton.readPermissions = ["public_profile", "email", "user_friends"]
            loginButton.delegate = self
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
        
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                // Do work
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    
}



