//
//  UsersAudioContext.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 5/24/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import Foundation

enum UsersAudioContextScope {
    case Local
    case Default
}

class UsersAudioContext: AudioContext {
 
    private(set) var scope: UsersAudioContextScope!
    var block: ((suc: Bool) -> ())!
    
    override func loadNextPortion(completionBlock block: (suc: Bool) -> ()) {
        
    }
    
    override func load(completionBlock block: (suc: Bool) -> ()) {
        //        let audioRequest
    }
    
    init(scope: UsersAudioContextScope, completionBlock block: (suc: Bool) -> ()) {
        
        self.scope = scope
        self.block = block
        super.init()
    }
    
    // prevent from instantiation with empty init
    private override init() {}
    
}

