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
    func audios() -> [AudioItem] {
        
        let items = (self.json as! [String: AnyObject])["items"] as! [[String: AnyObject]]
        var audios = [AudioItem]()
        for i in items {
            audios.append(AudioItem.audioItemFromVKResponseItem(i))
        }
        
        return audios
        
    }
    
    // audios owned by user
    func usersAudio() -> [AudioItem] {
        
        let items = (self.json as! [String: AnyObject])["items"] as! [[String: AnyObject]]
        var usersAudio = [AudioItem]()
        let userId = Int(VKSdk.accessToken().userId)!
        for i in items {
            let audioItem = AudioItem.audioItemFromVKResponseItem(i)
            if audioItem.ownerId == userId {
                usersAudio.append(audioItem)
            }
        }
    
        return usersAudio
        
    }
    
    // audios that aren't owned by user
    func globalAudio() -> [AudioItem] {
        
        let items = (self.json as! [String: AnyObject])["items"] as! [[String: AnyObject]]
        var globalAudio = [AudioItem]()
        let userId = Int(VKSdk.accessToken().userId)!
        for i in items {
            let audioItem = AudioItem.audioItemFromVKResponseItem(i)
            if audioItem.ownerId != userId {
                globalAudio.append(audioItem)
            }
        }
        
        return globalAudio
        
    }
    
    // returns true if 1, else -- false
    func success() -> Bool {
        if let r = self.json as? Int {
            return r == 1
        }
        return false
    }
    
    // id of added audio
    func audioId() -> Int {
        return self.json as! Int
    }
    
}