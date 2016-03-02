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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "validSessionAquired", name: "SPTSessionUpdated", object: nil)
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
            refreshSession()
        }
        firstLoad = false
    }
    
    @IBAction func loginWithSpotify(sender: AnyObject) {
        refreshSession()
    }
    
    func refreshSession() {
        
        print("REFRESH SESSION")
        guard let session = spotifyAuthenticator.session else {
            self.reauthenticate()
            return
        }
        
        if (session.isValid()) {
            self.validSessionAquired()
            return
        }
        
        if (!session.isValid() && spotifyAuthenticator.hasTokenRefreshService) {
            print ("RENEWING")
            
            spotifyAuthenticator.renewSession(session) { (error: NSError!, session: SPTSession!) in
                print("CALLBACK")
                if error != nil {
                    print("    Couldn't login with session: \(error)")
                    self.reauthenticate()
                    return
                }
                
                self.validSessionAquired()
            }
            print("DONE")
            return
        }
        
        self.reauthenticate()
    }
    
    func reauthenticate() {
        spotifyAuthVC = SPTAuthViewController.authenticationViewController()
        spotifyAuthVC!.delegate = self
        spotifyAuthVC!.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        
        spotifyAuthVC!.definesPresentationContext = true
        print("PRESENT")
        presentViewController(spotifyAuthVC!, animated: false, completion: nil)
    }
    
    func validSessionAquired() {
        print ("VALIDATED!!!")
        PlayQueueManager.defaultInstance().login()
        self.dismissViewControllerAnimated(true, completion: nil)
        
        //performSegueWithIdentifier("showHome", sender: self)
    }
    
    func logonFailed() {
        print("AUTHENTICATION FAILED")
    }
    
    // SPTAuthViewDelegate protocol methods
    
    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didLoginWithSession session: SPTSession!) {
        print("AUTH VC DELEGATE SUCCESS");
        self.validSessionAquired()
    }
    
    func authenticationViewControllerDidCancelLogin(authenticationViewController: SPTAuthViewController!) {
        print("login cancelled")
        logonFailed()
    }
    
    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didFailToLogin error: NSError!) {
        print("login failed: \(error)")
        logonFailed()
    }
    
    func handleSpotifySessionUpdated() {
        spotifyAuthVC?.dismissViewControllerAnimated(true, completion: nil)
        print("LOGON SUCCESS");
        validSessionAquired()
    }

}

