//
//  AlbumTableViewSource.swift
//  SimpleSpotify
//
//  Created by Charles Luxton on 24/02/2016.
//  Copyright © 2016 Charles Luxton. All rights reserved.
//

import UIKit
import AlamofireImage

public protocol AlbumTableDelegate {
    func albumSelected(album: SpotifyAlbum)
}

public class AlbumTableViewSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    public var imageDownloader: ImageDownloader?
    public var albumTableDelegate: AlbumTableDelegate?

    var albums: [SpotifyAlbum] = []
    var selectedAlbumIndex : NSIndexPath?
    
    public func setData(newData: [SpotifyAlbum]) {
        albums = newData
        selectedAlbumIndex = nil
    }
    
    //    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    //        return 44;
    //    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count;
    }
    
    //    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //        return "Title"
    //    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        if (indexPath == selectedAlbumIndex) {
//            return 136
//        }
        return 136
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("albumCell", forIndexPath: indexPath) as! AlbumTableViewCell
        let album = albums[indexPath.row]
        
        cell.setAlbum(album)
        cell.albumArt.image = nil
        
        if (imageDownloader != nil && album.images.count > 1) {
            let request = NSURLRequest(URL: NSURL(string: album.images[1].url)!)
            
            imageDownloader?.downloadImage(URLRequest: request) { response in
                response.result.value
                
                if let image = response.result.value {
                    self.updateCellImage(tableView, indexPath: indexPath, image: image)
                }
            }
        }

        
        return cell
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedAlbumIndex = indexPath
        
        tableView.beginUpdates()
        tableView.endUpdates()
        
        if let delegate = self.albumTableDelegate {
            delegate.albumSelected(albums[indexPath.row])
        }
    }
    
    public func updateCellImage(tableView: UITableView, indexPath: NSIndexPath, image: Image) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? AlbumTableViewCell {
            cell.albumArt.image = image
        }
    }
    
}