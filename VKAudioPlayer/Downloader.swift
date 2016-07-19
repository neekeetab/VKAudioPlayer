//
//  Downloader.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 7/19/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import Foundation

class Downloader: CachingPlayerItemDelegate {
    
    let sharedDownloader = Downloader()
    var numberOfSimultaneousDownloads = 3
    
    private var audioItemsToLoad = Queue<AudioItem>()
    private var audioItemsBeingDownloaded = [AudioItem: CachingPlayerItem]()
    
    // MARK: CachingPlayerItem Delegate
    
    @objc func playerItem(playerItem: CachingPlayerItem, didDownloadBytesSoFar bytesDownloaded: Int, outOf bytesExpected: Int) {
        let notification = NSNotification(name: "AudioItemProgressNotification", object: nil, userInfo: [
            "audioItem": (playerItem as! AudioCachingPlayerItem).audioItem!,
            "bytesDownloaded": bytesDownloaded,
            "bytesExpected": bytesExpected
            ])
        NSNotificationCenter.defaultCenter().postNotification(notification)
        // Notification
    }
    
    @objc func playerItem(playerItem: CachingPlayerItem, didFinishDownloadingData data: NSData) {
        let notification = NSNotification(name: "AudioItemDownloadedNotification", object: nil, userInfo: [
            "audioItem": (playerItem as! AudioCachingPlayerItem).audioItem!,
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
                    return
                }
                
                let playerItem = CachingPlayerItem(url: audioItem.url)
                playerItem.delegate = self
            
                audioItemsBeingDownloaded[audioItem] = playerItem
                playerItem.download()
                
            }
        }
    }
    
    // adds audioItem to download queue
    func downloadAudioItem(audioItem: AudioItem) {
        audioItemsToLoad.enqueue(audioItem)
        if audioItemsBeingDownloaded.count < numberOfSimultaneousDownloads {
            downloadNextAudioItem()
        }
    }
    
    func cancelDownloadAudioItem(audioItem: AudioItem) {
        //
    }
    
    func playerItemForAudioItem(audioItem: AudioItem) -> CachingPlayerItem? {
        return audioItemsBeingDownloaded[audioItem]
    }
    
    // MARK: Notificatoins handling
    
    @objc func audioItemDownloadedNotificationHandler(notification: NSNotification) {
        if let audioItem = notification.object as? AudioItem {
            audioItemsBeingDownloaded.removeValueForKey(audioItem)
            downloadNextAudioItem()
        }
    }
    
    // MARK:
    
    private init() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(audioItemDownloadedNotificationHandler), name: "AudioItemDownloadedNotification", object: nil)
    }
    
}
