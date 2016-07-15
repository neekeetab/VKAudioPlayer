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
    
    func playerItem(playerItem: CachingPlayerItem, didFinishLoadingData data: NSData) {
        let cache = HybridCache(name: "VKAudioPlayerStorage")
        cache.add("", object: data)
    }
    
    func playerItem(playerItem: CachingPlayerItem, didLoadBytesSoFar bytesLoaded: Int, outOf bytesExpected: Int) {
        print("\(Float(Double(bytesLoaded)/Double(bytesExpected)) * 100)%")
        audioPlayerViewController.popupItem.progress = Float(Double(bytesLoaded)/Double(bytesExpected))
    }
    
}