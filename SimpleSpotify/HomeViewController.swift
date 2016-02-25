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
    var searchResponse: SpotifySearchRepsonse?
    var selectedArtist: SpotifyArtist?
    var selectedAlbum: SpotifyAlbum?
    
    
    var playQueue: PlayQueueManager?
    
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
        searchFieldWrapper.layer.cornerRadius = 6.0
        
        self.searchField!.autocorrectionType = .No
        self.searchField!.keyboardType = .WebSearch
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.title = "Search"
        
        let searchTextUpdated = self.searchField.rx_text
            .debounce(1, scheduler: MainScheduler.instance)
            .filter { s -> Bool in s.characters.count > 0 }
            .shareReplay(1)
        
//        let searchTypeUpdated = self.searchTypeRadio.rx_value
//            .map {v -> SPTSearchQueryType in
//                switch v {
//                case 0:
//                    return SPTSearchQueryType.QueryTypeArtist
//                case 1:
//                    return SPTSearchQueryType.QueryTypeAlbum
//                case 2:
//                    return SPTSearchQueryType.QueryTypeTrack
//                default:
//                    return SPTSearchQueryType.QueryTypeArtist
//                }
//            }
//            .shareReplay(1)
        
        searchTextUpdated
            .subscribeNext { query in
                print("Searching")
                SpotifyApi.searchAll(query) { (response: SpotifySearchRepsonse?, error: NSError?) in
                    if (response != nil) {
                        self.searchResponse = response
                        self.tableView.reloadData()
                    } else {
                        print("ERROR SEARCHING")
                    }
                }
        }
        
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        playQueue = appDelegate.playQueue!
        
        playQueue?.login()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        print("VIEW DID APPEAR")
        if (searchResponse == nil) {
            searchField.becomeFirstResponder()
        }
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
    
    private

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
            
            playQueue?.queueSong(searchResponse!.tracks.items[indexPath.row])
            
        } else if (indexPath.section == ArtistSection) {
            selectedArtist = searchResponse!.artists.items[indexPath.row]
            performSegueWithIdentifier("showArtist", sender: self)
        } else if (indexPath.section == AlbumSection) {
            selectedAlbum = searchResponse!.albums.items[indexPath.row]
            performSegueWithIdentifier("showAlbum", sender: self)

        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        searchField.resignFirstResponder();
    }

}
