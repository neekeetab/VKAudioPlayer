//
//  CacheController.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 7/19/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import Foundation

class CacheController: CachingPlayerItemDelegate {
    
    static let sharedCacheController = CacheController()
    
    private var _numberOfSimultaneousDownloads = 3
    var numberOfSimultaneousDownloads: Int {
        get {
            return _numberOfSimultaneousDownloads
        }
        set {
            _numberOfSimultaneousDownloads = newValue
            downloadNextAudioItem()
        }
    }
    
    private var audioItemsToLoad = Queue<AudioItem>()
    private var audioItemsBeingDownloaded = [AudioItem: AudioCachingPlayerItem]()
    private var audioItemsToBeCanceled = Set<AudioItem>()
    
    // MARK: CachingPlayerItem Delegate
    
    @objc func playerItem(playerItem: CachingPlayerItem, didDownloadBytesSoFar bytesDownloaded: Int, outOf bytesExpected: Int) {
        
        let audioItem = (playerItem as! AudioCachingPlayerItem).audioItem
        let notification = NSNotification(name: "AudioItemProgressNotification", object: nil, userInfo: [
            "audioItem": audioItem,
            "bytesDownloaded": bytesDownloaded,
            "bytesExpected": bytesExpected
            ])
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }
    
    @objc func playerItem(playerItem: CachingPlayerItem, didFinishDownloadingData data: NSData) {
        
        let audioItem = (playerItem as! AudioCachingPlayerItem).audioItem
        audioItemsBeingDownloaded.removeValueForKey(audioItem)
        downloadNextAudioItem()
        
        Storage.sharedStorage.add(String(audioItem.id), object: data)
        
        let notification = NSNotification(name: "AudioItemDownloadedNotification", object: nil, userInfo: [
            "audioItem": audioItem,
            "data": data
            ])
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }
    
    // MARK:
    
    private func downloadNextAudioItem() {
        if audioItemsBeingDownloaded.count < numberOfSimultaneousDownloads {
            if let audioItem = audioItemsToLoad.dequeue() {
                
                // if audioItem is already downloaded
                if Storage.sharedStorage.objectIsCached(String(audioItem.id)) {
                    downloadNextAudioItem()
                    return
                }
                
                // if downloading was canceled
                if audioItemsToBeCanceled.contains(audioItem) {
                    audioItemsToBeCanceled.remove(audioItem)
                    downloadNextAudioItem()
                    return
                }
                
                let playerItem = AudioCachingPlayerItem(audioItem: audioItem)
                playerItem.delegate = self
            
                audioItemsBeingDownloaded[audioItem] = playerItem
                playerItem.download()
                
            }
        }
    }
    
    // adds audioItem to download queue
    func downloadAudioItem(audioItem: AudioItem) {
        audioItemsToLoad.enqueue(audioItem)
        audioItemsToBeCanceled.remove(audioItem)
        if audioItemsBeingDownloaded.count < numberOfSimultaneousDownloads {
            downloadNextAudioItem()
        }
    }
    
    func cancelDownloadingAudioItem(audioItem: AudioItem) {
        if let _ = audioItemsBeingDownloaded[audioItem] {
            audioItemsBeingDownloaded.removeValueForKey(audioItem)
        } else {
            audioItemsToBeCanceled.insert(audioItem)
        }
        let notification = NSNotification(name: AudioItemIsCanceledCachingNotification, object: nil, userInfo: [
            "audioItem": audioItem
            ])
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }
    
    func playerItemForAudioItem(audioItem: AudioItem, completionHandler: (playerItem: AudioCachingPlayerItem, cached: Bool)->()){
        // if audioItem is cached
        if Storage.sharedStorage.objectIsCached(String(audioItem.id)) {
            
            Storage.sharedStorage.object(String(audioItem.id), completion: { (data: NSData?) in
                let playerItem = AudioCachingPlayerItem(data: data!, audioItem: audioItem)
                completionHandler(playerItem: playerItem, cached: true)
            })
            
        } else {
            
            // if audioItem is being downloaded
            if let playerItem = audioItemsBeingDownloaded[audioItem] {
                completionHandler(playerItem: playerItem, cached: false)
                return
            }
            
            let playerItem = AudioCachingPlayerItem(audioItem: audioItem)
            playerItem.delegate = self
            completionHandler(playerItem: playerItem, cached: false)
            
        }
    }
    
    // MARK:
    
    private init() {}
    
}
