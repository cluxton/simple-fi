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

struct SearchParameters {
    var query: String = ""
    var searchType: SPTSearchQueryType = SPTSearchQueryType.QueryTypeArtist
}

class HomeViewController: UIViewController, SPTAudioStreamingPlaybackDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    let ArtistSection = 0
    let AlbumSection = 1
    let TrackSection = 2
    
    let spotifyAuthenticator = SPTAuth.defaultInstance()
    var player: SPTAudioStreamingController?
    var searchResponse: SpotifySearchRepsonse?
    
    @IBOutlet weak var searchFieldWrapper: UIView!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var searchTypeRadio: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.reloadData()
    
        searchField.keyboardAppearance = UIKeyboardAppearance.Dark
        
        setupSpotifyPlayer()
        
        let disposeBag = DisposeBag.init()
        
        let searchTextUpdated = self.searchField.rx_text
            .debounce(0.5, scheduler: MainScheduler.instance)
            .filter { s -> Bool in s.characters.count > 0 }
            .shareReplay(1)
        
        let searchTypeUpdated = self.searchTypeRadio.rx_value
            .map {v -> SPTSearchQueryType in
                switch v {
                case 0:
                    return SPTSearchQueryType.QueryTypeArtist
                case 1:
                    return SPTSearchQueryType.QueryTypeAlbum
                case 2:
                    return SPTSearchQueryType.QueryTypeTrack
                default:
                    return SPTSearchQueryType.QueryTypeArtist
                }
            }
            .shareReplay(1)
        
        Observable
            .combineLatest(searchTextUpdated, searchTypeUpdated) { query, type -> SearchParameters in
                return SearchParameters(query: "*" + query + "*", searchType: type)
            }
            .debounce(0.5, scheduler: MainScheduler.instance)
            .subscribeNext { parameters in
                print("Searching")
                SpotifyApi.Search(parameters.query, type: parameters.searchType) { (response: SpotifySearchRepsonse?, error: NSError?) in
                    if (response != nil) {
                        self.searchResponse = response
                        self.tableView.reloadData()
                    } else {
                        print("ERROR SEARCHING")
                    }
                }
            }
        
            // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
                // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        print("VIEW DID APPEAR")
        player!.loginWithSession(spotifyAuthenticator.session, callback: { (error: NSError!) in
            if error != nil {
                print("Couldn't login with session: \(error)")
                return
            }
        })
    }
    
    private
    
    func setupSpotifyPlayer() {
        player = SPTAudioStreamingController(clientId: spotifyAuthenticator.clientID)
        player!.playbackDelegate = self
        player!.diskCache = SPTDiskCache(capacity: 1024 * 1024 * 64)
    }
    
    func playTrack(session: SPTSession, track: String) {
        
        self.player!.playURIs([NSURL(string: "spotify:track:" + track)!], withOptions: nil, callback: nil)
        
    }
    
    //Table view methods
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch(section) {
        case ArtistSection:
            return (searchResponse!.artists.items.count > 0 ? 44 : 0)
        case AlbumSection:
            return (searchResponse!.albums.items.count > 0 ? 44 : 0)
        case TrackSection:
            return (searchResponse!.tracks.items.count > 0 ? 44 : 0)
        default:
            return 0
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (searchResponse == nil) {
            return 0
        }
        
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == ArtistSection) {
            return searchResponse!.artists.items.count
        } else if (section == AlbumSection) {
            return searchResponse!.albums.items.count
        } else if (section == TrackSection) {
            return searchResponse!.tracks.items.count
        }
        
        return 0;
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section) {
        case ArtistSection:
            return "Artists"
        case AlbumSection:
            return "Albums"
        case TrackSection:
            return "Tracks"
        default:
            return ""
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCellWithIdentifier("cell")
        if (cell == nil) {
            cell = UITableViewCell();
        }
        if (indexPath.section == ArtistSection) {
            cell!.textLabel?.text = searchResponse!.artists.items[indexPath.row].name
        } else if (indexPath.section == AlbumSection) {
            cell!.textLabel?.text = searchResponse!.albums.items[indexPath.row].name
        } else if (indexPath.section == TrackSection) {
            cell!.textLabel?.text = searchResponse!.tracks.items[indexPath.row].name
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == TrackSection) {
            playTrack(spotifyAuthenticator.session, track: searchResponse!.tracks.items[indexPath.row].id)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        searchField.resignFirstResponder();
    }

}
