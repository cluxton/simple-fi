//
//  HomeViewController.swift
//  SimpleSpotify
//
//  Created by Charles Luxton on 22/02/2016.
//  Copyright © 2016 Charles Luxton. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AlamofireImage

struct SearchParameters {
    var query: String = ""
    var searchType: SPTSearchQueryType = SPTSearchQueryType.QueryTypeArtist
}

class HomeViewController: UIViewController, SearchTableSourceDelegate {
    
    let imageDownloader = ImageDownloader(
        configuration: ImageDownloader.defaultURLSessionConfiguration(),
        downloadPrioritization: .LIFO,
        maximumActiveDownloads: 4,
        imageCache: AutoPurgingImageCache()
    )
    
    let disposeBag = DisposeBag.init()
    
    let ArtistSection = 0
    let AlbumSection = 1
    let TrackSection = 2
    
    let spotifyAuthenticator = SPTAuth.defaultInstance()
    let tableSource: SearchTableViewSource = SearchTableViewSource()
    var searchResponse: SpotifySearchRepsonse?
    var selectedArtist: SpotifyArtist?
    var selectedAlbum: SpotifyAlbum?
    var playQueue: PlayQueueManager?
    var firstLoad: Bool = true
    
    @IBOutlet weak var searchFieldWrapper: UIView!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var searchTypeRadio: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playQueue = PlayQueueManager.defaultInstance()
        
        tableSource.playQueue = self.playQueue
        tableSource.imageDownloader = self.imageDownloader
        tableSource.delegate = self
        
        self.tableView.registerNib(UINib(nibName:"SearchHeaderCell", bundle: nil), forCellReuseIdentifier: "searchHeaderCell")
        self.tableView.registerNib(UINib(nibName:"SongTableViewCell", bundle: nil), forCellReuseIdentifier: "trackCell")
        self.tableView.registerNib(UINib(nibName:"AlbumTableViewCellSmall", bundle: nil), forCellReuseIdentifier: "albumCell")
        self.tableView.registerNib(UINib(nibName:"ArtistTableViewCell", bundle: nil), forCellReuseIdentifier: "artistCell")

        self.tableView.delegate = tableSource
        self.tableView.dataSource = tableSource
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.reloadData()
        
        searchLabel.hidden = true
    
        searchField.keyboardAppearance = UIKeyboardAppearance.Dark
        searchFieldWrapper.layer.cornerRadius = 6.0
        
        self.searchField!.autocorrectionType = .No
        self.searchField!.keyboardType = .WebSearch
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.title = "Search"
        
        let searchTextUpdated = self.searchField.rx_text
            .debounce(1, scheduler: MainScheduler.instance)
            .filter { s -> Bool in s.characters.count > 0 }
            .shareReplay(1)
        
        searchTextUpdated
            .subscribeNext { [weak self] query in
                self?.searchLabel.text = "Searching..."
                self?.searchLabel.hidden = false
                self?.tableView.hidden = true
                SpotifyApi.searchAll(query) { (response: SpotifySearchRepsonse?, error: NSError?) in
                    if let results = response {
                        self?.handleSearchResults(results, query: query)
                    } else {
                        self?.searchLabel.text = "There was an error while searching."
                    }
                }
            }
            .addDisposableTo(disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("VIEW DID APPEAR")
        if (firstLoad) {
            searchField.becomeFirstResponder()
        }
        firstLoad = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showArtist") {
            let vc = segue.destinationViewController as? ArtistViewController
            vc?.artist = selectedArtist
        } else if (segue.identifier == "showAlbum") {
            let vc = segue.destinationViewController as? AlbumViewController
            vc?.album = selectedAlbum
        }
    }
    
    func handleSearchResults(results: SpotifySearchRepsonse, query: String) {
        self.tableSource.setData(
            results.tracks.items,
            artists: results.artists.items,
            albums: results.albums.items)
        self.tableView.reloadData()
        self.tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
        
        if(results.tracks.items.count != 0
            || results.albums.items.count != 0
            || results.artists.items.count != 0) {
            self.searchLabel.hidden = true
            self.tableView.hidden = false
        } else {
            self.searchLabel.text = "No results found for '\(query)'"
            self.tableView.hidden = true
        }
        
    }
    
    func albumSelected(album: SpotifyAlbum) {
        print("SHOW ALBUM")
        selectedAlbum = album
        performSegueWithIdentifier("showAlbum", sender: self)
    }
    
    func artistSelected(artist: SpotifyArtist) {
        print("SHOW ARTIST")
        selectedArtist = artist
        performSegueWithIdentifier("showArtist", sender: self)
    }
    
    func didStartScrolling() {
        searchField.resignFirstResponder()
    }

}
