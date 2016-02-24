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
    var tracks: [SpotifyTrack] = []
    var selectedTrackIndex : NSIndexPath?
    
    public func setData(newData: [SpotifyTrack]) {
        tracks = newData
        selectedTrackIndex = nil
    }
    
//    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 44;
//    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count;
    }
    
//    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "Title"
//    }
    
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
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    public func playSong(track: SpotifyTrack) {
        print(track.uri)
    }
    
    public func queueSong(track: SpotifyTrack) {
        print(track.uri)
    }
    
    
}