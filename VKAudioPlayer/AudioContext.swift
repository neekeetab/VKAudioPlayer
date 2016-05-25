//
//  AudioContext.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 5/24/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import Foundation
import VK_ios_sdk

// think of it as an abstract class
class AudioContext {
    
    var usersAudio = [VKAudioItem]()
    var globalAudio = [VKAudioItem]()
//    var fetchedAudioIDs = Set<Int>()
    var numberOfLoadedPortions = 0
    
    func loadNextPortion(completionBlock block: (suc: Bool) -> ()) {
        fatalError("Not implemented")
    }
    
    func load(completionBlock block: (suc: Bool) -> ()) {
        fatalError("Not implemented")
    }
    
    init() {}
    
}

// TODO: CoreData requests