//
//  SpotifyApi.swift
//  SimpleSpotify
//
//  Created by Charles Luxton on 23/02/2016.
//  Copyright © 2016 Charles Luxton. All rights reserved.
//

import Foundation
import EVReflection

public class EVObjectOptional: EVObject {
    override public func setValue(value: AnyObject!, forUndefinedKey key: String) {
        
    }
}

public class SpotifyImage: EVObjectOptional {
    var height: Int = 0
    var width: Int = 0
    var url: String = ""
}

public class SpotifyArtist: EVObjectOptional {
    var name: String = ""
    var href: String = ""
    var id: String = ""
    var images : [SpotifyImage] = []
}

public class SpotifyAlbum: EVObjectOptional {
    var name: String = ""
    var href: String = ""
    var id: String = ""
    var images : [SpotifyImage] = []
}

public class SpotifyTrack: EVObjectOptional {
    var name: String = ""
    var href: String = ""
    var id: String = ""
    var images : [SpotifyImage] = []
    var durationMs : Int = 0
}

public class SpotifyArtistList: EVObjectOptional {
    var items : [SpotifyArtist] = []
}

public class SpotifyTrackList: EVObjectOptional {
    var items : [SpotifyTrack] = []
}

public class SpotifyAlbumList: EVObjectOptional {
    var items : [SpotifyAlbum] = []
}

public class SpotifySearchRepsonse: EVObjectOptional {
    var artists: SpotifyArtistList = SpotifyArtistList()
    var tracks: SpotifyTrackList = SpotifyTrackList()
    var albums: SpotifyAlbumList = SpotifyAlbumList()
}

public class SpotifyApi {
    static func Search(query: String, type: SPTSearchQueryType, callback: (SpotifySearchRepsonse?, NSError?) -> Void) {
        let at = SPTAuth.defaultInstance().session.accessToken
        
        let requestCallback: SPTRequestDataCallback = { (error: NSError!, response: NSURLResponse!, data: NSData!) in
            let searchResponse = SpotifySearchRepsonse(json: String(data: data, encoding: NSUTF8StringEncoding));
            callback(searchResponse, nil)
        }
        
        do {
            let search = try SPTSearch.createRequestForSearchWithQuery(query, queryType: type, accessToken: at)
            SPTRequest.sharedHandler().performRequest(search, callback: requestCallback)
            
        } catch {
            callback(nil, nil)
        }
        
    }
}