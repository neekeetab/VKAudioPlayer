//
//  VKResponse+.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 5/24/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import Foundation
import VK_ios_sdk

extension VKResponse {
    
    // all audios
    func audios() -> [VKAudioItem] {
        
        let items = (self.json as! [String: AnyObject])["items"] as! [[String: AnyObject]]
        var audios = [VKAudioItem]()
        for i in items {
            audios.append(VKAudioItem.audioItemFromVKResponseItem(i))
            
        }
        
        return audios
        
    }
    
    // audios owned by user
    func usersAudio() -> [VKAudioItem] {
        
        let items = (self.json as! [String: AnyObject])["items"] as! [[String: AnyObject]]
        var usersAudio = [VKAudioItem]()
        let userId = Int(VKSdk.accessToken().userId)!
        for i in items {
            let audioItem = VKAudioItem.audioItemFromVKResponseItem(i)
            if audioItem.ownerId == userId {
                usersAudio.append(audioItem)
            }
        }
    
        return usersAudio
        
    }
    
    // audios that aren't owned by user
    func globalAudio() -> [VKAudioItem] {
        
        let items = (self.json as! [String: AnyObject])["items"] as! [[String: AnyObject]]
        var globalAudio = [VKAudioItem]()
        let userId = Int(VKSdk.accessToken().userId)!
        for i in items {
            let audioItem = VKAudioItem.audioItemFromVKResponseItem(i)
            if audioItem.ownerId != userId {
                globalAudio.append(audioItem)
            }
        }
        
        return globalAudio
        
    }
    
}