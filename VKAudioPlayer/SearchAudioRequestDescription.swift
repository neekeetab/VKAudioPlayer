//
//  SearchAudioRequestDescription.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 5/26/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import Foundation
import VK_ios_sdk

class SearchAudioRequestDescription: AudioRequestDescription {
    
    let searchString: String
    
    override func request(offset: Int) -> VKRequest {
        return VKRequest.searchAudioRequest(searchString, offset: offset)
    }
    
    init(searchString: String) {
        self.searchString = searchString
    }
    
}