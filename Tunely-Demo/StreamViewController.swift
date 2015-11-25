//
//  StreamViewController.swift
//  Tunely-Demo
//
//  Created by Cole Stipe on 11/3/15.
//  Copyright © 2015 Tracy Nham. All rights reserved.
//

import Alamofire
import SwiftyJSON
import UIKit
import PubNub

var playlistTrackname = [String]()
var playlistArtistname = [String]()
var player:SPTAudioStreamingController?

class StreamViewController: UIViewController,SPTAudioStreamingPlaybackDelegate, UITableViewDataSource, UITableViewDelegate, PNObjectEventListener {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel : UILabel?
    @IBOutlet weak var listenersView: UICollectionView!
    
    // playlist of song objects
    var userPlaylistTrackStrings = [Song]()
    
    var listenersPic : [String] = []
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var streamName : String!
    
    var currentSong: String = ""
    
    @IBOutlet weak var thisSong: UILabel!
    @IBOutlet weak var SearchButton: UIButton!
    
    
    @IBAction func searchSongs(sender: AnyObject) {
        let searchSongView:SongSearchViewController = SongSearchViewController(nibName: "SongSearchViewController", bundle: nil)
        self.presentViewController(searchSongView, animated: true, completion: nil)
    }    
    
    let kClientID = "4d63faabbbed404384264f330f8610b7";
    let kCallBackURL = "SpotifyTesting://callback"
    
    //var player:SPTAudioStreamingController?
    
    
    var isPlaying = false;
    var TrackListPosition = 0;
    var firstPlay = true;
    var pausePressed = false;
    var skipSongs = false;
    
    var serializedPlaylist: [AnyObject] = []
    
    //array of songs returned by spotify search request
    var songs: [Song] = []
    
    
    @IBOutlet weak var PlayPause: UIBarButtonItem!
    //@IBOutlet weak var Next: UIButton!
    
