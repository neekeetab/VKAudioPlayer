//
//  VKAudioItem.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 5/24/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import Foundation
import VK_ios_sdk

// representative for VK audio object
class VKAudioItem {
    
    var id = 0
    var ownerId = 0
    var artist = ""
    var title = ""
    var url = NSURL()
    
    static func audioItemFromVKResponseItem(responseItem: [String: AnyObject]) -> VKAudioItem {
        
        let audioItem = VKAudioItem()
        audioItem.id = responseItem["id"] as! Int
        audioItem.ownerId = responseItem["owner_id"] as! Int
        audioItem.artist = responseItem["artist"] as! String
        audioItem.title = responseItem["title"] as! String
        audioItem.url =  NSURL(string: responseItem["url"] as! String)!
        
        return  audioItem
        
    }
    
}