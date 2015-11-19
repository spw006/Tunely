//
//  HostViewController.swift
//  Tunely-Demo
//
//  Created by Cole Stipe on 11/2/15.
//  Copyright © 2015 Tracy Nham. All rights reserved.
//

import Alamofire
import SwiftyJSON

import UIKit

var SpotifyLoginFlag = false;
var session:SPTSession!


class HostViewController: UIViewController {
    
    

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
            session = NSKeyedUnarchiver.unarchiveObjectWithData(sessionDataObj) as! SPTSession
            if !session.isValid() {
                SPTAuth.defaultInstance().renewSession(session, callback: { (error:NSError!, renewedSession: SPTSession!) ->
                    Void in
                    print("session not valid")
                    if error == nil {
                        let sessionData = NSKeyedArchiver.archivedDataWithRootObject(session)
                        userDefaults.setObject(sessionData, forKey: "SpotifySession")
                        userDefaults.synchronize()
                        
                        session = renewedSession
                        
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
            
        }else {
            print("session not available");
            
            loginButton.hidden = false;
        }
        
        
        
        
        
    }
    
    @IBAction func cancel() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /** Populate the list with all streams */
    @IBAction func viewStream(sender: AnyObject) {
        
        // Create a pubnub channel and subscribe to it
        let userFbid = defaults.stringForKey("userFbid")!
        let userName = defaults.stringForKey("userName")!
        let streamName = userName + "'s Stream"
        let channelName = userFbid + "channel"
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let uri : String = "http://ec2-54-183-142-37.us-west-1.compute.amazonaws.com/api/streams"
        var parameters: [String: AnyObject] = ["name": streamName, "host": userFbid, "pubnub": channelName]
        let headers : [String: String] = ["x-access-token": FBSDKAccessToken.currentAccessToken().tokenString]
        
        // check for optional password field
        if (passwordField.text != nil) {
            parameters["password"] = passwordField.text
        }
        
        // create a stream
        /*
        Alamofire.request(.POST, uri, parameters: parameters, headers:headers)
            .responseJSON { json in
                
                let stream = JSON(data: json.data!)
                
                print(stream)
                
                let errors : Bool = (stream["errors"] != nil)
                let duplicate : Bool = (stream["code"] == 11000)
                
                // Do not proceed if server did not respond
                if (stream == nil) {
                    print("No response from server.")
                    return
                }
                
                // Do not proceed if there was an error during the POST request
                if (errors) {
                    print("Error POST stream.")
                    return;
                }
                
                // Do not proceed if a user already has a stream created
                if (duplicate) {
                    print("User already has a stream.")
                    return;
                }
                
                print("SUCCESSFUL POST stream to server, creating channel...")
                
                // subscribe the host to the channel
                appDelegate.client?.subscribeToChannels([channelName], withPresence: true)
                
                let streamID = stream["_id"].stringValue
                defaults.setObject(streamID, forKey: "hostedStream")
                defaults.setObject(channelName, forKey: "channelName")
                
                // go to stream view
                let streamView:StreamViewController = StreamViewController(nibName: "StreamViewController", bundle: nil)
                self.presentViewController(streamView, animated: true, completion: nil)
        }*/
        appDelegate.client?.subscribeToChannels([channelName], withPresence: true)

        
        // go to stream view
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
        print("update after first login")
        loginButton.hidden = true;
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if let sessionObj:AnyObject = userDefaults.objectForKey("SpotifySession") {
            let sessionDataObj = sessionObj as! NSData
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObjectWithData(sessionDataObj) as! SPTSession
            
            //playUsingSession(firstTimeSession)
            session = firstTimeSession
            
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
