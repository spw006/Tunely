//
//  HostViewController.swift
//  Tunely-Demo
//
//  Created by Cole Stipe on 11/2/15.
//  Copyright © 2015 Tracy Nham. All rights reserved.
//

import Alamofire
import UIKit

var SpotifyLoginFlag = false;


class HostViewController: UIViewController {
    
    
    var session:SPTSession!

    // Stream object
    var newStream : NSMutableDictionary = [ "name" : "", "password" : "" ]
    
    //Spotify
    let kClientID = "bc9df159847e473bac13ac944653af50";
    let kCallBackURL = "Tunely-Demo://callback"

    // UI elements
    @IBOutlet weak var isPrivateStream : UISwitch!
    @IBOutlet weak var passwordField : UITextField!
    @IBOutlet weak var passwordPrompt : UILabel!
    

    @IBOutlet weak var loginButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("userid: " + defaults.stringForKey("userid")!)
        
        // initially hide the private stream options
        passwordPrompt.hidden = true
        passwordField.hidden = true

//        // Do any additional setup after loading the view.
//        let uri : String = "http://ec2-54-183-142-37.us-west-1.compute.amazonaws.com/api/streams/563918ef7579b04a6629f14b"
//        let parameters : [String: String] = ["song": "new song"]
//        let headers : [String: String]? = ["x-access-token": FBSDKAccessToken.currentAccessToken().tokenString]
//        
//        Alamofire.request(.PUT, uri, parameters: parameters, headers:headers, encoding: .JSON)
//            .responseJSON {response in
//                print(response)
//        }
        
        
        
        loginButton.hidden = true;
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "UpdateAfterFirstLogin", name: "loginSuccessful", object: nil)
        let userDefaults = NSUserDefaults.standardUserDefaults()
        print("viewdidload")
        if let sessionObj:AnyObject = userDefaults.objectForKey("SpotifySession") {
            //session available
            print("session available");
            let sessionDataObj = sessionObj as! NSData
            let session = NSKeyedUnarchiver.unarchiveObjectWithData(sessionDataObj) as! SPTSession
            if !session.isValid() {
                SPTAuth.defaultInstance().renewSession(session, callback: { (error:NSError!, renewedSession: SPTSession!) ->
                    Void in
                    if error == nil {
                        let sessionData = NSKeyedArchiver.archivedDataWithRootObject(session)
                        userDefaults.setObject(sessionData, forKey: "SpotifySession")
                        userDefaults.synchronize()
                        
                        self.session = renewedSession
                        
                        //self.playUsingSession(renewedSession)
                        
                    }
                    else {
                        print("error refresshing session")
                    }
                })
                
                
            }else {
                print("sessionValid")
                //playUsingSession(session)
            }
            
        } else {
            print("session not available");
            
            loginButton.hidden = false;
        }
        
        
        
        
        
    }
    
    @IBAction func cancel() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func viewStream(sender: AnyObject) {
        let streamView:StreamViewController = StreamViewController(nibName: "StreamViewController", bundle: nil)
        self.presentViewController(streamView, animated: true, completion: nil)
    }
    
    @IBAction func changeSlider() {
        if isPrivateStream.on == false {
            
            // slider turned OFF
            passwordPrompt.hidden = true
            passwordField.hidden = true
            if passwordField.isFirstResponder() {
                passwordField.resignFirstResponder()
            }
        }
        else {
            
            // slider turned ON
            passwordPrompt.hidden = false
            passwordField.hidden = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func hostButtonPressed(sender: AnyObject) {
        print("LOL")
        let streamView:StreamViewController = StreamViewController(nibName: "StreamViewController", bundle: nil)
        self.presentViewController(streamView, animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    @IBAction func loginWithSpotify(sender: AnyObject) {
        print("buttonclicked");
        SpotifyLoginFlag = true;
        let auth = SPTAuth.defaultInstance()
        auth.clientID = kClientID;
        auth.redirectURL = NSURL(string: kCallBackURL);
        auth.requestedScopes = [SPTAuthStreamingScope];
        let loginURL : NSURL = auth.loginURL;
        // let loginURL = SPTAuth.loginURLForClientId(kClientID, withRedirectURL: NSURL(string: kCallBackURL), scopes: [SPTAuthStreamingScope], responseType: "code")
        
        let seconds = 0.5
        let delay = seconds * Double(NSEC_PER_MSEC)
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            print(UIApplication.sharedApplication().openURL(loginURL))
        })
        
        
        
        
    }
    
    func UpdateAfterFirstLogin() {
        loginButton.hidden = true;
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if let sessionObj:AnyObject = userDefaults.objectForKey("SpotifySession") {
            let sessionDataObj = sessionObj as! NSData
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObjectWithData(sessionDataObj) as! SPTSession
            
            //playUsingSession(firstTimeSession)
            
        }
        
        
    }
    
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
