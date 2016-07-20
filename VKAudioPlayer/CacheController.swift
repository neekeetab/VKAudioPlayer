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
    private var audioItemsToCancel = Set<AudioItem>()
    
    // MARK: CachingPlayerItem Delegate
    
    @objc func playerItem(playerItem: CachingPlayerItem, didDownloadBytesSoFar bytesDownloaded: Int, outOf bytesExpected: Int) {
        
        let audioItem = (playerItem as! AudioCachingPlayerItem).audioItem
        let notification = NSNotification(name: CacheControllerDidUpdateDownloadingProgressOfAudioItemNotification, object: nil, userInfo: [
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
        
        let notification = NSNotification(name: CacheControllerDidCacheAudioItemNotification, object: nil, userInfo: [
            "audioItem": audioItem,
            ])
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }
    
    // MARK:
    
    private func downloadNextAudioItem() {
        if audioItemsBeingDownloaded.count < numberOfSimultaneousDownloads {
            if let audioItem = audioItemsToLoad.dequeue() {
            
                if audioItem.cached {
                    downloadNextAudioItem()
                    return
                }
                
                if audioItemsToCancel.contains(audioItem) {
                    audioItemsToCancel.remove(audioItem)
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
        audioItemsToCancel.remove(audioItem)
        if audioItemsBeingDownloaded.count < numberOfSimultaneousDownloads {
            downloadNextAudioItem()
        }
    }
    
    func cancelDownloadingAudioItem(audioItem: AudioItem) {
        if let _ = audioItemsBeingDownloaded[audioItem] {
            audioItemsBeingDownloaded.removeValueForKey(audioItem)
        } else {
            audioItemsToCancel.insert(audioItem)
        }
        let notification = NSNotification(name: CacheControllerDidCancelDownloadingAudioItemNotification, object: nil, userInfo: [
            "audioItem": audioItem
            ])
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }
    
    func playerItemForAudioItem(audioItem: AudioItem, completionHandler: (playerItem: AudioCachingPlayerItem, cached: Bool)->()){
        
        if audioItem.cached {
            
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
    
    func uncacheAudioItem(audioItem: AudioItem) {
        Storage.sharedStorage.remove(String(audioItem.id))
    }
    
    // MARK:
    
    private init() {}
    
}
