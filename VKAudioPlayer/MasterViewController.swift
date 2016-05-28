//
//  MasterViewController.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 5/28/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import UIKit

class MasterViewController: UIViewController {

    var tableViewController: TableViewController!
    var audioPlayerViewController: AudioPlayerViewController!
    
    // MARK: - IB
    @IBAction func searchButtonPressed(sender: AnyObject) {
        tableViewController.search(self)
    }
    @IBAction func settingsButtonPressed(sender: AnyObject) {
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
