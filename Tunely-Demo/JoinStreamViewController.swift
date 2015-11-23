//
//  JoinStreamViewController.swift
//  Tunely-Demo
//
//  Created by Sean Wang on 11/19/15.
//  Copyright © 2015 Tracy Nham. All rights reserved.
//

import UIKit
import PubNub
import Alamofire
import SwiftyJSON


class JoinStreamViewController: UIViewController,SPTAudioStreamingPlaybackDelegate, UITableViewDataSource, UITableViewDelegate, PNObjectEventListener {
    
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var listenersView: UICollectionView!
    
    @IBOutlet weak var backButton: UIButton!
    /** this joined user's playlist */
    var playlist: [Song] = []
    
    var streamName : String!
    
    
    var listenersPic : [String] = []
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    @IBOutlet weak var SearchButton: UIButton!
    
    @IBAction func searchSongs(sender: AnyObject) {
        let searchSongView:JoinSearchViewController = JoinSearchViewController(nibName: "JoinSearchViewController", bundle: nil)
        
        
        appDelegate.client?.removeListener(self)
        
        self.presentViewController(searchSongView, animated: true, completion: nil)
    }
    
    
    
    
    let kClientID = "4d63faabbbed404384264f330f8610b7";
    let kCallBackURL = "SpotifyTesting://callback"
    
    //var player:SPTAudioStreamingController?
    
    
    var isPlaying = false;
    var TrackListPosition = 0;
    var firstPlay = true;
    var pausePressed = true;
    var skipSongs = false;
    
    //array of songs returned by spotify search request
    var songs: [Song] = []
    
    
    @IBOutlet weak var PlayPause: UIBarButtonItem!
    //@IBOutlet weak var Next: UIButton!
    
    @IBOutlet weak var Back: UIBarButtonItem!
    @IBOutlet weak var Next: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("streamviewcontroller view loaded")
        
        titleLabel?.text = streamName
        

            appDelegate.client?.addListener(self)

        
        appDelegate.client?.addListener(self)
        
        //let nib = UINib(nibName: "CollectionViewCell", bundle: nil)
        
        //self.listenersView.registerNib(nib, forCellWithReuseIdentifier: "reuseIdentifier")
        
        //client = appDelegate.client!
        //client?.addListener(self)
        //appDelegate.client!.addListener(self)
        
        /* Table Setup delegates */
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        
        
        
        
        
        
        // When the user joins a stream, initially populate the table with the current playlist
        // basically requests for the playlist from the host
        let targetChannel =  appDelegate.client?.channels().last as! String
        let songObject : [String : String] = ["joinRequest": "joinRequest"]
        appDelegate.client!.publish(songObject, toChannel: targetChannel, compressed: false, withCompletion: { (status) -> Void in })
        
        
        // construct picture object
        let pictureObject : [String : [String : String]] = [
            "pictureObject" : ["picURL" : defaults.stringForKey("userPicURL")! as String]]
        
        appDelegate.client!.publish(pictureObject, toChannel: targetChannel,
            compressed: false, withCompletion: { (status) -> Void in
        })
        
        self.tableView.reloadData()
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
        return listenersPic.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("reuseIdentifier", forIndexPath: indexPath) as! CollectionViewCell
        
        let url : NSURL = NSURL(string : listenersPic[indexPath.row])!
        let data : NSData = NSData(contentsOfURL: url)!
        
        cell.imageView.image = UIImage(data: data);
        
        return cell
    }
    
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    
    
    //TABLE VIEW:
    
    /** Number of sections */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /** Number of rows in a section */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlist.count
    }
    
    /** Populates table */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell?
        
        if (cell != nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        }
        
        if (playlist.count > 0) {
            cell!.textLabel?.text = playlist[indexPath.row].title
            cell!.detailTextLabel?.text = playlist[indexPath.row].artist + " - " + playlist[indexPath.row].album
        }
        
        return cell!
    }
    
    
    
    
    
    
    /************************** PUBNUB FUNCTIONS ************************/
     
    /** Handle received message */
    func client(client: PubNub!, didReceiveMessage message: PNMessageResult!) {
        print("Received message: \(message.data.message) on channel " +
            "\((message.data.actualChannel ?? message.data.subscribedChannel)!) at " +
            "\(message.data.timetoken)")
        
        
        // If a joined user received a listeners object, they update their listeners
        if let listenersPic = message.data.message["listenersObject"] {
            if (listenersPic != nil) {
                self.listenersPic = listenersPic as! [String]
                print(listenersPic)
                listenersView.reloadData()
            }
        }
        
        // When a joined user receives the playist message from the host, they update their local playlist
        if let playlistObject = message.data.message["playlistObject"] {
            if (playlistObject != nil) {
                
                // reconstruct the playlist
                let playlistJSON: JSON = JSON(playlistObject)
                
                // loop through the playlist to get the songs
                var playlist: [Song] = []
                for (_, songJSON) in playlistJSON {
                    let song = Song()
                    song.trackID = songJSON["trackID"].stringValue
                    song.title = songJSON["title"].stringValue
                    song.artist = songJSON["artist"].stringValue
                    song.album = songJSON["album"].stringValue
                    
                    playlist.append(song)
                }
                
                // update this joined user's playlist
                self.playlist = playlist
                
                // update the table
                self.tableView.reloadData()
            }
        }
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
    
    @IBAction func endStream(sender: AnyObject) {
        // unsubscribe from pubnub
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let targetChannel = appDelegate.client?.channels().last {
            print("unsubscribed from " + (targetChannel as! String))
            appDelegate.client?.unsubscribeFromChannels([targetChannel as! String], withPresence: true)
        }
        
        print(appDelegate.client?.channels())
        
        // go back to home after delete
        dismissViewControllerAnimated(true, completion: nil)
    }
}
