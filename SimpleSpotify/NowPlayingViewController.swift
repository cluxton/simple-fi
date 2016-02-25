//
//  NowPlayingViewController.swift
//  SimpleSpotify
//
//  Created by Charles Luxton on 24/02/2016.
//  Copyright © 2016 Charles Luxton. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AlamofireImage

class NowPlayingViewController: UIViewController, PlaybackStateListener {

    let imageDownloader = ImageDownloader(
        configuration: ImageDownloader.defaultURLSessionConfiguration(),
        downloadPrioritization: .LIFO,
        maximumActiveDownloads: 4,
        imageCache: AutoPurgingImageCache()
    )
    
    @IBOutlet weak var playPause: UIButton!
    @IBOutlet weak var skip: UIButton!
    
    @IBOutlet weak var trackTitle: UILabel!
    @IBOutlet weak var trackAlbum: UILabel!
    @IBOutlet weak var trackArtist: UILabel!
    @IBOutlet weak var trackImage: UIImageView!
    
    @IBOutlet weak var timeElapsed: UILabel!
    @IBOutlet weak var timeTotal: UILabel!
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var tableView: UITableView?
    
    var tableSource: SongTableViewSource = SongTableViewSource()
    
    var playQueue: PlayQueueManager?
    var currentUri: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let tv = tableView {
            tv.registerNib(UINib(nibName:"SongTableViewCell", bundle: nil), forCellReuseIdentifier: "trackCell")
            tv.delegate = tableSource
            tv.dataSource = tableSource
            tv.separatorStyle = .None
        }
        
        
        Observable<Int>
            .interval(0.2, scheduler: MainScheduler.instance)
            .observeOn(MainScheduler.instance)
            .subscribe { event in
                self.updateSeeker()
            }
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        playQueue = appDelegate.playQueue
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        playQueue?.addListener(self)
    }
    
    override func viewWillDisappear(animated: Bool) {
        playQueue?.removeListener(self)
    }

    @IBAction func playPause(sender: AnyObject) {
        if (playQueue!.getPlaybackState().isPlaying) {
            playQueue!.pause()
        } else {
            playQueue!.play()
        }
    }
    
    @IBAction func skip(sender: AnyObject) {
        playQueue?.skip()
    }
    
    @IBAction func browse(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func showFull(sender: AnyObject) {
        performSegueWithIdentifier("showNowPlaying", sender: self)
    }
    
    //PlaybackStateListener methods
    
    func trackUpdated(uri: String) {
        currentUri = uri
        getTrack(uri)
        
        
        if let tv = tableView {
            tableSource.setData(playQueue!.getQueue())
            tv.reloadData()
        }
    }
    
    
    func playbackStateUpdated(isPlaying: Bool) {
        print("Handle Playback Change")
        
        let text = isPlaying ? "Pause" : "Play"
        playPause.setTitle(text, forState: .Normal)
        playPause.setTitle(text, forState: .Highlighted)
    }
    
    func updateSeeker() {
        let state = playQueue!.getPlaybackState()
        
        progressBar.progress = Float(1 / state.duration * state.progress)
        
        timeElapsed.text = formatInterval(state.progress)
        timeTotal.text = formatInterval(state.duration)
    }
    
    func getTrack(uri: String) {
        SpotifyApi.track(uri) { (track: SpotifyTrack?, error: NSError?) in
            
            if let t = track {
                
                self.trackTitle?.text = t.name
                
                if let album = t.album {
                    self.trackAlbum?.text = album.name
                }
                
                let artistLabel = t.artists
                    .map { $0.name }
                    .joinWithSeparator(" - ")
                
                self.trackArtist?.text = artistLabel
                
                if (self.trackImage != nil) {
                    self.downloadTrackImage(t)
                }
            }
            
        }
    }
    
    func downloadTrackImage(track: SpotifyTrack) {
        
        if let album = track.album {
            let request = NSURLRequest(URL: NSURL(string: album.images[0].url)!)
            
            imageDownloader.downloadImage(URLRequest: request) { response in
                
                if (track.uri != self.currentUri) {
                    return
                }
                
                if let value = response.result.value {
                    if let trackImage = self.trackImage {
                        trackImage.image = value
                    }
                }
            }
        }
    }
    
    func formatInterval(interval: NSTimeInterval) -> String {
        let totalSeconds = Int(interval)
        let seconds = totalSeconds % 60
        let minutes = totalSeconds / 60
        
        return "\(String(format: "%01d", minutes)):\(String(format: "%02d", seconds))"
    }

}
