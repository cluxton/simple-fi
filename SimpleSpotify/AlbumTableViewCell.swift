//
//  AlbumTableViewCell.swift
//  SimpleSpotify
//
//  Created by Charles Luxton on 24/02/2016.
//  Copyright © 2016 Charles Luxton. All rights reserved.
//

import UIKit
import AlamofireImage

public class AlbumTableViewCell: UITableViewCell {
    
    static let DefaultHeight: CGFloat = 136
    static let SmallHeight: CGFloat = 64
    static let Identifier: String = "albumCell"


    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var albumArt: UIImageView!
    
    //var album: SpotifyAlbum?
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = UIColor.clearColor()
        self.clipsToBounds = true
        self.selectionStyle = .None
        self.accessoryType = .DisclosureIndicator
        
        let size = self.contentView.frame.size
        let border = UIView(frame: CGRect(x: 10, y: size.height - 1, width: size.width - 10, height: 1))
        border.backgroundColor = UIColor.whiteColor()
        border.alpha = 0.1
        border.autoresizingMask = [.FlexibleWidth, .FlexibleTopMargin];
        
        self.contentView.addSubview(border)
    }

    override public func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func setAlbum(album: SpotifyAlbum) {
        //self.album = album
        
        name!.text = album.name
        artistName!.text = ""
        subtitle?.text = ""
    }
    
    public static func cellFactory(tableView: UITableView, indexPath: NSIndexPath, album: SpotifyAlbum, imageDownloader: ImageDownloader?) -> AlbumTableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Identifier, forIndexPath: indexPath) as! AlbumTableViewCell
        
        cell.setAlbum(album)
        cell.albumArt.image = nil
        
        if (imageDownloader != nil && album.images.count > 1) {
            let request = NSURLRequest(URL: NSURL(string: album.images[1].url)!)
            
            imageDownloader?.downloadImage(URLRequest: request) { response in
                response.result.value
                
                if let image = response.result.value {
                    updateCellImage(tableView, indexPath: indexPath, image: image)
                }
            }
        }
        
        return cell
    }
    
    private
    
    static func updateCellImage(tableView: UITableView, indexPath: NSIndexPath, image: Image) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? AlbumTableViewCell {
            cell.albumArt.image = image
        }
    }
    
}
