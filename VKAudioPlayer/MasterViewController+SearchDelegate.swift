//
//  TableViewController+SearchDelegate.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 5/24/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import UIKit
import VK_ios_sdk

extension TableViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        if !searchController.active {
            refreshControl = UIRefreshControl()
            refreshControl!.addTarget(self, action: #selector(refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        }
        
        if searchController.active {
            refreshControl?.endRefreshing()
            refreshControl = nil
            
            context.cancel()
            let audioRequestDescription = AudioRequestDescription.searchAudioRequestDescription(searchController.searchBar.text!)
            initializeContext(audioRequestDescription)
        }
        
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        context.cancel()
        let audioRequestDescription = AudioRequestDescription.usersAudioRequestDescription()
        initializeContext(audioRequestDescription)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {}

}