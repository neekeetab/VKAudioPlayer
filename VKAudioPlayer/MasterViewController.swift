//
//  MasterViewController.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 5/28/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import UIKit
import VK_ios_sdk

class MasterViewController: UIViewController, VKSdkDelegate, VKSdkUIDelegate {

    var tableViewController: TableViewController!
    var audioPlayerViewController: AudioPlayerViewController!
    let indicatorView = UIActivityIndicatorView()
    
    // MARK: - IB
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBAction func searchButtonPressed(sender: AnyObject) {
        tableViewController.search(self)
    }
    
    @IBAction func settingsButtonPressed(sender: AnyObject) {
    }
    
    // MARK: - VK delegate
    func vkSdkUserAuthorizationFailed() {
        print("Authorization failed")
        // TODO: handle appropriately
    }
    
    func vkSdkAccessAuthorizationFinishedWithResult(result: VKAuthorizationResult!) {
        let audioRequestDescription = AudioRequestDescription.usersAudioRequestDescription()
        tableViewController.initializeContext(audioRequestDescription)
    }
    
    func vkSdkShouldPresentViewController(controller: UIViewController!) {
        self.navigationController!.presentViewController(controller, animated: true, completion: nil)
    }
    
    func vkSdkNeedCaptchaEnter(captchaError: VKError!) {
        tableViewController.searchController.active = false
        let captchaController = VKCaptchaViewController.captchaControllerWithError(captchaError)
        captchaController.presentIn(self)
    }
    
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()

        let sdkInstance = VKSdk.initializeWithAppId(appID)
        sdkInstance.uiDelegate = self
        sdkInstance.registerDelegate(self)
        
        //        VKSdk.forceLogout()
        //        return
        
        indicatorView.center = view.center
        indicatorView.activityIndicatorViewStyle = .Gray
        indicatorView.hidesWhenStopped = true
        view.addSubview(indicatorView)
        
        let scope = ["audio"]
        indicatorView.startAnimating()
        VKSdk.wakeUpSession(scope, completeBlock: { state, error in
            self.indicatorView.stopAnimating()
            if state == VKAuthorizationState.Authorized {
                // ready to go
                let audioRequestDescription = AudioRequestDescription.usersAudioRequestDescription()
                self.tableViewController.initializeContext(audioRequestDescription)
            } else if state == VKAuthorizationState.Initialized {
                // auth needed
                VKSdk.authorize(scope)
            } else if state == VKAuthorizationState.Error {
                self.showMessage("You're now switched to cache-only mode. Pull down to retry.", title: "Failed to authorize")
                // TODO: Handle appropriately
            } else if error != nil {
                fatalError(error.description)
                // TODO: Handle appropriately
            }
        })

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return  UIStatusBarStyle.LightContent
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "tableViewController_embedded" {
            tableViewController = segue.destinationViewController as! TableViewController
            tableViewController.masterViewController = self
        }
        if segue.identifier == "auidioPlayerViewController" {
            audioPlayerViewController = segue.destinationViewController as! AudioPlayerViewController
        }
    }

}
