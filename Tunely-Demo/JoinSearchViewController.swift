//
//  JoinSearchViewController.swift
//  Tunely-Demo
//
//  Created by Sean Wang on 11/20/15.
//  Copyright © 2015 Tracy Nham. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PubNub

class JoinSearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, PNObjectEventListener {
    
    
    @IBOutlet weak var BackButton: UIButton!
    
    @IBAction func goBack(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //pubnub
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var searchActive : Bool = false
    
    var filtered:[String] = []
    
    @IBOutlet weak var SongSearchBar: UISearchBar!
    
    var songs: [Song] = []
    
    
    
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        print("searchDisplayController called")
        songs.removeAll()
        if(searchActive == true){
            self.getSongs(searchText)
            
            //self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Setup delegates */
        tableView.delegate = self
        tableView.dataSource = self
        SongSearchBar.delegate = self
        
        appDelegate.client?.addListener(self)
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")

    }
    
    func getSongs(timer: String!) {
        let searchTerm = timer
        
        self.title = "Results for \(searchTerm)"
        
        // logic to switch service; need to eventually move this to an interface
        // or move this code inside a rest API, and then into an interface
        
        // URL encode the search term
        let searchTermEncoded = searchTerm.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
        
        // create the url for the web request
        let uri: String = "https://api.spotify.com/v1/search?q=\(searchTermEncoded!)&type=artist,album,track"
        
        
        Alamofire
            .request(.GET, uri)
            .response { request, response, data, error in
                
                let json = JSON(data: data!)
                
                //print(json["tracks"]["items"].count);
                //print(json["tracks"]["items"])
                
                for var i = 0; i < json["tracks"]["items"].count; i++ {
                    
                    let data = json["tracks"]["items"][i]
                    
                    // return the object list
                    let song = Song()
                    
                    song.title = data["name"].string!
                    song.album = data["album"]["name"].string!
                    song.artist = data["artists"][0]["name"].string!
                    song.trackID = data["id"].string!
                    
                    
                    self.songs += [song]
                    
                }
                /*
                dispatch_async(dispatch_get_main_queue()) {
                self.tableView!.reloadData()
                }*/
                self.tableView!.reloadData()
                
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    /** When a user selects a song */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // get the song selected
        let selectedSong = songs[indexPath.row]
        
        let songObject: [String: [String: String]] = [
            "songObject": [
                "trackID": selectedSong.trackID,
                "title": selectedSong.title,
                "artist": selectedSong.artist,
                "album": selectedSong.album
            ]
        ]
        
        // Make the JSON to send
        let message: AnyObject = JSON(songObject).object
        
        // publish the song message to the target channel
        // Only the host (StreamViewController should deal with this message)
        let targetChannel =  appDelegate.client?.channels().last as! String
        appDelegate.client!.publish(message, toChannel: targetChannel, compressed: false, withCompletion: { (status) -> Void in })
        
        // popup confirm
        let alert = UIAlertController(title: "Song Added", message: selectedSong.title + " just added", preferredStyle: UIAlertControllerStyle.Alert)
        let alertAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in }
        alert.addAction(alertAction)
        presentViewController(alert, animated: true) { () -> Void in }
    }
    
    /** Populates the table with songs */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell?
        
        if (cell != nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        }
        
        // populate the table with the songs (title and artist)
        if (songs.count > 0){
            let song = songs[indexPath.row]
            
            cell!.textLabel?.text = song.title
            cell!.detailTextLabel?.text = song.artist + " - " + song.album
        }
        
        return cell!
    }

}
