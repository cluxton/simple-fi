//
//  AlbumCollectionViewCell.swift
//  SimpleSpotify
//
//  Created by Charles Luxton on 23/02/2016.
//  Copyright © 2016 Charles Luxton. All rights reserved.
//

import UIKit

public class AlbumCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var albumArt: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func setAlbum(album: SpotifyAlbum) {
        title.text = album.name
    }

}
