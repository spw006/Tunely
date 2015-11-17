//
//  SearchSongTableViewController.swift
//  Tunely-Demo
//
//  Created by Sean Wang on 11/12/15.
//  Copyright © 2015 Tracy Nham. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SongSearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate {
    

    @IBOutlet weak var BackButton: UIButton!
    
    @IBAction func goBack(sender: AnyObject) {
        let streamView:StreamViewController = StreamViewController(nibName: "StreamViewController", bundle: nil)
        self.presentViewController(streamView, animated: true, completion: nil)
    }
    
    
    
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
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
    }
    
    func getSongs(timer: String!) {
        
        
        print("getSongs called")
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
    /*
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String?) -> Bool {
    
    print("searchDisplayController called")
    
    self.getSongs(searchString)
    
    return true
    
    
    }*/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return songs.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let row = indexPath.row
        print(songs[row].title)
        //ViewController().addSongtoPlaylist(songs[row].trackID)
        //ViewController.addSongtoPlaylist(ViewController)
        var formattedTrackName = NSURL(string: "spotify:track:"+songs[row].trackID);
        print(formattedTrackName)
        
        userPlaylistTrackStrings.append(formattedTrackName!)
        //player?.queueURI(formattedTrackName, callback: nil)
        //player?.playURI(formattedTrackName, callback: nil)
        //.ViewController.addSongtoPlaylist(songs[row].trackID)
        
        
        
    }
    /*
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    let row = indexPath.row
    println(swiftBlogs[row])
    }*/
    
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print("tableView called")
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        //var cell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        


        
        
        print(indexPath.row)
        //print(songs.count)
        if(songs.count > 0){
            let song = songs[indexPath.row]
            
            cell.textLabel?.text = song.title
            
            cell.detailTextLabel?.text = song.artist + " - " + song.album
        }
        return cell
    }
}

