//
//  AudioItem.swift
//  AudioPlayer
//
//  Created by Nikita Belousov on 5/24/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import Foundation
import VK_ios_sdk

let AudioItemDownloadStatusCached = Float(2.0)
let AudioItemDownloadStatusNotCached = Float(-1.0)

// representative for VK audio object
class AudioItem: NSObject {
    
    var id = 0
    var ownerId = 0
    var artist = ""
    var title = ""
    var url = NSURL()
    var duration = 0

    var downloadStatus: Float {
        return CacheController.sharedCacheController.downloadStatusForAudioItem(self)
    }
    var cached: Bool {
        return Storage.sharedStorage.objectIsCached(String(self.id))
    }
    var playing: Bool {
        return AudioController.sharedAudioController.currentAudioItem == self
    }
    
    static func audioItemFromVKResponseItem(responseItem: [String: AnyObject]) -> AudioItem {
        
        let audioItem = AudioItem()
        audioItem.id = responseItem["id"] as! Int
        audioItem.ownerId = responseItem["owner_id"] as! Int
        audioItem.artist = responseItem["artist"] as! String
        audioItem.title = responseItem["title"] as! String
        audioItem.url =  NSURL(string: responseItem["url"] as! String)!
        audioItem.duration = responseItem["duration"] as! Int
        
        return  audioItem
        
    }
    
}

func ==(lhs: AudioItem, rhs: AudioItem) -> Bool {
    return lhs.id == rhs.id
}

func !=(lhs: AudioItem, rhs: AudioItem) -> Bool {
    return !(lhs == rhs)
}

func ==(lhs: AudioItem?, rhs: AudioItem?) -> Bool {
    return (!(lhs != nil) && !(rhs != nil)) // lhs == nil && rhs == nil
        || (lhs != nil && rhs != nil && lhs!.id == rhs!.id)
}