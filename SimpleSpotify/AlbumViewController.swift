//
//  AlbumViewController.swift
//  SimpleSpotify
//
//  Created by Charles Luxton on 23/02/2016.
//  Copyright © 2016 Charles Luxton. All rights reserved.
//

import UIKit
import AlamofireImage

public class AlbumViewController: UIViewController {

    let imageDownloader = ImageDownloader(
        configuration: ImageDownloader.defaultURLSessionConfiguration(),
        downloadPrioritization: .LIFO,
        maximumActiveDownloads: 4,
        imageCache: AutoPurgingImageCache()
    )
    
    @IBOutlet weak var albumArt: UIImageView!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var albumArtist: UILabel!
    @IBOutlet weak var albumInfo: UILabel!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var queueButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    public var album: SpotifyAlbum?
    
    let tableSource: SongTableViewSource = SongTableViewSource()
    
    var playQueue: PlayQueueManager?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(UINib(nibName:"SongTableViewCell", bundle: nil), forCellReuseIdentifier: "trackCell")
        tableView.separatorStyle = .None
        tableView.delegate = tableSource
        tableView.dataSource = tableSource
        
        albumName!.text = album?.name
        albumArtist!.text = ""
        albumInfo!.text = ""
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        playQueue = appDelegate.playQueue
        
        tableSource.playQueue = playQueue!
        
        // Do any additional setup after loading the view.
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchAlbum()
        downloadAlbumImage()
    }
    
    @IBAction func playAlbum(sender: AnyObject) {
        playQueue!.playSongsImmediate(tableSource.tracks)
    }

    @IBAction func queueAlbum(sender: AnyObject) {
        playQueue!.queueSongs(tableSource.tracks)
    }
    
    
    private
    
    func fetchAlbum() {
        SpotifyApi.albumTracks((self.album?.uri)!) { (response: SpotifyAlbumResponse?, error: NSError?) in
            if (response != nil) {
                self.tableSource.setData((response?.tracks.items)!)
                self.tableView.reloadData()
            }
        }
    }
    
    func downloadAlbumImage() {
        if(album != nil && album!.images.count > 1) {
            let request = NSURLRequest(URL: NSURL(string: album!.images[1].url)!)
            
            imageDownloader.downloadImage(URLRequest: request) { response in
                response.result.value
                
                if let value = response.result.value {
                    if let albumImg = self.albumArt {
                        albumImg.image = value
                    }
                }
            }
        }
    }

}
