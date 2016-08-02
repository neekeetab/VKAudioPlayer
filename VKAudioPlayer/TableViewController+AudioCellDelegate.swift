//
//  TableViewController+AudioCellDelegate.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 6/21/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import UIKit
import VK_ios_sdk

extension TableViewController: AudioCellDelegate {
    
    func addButtonPressed(sender: AudioCell) {
        let indexPath = tableView.indexPathForCell(sender)
        let audioItem = audioItemForIndexPath(indexPath!)
        let request = VKRequest.addAudioRequest(audioItem)
        request.executeWithResultBlock({ response in
            self.showMessage("", title: "Audio has been added")
            sender.ownedByUser = true
        }, errorBlock: { error in
            self.showError(error.description)
            sender.ownedByUser = false
        })
    }
    
    func downloadButtonPressed(sender: AudioCell) {
        CacheController.sharedCacheController.downloadAudioItem(sender.audioItem!)
    }
    
    func cancelButtonPressed(sender: AudioCell) {
        CacheController.sharedCacheController.cancelDownloadingAudioItem(sender.audioItem!)
    }
    
}

