//
//  AudioCachingPlayerItem.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 7/15/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import Foundation

class AudioCachingPlayerItem: CachingPlayerItem {
    
    var audioItem: AudioItem
    
    init(audioItem: AudioItem) {
        self.audioItem = audioItem
        super.init(url: audioItem.url)
    }
    
    init(data: NSData, audioItem: AudioItem) {
        self.audioItem = audioItem
        super.init(data: data, mimeType:"audio/mpeg", fileExtension: "mp3")
    }
    
//    deinit {
//        let notification = NSNotification(name: AudioCachingPlayerItemWillDeinitNotificatoin, object: nil, userInfo: [
//            "audioItem": audioItem
//            ])
//        NSNotificationCenter.defaultCenter().postNotification(notification)
//    }
//    
}