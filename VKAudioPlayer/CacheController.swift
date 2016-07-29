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
    
    private var audioItemsToDownoad = Queue<AudioItem>()
    private var audioItemsBeingDownloaded = [AudioItem: AudioCachingPlayerItem]()
    private var audioItemsToCancel = Set<AudioItem>()
    
    // audioItemsTotalDownloadStatus holds the invariant: audioItemsTotalDownloadStatus = audioItemsToDownload + audioItemsBeingDownloaded - audioItemsToCancel
    private var audioItemsTotalDownloadStatus = [AudioItem: Float]()
    
    // MARK:
    
    private func downloadNextAudioItem() {
        if audioItemsBeingDownloaded.count < numberOfSimultaneousDownloads {
            if let audioItem = audioItemsToDownoad.dequeue() {
                
                if audioItem.downloadStatus == AudioItemDownloadStatusCached {
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
        audioItemsToDownoad.enqueue(audioItem)
        audioItemsToCancel.remove(audioItem)
        
        let notification = NSNotification(name: CacheControllerDidUpdateDownloadStatusOfAudioItemNotification, object: nil, userInfo: [
            "audioItem": audioItem,
            "downloadStatus": 0.0
            ])
        NSNotificationCenter.defaultCenter().postNotification(notification)
        
        audioItemsTotalDownloadStatus[audioItem] = 0.0
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
        audioItemsTotalDownloadStatus.removeValueForKey(audioItem)
        let notification = NSNotification(name: CacheControllerDidUpdateDownloadStatusOfAudioItemNotification, object: nil, userInfo: [
            "audioItem": audioItem,
            "downloadStatus": downloadStatusForAudioItem(audioItem)
            ])
        NSNotificationCenter.defaultCenter().postNotification(notification)
        downloadNextAudioItem()
    }
    
    func playerItemForAudioItem(audioItem: AudioItem, completionHandler: (playerItem: AudioCachingPlayerItem, cached: Bool)->()){
        
        if audioItem.downloadStatus == AudioItemDownloadStatusCached {
            
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
    
    func downloadStatusForAudioItem(audioItem: AudioItem) -> Float {
        if let status = audioItemsTotalDownloadStatus[audioItem] {
            return status
        }
        if Storage.sharedStorage.objectIsCached(String(audioItem.id)) {
            return AudioItemDownloadStatusCached
        }
        return AudioItemDownloadStatusNotCached
    }
    
    func uncacheAudioItem(audioItem: AudioItem) {
        Storage.sharedStorage.remove(String(audioItem.id))
        let notification = NSNotification(name: CacheControllerDidUpdateDownloadStatusOfAudioItemNotification, object: nil, userInfo: [
            "audioItem": audioItem,
            "downloadStatus": AudioItemDownloadStatusNotCached
            ])
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }
    
    // MARK: CachingPlayerItem Delegate
    
    @objc func playerItem(playerItem: CachingPlayerItem, didDownloadBytesSoFar bytesDownloaded: Int, outOf bytesExpected: Int) {
        
        let audioItem = (playerItem as! AudioCachingPlayerItem).audioItem
        audioItemsTotalDownloadStatus[audioItem] = Float(Double(bytesDownloaded)/Double(bytesExpected))
        let notification = NSNotification(name: CacheControllerDidUpdateDownloadStatusOfAudioItemNotification, object: nil, userInfo: [
            "audioItem": audioItem,
            "downloadStatus": downloadStatusForAudioItem(audioItem)
            ])
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }
    
    @objc func playerItem(playerItem: CachingPlayerItem, didFinishDownloadingData data: NSData) {
        
        let audioItem = (playerItem as! AudioCachingPlayerItem).audioItem
        audioItemsBeingDownloaded.removeValueForKey(audioItem)
        audioItemsTotalDownloadStatus.removeValueForKey(audioItem)
        downloadNextAudioItem()
        
        Storage.sharedStorage.add(String(audioItem.id), object: data)
        
        let notification = NSNotification(name: CacheControllerDidUpdateDownloadStatusOfAudioItemNotification, object: nil, userInfo: [
            "audioItem": audioItem,
            "downloadStatus": AudioItemDownloadStatusCached
            ])
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }

    @objc func playerItemDidStopPlayback(playerItem: CachingPlayerItem) {
        
        let audioItem = (playerItem as! AudioCachingPlayerItem).audioItem
        downloadNextAudioItem()
        
        let notification = NSNotification(name: AudioControllerDidPauseAudioItemNotification, object: nil, userInfo: [
            "audioItem": audioItem
            ])
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }
    
    @objc func playerItemWillDeinit(playerItem: CachingPlayerItem) {
        let audioItem = (playerItem as! AudioCachingPlayerItem).audioItem
        if let _ = audioItemsTotalDownloadStatus[audioItem] {
            audioItemsTotalDownloadStatus.removeValueForKey(audioItem)
            let notification = NSNotification(name: CacheControllerDidUpdateDownloadStatusOfAudioItemNotification, object: nil, userInfo: [
                "audioItem": audioItem,
                "downloadStatus": downloadStatusForAudioItem(audioItem)
                ])
            NSNotificationCenter.defaultCenter().postNotification(notification)
        }
        
    }
    
    // MARK:
    
    private init() {}
    
}
