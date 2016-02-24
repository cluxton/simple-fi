//
//  ArtistViewController.swift
//  SimpleSpotify
//
//  Created by Charles Luxton on 23/02/2016.
//  Copyright © 2016 Charles Luxton. All rights reserved.
//

import UIKit
import AlamofireImage

class ArtistViewController: UIViewController {

    let imageDownloader = ImageDownloader(
        configuration: ImageDownloader.defaultURLSessionConfiguration(),
        downloadPrioritization: .LIFO,
        maximumActiveDownloads: 4,
        imageCache: AutoPurgingImageCache()
    )

    let tracksTableSource: SongTableViewSource = SongTableViewSource()
    let albumTableSource: AlbumTableViewSource = AlbumTableViewSource()
    
    var artist: SpotifyArtist?

    
    @IBOutlet weak var trackTableView: UITableView!
    @IBOutlet weak var albumTableView: UITableView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        image.layer.cornerRadius = image.frame.size.width / 2
        image.clipsToBounds = true
        image.layer.borderWidth = 2.0
        image.layer.borderColor = UIColor.blackColor().CGColor
        
        albumTableSource.imageDownloader = self.imageDownloader
        
        trackTableView.registerNib(UINib(nibName:"SongTableViewCell", bundle: nil), forCellReuseIdentifier: "trackCell")
        trackTableView.separatorStyle = .None
        trackTableView.delegate = tracksTableSource
        trackTableView.dataSource = tracksTableSource
        
        albumTableView.registerNib(UINib(nibName:"AlbumTableViewCell", bundle: nil), forCellReuseIdentifier: "albumCell")
        albumTableView.separatorStyle = .None
        albumTableView.delegate = albumTableSource
        albumTableView.dataSource = albumTableSource
        
        name!.text = artist?.name
        self.title = artist?.name
        
        if let navigationController = self.navigationController {
            navigationController.title = artist?.name
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        updateTopTracks()
        updateAlbums()
        downloadArtistImage()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    private
    
    func updateTopTracks() {
        SpotifyApi.topTracks((self.artist?.uri)!) { (response: SpotifyTracksResponse?, error: NSError?) in
            if (response != nil) {
                self.tracksTableSource.setData((response?.tracks)!)
                self.trackTableView.reloadData()
            }
        }
    }
    
    func updateAlbums() {
        SpotifyApi.albums((self.artist?.uri)!, albumType: .Album) { (response: SpotifyAlbumsResponse?, error: NSError?) in
            if (response != nil) {
                self.albumTableSource.setData((response?.items)!)
                self.albumTableView.reloadData()
            }
        }
    }
    
    func downloadArtistImage() {
        if(artist != nil && artist!.images.count > 1) {
            let request = NSURLRequest(URL: NSURL(string: artist!.images[1].url)!)
            
            imageDownloader.downloadImage(URLRequest: request) { response in
                response.result.value
                
                if let value = response.result.value {
                    if let artistImage = self.image {
                        artistImage.image = value
                    }
                }
            }
        }
    }

}
