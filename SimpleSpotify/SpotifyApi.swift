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
    var uri: String = ""
    var images : [SpotifyImage] = []
}

public class SpotifyAlbum: EVObjectOptional {
    var name: String = ""
    var href: String = ""
    var uri: String = ""
    var id: String = ""
    var images : [SpotifyImage] = []
}

public class SpotifyTrack: EVObjectOptional {
    var name: String = ""
    var href: String = ""
    var uri: String = ""
    var id: String = ""
    var images : [SpotifyImage] = []
    var durationMs : Int = 0
    var album : SpotifyAlbum?
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

public class SpotifyTracksResponse: EVObjectOptional {
    var tracks: [SpotifyTrack] = []
}

public class SpotifyAlbumsResponse: EVObjectOptional {
    var items: [SpotifyAlbum] = []
}

public class SpotifyApi {
    static func performRequest(request: NSURLRequest, callback: (SpotifySearchRepsonse?, NSError?) -> Void) {
        SPTRequest.sharedHandler().performRequest(request) { (error: NSError!, response: NSURLResponse!, data: NSData!) in
            let searchResponse = SpotifySearchRepsonse(json: String(data: data, encoding: NSUTF8StringEncoding));
            callback(searchResponse, nil)
        }
    }
    
    static func search(query: String, type: SPTSearchQueryType, callback: (SpotifySearchRepsonse?, NSError?) -> Void) {
        let at = SPTAuth.defaultInstance().session.accessToken
        
        do {
            let search = try SPTSearch.createRequestForSearchWithQuery(query, queryType: type, accessToken: at)
            SPTRequest.sharedHandler().performRequest(search) { (error: NSError!, response: NSURLResponse!, data: NSData!) in
                let searchResponse = SpotifySearchRepsonse(json: String(data: data, encoding: NSUTF8StringEncoding));
                callback(searchResponse, nil)
            }
            
        } catch {
            callback(nil, nil)
        }
    }
    
    static func topTracks(artist: String, callback: (SpotifyTracksResponse?, NSError?) -> Void) {
        let at = SPTAuth.defaultInstance().session.accessToken
        
        do {
            let request = try SPTArtist.createRequestForTopTracksForArtist(NSURL(string: artist), withAccessToken: at, market: "AU")
            SPTRequest.sharedHandler().performRequest(request) { (error: NSError!, response: NSURLResponse!, data: NSData!) in
                
//                let str = NSString(data: data, encoding: NSUTF8StringEncoding)
//                print(str)
                
                let searchResponse = SpotifyTracksResponse(json: String(data: data, encoding: NSUTF8StringEncoding));
                callback(searchResponse, nil)
            }
            
        } catch {
            callback(nil, nil)
        }
    }
    
    static func albums(artist: String, albumType: SPTAlbumType, callback: (SpotifyAlbumsResponse?, NSError?) -> Void) {
        let at = SPTAuth.defaultInstance().session.accessToken
        do {
            let request = try SPTArtist.createRequestForAlbumsByArtist(NSURL(string: artist), ofType: albumType, withAccessToken: at, market: "AU")
            SPTRequest.sharedHandler().performRequest(request) { (error: NSError!, response: NSURLResponse!, data: NSData!) in
                let searchResponse = SpotifyAlbumsResponse(json: String(data: data, encoding: NSUTF8StringEncoding));
                callback(searchResponse, nil)
            }
        } catch {
            callback(nil, nil)
        }
        
    }
}