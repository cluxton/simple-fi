//
//  ViewController.swift
//  SimpleSpotify
//
//  Created by Charles Luxton on 22/02/2016.
//  Copyright © 2016 Charles Luxton. All rights reserved.
//

import UIKit

class AuthViewController: UIViewController, SPTAuthViewDelegate, SPTAudioStreamingPlaybackDelegate {
    
    @IBOutlet weak var Header: UILabel!
    @IBOutlet weak var Subtitle: UILabel!
    @IBOutlet weak var LoginButton: UIButton!
    
    var firstLoad: Bool = true
    var player: SPTAudioStreamingController?
    var spotifyAuthVC: SPTAuthViewController?
    
    let spotifyAuthenticator = SPTAuth.defaultInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleSpotifySessionUpdated", name: "SPTSessionUpdated", object: nil)
        self.setViewText("", subtitle: "")
        LoginButton?.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (firstLoad) {
            refreshSession()
        }
        firstLoad = false
    }
    
    @IBAction func loginWithSpotify(sender: AnyObject) {
        self.reauthenticate()
    }
    
    func refreshSession() {
        guard let session = spotifyAuthenticator.session else {
            //self.reauthenticate()
            self.setViewText("Log in to spotify", subtitle: "A Spotify Premium account is requied to use this application.")
            self.LoginButton?.hidden = false
            return
        }
        
        if (session.isValid()) {
            self.validSessionAquired()
            return
        }
        
        if (!session.isValid() && spotifyAuthenticator.hasTokenRefreshService) {
            
            setViewText("Logging in to spotify...", subtitle: "Please wait.")
            LoginButton?.hidden = true
            
            spotifyAuthenticator.renewSession(session) { [weak self] (error: NSError!, session: SPTSession!) in
                print("CALLBACK")
                if error != nil {
                    print("    Couldn't login with session: \(error)")
                    self?.logonFailed()
                    return
                }
                
                self?.validSessionAquired()
            }
            print("DONE")
            return
        }
        
        self.setViewText("Log in to spotify", subtitle: "A Spotify Premium account is requied to use this application.")
        self.LoginButton?.hidden = false
        
        //self.reauthenticate()
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
        print("VALID SESSION")
        self.setViewText("Log in successful", subtitle: "")
        self.LoginButton?.hidden = true
        
        PlayQueueManager.defaultInstance().login()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setViewText(header: String, subtitle: String) {
        Header?.text = header
        Subtitle?.text = subtitle
    }
    
    func logonFailed() {
        self.setViewText("Unable to log in", subtitle: "Please try again.")
        self.LoginButton?.hidden = false
        spotifyAuthVC?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didLoginWithSession session: SPTSession!) {
        self.validSessionAquired()
    }
    
    func authenticationViewControllerDidCancelLogin(authenticationViewController: SPTAuthViewController!) {
        logonFailed()
    }
    
    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didFailToLogin error: NSError!) {
        print("    didFailToLogin: \(error)")
        logonFailed()
    }
    
    func handleSpotifySessionUpdated() {
        spotifyAuthVC?.dismissViewControllerAnimated(true) { [weak self] in
            self?.validSessionAquired()
        }
    }

}

