//
//  MasterViewController+SearchDelegate.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 5/24/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import UIKit
import VK_ios_sdk

extension MasterViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        usersAudio = []
        globalAudio = []
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
            
            self.usersAudio += response.usersAudio()
            self.globalAudio += response.globalAudio()
            
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
            usleep(timePerRequestsMilliseconds)
            self.indicatorView.startAnimating()
            if opWeak != nil && opWeak!.cancelled == false {
                searchAudioRequest.start()
            }
        })
        
        self.requestOperationQueue.addOperation(operation)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        executeInitialRequest()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
    }

}