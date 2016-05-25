//
//  UsersAudioRequestDescription.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 5/26/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import Foundation
import VK_ios_sdk

class UsersAudioRequestDescription: AudioRequestDescription {

    override func request(offset: Int) -> VKRequest {
        return VKRequest.usersAudioRequest(offset)
    }
    
}