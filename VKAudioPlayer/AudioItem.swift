//
//  AudioItem.swift
//  AudioPlayer
//
//  Created by Nikita Belousov on 5/24/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import Foundation
import VK_ios_sdk

// representative for VK audio object
class AudioItem: NSObject {
    
    var id = 0
    var ownerId = 0
    var artist = ""
    var title = ""
    var url = NSURL()
    var duration = 0
    
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