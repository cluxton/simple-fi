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
    var artists: [SpotifyArtist] = []
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

public class SpotifyAlbumResponse: EVObjectOptional {
    var releaseDate: String = ""
    var images : [SpotifyImage] = []
    var tracks: SpotifyTrackList = SpotifyTrackList()
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
    
    static func searchAll(query: String, callback: (SpotifySearchRepsonse?, NSError?) -> Void) {
        let at = SPTAuth.defaultInstance().session.accessToken

        let queryEscaped = query.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
        print("query: \(queryEscaped)")
        
        let url = NSURL(string: "https://api.spotify.com/v1/search?q=\(queryEscaped!)&type=track,artist,album&limit=6")
        print("URL: \(url?.absoluteString)")
            
        let req = NSMutableURLRequest(URL: url!)
        req.setValue("Bearer \(at)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        
        SPTRequest.sharedHandler().performRequest(req) { (error: NSError!, response: NSURLResponse!, data: NSData!) in
            let searchResponse = SpotifySearchRepsonse(json: String(data: data, encoding: NSUTF8StringEncoding));
            callback(searchResponse, nil)
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
    
    static func albumTracks(album: String, callback: (SpotifyAlbumResponse?, NSError?) -> Void) {
        let at = SPTAuth.defaultInstance().session.accessToken
        do {
            let request = try SPTAlbum.createRequestForAlbum(NSURL(string: album), withAccessToken: at, market: "AU")
            SPTRequest.sharedHandler().performRequest(request) { (error: NSError!, response: NSURLResponse!, data: NSData!) in
                let searchResponse = SpotifyAlbumResponse(json: String(data: data, encoding: NSUTF8StringEncoding));
                callback(searchResponse, nil)
            }
        } catch {
            callback(nil, nil)
        }
        
    }
    
    static func track(uri: String, callback: (SpotifyTrack?, NSError?) -> Void) {
        let at = SPTAuth.defaultInstance().session.accessToken
        
        do {
            let request = try SPTTrack.createRequestForTrack(NSURL(string: uri), withAccessToken: at, market: "AU")
            
            SPTRequest.sharedHandler().performRequest(request) { (error: NSError!, response: NSURLResponse!, data: NSData!) in
                let searchResponse = SpotifyTrack(json: String(data: data, encoding: NSUTF8StringEncoding));
                callback(searchResponse, nil)
            }
        } catch {
            callback(nil, nil)
        }
    }
}