//
//  StreamViewController.swift
//  Tunely-Demo
//
//  Created by Cole Stipe on 11/3/15.
//  Copyright © 2015 Tracy Nham. All rights reserved.
//

import Alamofire
import UIKit

var player:SPTAudioStreamingController?
var userPlaylistTrackStrings = [NSURL]()

class StreamViewController: UIViewController,SPTAudioStreamingPlaybackDelegate {
    
    @IBOutlet weak var titleLabel : UILabel?

    @IBOutlet weak var SearchButton: UIButton!
    
    @IBAction func searchSongs(sender: AnyObject) {
        let searchSongView:SongSearchViewController = SongSearchViewController(nibName: "SongSearchViewController", bundle: nil)
        self.presentViewController(searchSongView, animated: true, completion: nil)
    }
    
    @IBAction func hostStream(sender: AnyObject) {
        let hostView:HostViewController = HostViewController(nibName: "HostViewController", bundle: nil)
        self.presentViewController(hostView, animated: true, completion: nil)
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
        if player == nil {
            player = SPTAudioStreamingController(clientId: kClientID)
        }
        if(firstPlay == true)
        {
            player?.playURI(userPlaylistTrackStrings[0], callback: nil)
            firstPlay = false;
        }
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
        if(pausePressed == false){
            pausePressed = true;
            print("music paused")
        }
        else
        {
            print("music played")
            pausePressed = false;
        }
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
        if player == nil {
            player = SPTAudioStreamingController(clientId: kClientID)
        }
        
        //debug
        //self.addSongtoPlaylist("1UfBAJfmofTffrae5ls6DA") //fairytale
        
        player?.skipNext(nil)
    }
    
    func addSongtoPlaylist(trackID: String)
    {
        // var userPlaylistTrackStrings = [NSURL]()
        
        print("song added to playlist!")
        if player == nil {
            player = SPTAudioStreamingController(clientId: kClientID)
        }
        
        var formattedTrackName = NSURL(string: "spotify:track:"+trackID);
        print(formattedTrackName)
        
        userPlaylistTrackStrings.append(formattedTrackName!)
        
        
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
                player.playURI(userPlaylistTrackStrings[trackListPosition], callback: nil)
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
            self.addSongtoPlaylist("24w8CSNGN34hYPCrjdRLob") //fairytale
            
            SPTTrack.trackWithURI(NSURL(string: "spotify:track:3f9zqUnrnIq0LANhmnaF0V"), session: sessionObj, callback: { (error:NSError!, trackObj:AnyObject!) -> Void in
                if error != nil {
                    print("track lookup got error")
                    return
                }
                //let track = trackObj as! SPTTrack
                //self.player?.playTrackProvider(track, callback: nil)
                print("song will play lol")
                //self.player?.playURI(NSURL(string: "spotify:track:4gqgQQHynn86YrJ9dEuMfc"), callback: nil)
                //self.player?.playURI(NSURL(string: "spotify:track:4gqgQQHynn86YrJ9dEuMfc"), callback: nil)
                
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
        
        titleLabel?.text = "My Stream"

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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
