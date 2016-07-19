//
//  TableViewController+AudioContextDelegate.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 7/19/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import Foundation
import UIKit

extension TableViewController: AudioContextDelegate {
    
    func audioContextDidLoadNewPortionOfData(audioContext: AudioContext) {
        refreshControl?.endRefreshing()
        
        tableView.reloadData()
        
        if !audioContext.hasMoreToLoad() {
            UIView.animateWithDuration(0.3, animations: {
                self.tableView.tableFooterView = nil
            })
        }
        
        tableView.userInteractionEnabled = true
        searchButton.enabled = true
        
        delay(1, closure: {
            self.allowedToFetchNewData = true
        })

    }
    
    func audioContextDidFailToLoadNewPortionOfData(audioContext: AudioContext) {
        refreshControl?.endRefreshing()
        
        showMessage("You're now switched to cache-only mode. Pull down to retry.", title: "Network is unreachable")
        // TODO: swifch to cache-only mode
        
        tableView.userInteractionEnabled = true
        searchButton.enabled = true
        
        delay(1, closure: {
            self.allowedToFetchNewData = true
        })
    }
    
}