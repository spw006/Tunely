//
//  Song.swift
//  Tunely-Demo
//
//  Created by Sean Wang on 11/12/15.
//  Copyright © 2015 Tracy Nham. All rights reserved.
//

import Foundation
import SwiftyJSON

class Song {
    var trackID: String
    var title: String
    var artist: String
    var album: String
    
    init() {
        trackID = ""
        title = ""
        artist = ""
        album = ""
    }
    
    func toSerializableData() -> AnyObject {
        return [
            "trackID": NSString(string: trackID),
            "title": NSString(string: title),
            "artist": NSString(string: artist),
            "album": NSString(string: album)
        ]
    }
}