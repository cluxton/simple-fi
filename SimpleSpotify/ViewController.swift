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
    
    var firstLoad: Bool = true
    
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (firstLoad) {
            loginWithSpotify(self)
        }
        firstLoad = false
    }
    
    @IBAction func loginWithSpotify(sender: AnyObject) {
        if let session = spotifyAuthenticator.session {
            print("EXISTING SESSION")
            
            if (session.isValid()) {
                print("  Session is valid")
                performSegueWithIdentifier("showHome", sender: self)
                return
            }
            
            if (!session.isValid() && spotifyAuthenticator.hasTokenRefreshService) {
                print("  renewing session")
                spotifyAuthenticator.renewSession(session) { (error: NSError!, session: SPTSession!) in
                    if error != nil {
                        print("    Couldn't login with session: \(error)")
                        return
                    }
                    print("    SESSION RENEWED")
                    
                }
            }
        }
        
        
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
        print("login failed: \(error)")
    }
    
    func handleSpotifySessionUpdated() {
        print("LOGON SUCCESS");
        spotifyAuthVC!.dismissViewControllerAnimated(true, completion: nil)
        performSegueWithIdentifier("showHome", sender: self)
    }

}

