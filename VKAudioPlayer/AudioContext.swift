//
//  AudioContext.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 5/24/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import Foundation
import VK_ios_sdk

protocol AudioContextDelegate: class {
    
    func audioContextDidLoadNewPortionOfData(audioContext: AudioContext)
    func audioContextDidFailToLoadNewPortionOfData(audioContext: AudioContext)
    
}

class AudioContext {
    
    var audioRequestDescription: AudioRequestDescription!
    weak var delegate: AudioContextDelegate?
    
    var audioItemsExpected: Int?
    
    var userAudio = [AudioItem]()
    var globalAudio = [AudioItem]()
    var numberOfLoadedPortions = 0
    var canceled = false
    
    // Cancel requests. This is useful in the case when some request is being performed but at the same time we decide to switch to new context.
    // Without calling cancel() we would end up with old block running when new context already in use
    func cancel() {
        canceled = true
    }
    
    // true if context is performing request
    func busy() -> Bool {
        return VKAudioRequestExecutor.sharedExecutor.operationQueue.operationCount > 0
    }
    
    func loadNextPortion() {
        loadNextPortion(nil)
    }
    
    func loadNextPortion(completionHandler: ((suc: Bool) -> ())?) {
        
        canceled = false
        
        let audioRequest = audioRequestDescription!.request(numberOfLoadedPortions * elementsPerRequest)
        audioRequest.completeBlock = { response in
            if !self.canceled {
                
                self.audioItemsExpected = response.count()
            
                let userAudio = response.userAudio()
                let globalAudio = response.globalAudio()
            
                self.userAudio += userAudio
                self.globalAudio += globalAudio
            
                if userAudio.count + globalAudio.count > 0 {
                    self.numberOfLoadedPortions += 1
                }
                
                self.delegate?.audioContextDidLoadNewPortionOfData(self)
                completionHandler?(suc: true)
                
            }
        }
        audioRequest.errorBlock = { error in
            print(error)
            self.delegate?.audioContextDidFailToLoadNewPortionOfData(self)
            completionHandler?(suc: false)

        }
        audioRequest.requestTimeout = 3
        audioRequest.attempts = 3
        
        VKAudioRequestExecutor.sharedExecutor.executeRequest(audioRequest)
        
    }
    
    func hasMoreToLoad() -> Bool {
        return numberOfLoadedPortions * elementsPerRequest >= audioItemsExpected
    }
    
    init(audioRequestDescription: AudioRequestDescription) {
        self.audioRequestDescription = audioRequestDescription
    }
    
    init() {}
    
}