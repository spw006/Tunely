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


var player:SPTAudioStreamingController?
//var userPlaylistTrackStrings = [NSURL]()

var userPlaylistTrackStrings = [Song]()

class StreamViewController: UIViewController,SPTAudioStreamingPlaybackDelegate, UITableViewDataSource, UITableViewDelegate, PNObjectEventListener {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var titleLabel : UILabel?
    @IBOutlet weak var listenersView: UICollectionView!
    
    
    var listenersPic : [String] = []
    var listeners : [String] = []
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    //var client: PubNub?
    var streamName : String!
    

    @IBOutlet weak var SearchButton: UIButton!
    
    @IBAction func searchSongs(sender: AnyObject) {
        let searchSongView:SongSearchViewController = SongSearchViewController(nibName: "SongSearchViewController", bundle: nil)
        //appDelegate.client?.removeListener(self)
        
        self.presentViewController(searchSongView, animated: true, completion: nil)
    }
    

    
    
    let kClientID = "4d63faabbbed404384264f330f8610b7";
    let kCallBackURL = "SpotifyTesting://callback"
    
    //var player:SPTAudioStreamingController?
    
    
    var isPlaying = false;
    var trackListPosition = 0;
    var firstPlay = true;
    var pausePressed = true;
    
    
    //table view
    //@IBOutlet
    //var tableView: UITableView!
    
    //var timer: NSTimer = NSTimer()
    
    
    
    //array of songs returned by spotify search request
    var songs: [Song] = []
    
    
    @IBOutlet weak var PlayPause: UIBarButtonItem!
    //@IBOutlet weak var Next: UIButton!
    
    @IBOutlet weak var Back: UIBarButtonItem!
    @IBOutlet weak var Next: UIBarButtonItem!
    
    
    
    
    @IBAction func PlayPause(sender: AnyObject) {
        pausePressed = true
        if player == nil {
            player = SPTAudioStreamingController(clientId: kClientID)
            player?.playbackDelegate = self;
            print("no player")
        }
        if(firstPlay == true)
        {
            print("first play")
            playUsingSession(session)
            //player?.playURI(userPlaylistTrackStrings[0], callback: nil)
            let tmpString = userPlaylistTrackStrings[0].trackID 
            let formattedTrackName = NSURL(string: "spotify:track:"+tmpString);
            player?.playURI(formattedTrackName, callback: nil)
            //isPlaying = true;
            firstPlay = false
        }
        else {
            player?.setIsPlaying(isPlaying, callback: nil)

            if(isPlaying == false){
                isPlaying = true;
                print("music paused")
            }
            else
            {
                print("music played")
                isPlaying = false;
            }
        }
        pausePressed = false
        //playUsingSession(session)
        
        //self.player?.setIsPlaying(isPlaying, callback: nil)
        /*
        Alamofire.request(.GET, "https://api.spotify.com/v1/search?q=loveland&type=track")
        .responseJSON { response in
        debugPrint(response)*/
        /*
        Alamofire.request(.GET, "https://api.spotify.com/v1/search?q=loveland&type=track").response { request, response, data, error in
        
        let json = JSON(data: data!)
        
        print(json["tracks"]["items"].count);
        //print(json["tracks"]["items"])
        
        for var i = 0; i < json["tracks"]["items"].count; i++ {
        
        let data = json["tracks"]["items"][i]
        
        // return the object list
        let song = Song()
        
        song.title = data["name"].string!
        song.album = data["album"]["name"].string!
        song.artist = data["artists"][0]["name"].string!
        song.trackID = data["id"].string!
        
        print(song.title)
        print(song.artist)
        print(song.trackID)
        
        self.songs += [song]
        
        }
        }*/
        
        
    }
    @IBAction func SkipForwardSong(sender: AnyObject) {
        print("next song button pressed")
        if player == nil {
            player = SPTAudioStreamingController(clientId: kClientID)
        }
        
        //debug
        //self.addSongtoPlaylist("1UfBAJfmofTffrae5ls6DA") //fairytale
        
        player?.skipNext(nil)
    }
    
