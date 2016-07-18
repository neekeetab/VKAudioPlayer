//
//  VKRequest+.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 5/24/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import Foundation
import VK_ios_sdk

extension VKRequest {
    
    static func searchAudioRequest(searchString: String, offset: Int) -> VKRequest {
        return VKApi.requestWithMethod("audio.search", andParameters: [
            "q": searchString,
            "auto_complete": 1,
            "search_own": 1,
            "count": elementsPerRequest,
            "offset": offset
            ])
    }
    
    static func usersAudioRequest(offset: Int) -> VKRequest {
        return VKApi.requestWithMethod("audio.get", andParameters: [
            "count": elementsPerRequest,
            "offset": offset,
            "need_user": 0
            ])
    }
    
    static func addAudioRequest(audioItem: AudioItem) -> VKRequest {
        return VKApi.requestWithMethod("audio.add", andParameters: [
            "audio_id": audioItem.id,
            "owner_id": audioItem.ownerId
            ])
    }
    
    static func deleteAudioRequest(audioItem: AudioItem) -> VKRequest {
        return VKApi.requestWithMethod("audio.delete", andParameters: [
            "audio_id": audioItem.id,
            "owner_id": audioItem.ownerId
            ])
    }
    
}