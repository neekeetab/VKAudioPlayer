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
        if searchController.active {
            refreshControl?.endRefreshing()
            refreshControl = nil
            let audioRequestDescription = AudioRequestDescription.searchAudioRequestDescription(searchController.searchBar.text!)
            initializeContext(audioRequestDescription)
            tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        context.cancel()
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        let audioRequestDescription = AudioRequestDescription.userAudioRequestDescription()
        self.initializeContext(audioRequestDescription)
        
        delay(0.5, closure: {
            self.navigationController?.view.bringSubviewToFront(self.navigationController!.popupContentView)
        })
        
        tableView.setContentOffset(tableView.contentOffset, animated: false)

        tableView.reloadData()
        
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {}

}