//
//  AudioModel.swift
//  VKAudioPlayer
//
//  Created by Nikitab Belousov on 5/24/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import Foundation

// Think of it as an abstract class
class AudioModel {
    
    var userAudios: [VKAudioItem]!
    var globalAudios: [VKAudioItem]!
    var fetchedAudioIDs: Set<Int>!
    
    func loadNextPortion(withCompletionBlock block: () -> ()) {
        fatalError("Not implemented")
    }
    
    func reload(withCompletionBlock block: () -> ()) {
        fatalError("Not implemented")
    }
    
}