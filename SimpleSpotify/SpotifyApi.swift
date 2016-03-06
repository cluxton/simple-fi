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
    
    
    static func search(query: String, type: SPTSearchQueryType, callback: (SpotifySearchRepsonse?, NSError?) -> Void) {
        performRequest(callback) { accessToken in
            return try SPTSearch.createRequestForSearchWithQuery(query, queryType: type, accessToken: accessToken)
        }
        
    }
    
    static func searchAll(query: String, callback: (SpotifySearchRepsonse?, NSError?) -> Void) {
        performRequest(callback) { accessToken in
            let queryEscaped = query.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
            
            let req = NSMutableURLRequest(
                URL: NSURL(string: "https://api.spotify.com/v1/search?q=\(queryEscaped!)&type=track,artist,album&limit=6")!
            )
            req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            req.setValue("application/json", forHTTPHeaderField: "Accept")
            return req
        }
    }
    
    static func topTracks(artist: String, callback: (SpotifyTracksResponse?, NSError?) -> Void) {
        performRequest(callback) { accessToken in
            return try SPTArtist.createRequestForTopTracksForArtist(NSURL(string: artist), withAccessToken: accessToken, market: "AU")
        }
    }
    
    static func albums(artist: String, albumType: SPTAlbumType, callback: (SpotifyAlbumsResponse?, NSError?) -> Void) {
        performRequest(callback) { accessToken in
            return try SPTArtist.createRequestForAlbumsByArtist(NSURL(string: artist), ofType: albumType, withAccessToken: accessToken, market: "AU")
        }
    }
    
    static func albumTracks(album: String, callback: (SpotifyAlbumResponse?, NSError?) -> Void) {
        performRequest(callback) { accessToken in
            return try SPTAlbum.createRequestForAlbum(NSURL(string: album), withAccessToken: accessToken, market: "AU")
        }
    }
    
    static func track(uri: String, callback: (SpotifyTrack?, NSError?) -> Void) {
        performRequest(callback) { accessToken in
            return try SPTTrack.createRequestForTrack(NSURL(string: uri), withAccessToken: accessToken, market: "AU")
        }
    }
    
    private
    
    static func performRequest<ReturnType: EVObject>(callback: (ReturnType?, NSError?) -> Void, requestFactory: (accessToken: String) throws -> NSURLRequest) {
        let at = SPTAuth.defaultInstance().session?.accessToken
        do {
            let request = try requestFactory(accessToken: at!)
            SPTRequest.sharedHandler().performRequest(request) { (error: NSError!, response: NSURLResponse!, data: NSData!) in
                
                if(error != nil) {
                    print("Error performing request: \(error)")
                    callback(nil, nil)
                    return
                }
                
                
                let searchResponse = ReturnType(json: String(data: data, encoding: NSUTF8StringEncoding));
                callback(searchResponse, nil)
            }
            
        } catch {
            print("CAUGHT ERROR: \(error)")
            callback(nil, nil)
        }
    }

}