//
//  SongTableViewCell.swift
//  SimpleSpotify
//
//  Created by Charles Luxton on 23/02/2016.
//  Copyright © 2016 Charles Luxton. All rights reserved.
//

import UIKit

public protocol SongCellDelegate {
    func playSong(track: SpotifyTrack)
    func queueSong(track: SpotifyTrack)
}

public class SongTableViewCell: UITableViewCell {
    
    static let DefaultHeight: Int = 66
    static let OpenHeight: Int = 136

    @IBOutlet public weak var queueButton: UIButton!
    @IBOutlet public weak var playButton: UIButton!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var title: UILabel!
    
    var track: SpotifyTrack?
    public var songCellDelegate: SongCellDelegate?
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.clipsToBounds = true
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
    }

    
    override public func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func setSong(track: SpotifyTrack) {
        self.track = track
        title!.text = track.name
        subtitle!.text = track.album?.name
        status!.text = ""
    }
    
    @IBAction func playTrack(sender: AnyObject) {
        if let delegate = songCellDelegate {
            delegate.playSong(track!)
        }
    }
    
    @IBAction func queueTrack(sender: AnyObject) {
        if let delegate = songCellDelegate {
            delegate.queueSong(track!)
        }
    }
    
}
