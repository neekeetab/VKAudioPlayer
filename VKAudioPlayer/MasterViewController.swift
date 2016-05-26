//
//  ViewController.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 5/6/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import UIKit
import VK_ios_sdk
import FreeStreamer
import AVFoundation

class MasterViewController: UIViewController {
    
    // MARK: Interface builder
    @IBOutlet weak var tableView: UITableView!
    @IBAction func searchButtonPressed(sender: AnyObject) {
        UIView.animateWithDuration(0.3, animations: {
            self.tableView.contentOffset = CGPoint(x: 0, y: -self.tableView.contentInset.top)
        })
        self.searchController.searchBar.becomeFirstResponder()
    }
    
    // MARK: -
    var audioStream = FSAudioStream()
    let searchController = UISearchController(searchResultsController: nil)
    var indicatorView = UIActivityIndicatorView()
    var context = AudioContext()
    
    // MARK: -
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom - height < distanceFromBottomToPreload {
            context.loadNextPortion()
        }
    }
    
    // MARK: - 
    func initializeContext(audioRequestDescription: AudioRequestDescription) {
        self.indicatorView.startAnimating()
        context = AudioContext(audioRequestDescription: audioRequestDescription, completionBlock: { suc, usersAudio, globalAudio in
            if suc {
                
                var paths = [NSIndexPath]()
                if audioRequestDescription is UsersAudioRequestDescription {
                    for i in 0 ..< usersAudio.count {
                        paths.append(NSIndexPath(forRow: self.context.usersAudio.count - usersAudio.count + i, inSection: 0))
                    }
                }
                if audioRequestDescription is SearchAudioRequestDescription {
                    for i in 0 ..< usersAudio.count {
                        paths.append(NSIndexPath(forRow: self.context.usersAudio.count - usersAudio.count + i, inSection: 0))
                    }
                    for i in 0 ..< globalAudio.count {
                        paths.append(NSIndexPath(forRow: self.context.globalAudio.count - globalAudio.count + i, inSection: 1))
                    }
                }
                if paths.count > 0 {
                    self.tableView.insertRowsAtIndexPaths(paths, withRowAnimation: UITableViewRowAnimation.Automatic)
                }
                self.indicatorView.stopAnimating()
                
            } else {
                // TODO: Handle appropriately
                print("error")
            }
        })
        tableView.reloadData()
        context.loadNextPortion()
    }
    
    // MARK: - View controller customization
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        VKSdk.forceLogout()
//        return
        
        definesPresentationContext = true
        let sdkInstance = VKSdk.initializeWithAppId(appID)
        sdkInstance.uiDelegate = self
        sdkInstance.registerDelegate(self)
        
        let scope = ["audio"]
        VKSdk.wakeUpSession(scope, completeBlock: { state, error in
            if state == VKAuthorizationState.Authorized {
                // ready to go
                let audioRequestDescription = AudioRequestDescription.usersAudioRequestDescription()
                self.initializeContext(audioRequestDescription)
            } else if state == VKAuthorizationState.Initialized {
                // auth needed
                VKSdk.authorize(scope)
            } else if state == VKAuthorizationState.Error {
                fatalError("Cannot get session")
                // TODO: Handle appropriately
            } else if error != nil {
                fatalError(error.description)
                // TODO: Handle appropriately
            }
        })
        
        indicatorView.center = view.center
        indicatorView.activityIndicatorViewStyle = .Gray
        indicatorView.hidesWhenStopped = true
        view.addSubview(indicatorView)
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return  UIStatusBarStyle.LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}