    @IBAction func SkipBackSong(sender: AnyObject) {
        print("back song button pressed")
        if player == nil {
            player = SPTAudioStreamingController(clientId: kClientID)
        }
        
        //debug
        //self.addSongtoPlaylist("1UfBAJfmofTffrae5ls6DA") //fairytale
        
        player?.skipPrevious(nil)
    }
    
    func addSongtoPlaylist(trackID: String)
    {
        // var userPlaylistTrackStrings = [NSURL]()
        
        print("song added to playlist!")
        if player == nil {
            player = SPTAudioStreamingController(clientId: kClientID)
        }
        
        let formattedTrackName = NSURL(string: "spotify:track:"+trackID);
        print(formattedTrackName)
        
        //userPlaylistTrackStrings.append(formattedTrackName!)
        //userPlaylistTrackStrings.append(formattedTrackName!)
        
        
        //player?.queueURI(formattedTrackName, callback: nil)
        //player?.replaceURIs(userPlaylistTrackStrings, withCurrentTrack: (player?.currentTrackIndex)!, callback: nil)
        
        
        //self.player?.queueURI(<#T##uri: NSURL!##NSURL!#>, callback: <#T##SPTErrorableOperationCallback!##SPTErrorableOperationCallback!##(NSError!) -> Void#>)
        
    }
    
    
    
    func audioStreaming(player: SPTAudioStreamingController, didStopPlayingTrack uri: NSURL) {
        print("track ended" )
        if(pausePressed == false){
            trackListPosition++;
            if(trackListPosition < userPlaylistTrackStrings.count)
            {
                var tmpString = userPlaylistTrackStrings[trackListPosition].trackID
                let formattedTrackName = NSURL(string: "spotify:track:"+tmpString);
                player.playURI(formattedTrackName, callback: nil)
            }
        }
    }
    func playUsingSession(sessionObj:SPTSession) {
        print("playing using session called")
        if player == nil {
            player = SPTAudioStreamingController(clientId: kClientID)
            player?.playbackDelegate = self;
            
        }
        player?.loginWithSession(sessionObj, callback: { (error:NSError!) -> Void in
            if error != nil {
                print("enabling playback got error")
                return
            }
            //SPTRequest.requestItemAtURI(<#T##uri: NSURL!##NSURL!#>, withSession: <#T##SPTSession!#>, callback: <#T##SPTRequestCallback!##SPTRequestCallback!##(NSError!, AnyObject!) -> Void#>)
            //SPTTrack.trackWithURI(<#T##uri: NSURL!##NSURL!#>, session: <#T##SPTSession!#>, callback: <#T##SPTRequestCallback!##SPTRequestCallback!##(NSError!, AnyObject!) -> Void#>)
            
            //self.addSongtoPlaylist("3KUs7BeZGMze6HDDdFlb7j") //loveland
            //self.addSongtoPlaylist("24w8CSNGN34hYPCrjdRLob") //fairytale
            
            SPTTrack.trackWithURI(NSURL(string: "spotify:track:3f9zqUnrnIq0LANhmnaF0V"), session: sessionObj, callback: { (error:NSError!, trackObj:AnyObject!) -> Void in
                if error != nil {
                    print("track lookup got error")
                    return
                }
                //let track = trackObj as! SPTTrack
                //self.player?.playTrackProvider(track, callback: nil)
                print("song will play lol")
                //self.player?.playURI(NSURL(string: "spotify:track:4gqgQQHynn86YrJ9dEuMfc"), callback: nil)
                //player?.playURI(NSURL(string: "spotify:track:4gqgQQHynn86YrJ9dEuMfc"), callback: nil)
                
                //player?.playURIs(userPlaylistTrackStrings, fromIndex: 0, callback: nil)
                //player?.playURI(
                
                
                //player?.queuePlay(nil)
                
                
                //self.player?.play
                //self.player?.playURI(<#T##uri: NSURL!##NSURL!#>, callback: <#T##SPTErrorableOperationCallback!##SPTErrorableOperationCallback!##(NSError!) -> Void#>)
            })
            /*
            SPTRequest.requestItemAtURI(NSURL(string: "spotfiy:track:3f9zqUnrnIq0LANhmnaF0V"), withSession: sessionObj, callback: { (error:NSError!, albumObj:AnyObject!) -> Void in
            if error != nil {
            print("album lookup got error")
            return
            }
            let album = albumObj as! SPTAlbum
            self.player?.playTrackProvider(album, callback: nil)
            })*/
            
        })
    }
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        print("streamviewcontroller view loaded")
        
