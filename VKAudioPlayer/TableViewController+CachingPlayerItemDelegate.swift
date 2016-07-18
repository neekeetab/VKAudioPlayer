//
//  TableViewController+CachingPlayerItemDelegate.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 7/15/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import Foundation
import LNPopupController

extension TableViewController: CachingPlayerItemDelegate {
    
    func playerItem(playerItem: CachingPlayerItem, didFinishDownloadingData data: NSData) {
        if let unwrappedPlayerItem = playerItem as? VKCachingPlayerItem {
            if let audioItem = unwrappedPlayerItem.audioItem {
                Storage.sharedStorage.add(String(audioItem.id), object: data)
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    self.audioPlayerViewController.popupItem.progress = 0.0
                })
            }
        }
    }
    
    func playerItem(playerItem: CachingPlayerItem, didDownloadBytesSoFar bytesDownloaded: Int, outOf bytesExpected: Int) {
        NSOperationQueue.mainQueue().addOperationWithBlock({
            self.audioPlayerViewController.popupItem.progress = Float(Double(bytesDownloaded)/Double(bytesExpected))
        })
    }
    
}