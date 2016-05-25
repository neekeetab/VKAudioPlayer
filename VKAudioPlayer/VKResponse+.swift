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
        for i in items {
            usersAudio.append(VKAudioItem.audioItemFromVKResponseItem(i))
        }
    
        return usersAudio
        
    }
    
    // audios that aren't owned by user
    func globalAudio() -> [VKAudioItem] {
        
        let items = (self.json as! [String: AnyObject])["items"] as! [[String: AnyObject]]
        var globalAudio = [VKAudioItem]()
        for i in items {
           globalAudio.append(VKAudioItem.audioItemFromVKResponseItem(i))
        }
        
        return globalAudio
        
    }
    
}