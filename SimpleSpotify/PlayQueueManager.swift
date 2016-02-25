//
//  PlayQueueManager.swift
//  SimpleSpotify
//
//  Created by Charles Luxton on 24/02/2016.
//  Copyright © 2016 Charles Luxton. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public protocol PlaybackStateListener: NSObjectProtocol {
    func trackUpdated(uri: String)
    func playbackStateUpdated(isPlaying: Bool)
}

public struct PlaybackState {
    var isPlaying: Bool
    var duration: NSTimeInterval = NSTimeInterval(1)
    var progress: NSTimeInterval = NSTimeInterval(0)
}

public class PlayQueueManager: NSObject, SPTAudioStreamingPlaybackDelegate {
    
    private let spotifyAuthenticator = SPTAuth.defaultInstance()
    private var player: SPTAudioStreamingController?
    private var mainQueue: [SpotifyTrack] = []
    private var upNext: [SpotifyTrack] = []
    private var combinedQueue: [SpotifyTrack] = []


    private var listeners: [PlaybackStateListener] = []
    
    public var currentTrack: SpotifyTrack?

    
    override init() {
       super.init()
        player = SPTAudioStreamingController(clientId: spotifyAuthenticator.clientID)
        player!.playbackDelegate = self
        player!.diskCache = SPTDiskCache(capacity: 1024 * 1024 * 64)
        
    }
    
    public func login() {
        player!.loginWithSession(spotifyAuthenticator.session, callback: { (error: NSError!) in
            if error != nil {
                print("Couldn't login with session: \(error)")
                return
            }
        })
    }
    
    public func queueSong(track: SpotifyTrack) {
        upNext.append(track)
        updatePlayerQueue()
    }
    
    public func queueSongs(tracks: [SpotifyTrack]) {
        mainQueue.appendContentsOf(tracks)
        updatePlayerQueue()
    }
    
    public func playSongImmediate(track: SpotifyTrack) {
        upNext.insert(track, atIndex: 0)
        updatePlayerQueue()
        
        if (player!.isPlaying) {
            skip()
        }
    }
    
    public func playSongsImmediate(tracks: [SpotifyTrack]) {
        upNext = []
        mainQueue = []
        mainQueue.appendContentsOf(tracks)
        updatePlayerQueue()
        
        if (player!.isPlaying) {
            skip()
        }
    }
    
    public func play() {
        player?.setIsPlaying(true) { (error: NSError!) in
            if error != nil {
                print("Error playing: \(error)")
                return
            }
        }
    }
    
    public func pause() {
        player?.setIsPlaying(false) { (error: NSError!) in
            if error != nil {
                print("Error pausing: \(error)")
                return
            }
        }
    }
    
    public func skip() {
        player?.skipNext{ (error: NSError!) in
            if error != nil {
                print("Error skipping: \(error)")
                return
            }
        }
    }
    
    public func getPlaybackState() -> PlaybackState {
        return PlaybackState(isPlaying: player!.isPlaying, duration: player!.currentTrackDuration, progress: player!.currentPlaybackPosition)
    }
    
    public func getQueue() -> [SpotifyTrack] {
        return combinedQueue
    }
    
    public func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        print("POST")
        listeners.forEach { l in
            l.playbackStateUpdated(isPlaying)
        }
    }
    
    public func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangeToTrack trackMetadata: [NSObject : AnyObject]!) {
        print("CHANGE TO TRACK")
    }
    
    public func audioStreaming(audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: NSURL!) {
        print("START PLAYING TRACK ")
        
        
        
        let nextSong = peekNextSong()
        if (nextSong != nil && nextSong!.uri == trackUri.absoluteString) {
            currentTrack = popNextSong()
            updatePlayerQueue()
            print("POST")
        }
        
        listeners.forEach { l in
            l.trackUpdated(trackUri.absoluteString)
        }
    }
    
    public func audioStreaming(audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: NSURL!) {
        print("STOP PLAYING TRACK")
    }
    
    public func audioStreaming(audioStreaming: SPTAudioStreamingController!, didSeekToOffset offset: NSTimeInterval) {
        print(offset)
    }
    
    public func addListener(listener: PlaybackStateListener) {
        listeners.append(listener)
        print("ADD LISTENER")
        
        listener.playbackStateUpdated(player!.isPlaying)
        if let track = currentTrack {
            print("    UPDATE TRACK")
            listener.trackUpdated(track.uri)
        }
        print("    \(listeners.count)")
        
    }
    
    public func removeListener(listener: PlaybackStateListener) {
        listeners = listeners.filter({ $0 !== listener })
        print("REMOVE LISTENER")
        print("    \(listeners.count)")

    }
    
    private
    
    func updatePlayerQueue() {
        print("UpNext queue: \(upNext.count)")
        print("Main queue: \(mainQueue.count)")
        combinedQueue = []
        combinedQueue.appendContentsOf(upNext)
        combinedQueue.appendContentsOf(mainQueue)
        
        let uris = combinedQueue.map { NSURL(string: $0.uri)! }
        
        player?.queueURIs(uris, clearQueue: true) { (error: NSError!) in
            if error != nil {
                print("Error queueing: \(error)")
                return
            }
        }
        
    }
    
    func popNextSong() -> SpotifyTrack? {
        if (upNext.count > 0) {
            return upNext.removeAtIndex(0)
        }
        
        if (mainQueue.count > 0) {
            return mainQueue.removeAtIndex(0)
        }
        
        return nil
    }
    
    func peekNextSong() -> SpotifyTrack? {
        if (upNext.count > 0) {
            return upNext[0]
        }
        
        if (mainQueue.count > 0) {
            return mainQueue[0]
        }
        
        return nil
    }

}
