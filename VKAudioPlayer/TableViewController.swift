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

class TableViewController: UITableViewController {
    
    // MARK: Interface builder
    @IBOutlet var footerView: UIView!
    
    // MARK: -
    var masterViewController: MasterViewController!
    var audioStream = FSAudioStream()
    let searchController = UISearchController(searchResultsController: nil)
    var indicatorView = UIActivityIndicatorView()
    var context = AudioContext()
    
    // MARK: -
    func search(sender: AnyObject) {
        UIView.animateWithDuration(0.3, animations: {
            self.tableView.contentOffset = CGPoint(x: 0, y: -self.tableView.contentInset.top)
        })
        self.searchController.searchBar.becomeFirstResponder()
    }
    
    // MARK: -
    func refresh(sender: AnyObject) {
        tableView.userInteractionEnabled = false
        masterViewController.searchButton.enabled = false
        
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
            print(distanceFromBottom - height)
            if distanceFromBottom - height + 100 /* player height */ < distanceFromBottomToPreload && context.busy() == false && allowedToFetchNewData {
                tableView.tableFooterView = footerView
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
            
            if self.refreshControl!.refreshing  {
                self.refreshControl!.endRefreshing()
            }

            delay(1, closure: {
                self.allowedToFetchNewData = true
            })
            
            self.tableView.userInteractionEnabled = true
            self.masterViewController.searchButton.enabled = true
            
            if suc {
                if usersAudio.count + globalAudio.count > 0 {
                    self.tableView.reloadData()
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
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        refreshControl!.addTarget(self, action: #selector(refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
    
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