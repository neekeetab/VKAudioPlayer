//
//  VKCachingPlayerItem.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 7/15/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import Foundation
import Cache

class VKCachingPlayerItem: CachingPlayerItem {
    
    var audioItem: VKAudioItem?
    var cache: HybridCache?
    
//    init(audioItem: VKAudioItem, cache: HybridCache) {
//        super.init(url: NSURL())
//    }
    
}