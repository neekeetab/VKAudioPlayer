//
//  VKAudioResponse.swift
//  VKAudioPlayer
//
//  Created by Nikitab Belousov on 5/24/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import Foundation
import VK_ios_sdk

extension VKResponse {
    
    // WARNING: call of further methods on non-audio responses gives unexpected results!
    
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
    func userAudios() -> [VKAudioItem] {
        
        let items = (self.json as! [String: AnyObject])["items"] as! [[String: AnyObject]]
        var userAudios = [VKAudioItem]()
        for i in items {
            userAudios.append(VKAudioItem.audioItemFromVKResponseItem(i))
        }
    
        return userAudios
        
    }
    
    // audios that aren't owned by user
    func globalAudios() -> [VKAudioItem] {
        
        let items = (self.json as! [String: AnyObject])["items"] as! [[String: AnyObject]]
        var globalAudios = [VKAudioItem]()
        for i in items {
           globalAudios.append(VKAudioItem.audioItemFromVKResponseItem(i))
        }
        
        return globalAudios
        
    }

    
}