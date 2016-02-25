//
//  ViewController.swift
//  SimpleSpotify
//
//  Created by Charles Luxton on 22/02/2016.
//  Copyright © 2016 Charles Luxton. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SPTAuthViewDelegate, SPTAudioStreamingPlaybackDelegate {
    
    var player: SPTAudioStreamingController?
    var spotifyAuthVC: SPTAuthViewController?
    
    let spotifyAuthenticator = SPTAuth.defaultInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleSpotifySessionUpdated", name: "SPTSessionUpdated", object: nil)
        //setupSpotifyPlayer()
                // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginWithSpotify(sender: AnyObject) {
        
        spotifyAuthVC = SPTAuthViewController.authenticationViewController()
        spotifyAuthVC!.delegate = self
        spotifyAuthVC!.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        
        spotifyAuthVC!.definesPresentationContext = true
        print("PRESENT")
        presentViewController(spotifyAuthVC!, animated: false, completion: nil)
        
    }
    
    // SPTAuthViewDelegate protocol methods
    
    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didLoginWithSession session: SPTSession!) {
        print("AUTH VC DELEGATE SUCCESS");
        spotifyAuthenticator.session = session;
        NSNotificationCenter.defaultCenter().postNotificationName("SPTSessionUpdated", object: self)
    }
    
    func authenticationViewControllerDidCancelLogin(authenticationViewController: SPTAuthViewController!) {
        print("login cancelled")
    }
    
    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didFailToLogin error: NSError!) {
        print("login failed")
    }
    
    func handleSpotifySessionUpdated() {
        print("LOGON SUCCESS");
        spotifyAuthVC!.dismissViewControllerAnimated(true, completion: nil)
        performSegueWithIdentifier("showHome", sender: self)
        //loginWithSpotifySession(spotifyAuthenticator.session)
    }
    
    
    
    
//    func setupSpotifyPlayer() {
//        player = SPTAudioStreamingController(clientId: spotifyAuthenticator.clientID)
//        player!.playbackDelegate = self
//        player!.diskCache = SPTDiskCache(capacity: 1024 * 1024 * 64)
//    }
    
//    func loginWithSpotifySession(session: SPTSession) {
//        player!.loginWithSession(session, callback: { (error: NSError!) in
//            if error != nil {
//                print("Couldn't login with session: \(error)")
//                return
//            }
//            self.useLoggedInPermissions()
//        })
//    }
    
//    func useLoggedInPermissions() {
//        let spotifyURI = "spotify:track:1WJk986df8mpqpktoktlce"
//        player!.playURIs([NSURL(string: spotifyURI)!], withOptions: nil, callback: nil)
//        performSegueWithIdentifier("showHome", sender: self)
//    }
    
    


}

