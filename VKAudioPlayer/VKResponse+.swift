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
    
    // all audio
    func audio() -> [AudioItem] {
        
        let items = (self.json as! [String: AnyObject])["items"] as! [[String: AnyObject]]
        var audio = [AudioItem]()
        for i in items {
            audio.append(AudioItem.audioItemFromVKResponseItem(i))
        }
        
        return audio
        
    }
    
    // audio owned by user
    func userAudio() -> [AudioItem] {
        
        let items = (self.json as! [String: AnyObject])["items"] as! [[String: AnyObject]]
        var userAudio = [AudioItem]()
        let userId = Int(VKSdk.accessToken().userId)!
        for i in items {
            let audioItem = AudioItem.audioItemFromVKResponseItem(i)
            if audioItem.ownerId == userId {
                userAudio.append(audioItem)
            }
        }
    
        return userAudio
        
    }
    
    // audio that aren't owned by user
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
    // used for audio.add request
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
    
    // number of audio items expected
    func count() -> Int {
        return (self.json as! [String: AnyObject])["count"] as! Int
    }
    
}