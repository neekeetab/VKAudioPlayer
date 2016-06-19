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
    
    var audioRequestDescription: AudioRequestDescription?
    var block: ((suc: Bool, usersAudio: [VKAudioItem], globalAudio: [VKAudioItem]) -> ())?
    
    var usersAudio = [VKAudioItem]()
    var globalAudio = [VKAudioItem]()
    var numberOfLoadedPortions = 0
    var canceled = false
    //    var fetchedAudioIDs = Set<Int>()
    
    // Cancel requests. This is useful in case when some request is performing but at the same time we decide to switch context.
    // Without calling cancel() we would end up with old block running on new context
    func cancel() {
        canceled = true
    }
    
    // true if context is performing request
    func busy() -> Bool {
        return VKAudioRequestExecutor.sharedExecutor.operationQueue.operationCount > 0
    }
    
    func loadNextPortion() {
        
        canceled = false
        if block == nil {
            fatalError("Completion block hasn't been provided")
        }
        if audioRequestDescription == nil {
            fatalError("Audio request description hasn't been provided")
        }
        
        let audioRequest = audioRequestDescription!.request(numberOfLoadedPortions * elementsPerRequest)
        audioRequest.completeBlock = { response in
            if !self.canceled {
            
                let usersAudio = response.usersAudio()
                let globalAudio = response.globalAudio()
            
                self.usersAudio += usersAudio
                self.globalAudio += globalAudio
            
                if usersAudio.count + globalAudio.count > 0 {
                    self.numberOfLoadedPortions += 1
                }
                self.block!(suc: true, usersAudio: usersAudio, globalAudio: globalAudio)
            }
        }
        audioRequest.errorBlock = { error in
            print(error)
            self.block!(suc: false, usersAudio: [], globalAudio: [])
        }
        audioRequest.requestTimeout = 3
        audioRequest.attempts = 3
        
        VKAudioRequestExecutor.sharedExecutor.executeRequest(audioRequest)
        
    }
    
    init(audioRequestDescription: AudioRequestDescription, completionBlock block: (suc: Bool, usersAudio: [VKAudioItem], globalAudio: [VKAudioItem]) -> ()) {
        self.audioRequestDescription = audioRequestDescription
        self.block = block
    }
    
    init() {}
    
}