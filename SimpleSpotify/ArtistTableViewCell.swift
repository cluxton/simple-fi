//
//  ArtistTableViewCell.swift
//  SimpleSpotify
//
//  Created by Charles Luxton on 27/02/2016.
//  Copyright © 2016 Charles Luxton. All rights reserved.
//

import UIKit

class ArtistTableViewCell: UITableViewCell {

    @IBOutlet weak var Label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.backgroundColor = UIColor.clearColor()
        self.clipsToBounds = true
        self.selectionStyle = .None
        
        let size = self.contentView.frame.size
        let border = UIView(frame: CGRect(x: 10, y: size.height - 1, width: size.width - 10, height: 1))
        border.backgroundColor = UIColor.whiteColor()
        border.alpha = 0.1
        border.autoresizingMask = [.FlexibleWidth, .FlexibleTopMargin];
        
        self.contentView.addSubview(border)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setArtist(artist: SpotifyArtist) {
        self.Label.text = artist.name
    }
    
    
}
