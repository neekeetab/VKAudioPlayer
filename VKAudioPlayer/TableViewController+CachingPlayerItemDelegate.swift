//
//  TableViewController+CachingPlayerItemDelegate.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 7/15/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import Foundation
import Cache
import LNPopupController

extension TableViewController: CachingPlayerItemDelegate {
    
    func playerItem(playerItem: CachingPlayerItem, didFinishDownloadingData data: NSData) {
        if let unwrappedPlayerItem = playerItem as? VKCachingPlayerItem {
            if let audioItem = unwrappedPlayerItem.audioItem {
                cache.add(String(audioItem.id), object: data)
            }
        }
    }
    
    func playerItem(playerItem: CachingPlayerItem, didDownloadBytesSoFar bytesDownloaded: Int, outOf bytesExpected: Int) {
        print("\(Float(Double(bytesDownloaded)/Double(bytesExpected)) * 100)%")
        audioPlayerViewController.popupItem.progress = Float(Double(bytesDownloaded)/Double(bytesExpected))
    }
    
}