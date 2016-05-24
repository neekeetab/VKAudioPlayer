//
//  ViewController.swift
//  VKAudioPlayer
//
//  Created by Nikitab Belousov on 5/6/16.
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
    var usersAudio = [VKAudioItem]()
    var globalAudio = [VKAudioItem]()
    let searchController = UISearchController(searchResultsController: nil)
    var indicatorView = UIActivityIndicatorView()
    let requestOperationQueue = NSOperationQueue() // in this queue only last operation is executed, all others are canceled
    
    // MARK: -
    func executeInitialRequest() {
        
        usersAudio = []
        globalAudio = []
        tableView.reloadData()
        
        indicatorView.startAnimating()
        let audioRequest = VKApi.requestWithMethod("audio.get", andParameters: [
            "count": elementsPerRequest
            ])
        audioRequest.executeWithResultBlock({ response in
            
            self.usersAudio += response.usersAudio()
            self.globalAudio += self.globalAudio
            
            self.tableView?.reloadData()
            self.indicatorView.stopAnimating()
            
            }, errorBlock: { error in
                print(error)
                // TODO: handle appropriately
        })
    }
    
    func sectionForglobalAudio() -> Int {
        if usersAudio.count != 0 {
            return 1
        }
        return 0
    }
    
    var requestExecuted = true
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom - height < distanceFromBottomToPreload {
            
            if usersAudio.count != 0 || globalAudio.count != 0 {
                if requestOperationQueue.operationCount == 0 && requestExecuted {
                    
                    indicatorView.startAnimating()
                    var audioRequest: VKRequest!
                    
                    if searchController.active {
                        audioRequest = VKApi.requestWithMethod("audio.search", andParameters: [
                            "q": searchController.searchBar.text!,
                            "auto_complete": 1,
                            "search_own": 1,
                            "offset": usersAudio.count + globalAudio.count
                            ])
                        
                        audioRequest.completeBlock = { response in
                            let items = response.globalAudio()
                            var paths = [NSIndexPath]()
                            for i in 0 ..< items.count {
                                paths.append(NSIndexPath(forRow: self.globalAudio.count + i, inSection: self.sectionForglobalAudio()))
                            }
                            self.globalAudio += items
                            self.tableView.insertRowsAtIndexPaths(paths, withRowAnimation: UITableViewRowAnimation.Automatic)
                            self.indicatorView.stopAnimating()
                            self.requestExecuted = true
                        }
                    } else {
                        audioRequest = VKApi.requestWithMethod("audio.get", andParameters: [
                            "offset": usersAudio.count,
                            "count": elementsPerRequest,
                            "need_user": 0
                            ])
                        audioRequest.completeBlock = { response in
                            let items = response.usersAudio()
                            var paths = [NSIndexPath]()
                            for i in 0 ..< items.count {
                                paths.append(NSIndexPath(forRow: self.usersAudio.count + i, inSection: 0))
                            }
                            self.usersAudio += items
                            self.tableView.insertRowsAtIndexPaths(paths, withRowAnimation: UITableViewRowAnimation.Automatic)
                            self.indicatorView.stopAnimating()
                            self.requestExecuted = true
                        }
                    }
                    
                    audioRequest.errorBlock = { error in
                        self.indicatorView.stopAnimating()
                        print(error)
                        self.requestExecuted = true
                        // TODO: Handle appropriately
                    }
                    
                    let operation = NSBlockOperation()
                    weak var opWeak = operation
                    operation.addExecutionBlock({
                        usleep(timePerRequestsMilliseconds)
                        self.indicatorView.startAnimating()
                        if opWeak != nil && opWeak!.cancelled == false {
                            self.requestExecuted = false
                            audioRequest.start()
                        }
                    })
                    
                    self.requestOperationQueue.addOperation(operation)
                }
            }
        }
        
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
                self.executeInitialRequest()
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
        
        requestOperationQueue.maxConcurrentOperationCount = 1
        
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