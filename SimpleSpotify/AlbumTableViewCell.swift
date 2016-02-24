//
//  AlbumTableViewCell.swift
//  SimpleSpotify
//
//  Created by Charles Luxton on 24/02/2016.
//  Copyright © 2016 Charles Luxton. All rights reserved.
//

import UIKit

public class AlbumTableViewCell: UITableViewCell {
    
    static let DefaultHeight: Int = 136

    
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
    }

    override public func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func setAlbum(album: SpotifyAlbum) {
        //self.album = album
        
        name!.text = album.name
        artistName!.text = ""
        subtitle!.text = ""
    }
}