    @IBOutlet weak var Back: UIBarButtonItem!
    @IBOutlet weak var Next: UIBarButtonItem!
    
    
    @IBAction func PlayPause(sender: AnyObject) {
        // do not allow user to play/pause if the playlist is empty
        if (self.userPlaylistTrackStrings.isEmpty) {
            return;
        }
        
        pausePressed = true
        if player == nil {
            player = SPTAudioStreamingController(clientId: kClientID)
            player?.playbackDelegate = self;
            print("no player")
        }
        if(userPlaylistTrackStrings.count > 0) {
        if(firstPlay == true)
        {
            print("first play")
            //updateSession()
            //playUsingSession(session)
            //player?.playURI(userPlaylistTrackStrings[0], callback: nil)
            let tmpString = userPlaylistTrackStrings[0].trackID
            let tmpTitle = "Current Song: " + userPlaylistTrackStrings[0].title + " - " + userPlaylistTrackStrings[0].artist
            let formattedTrackName = NSURL(string: "spotify:track:"+tmpString);
            
            player?.playURI(formattedTrackName, callback: { error -> Void in
                if error == nil {
                        self.currentSong = tmpTitle
                        self.thisSong.text = self.currentSong
                }
                else {print(error)}
            })
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
        }
        pausePressed = false

        
        
    }
    @IBAction func SkipForwardSong(sender: AnyObject) {
        print("next song button pressed")
        
        if player == nil {
            player = SPTAudioStreamingController(clientId: kClientID)
        }
        skipSongs = true;
        TrackListPosition=TrackListPosition+1;
        if(TrackListPosition < userPlaylistTrackStrings.count)
        {
            let tmpString = userPlaylistTrackStrings[TrackListPosition].trackID
            let tmpTitle = "Current Song: " + userPlaylistTrackStrings[TrackListPosition].title + " - " + userPlaylistTrackStrings[TrackListPosition].artist
            let formattedTrackName = NSURL(string: "spotify:track:"+tmpString);
            print(userPlaylistTrackStrings[TrackListPosition].title)
            //player!.setIsPlaying(false, callback: nil)
            //player!.stop(nil)
            player!.playURI(formattedTrackName, callback: { error -> Void in
                if error == nil {
                    self.skipSongs = false;
                    self.currentSong = tmpTitle
                    self.thisSong.text = self.currentSong
                    return
                }
            })
        }
        else
        {
            TrackListPosition=TrackListPosition-1;
        }

        //debug
        //self.addSongtoPlaylist("1UfBAJfmofTffrae5ls6DA") //fairytale
        
        //player?.skipNext(nil)
        //skipSongs = false;
    }
    
    @IBAction func SkipBackSong(sender: AnyObject) {
        print("back song button pressed")
        if player == nil {
            player = SPTAudioStreamingController(clientId: kClientID)
        }
        skipSongs = true;
        TrackListPosition=TrackListPosition-1;
        if(TrackListPosition >= 0)
        {
            let tmpString = userPlaylistTrackStrings[TrackListPosition].trackID
            let tmpTitle = "Current Song: " + userPlaylistTrackStrings[TrackListPosition].title + " - " + userPlaylistTrackStrings[TrackListPosition].artist
            let formattedTrackName = NSURL(string: "spotify:track:"+tmpString);
            //player!.setIsPlaying(false, callback: nil)
            //player!.stop(nil)

            player!.playURI(formattedTrackName, callback: { error -> Void in
                if error == nil {
                    self.skipSongs = false;
                    self.currentSong = tmpTitle
                    self.thisSong.text = self.currentSong
                    return
                }
            })
        }
        else
        {
            TrackListPosition=TrackListPosition+1;
        }

        //debug
        //self.addSongtoPlaylist("1UfBAJfmofTffrae5ls6DA") //fairytale
        
        //player?.skipPrevious(nil)
        //skipSongs = false;
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
            print(skipSongs)
            if(skipSongs == false){
                print("fuck life")
                TrackListPosition=TrackListPosition+1;
            if(TrackListPosition < userPlaylistTrackStrings.count)
            {
                print("audio streaming next song")
                let tmpString = userPlaylistTrackStrings[TrackListPosition].trackID
                let tmpTitle = "Current Song: " + userPlaylistTrackStrings[TrackListPosition].title + " - " + userPlaylistTrackStrings[TrackListPosition].artist
                let formattedTrackName = NSURL(string: "spotify:track:"+tmpString);
                player.playURI(formattedTrackName, callback: nil)
                self.currentSong = tmpTitle
                self.thisSong.text = self.currentSong
            }
            }
        }
    }
    /*
    
    func updateSession() {

        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if let sessionObj:AnyObject = userDefaults.objectForKey("SpotifySession") {
            let sessionDataObj = sessionObj as! NSData
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObjectWithData(sessionDataObj) as! SPTSession
            
            //playUsingSession(firstTimeSession)
            //session = firstTimeSession
            
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
    */
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel?.text = streamName
        thisSong.textAlignment = .Center
        thisSong.text = "Current Song: "
        
        //player?.playbackDelegate = self;

        
        /*if (firstLoad == true) {
            appDelegate.client?.addListener(self)
            clnt = appDelegate.client
            firstLoad = false
        } */
        
        appDelegate.client?.addListener(self)
        /*
        if(player != nil) {
            player?.playbackDelegate = self;
            print("nil player at streamingcontroller")
        }*/
        player?.playbackDelegate = self
        
        let nib = UINib(nibName: "CollectionViewCell", bundle: nil)
        
        self.listenersView.registerNib(nib, forCellWithReuseIdentifier: "reuseIdentifier")
        
        /* Table Setup delegates */
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.tableView.reloadData()
        
        
        

        
        
        

