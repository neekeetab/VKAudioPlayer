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
import LNPopupController

class TableViewController: UITableViewController {
    
    // MARK: Interface builder
    @IBOutlet var footerView: UIView!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    @IBAction func searchButtonPressed(sender: AnyObject) {
        search()
    }
    
    @IBAction func settingsButtonPressed(sender: AnyObject) {
    }
    
    // MARK: -
    var audioStream = FSAudioStream()
    let searchController = UISearchController(searchResultsController: nil)
    var indicatorView = UIActivityIndicatorView()
    var context = AudioContext()
    
    // MARK: -
    func search() {
        UIView.animateWithDuration(0.3, animations: {
            self.tableView.contentOffset = CGPoint(x: 0, y: -self.tableView.contentInset.top)
        })
        self.searchController.searchBar.becomeFirstResponder()
    }
    
    // MARK: -
    func refresh(sender: AnyObject) {
        tableView.userInteractionEnabled = false
        searchButton.enabled = false
        context.cancel()
        initializeContext(AudioRequestDescription.usersAudioRequestDescription())
        
    }
    
    // MARK: -
    var allowedToFetchNewData = true
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if context.usersAudio.count != 0 || context.globalAudio.count != 0 {
            let height = scrollView.frame.size.height
            let contentYoffset = scrollView.contentOffset.y
            let distanceFromBottom = scrollView.contentSize.height - contentYoffset
            if distanceFromBottom - height < distanceFromBottomToPreload && context.busy() == false && allowedToFetchNewData {
//                tableView.tableFooterView = footerView
                context.loadNextPortion()
                allowedToFetchNewData = false
            }
        }
    }
    
    // MARK: -
    func initializeContext(audioRequestDescription: AudioRequestDescription) {
        tableView.tableFooterView = footerView
        context.cancel()
        context = AudioContext(audioRequestDescription: audioRequestDescription, completionBlock: { suc, usersAudio, globalAudio in
            
            self.refreshControl?.endRefreshing()
            
            if suc {
                if usersAudio.count + globalAudio.count > 0 {
                        self.tableView.reloadData()
                } else { // means the end of data
                    UIView.animateWithDuration(0.3, animations: {
                        self.tableView.tableFooterView = nil
                    })
                }
            } else {
                self.showMessage("You're now switched to cache-only mode. Pull down to retry.", title: "Network is unreachable")
                // TODO: swifch to cache-only mode
            }
            
            self.tableView.userInteractionEnabled = true
            self.searchButton.enabled = true
            
            delay(1, closure: {
                self.allowedToFetchNewData = true
            })
            
        })
        tableView.reloadData()
        context.loadNextPortion()
    }
    
    // MARK: - View controller customization
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
                self.initializeContext(audioRequestDescription)
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
        
        //
        
        refreshControl!.addTarget(self, action: #selector(refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
    
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
        tableView.tableFooterView = footerView
        
        //
//        print(audioStream.configuration.cacheDirectory)
//        print(audioStream.configuration.cacheEnabled)
//        audioStream.expungeCache()
        do {
            try print(NSFileManager.defaultManager().contentsOfDirectoryAtPath(audioStream.configuration.cacheDirectory))
        } catch _ {
            
        }
    
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return  UIStatusBarStyle.LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}