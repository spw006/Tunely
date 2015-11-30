//
//  AppDelegate.swift
//  Tunely-Demo
//
//  Created by Tracy Nham on 10/15/15.
//  Copyright © 2015 Tracy Nham. All rights reserved.
//

import UIKit
import PubNub
import Alamofire
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var client: PubNub?
    
    let kClientID = "bc9df159847e473bac13ac944653af50";
    let kCallBackURL = "Tunely-Demo://callback"
    
    // For demo purposes the initialization is done in the init function so that
    // the PubNub client is instantiated before it is used.
    /*
    override init() {
        
        // Instantiate configuration instance.
        // Instantiate PubNub client.
        client = PubNub.clientWithConfiguration(configuration)
        
        super.init()
        client?.addListener(self)
    }*/
    

    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        //
        if(SpotifyLoginFlag == true) {
        if SPTAuth.defaultInstance().canHandleURL(NSURL(string:kCallBackURL)) {
            SPTAuth.defaultInstance().handleAuthCallbackWithTriggeredAuthURL(url, callback: {(error: NSError!, session: SPTSession!) -> Void in
                if error != nil {
                    print(error)
                    print("Authentication error")
                    return
                }
                let userDefaults = NSUserDefaults.standardUserDefaults()
                let sessionData = NSKeyedArchiver.archivedDataWithRootObject(session)
                userDefaults.setObject(sessionData, forKey: "SpotifySession")
                userDefaults.synchronize();
                
                NSNotificationCenter.defaultCenter().postNotificationName("loginSuccessful", object: nil)
                print("Authentication successful")
            })
            
            }
            return true;
        }
        //
        
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    
    /************************** PUBNUB FUNCTIONS ************************/
    
    // Handle new message from one of channels on which client has been subscribed.
    /*
    func client(client: PubNub!, didReceiveMessage message: PNMessageResult!) {
        
        // Handle new message stored in message.data.message
        if message.data.actualChannel != nil {
            
            // Message has been received on channel group stored in
            // message.data.subscribedChannel
        }
        else {
            
            // Message has been received on channel stored in
            // message.data.subscribedChannel
        }
        
        print("Received message: \(message.data.message) on channel " +
            "\((message.data.actualChannel ?? message.data.subscribedChannel)!) at " +
            "\(message.data.timetoken)")
    }
    
    // New presence event handling.
    func client(client: PubNub!, didReceivePresenceEvent event: PNPresenceEventResult!) {
        
        // Handle presence event event.data.presenceEvent (one of: join, leave, timeout,
        // state-change).
        if event.data.actualChannel != nil {
            
            // Presence event has been received on channel group stored in
            // event.data.subscribedChannel
        }
        else {
            
            // Presence event has been received on channel stored in
            // event.data.subscribedChannel
        }
        
        if event.data.presenceEvent != "state-change" {
            
            print("\(event.data.presence.uuid) \"\(event.data.presenceEvent)'ed\"\n" +
                "at: \(event.data.presence.timetoken) " +
                "on \((event.data.actualChannel ?? event.data.subscribedChannel)!) " +
                "(Occupancy: \(event.data.presence.occupancy))");
        }
        else {
            
            print("\(event.data.presence.uuid) changed state at: " +
                "\(event.data.presence.timetoken) " +
                "on \((event.data.actualChannel ?? event.data.subscribedChannel)!) to:\n" +
                "\(event.data.presence.state)");
        }
    }

    
    // Handle subscription status change.
    
    // Handle subscription status change.
    func client(client: PubNub!, didReceiveStatus status: PNStatus!) {
        if status.category == .PNUnexpectedDisconnectCategory {
            
            // This event happens when radio / connectivity is lost
        }
        else if status.category == .PNConnectedCategory {
            
            // Connect event. You can do stuff like publish, and know you'll get it.
            // Or just use the connected event to confirm you are subscribed for
            // UI / internal notifications, etc
            
            // Select last object from list of channels and send message to it.
            let targetChannel = client.channels().last as! String
            client.publish("Hello from the PubNub Swift SDK", toChannel: targetChannel,
                compressed: false, withCompletion: { (status) -> Void in
                    
                    if !status.error {
                        
                        // Message successfully published to specified channel.
                    }
                    else{
                        
                        // Handle message publish error. Check 'category' property
                        // to find out possible reason because of which request did fail.
                        // Review 'errorData' property (which has PNErrorData data type) of status
                        // object to get additional information about issue.
                        //
                        // Request can be resent using: status.retry()
                    }
            })
        }
        else if status.category == .PNReconnectedCategory {
            
            // Happens as part of our regular operation. This event happens when
            // radio / connectivity is lost, then regained.
        }
        else if status.category == .PNDecryptionErrorCategory {
            
            // Handle messsage decryption error. Probably client configured to
            // encrypt messages and on live data feed it received plain text.
        }
    }*/
    
    /************************ END PUBNUB FUNCTIONS ****************************/
    

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        let hostedStream = defaults.stringForKey("hostedStream")
        
        // delete the stream object in the database
        let uri : String = "http://ec2-54-183-142-37.us-west-1.compute.amazonaws.com/api/streams/" + hostedStream!
        let headers : [String: String] = ["x-access-token": FBSDKAccessToken.currentAccessToken().tokenString]
        
        Alamofire.request(.DELETE, uri, headers:headers)
            .responseJSON { json in
                
                let deletedStream = JSON(data: json.data!)
                
                print (deletedStream)
                
                // Do not proceed if server did not respond
                if (deletedStream == nil) {
                    print("No response from server or stream does not exist.")
                    return
                }
                
                // delete the value for the hostedStream key
                defaults.setObject(nil, forKey: "hostedStream")
                
                print("Deleted hosted stream.")
        }
        
        let targetChannel = client?.channels().last as! String
        client?.unsubscribeFromChannels([targetChannel], withPresence: true)
        
        
        
            
    }
}

