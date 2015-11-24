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
//var session:SPTSession!
var firstLoad = true;


class HostViewController: UIViewController, SPTAudioStreamingPlaybackDelegate {
    
    var session:SPTSession!

    // Stream object
    var newStream : NSMutableDictionary = [ "name" : "", "password" : "" ]
    
    //Spotify
    let kClientID = "bc9df159847e473bac13ac944653af50";
    let kCallBackURL = "Tunely-Demo://callback"
    let kTokenSwapURL = "https://tunelyspotifyauth.herokuapp.com/swap"
    let kTokenRefreshURL = "https://tunelyspotifyauth.herokuapp.com/refresh"

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
                SPTAuth.defaultInstance().tokenRefreshURL = NSURL(string: kTokenRefreshURL)
                SPTAuth.defaultInstance().tokenSwapURL = NSURL(string: kTokenSwapURL)
                SPTAuth.defaultInstance().renewSession(session, callback: { (error:NSError!, renewedSession: SPTSession!) ->
                    Void in
                    print("session not valid")
                    if error == nil {
                        print(error)
                        let sessionData = NSKeyedArchiver.archivedDataWithRootObject(session)
                        userDefaults.setObject(sessionData, forKey: "SpotifySession")
                        userDefaults.synchronize()
                        
                        self.session = renewedSession
                        
                        
                        self.playUsingSession(renewedSession)
                        
                    }
                    else {
                        print(error)
                        print("error refresshing session")
                    }
                })
                
                
            }else {
                print("sessionValid")
                
                playUsingSession(session)
            }
            
        }
        
        else {
            print("session not available");
            
            loginButton.hidden = false;
        }
    }
    
    
    
    func playUsingSession(sessionObj:SPTSession) {
        print("playing using session called")
        if player == nil {
            player = SPTAudioStreamingController(clientId: kClientID)
            //player?.playbackDelegate = self;
            
        }
        
        player?.loginWithSession(sessionObj, callback: { (error:NSError!) -> Void in
            if error != nil {
                print("enabling playback got error")
                return
            }
        })
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
        Alamofire.request(.POST, uri, parameters: parameters, headers:headers)
            .responseJSON { json in
                
                let stream = JSON(data: json.data!)
                
                print(stream)
                
                let errors : Bool = (stream["errors"] != nil)
                let duplicate : Bool = (stream["code"] == 11000)
                
                 //Do not proceed if server did not respond
                if (stream == nil) {
                    print("No response from server.")
                    return
                }
                
                 //Do not proceed if there was an error during the POST request
                if (errors) {
                    print("Error POST stream.")
                    return;
                }
                
                 //Do not proceed if a user already has a stream created
                if (duplicate) {
                    print("User already has a stream.")
                    
                    // popup confirm
                    let alert = UIAlertController(title: "You already have a hosted stream", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                    let alertAction = UIAlertAction(title: "OK!", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in }
                    alert.addAction(alertAction)
                    self.presentViewController(alert, animated: true) { () -> Void in }
                    return;
                }
                
                print("SUCCESSFUL POST stream to server, creating channel...")
                
                 //subscribe the host to the channel
                appDelegate.client?.subscribeToChannels([channelName], withPresence: true)
                
                print(appDelegate.client?.channels())
                
                let streamID = stream["_id"].stringValue
                defaults.setObject(streamID, forKey: "hostedStream")
                defaults.setObject(channelName, forKey: "channelName")
                
                 //go to stream view
                let streamView:StreamViewController = StreamViewController(nibName: "StreamViewController", bundle: nil)
                streamView.streamName = streamName
                self.presentViewController(streamView, animated: true, completion: nil)
        }
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
        auth.tokenRefreshURL = NSURL(string: kTokenRefreshURL)
        auth.tokenSwapURL = NSURL(string: kTokenSwapURL)
        //let loginURL : NSURL = auth.loginURL;
        
        let loginURL = SPTAuth.loginURLForClientId(kClientID, withRedirectURL: NSURL(string: kCallBackURL), scopes: [SPTAuthStreamingScope], responseType: "code")
        
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
            
            playUsingSession(firstTimeSession)
            //session = firstTimeSession
            
        }
    }
}
