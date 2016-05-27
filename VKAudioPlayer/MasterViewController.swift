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
    @IBOutlet var footerView: UIView!
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
    var allowedToFetchNewData = true
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if context.usersAudio.count != 0 || context.globalAudio.count != 0 {
            let height = scrollView.frame.size.height
            let contentYoffset = scrollView.contentOffset.y
            let distanceFromBottom = scrollView.contentSize.height - contentYoffset
            if distanceFromBottom - height < distanceFromBottomToPreload && context.busy() == false && allowedToFetchNewData {
                tableView.tableFooterView = footerView
                context.loadNextPortion()
                allowedToFetchNewData = false
                delay(1, closure: {
                    self.allowedToFetchNewData = true
                })
            }
        }
    }
    
    // MARK: -
    func showMessage(message: String, title: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alertVC.addAction(action)
        self.presentViewController(alertVC, animated: true, completion: nil)
    }
    
    // MARK: -
    func initializeContext(audioRequestDescription: AudioRequestDescription) {
        tableView.tableFooterView = footerView
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
                    self.tableView.insertRowsAtIndexPaths(paths, withRowAnimation: .Automatic)
                }
                
            } else {
                self.showMessage("You're now switched to cache-only mode. Pull down to retry.", title: "Network is unreachable")
                // TODO: swifch to cache-only mode
            }
            UIView.animateWithDuration(0.3, animations: {
                self.tableView.tableFooterView = nil
            })
        
        })
        tableView.reloadData()
        context.loadNextPortion()
    }
    
    // MARK: - View controller customization
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        VKSdk.forceLogout()
//        return
        
        definesPresentationContext = false
        let sdkInstance = VKSdk.initializeWithAppId(appID)
        sdkInstance.uiDelegate = self
        sdkInstance.registerDelegate(self)
        
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
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.translucent = false
        searchController.searchBar.opaque = true
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