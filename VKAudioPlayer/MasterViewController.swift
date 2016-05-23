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

class MasterViewController: UIViewController, VKSdkDelegate, VKSdkUIDelegate, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBAction func searchButtonPressed(sender: AnyObject) {
        UIView.animateWithDuration(0.3, animations: {
            self.tableView.contentOffset = CGPoint(x: 0, y: -self.tableView.contentInset.top)
        })
        
        self.searchController.searchBar.becomeFirstResponder()
    }
    
    // MARK: Constants
    let timePerRequestsMilliseconds: UInt32 = 333333
    let elementsPerRequest = 50
    let distanceFromBottomToPreload: CGFloat = 0
    
    // MARK: Instance variables
    var userId: String!
    var audioStream = FSAudioStream()
    var myAudios = [[String: AnyObject]]()
    var globalAudios = [[String: AnyObject]]()
    let searchController = UISearchController(searchResultsController: nil)
    var indicatorView = UIActivityIndicatorView()
    let requestOperationQueue = NSOperationQueue()
    
    // MARK: -
    func exctractMyAudiosFromResponse(response: VKResponse) -> [[String: AnyObject]] {
        
        let items = (response.json as! [String: AnyObject])["items"] as! [[String: AnyObject]]
        var myAudios = [[String: AnyObject]]()
        for i in items {
            if i["owner_id"] as? Int == Int(userId) {
                myAudios.append(i)
            }
        }
        return myAudios
        
    }
    
    func exctractGlobalAudiosFromResponse(response: VKResponse) -> [[String: AnyObject]] {
        
        let items = (response.json as! [String: AnyObject])["items"] as! [[String: AnyObject]]
        var globalAudios = [[String: AnyObject]]()
        for i in items {
            if i["owner_id"] as? Int != Int(userId) {
                globalAudios.append(i)
            }
        }
        return globalAudios
        
    }
    
    func sectionForGlobalAudios() -> Int {
        if myAudios.count != 0 {
            return 1
        }
        return 0
    }
    
    // MARK: -
    
    // MARK: Search controller's delegate methods
    
    func executeInitialRequest() {
        
        myAudios = []
        globalAudios = []
        
        tableView.reloadData()
        indicatorView.startAnimating()
        let audioRequest = VKApi.requestWithMethod("audio.get", andParameters: [
            "count": elementsPerRequest
            ])
        audioRequest.executeWithResultBlock({ response in
            
            self.myAudios += self.exctractMyAudiosFromResponse(response)
            self.globalAudios += self.exctractGlobalAudiosFromResponse(response)
            
            self.tableView?.reloadData()
            self.indicatorView.stopAnimating()
            
            }, errorBlock: { error in
                print(error)
        })
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        myAudios = []
        globalAudios = []
        tableView.reloadData()
        
        if searchController.active == false {
            return
        }
        
        indicatorView.startAnimating()
        
        let searchAudioRequest = VKApi.requestWithMethod("audio.search", andParameters: [
            "q": searchController.searchBar.text!,
            "auto_complete": 1,
            "search_own": 1,
            "count": elementsPerRequest
            ])
        searchAudioRequest.completeBlock = { response in
            
            self.myAudios += self.exctractMyAudiosFromResponse(response)
            self.globalAudios += self.exctractGlobalAudiosFromResponse(response)
            
            self.tableView?.reloadData()
            self.indicatorView.stopAnimating()
            
        }
        searchAudioRequest.errorBlock = { error in
            self.indicatorView.stopAnimating()
            print(error)
            // TODO: Handle appropriately
        }
        
        requestOperationQueue.cancelAllOperations()
        
        let operation = NSBlockOperation()
        weak var opWeak = operation
        operation.addExecutionBlock({
            usleep(self.timePerRequestsMilliseconds)
            self.indicatorView.startAnimating()
            if opWeak != nil && opWeak!.cancelled == false {
                searchAudioRequest.start()
            }
        })
        
        self.requestOperationQueue.addOperation(operation)
    }
    
    // MARK: Search bar's delegate methods
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        executeInitialRequest()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
    }
    
    // MARK: TableView's delegate methods
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        var audioItem: [String: AnyObject]!
        if myAudios.count != 0 && indexPath.section == 0 {
            audioItem = myAudios[indexPath.row]
        } else {
            audioItem = globalAudios[indexPath.row]
        }
        
        let audioUrl = NSURL(string: audioItem["url"] as! String)
        audioStream.stop()
        audioStream.playFromURL(audioUrl)
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var count = 0
        if myAudios.count != 0 {
            count += 1
        }
        if globalAudios.count != 0 {
            count += 1
        }
        return count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if myAudios.count != 0 && section == 0 {
            return myAudios.count
        }
        return globalAudios.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var audioItem: [String: AnyObject]!
        if myAudios.count != 0 && indexPath.section == 0 {
            audioItem = myAudios[indexPath.row]
        } else {
            audioItem = globalAudios[indexPath.row]
        }
        
        let cell = UITableViewCell()
        let title = audioItem["title"] as? String
        let author = audioItem["artist"] as? String
        cell.textLabel?.text = title! + " - " + author!
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if myAudios.count != 0 && section == 0 {
            return "My audios"
        }
        return "Global audios"
    }
    
    //    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    //        let height = scrollView.frame.size.height
    //        let contentYoffset = scrollView.contentOffset.y
    //        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
    //
    //        if distanceFromBottom <= height {
    //            print("need to load more")
    //        }
    //    }
    
    var requestExecuted = true
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom - height < distanceFromBottomToPreload {
            
            if myAudios.count != 0 || globalAudios.count != 0 {
                if requestOperationQueue.operationCount == 0 && requestExecuted {
                    
                    indicatorView.startAnimating()
                    var audioRequest: VKRequest!
                    
                    if searchController.active {
                        audioRequest = VKApi.requestWithMethod("audio.search", andParameters: [
                            "q": searchController.searchBar.text!,
                            "auto_complete": 1,
                            "search_own": 1,
                            "offset": myAudios.count + globalAudios.count
                            ])
                        audioRequest.completeBlock = { response in
                            let items = self.exctractGlobalAudiosFromResponse(response)
                            var paths = [NSIndexPath]()
                            for i in 0 ..< items.count {
                                paths.append(NSIndexPath(forRow: self.globalAudios.count + i, inSection: self.sectionForGlobalAudios()))
                            }
                            self.globalAudios += items
                            self.tableView.insertRowsAtIndexPaths(paths, withRowAnimation: UITableViewRowAnimation.Automatic)
                            self.indicatorView.stopAnimating()
                            self.requestExecuted = true
                        }
                    } else {
                        audioRequest = VKApi.requestWithMethod("audio.get", andParameters: [
                            "offset": myAudios.count,
                            "count": elementsPerRequest,
                            "need_user": 0
                            ])
                        audioRequest.completeBlock = { response in
                            let items = self.exctractMyAudiosFromResponse(response)
                            var paths = [NSIndexPath]()
                            for i in 0 ..< items.count {
                                paths.append(NSIndexPath(forRow: self.myAudios.count + i, inSection: 0))
                            }
                            self.myAudios += items
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
                        usleep(self.timePerRequestsMilliseconds)
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
    
    // MARK: View controller customization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        VKSdk.forceLogout()
        //        return
        
        definesPresentationContext = true
        let sdkInstance = VKSdk.initializeWithAppId("5450086")
        sdkInstance.uiDelegate = self
        sdkInstance.registerDelegate(self)
        
        let scope = ["audio"]
        VKSdk.wakeUpSession(scope, completeBlock: { state, error in
            if state == VKAuthorizationState.Authorized {
                // ready to go
                self.executeInitialRequest()
                self.userId = VKSdk.accessToken().userId
            } else if state == VKAuthorizationState.Initialized {
                // auth needed
                VKSdk.authorize(scope)
            } else if state == VKAuthorizationState.Error {
                fatalError("Cannot get session")
            } else if error != nil {
                fatalError(error.description)
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
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return  UIStatusBarStyle.LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: VK's delegate methods
    
    func vkSdkUserAuthorizationFailed() {
        print("Authorization failed")
        // TODO: handle appropriately
    }
    
    func vkSdkAccessAuthorizationFinishedWithResult(result: VKAuthorizationResult!) {
        //        print("Authorization finished with token: \(result.token.accessToken)")
        userId = VKSdk.accessToken().userId
        executeInitialRequest()
    }
    
    func vkSdkShouldPresentViewController(controller: UIViewController!) {
        self.navigationController!.presentViewController(controller, animated: true, completion: nil)
    }
    
    func vkSdkNeedCaptchaEnter(captchaError: VKError!) {
        searchController.active = false
        let captchaController = VKCaptchaViewController.captchaControllerWithError(captchaError)
        captchaController.presentIn(self)
    }
}