        print("endofviewload")
        

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    
    /** End the stream */
    @IBAction func endStream(sender: AnyObject) {

        let alert = UIAlertController(title: "Are you sure you want to end your stream?", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            
        // Cancel action
        let cancelAction = UIAlertAction(title: "No", style: .Cancel) {(action) in
            print(action)
        }
            
        // Enter action
        let enterAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) {(action) in
            self.deleteStreamAndUnsubscribe()
        }
            
        alert.addAction(cancelAction)
        alert.addAction(enterAction)
            
        // Show alert
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    /** Handles deleting the stream from the database and removing the host/joined users from the channel */
    func deleteStreamAndUnsubscribe() {
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
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // kick all joined users in the channel and then unsubscribe from pubnub
        if let targetChannel = appDelegate.client?.channels().last {
            
            // kick all joined users in the channel
            let endStreamMessage : [String : String] = ["endStream" :"endStream"]
            appDelegate.client!.publish(endStreamMessage, toChannel: targetChannel as! String,
                compressed: false, withCompletion: { (status) -> Void in
            })
            
            // unsubscribe from the channel
            appDelegate.client?.unsubscribeFromChannels([targetChannel as! String], withPresence: true)
            print("unsubscribed from " + (targetChannel as! String))
        }
        
        // go back to home after delete
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //TABLE VIEW:
    
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
        
        
        if player == nil {
            player = SPTAudioStreamingController(clientId: kClientID)
            player?.playbackDelegate = self;
            print("no player")
        }
        
        if(firstPlay == true)
        {
            print("first play")
            //updateSession()
            //playUsingSession(session)
            //player?.playURI(userPlaylistTrackStrings[0], callback: nil)
            //let tmpString = userPlaylistTrackStrings[0].trackID
            //let formattedTrackName = NSURL(string: "spotify:track:"+tmpString);
            //player?.playURI(formattedTrackName, callback: nil)
            //isPlaying = true;
            firstPlay = false
        }
        
        
        skipSongs = true
        let row = indexPath.row
        
        
        //player!.stop(nil)
        isPlaying = false;
        TrackListPosition = row
        
        
        let tmpString = userPlaylistTrackStrings[row].trackID //as! String
        let tmpTitle = "Current Song: " + userPlaylistTrackStrings[row].title + " - " + userPlaylistTrackStrings[row].artist
        print(userPlaylistTrackStrings[row].title)
        let formattedTrackName = NSURL(string: "spotify:track:"+tmpString);
        
        print("x")
        player?.playURI(formattedTrackName, callback: { error -> Void in
            if error == nil {
                self.skipSongs = false;
                self.currentSong = tmpTitle
                self.thisSong.text = self.currentSong
                return
            }
        })
        print("y")
        //skipSongs = false
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell?
        
        if (cell != nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        }
        
        if(userPlaylistTrackStrings.count > 0){
            cell!.textLabel?.text = userPlaylistTrackStrings[indexPath.row].title
            cell!.detailTextLabel?.text = userPlaylistTrackStrings[indexPath.row].artist + " - " + userPlaylistTrackStrings[indexPath.row].album
        }

        return cell!
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
    return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == .Delete
        {
            userPlaylistTrackStrings.removeAtIndex(indexPath.row)
            self.tableView.reloadData()
        }
        
        // publish playlist changes to listeners
        let targetChannel =  appDelegate.client?.channels().last as! String
        
        var playlist: [AnyObject] = []

        // construct the playlist
        for (var i = 0; i < userPlaylistTrackStrings.count; i++) {
            playlist.append(userPlaylistTrackStrings[i].toSerializableData())
        }
        
        serializedPlaylist = playlist
        
        // construct the object to send
        let playlistObject: [String: [AnyObject]] = [
            "playlistObject": playlist
        ]
        
        appDelegate.client!.publish(playlistObject, toChannel: targetChannel, compressed: false, withCompletion: { (status) -> Void in })
    }




    
    
    /************************** PUBNUB FUNCTIONS ************************/
     
    /* Received a message */
    func client(client: PubNub!, didReceiveMessage message: PNMessageResult!) {
        print("Received message: \(message.data.message) on channel " +
            "\((message.data.actualChannel ?? message.data.subscribedChannel)!) at " +
            "\(message.data.timetoken)")
        
        // If we receive a picture object, add it to the list of listeners and publish the updated listeners array
        if let pictureObject = message.data.message["pictureObject"] {
            if (pictureObject != nil) {
                
                // create the pic object
                let url = pictureObject["picURL"] as! String
                
                // we don't want to add a picture we already have
                if (listenersPic.contains(url)) {
                    return;
                }
                
                // add the picture to host's listenersPic array
                listenersPic.append(url);
                
                
                // construct the message to send (pictures of all current listeners)
                let listenersObject: [String: [String]] = [
                    "listenersObject": listenersPic
                ]
                
                listenersView.reloadData()
      
                // publish the pictures
                let targetChannel =  appDelegate.client?.channels().last as! String
                appDelegate.client!.publish(listenersObject, toChannel: targetChannel, compressed: false, withCompletion: { (status) -> Void in })
            }
        }
        
        // If we received a song, add it to the playlist and publish it
        if let songObject = message.data.message["songObject"] {
            if (songObject != nil) {
                
                // create the song object
                let song = Song()
                song.title = songObject["title"] as! String
                song.album = songObject["album"] as! String
                song.artist = songObject["artist"] as! String
                song.trackID = songObject["trackID"] as! String
                
                // add the song to the playlist
                userPlaylistTrackStrings.append(song)
                
                var playlist: [AnyObject] = []
                if (!self.serializedPlaylist.isEmpty) {
                    serializedPlaylist.append(song.toSerializableData())
                    playlist = serializedPlaylist
                }
                    
                else {
                    // construct the playlist
                    for (var i = 0; i < userPlaylistTrackStrings.count; i++) {
                        playlist.append(userPlaylistTrackStrings[i].toSerializableData())
                    }
                    serializedPlaylist = playlist
                }
                
                // construct the message to send
                let playlistObject: [String: [AnyObject]] = [
                    "playlistObject": playlist
                ]
                
                // publish the playlist
                let targetChannel =  appDelegate.client?.channels().last as! String
                appDelegate.client!.publish(playlistObject, toChannel: targetChannel, compressed: false, withCompletion: { (status) -> Void in })
                
                self.tableView.reloadData()
            }
        }
        
        
        // If the host user receives a request from a joined user, send the playlist
        if let joinRequest = message.data.message["joinRequest"] {
            if (joinRequest != nil) {
                
                var playlist: [AnyObject] = []
                if (!self.serializedPlaylist.isEmpty) {
                    playlist = serializedPlaylist
                }
                    
                else {
                    // construct the playlist
                    for (var i = 0; i < userPlaylistTrackStrings.count; i++) {
                        playlist.append(userPlaylistTrackStrings[i].toSerializableData())
                    }
                    serializedPlaylist = playlist
                }
                
                // construct the message to send
                let playlistObject: [String: [AnyObject]] = [
                    "playlistObject": playlist
                ]
                
                // publish the playlist
                let targetChannel =  appDelegate.client?.channels().last as! String
                appDelegate.client!.publish(playlistObject, toChannel: targetChannel, compressed: false, withCompletion: { (status) -> Void in })
            }
        }
            
        // If we received a leave request with the user's picture, remove the picture from the listenerspic array
        if let leaveRequest = message.data.message["leaveRequest"] {
            if (leaveRequest != nil) {
                let urlToRemove = leaveRequest as! String;
                listenersPic = listenersPic.filter() { $0 != urlToRemove}
                
                let listenersObject: [String: [String]] = [
                    "listenersObject": listenersPic
                ]
                
                listenersView.reloadData()
                
                // publish updated pictures
                let targetChannel =  appDelegate.client?.channels().last as! String
                appDelegate.client!.publish(listenersObject, toChannel: targetChannel, compressed: false, withCompletion: { (status) -> Void in })
            }
        }
        
        self.tableView.reloadData()
        
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
            
            /*let targetChannel = client.channels().last as! String
            
            //let uuid : String = (self.client?.uuid())!
            let uuid: String = client.uuid()
            
            
            /*let pictureObject : [String : [String : String]] = ["picObject" : ["url" : defaults.stringForKey("userPicURL")! , "uuid" : uuid]] */
            
            var userPicture = UserPicture();
            userPicture.picURL = defaults.stringForKey("userPicURL")!
            userPicture.name = defaults.stringForKey("userName")!
            
            // construct picture object
            let pictureObject : [String : AnyObject] = [
                "pictureObject" : userPicture.toSerializableData()
            ]
            
            
            client.publish(pictureObject, toChannel: targetChannel,
                compressed: false, withCompletion: { (status) -> Void in
            }) */
            
            
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
            
            // construct picture object
            let pictureObject : [String : [String : String]] = [
                "pictureObject" : ["picURL" : defaults.stringForKey("userPicURL")! as String]
            ]
            
            
            client.publish(pictureObject, toChannel: targetChannel,
            compressed: false, withCompletion: { (status) -> Void in
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
    

}
