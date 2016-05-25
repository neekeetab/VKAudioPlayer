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
    
    let audioRequestDescription: AudioRequestDescription
    let block: (suc: Bool) -> ()
    
    var usersAudio = [VKAudioItem]()
    var globalAudio = [VKAudioItem]()
    var numberOfLoadedPortions = 0
    //    var fetchedAudioIDs = Set<Int>()
    
    func loadNextPortion() {
        
        let audioRequest = audioRequestDescription.request(numberOfLoadedPortions * elementsPerRequest)
        audioRequest.completeBlock = { response in
            let count = self.usersAudio.count + self.globalAudio.count
            self.usersAudio += response.usersAudio()
            self.globalAudio += response.usersAudio()
            if count != self.usersAudio.count + self.globalAudio.count {
                self.numberOfLoadedPortions += 1
            }
            self.block(suc: true)
        }
        audioRequest.errorBlock = { error in
            print(error)
            self.block(suc: false)
        }
        
        VKAudioRequestExecutor.sharedExecutor.executeRequest(audioRequest)
        
    }
    
    init(audioRequestDescription: AudioRequestDescription, completionBlock block: (suc: Bool) -> ()) {
        self.audioRequestDescription = audioRequestDescription
        self.block = block
    }
    
}

// TODO: CoreData requests