        titleLabel?.text = streamName
        
        if(firstLoad == true)
        {
            appDelegate.client?.addListener(self)
            firstLoad = false
        }
        
        let nib = UINib(nibName: "CollectionViewCell", bundle: nil)
        
        self.listenersView.registerNib(nib, forCellWithReuseIdentifier: "reuseIdentifier")
        
        //client = appDelegate.client!
        //client?.addListener(self)
        //appDelegate.client!.addListener(self)
        
        /* Table Setup delegates */
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        //self.tableView.reloadData()
        //self.tableView.reloadData()
        self.tableView.reloadData()


        print("endofviewload")
        

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
        return listenersPic.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("reuseIdentifier", forIndexPath: indexPath) as! CollectionViewCell
        
        
        let url : NSURL = NSURL(string : listenersPic[indexPath.row])!
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
            print("actual channel")
        }
        else {
            
            // Message has been received on channel stored in
            // message.data.subscribedChannel
            print("other channel")
        }
        
        if let obj = message.data.message["songObj"] {
            /*
            if !self.listeners.contains(message.uuid) {
                print("adding " + message.uuid + " to my list of listeners")
                self.listenersPic.append(obj["url"] as! String)
                self.listeners.append(message.uuid)
                self.listenersView.reloadData()
            }
            else {
                print("ERROR: " + message.uuid + " is already a listener")
            }*/
            if(obj != nil){
            
                
                
            var song = Song()
                
            song.title = obj["title"] as! String
            song.album = obj["album"] as! String
            song.artist = obj["artist"] as! String
            song.trackID = obj["trackID"] as! String
            //var tmpString = song.trackID
            //var formattedTrackName = NSURL(string: "spotify:track:"+tmpString);
                
            
            userPlaylistTrackStrings.append(song)
            //var tempString2 = obj["title"] as! String
            //playlistTrackname.append(tempString2)
            
            }
            
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
            
            let targetChannel = client.channels().last as! String
            
            //let uuid : String = (self.client?.uuid())!
            let uuid: String = client.uuid()
            

            let picObject : [String : [String : String]] = ["pic" : ["url" : defaults.stringForKey("userPicURL")! , "uuid" : uuid]]
            
            
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
            
            //let uuid : String = (self.client?.uuid())!
            let uuid : String = (client?.uuid())!
            
            
            let picObject : [String : [String : String]] = ["pic" : ["url" : defaults.stringForKey("userPicURL")! , "uuid" : uuid]]
            
            
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
    
    
    
    //TABLE VIEW STUFF:
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userPlaylistTrackStrings.count
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let row = indexPath.row
        
        
        let tmpString = userPlaylistTrackStrings[row].trackID //as! String
        let formattedTrackName = NSURL(string: "spotify:track:"+tmpString);
        player?.playURI(formattedTrackName, callback: nil)
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print("tableView called")
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        //var cell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        print(indexPath.row)
        //print(songs.count)
        
        if(userPlaylistTrackStrings.count > 0){
            /*
            let song = playlistTrackname[indexPath.row]
            
            cell.textLabel?.text = song.title
            
            cell.detailTextLabel?.text = song.artist + " - " + song.album
*/
            //code for join stream but not host
            //cell.textLabel?.text = playlistTrackname[indexPath.row]
            
            print(userPlaylistTrackStrings[indexPath.row].title)
            cell.textLabel?.text = userPlaylistTrackStrings[indexPath.row].title
        }

        return cell
    }
    
    
    

}
