//
//  SearchAudioContext.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 5/24/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import Foundation

class SearchAudioContext: AudioContext {
    
    var searchString: String!
    var block: ((suc: Bool) -> ())!
    
    override func loadNextPortion(withCompletionBlock block: (suc: Bool) -> ()) {
        
    }
    
    override func load(withCompletionBlock block: (suc: Bool) -> ()) {
//        let audioRequest
    }
    
    init(searchString: String, completionBlock block: (suc: Bool) -> ()) {
        self.searchString = searchString
        self.block = block
        super.init()
    }
    
    // prevent from instantiation with empty init
    private override init() {}
    
}