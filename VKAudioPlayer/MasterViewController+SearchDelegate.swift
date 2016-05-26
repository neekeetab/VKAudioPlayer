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
        if searchController.active {
            let audioRequestDescription = AudioRequestDescription.searchAudioRequestDescription(searchController.searchBar.text!)
            initializeContext(audioRequestDescription)
        }
        indicatorView.startAnimating()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        let audioRequestDescription = AudioRequestDescription.usersAudioRequestDescription()
        initializeContext(audioRequestDescription)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {}

}