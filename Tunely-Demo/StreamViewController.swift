//
//  StreamViewController.swift
//  Tunely-Demo
//
//  Created by Cole Stipe on 11/3/15.
//  Copyright © 2015 Tracy Nham. All rights reserved.
//

import Alamofire
import UIKit
import PubNub

class StreamViewController: UIViewController, PNObjectEventListener {
    
    @IBOutlet weak var titleLabel : UILabel?
    @IBOutlet weak var listenersView: UICollectionView!
    
    
    var listeners : [String] = []
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var client: PubNub?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel?.text = "My Stream"
        
        //self.listenersView.registerClass(CollectionViewCell.self, forCellWithReuseIdentifier: "reuseIdentifier")
        
        
        let nib = UINib(nibName: "CollectionViewCell", bundle: nil)
        
        self.listenersView.registerNib(nib, forCellWithReuseIdentifier: "reuseIdentifier")
        client = appDelegate.client!
        client?.addListener(self)


        // Do any additional setup after loading the view.
    }
    
    func loadStream(url: NSString) {
        // STEP 1
        // get title for url
        // populate title label with it
        
        // STEP 2
        // get songs for url
        // populate table view with them
        
        // STEP 3
        // get listeners for url
        // populate collection view with them
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func revealSideBar(sender: AnyObject) {
        
        let sideBar:SideBarTableViewController = SideBarTableViewController(nibName: "SideBarTableViewController", bundle: nil)
        sideBar.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        self.presentViewController(sideBar, animated: true, completion: nil)
        
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // Return the number of sections
        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Return the number of items in the section
        return listeners.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("reuseIdentifier", forIndexPath: indexPath) as! CollectionViewCell
        
        
        //let pic_url = "http://www.joomlaworks.net/images/demos/galleries/abstract/7.jpg"
        
        let url : NSURL = NSURL(string : listeners[indexPath.row])!
        
        print(url)
        
        let data : NSData = NSData(contentsOfURL: url)!
        
        cell.imageView.image = UIImage(data: data);
        
        return cell
        
    }
    
    /************************** PUBNUB FUNCTIONS ************************/
    
    // Handle new message from one of channels on which client has been subscribed.
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
        
        if let obj = message.data.message["pic"]{
            self.listeners.append(obj["url"] as! String)
            print("heeyeyeyeyye")
            print(listeners)
            self.listenersView.reloadData()
        }
        else {
            print("nooo")
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
            /*    let targetChannel = client.channels().last as! String
            client.publish("Hello from the PubNub Swift SDK", toChannel: targetChannel,
            compressed: false, withCompletion: { (status) -> Void in
            
            if !status.error {
            
            // Message successfully published to specified channel.
            }
            else{
            
            // Handle message publish error. Check 'category' property
            // to find out possible reason because of which request did
            ail.
            // Review 'errorData' property (which has PNErrorData data type) of status
            // object to get additional information about issue.
            //
            // Request can be resent using: status.retry()
            }
            })
            } */
            
            let targetChannel = client.channels().last as! String
            
            let uuid : String = (self.client?.uuid())!
            
            
            
            let picObject : [String : [String : String]] = ["pic" : ["url" : defaults.stringForKey("picURL")! , "uuid" : uuid]]
            
            
            client.publish(picObject, toChannel: targetChannel,
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
    }
    
    /************************ END PUBNUB FUNCTIONS ****************************/
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
