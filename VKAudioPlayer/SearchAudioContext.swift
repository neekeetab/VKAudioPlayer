//
//  SearchAudioContext.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 5/24/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import Foundation
import VK_ios_sdk

class SearchAudioContext: AudioContext {
    
    var searchString: String!
    var block: ((suc: Bool) -> ())!
    
    override func loadNextPortion(completionBlock block: (suc: Bool) -> ()) {
        
        let searchAudioRequest = VKRequest.searchAudioRequest(searchString, offset: numberOfLoadedPortions * elementsPerRequest)
        searchAudioRequest.completeBlock = { response in
            let count = self.usersAudio.count + self.globalAudio.count
            self.usersAudio += response.usersAudio()
            self.globalAudio += response.usersAudio()
            if count != self.usersAudio.count + self.globalAudio.count {
                self.numberOfLoadedPortions += 1
            }
            self.block(suc: true)
        }
        searchAudioRequest.errorBlock = { error in
            print(error)
            self.block(suc: false)
        }
        
        VKAudioRequestExecutor.sharedExecutor.executeRequest(searchAudioRequest)
        
    }
    
    func load(searchString: String, completionBlock block: (suc: Bool) -> ()) {
        
    }
    
    override func load(completionBlock block: (suc: Bool) -> ()) {

    }
    
    init(searchString: String, completionBlock block: (suc: Bool) -> ()) {
        self.searchString = searchString
        self.block = block
        super.init()
    }
    
    // prevent from instantiation with empty init
    private override init() {}
    
}