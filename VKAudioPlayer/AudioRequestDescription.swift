//
//  AudioRequestDescription.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 5/26/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import Foundation
import VK_ios_sdk

// abstract
class AudioRequestDescription {
    
    static func userAudioRequestDescription() -> UserAudioRequestDescription {
        return UserAudioRequestDescription()
    }
    
    static func searchAudioRequestDescription(searchString: String) -> SearchAudioRequestDescription {
        return SearchAudioRequestDescription(searchString: searchString)
    }
    
    func request(offset: Int) -> VKRequest {
        fatalError("Not implemented")
    }
    
}