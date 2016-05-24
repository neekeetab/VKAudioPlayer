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
    
    // returns parsed json that contains only user's audios
    func userAudios() -> [[String: AnyObject]] {
        
        let items = (self.json as! [String: AnyObject])["items"] as! [[String: AnyObject]]
        var userAudios = [[String: AnyObject]]()
        for i in items {
            if i["owner_id"] as? Int == Int(VKSdk.accessToken().userId) {
                userAudios.append(i)
            }
        }
        return userAudios
        
    }
    
    // returns parsed json that contains only of global audios
    func globalAudios() -> [[String: AnyObject]] {
        
        let items = (self.json as! [String: AnyObject])["items"] as! [[String: AnyObject]]
        var globalAudios = [[String: AnyObject]]()
        for i in items {
            if i["owner_id"] as? Int != Int(VKSdk.accessToken().userId) {
                globalAudios.append(i)
            }
        }
        return globalAudios
        
    }

    
}