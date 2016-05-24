//
//  Model.swift
//  VKAudioPlayer
//
//  Created by Nikitab Belousov on 5/24/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import Foundation

class Model {
    
    var usersAudio: [VKAudioItem]!
    var globalAudio: [VKAudioItem]!
    var fetchedAudioIDs: Set<Int>!
    var numberOfPortions: Int!
    
    func loadNextPortion(withCompletionBlock block: (suc: Bool) -> ()) {
        fatalError("Not implemented")
    }
    
    func reload(withCompletionBlock block: (suc: Bool) -> ()) {
        fatalError("Not implemented")
    }
    
    static func searchModel(withSearchString string: String) -> Model {
        
        let searchModel = Model()
        
        
        return searchModel
        
    }
    
    static func usersModel() -> Model {
        
        let userModel = Model()
        
        return userModel
        
    }
    
}

// TODO: CoreData requests