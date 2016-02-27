//
//  SearchTableViewSource.swift
//  SimpleSpotify
//
//  Created by Charles Luxton on 27/02/2016.
//  Copyright © 2016 Charles Luxton. All rights reserved.
//

import UIKit
import AlamofireImage

public protocol SearchTableSourceDelegate {
    func artistSelected(artist: SpotifyArtist)
    func albumSelected(album: SpotifyAlbum)
    func didStartScrolling()
}

public class SearchTableViewSource: NSObject, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, SongCellDelegate {
    
    let HeaderHeight: CGFloat = 74
    
    let ArtistSection = 0
    let AlbumSection = 1
    let TrackSection = 2
    
    let sectionHeaders: [String] = [
        "Artists",
        "Albums",
        "Tracks"
    ]
    
    public var imageDownloader: ImageDownloader?
    public var playQueue: PlayQueueManager?
    
    public var delegate: SearchTableSourceDelegate?
    
    var tracks: [SpotifyTrack] = []
    var albums: [SpotifyAlbum] = []
    var artists: [SpotifyArtist] = []
    
    
    
    var selectedIndex : NSIndexPath?
    
    public func setData(tracks: [SpotifyTrack], artists: [SpotifyArtist], albums: [SpotifyAlbum]) {
        self.tracks = tracks
        self.artists = artists
        self.albums = albums
        
        selectedIndex = nil
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch(section) {
        case ArtistSection:
            return artists.count > 0 ? HeaderHeight : 0
        case AlbumSection:
            return albums.count > 0 ? HeaderHeight : 0
        case TrackSection:
            return tracks.count > 0 ? HeaderHeight : 0
        default:
            return 0
        }
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
        case ArtistSection:
            return artists.count
        case AlbumSection:
            return albums.count
        case TrackSection:
            return tracks.count
        default:
            return 0
        }
    }
    
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section) {
        case ArtistSection:
            return "Artists"
        case AlbumSection:
            return "Albums"
        case TrackSection:
            return "Tracks"
        default:
            return "-"
        }
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let isSelected: Bool = indexPath == selectedIndex
        
        switch(indexPath.section) {
        case ArtistSection:
            return 54
        case AlbumSection:
            return AlbumTableViewCell.SmallHeight
        case TrackSection:
            return  isSelected ?  SongTableViewCell.OpenHeight : SongTableViewCell.DefaultHeight
        default:
            return 44
        }
    }
    
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableCellWithIdentifier("searchHeaderCell") as! SearchHeaderCell
        view.label.text = sectionHeaders[section]
        return view
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch(indexPath.section) {
        case ArtistSection:
            return artistCell(tableView, indexPath: indexPath)
            
        case AlbumSection:
            let album = albums[indexPath.row]
            return AlbumTableViewCell.cellFactory(tableView, indexPath: indexPath, album: album, imageDownloader: imageDownloader)
            
        case TrackSection:
            return trackCell(tableView, indexPath: indexPath)
            
        default:
            return trackCell(tableView, indexPath: indexPath)
        }
    }
    
    public func artistCell(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("artistCell", forIndexPath: indexPath) as! ArtistTableViewCell
        let artist = artists[indexPath.row]
        cell.setArtist(artist)
        return cell
    }
    
    public func trackCell(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("trackCell", forIndexPath: indexPath) as! SongTableViewCell
        let track = tracks[indexPath.row]
        
        if cell.songCellDelegate == nil {
            cell.songCellDelegate = self
        }
        
        
        cell.setSong(track);
        
        
        return cell
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.section) {
        case ArtistSection:
            delegate?.artistSelected(artists[indexPath.row])
        case AlbumSection:
            delegate?.albumSelected(albums[indexPath.row])
        default:
            if (selectedIndex == indexPath) {
                selectedIndex = nil
            } else {
                selectedIndex = indexPath
            }
            
            tableView.beginUpdates()
            tableView.endUpdates()
        }
        
        
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
    
    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        delegate?.didStartScrolling()
    }
    
    
}
