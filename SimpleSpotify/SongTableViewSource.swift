//
//  SongTableViewSource.swift
//  SimpleSpotify
//
//  Created by Charles Luxton on 23/02/2016.
//  Copyright © 2016 Charles Luxton. All rights reserved.
//

import UIKit
import AlamofireImage

public class SongTableViewSource: NSObject, UITableViewDataSource, UITableViewDelegate, SongCellDelegate {
    
    public var imageDownloader: ImageDownloader?
    public var playQueue: PlayQueueManager?
    
    var tracks: [SpotifyTrack] = []
    var selectedTrackIndex : NSIndexPath?
    
    public func setData(newData: [SpotifyTrack]) {
        tracks = newData
        selectedTrackIndex = nil
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count;
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath == selectedTrackIndex) {
            return 136
        }
        return 66
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("trackCell", forIndexPath: indexPath) as! SongTableViewCell
        let track = tracks[indexPath.row]
        
        if cell.songCellDelegate == nil {
            cell.songCellDelegate = self
        }
        
        
        cell.setSong(track);
        
                
        return cell
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (selectedTrackIndex == indexPath) {
            selectedTrackIndex = nil
        } else {
            selectedTrackIndex = indexPath
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            tableView.scrollRectToVisible(tableView.rectForRowAtIndexPath(indexPath), animated: true)
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
        
        
        
    }
    
    public func playSong(track: SpotifyTrack) {
        if let queue = self.playQueue {
            queue.playSongImmediate(track)
        }
    }
    
    public func queueSong(track: SpotifyTrack) {
        if let queue = self.playQueue {
            queue.queueSong(track)
        }
    }
    
    
}
