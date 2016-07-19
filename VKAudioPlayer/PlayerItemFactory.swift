//
//  PlayerItemFactory.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 7/19/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import Foundation

class PlayerItemFactory {
    
    let sharedPlayerItemFactory = PlayerItemFactory()
    
    func playerItemForAudioItem(audioItem: AudioItem, completionHandler: (playerItem: AudioCachingPlayerItem, cached: Bool)->()){
        // if audioItem is cached
        if Storage.sharedStorage.objectIsCached(String(audioItem.id)) {
            Storage.sharedStorage.object(String(audioItem.id), completion: { (data: NSData?) in
                let playerItem = AudioCachingPlayerItem(data: data!, mimeType: "audio/mpeg", fileExtension: "mp3")
                playerItem.audioItem = audioItem
                completionHandler(playerItem: playerItem, cached: true)
            })
        } else {
            // if item is being downloaded
            if let playerItem = Downloader.sharedDownloader.playerItemForAudioItem(audioItem) {
                
            }

        }
    }
    
    private init() {}
    
}