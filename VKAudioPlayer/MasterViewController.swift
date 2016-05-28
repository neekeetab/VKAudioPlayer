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
    
    // MARK: - IB
    @IBAction func searchButtonPressed(sender: AnyObject) {
        tableViewController.search(self)
    }
    @IBAction func settingsButtonPressed(sender: AnyObject) {
    }
    
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

        // Do any additional setup after loading the view.
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
        }
        if segue.identifier == "auidioPlayerViewController" {
            audioPlayerViewController = segue.destinationViewController as! AudioPlayerViewController
        }
    }

}
