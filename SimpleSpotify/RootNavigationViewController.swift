//
//  RootNavigationViewController.swift
//  SimpleSpotify
//
//  Created by Charles Luxton on 27/02/2016.
//  Copyright © 2016 Charles Luxton. All rights reserved.
//

import UIKit

class RootNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let session = SPTAuth.defaultInstance().session {
            if (!session.isValid()) {
                self.showAuthenticator()
            }
        } else {
            self.showAuthenticator()
        }
    }
    
    func showAuthenticator() {
        performSegueWithIdentifier("showAuthenticator", sender: self)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
