//
//  Utils.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 5/24/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import Foundation

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

private class NSTimerActor {
    var block: () -> ()
    
    init(block: () -> ()) {
        self.block = block
    }
    
    dynamic func fire() {
        block()
    }
}

extension NSTimer {
    convenience init(_ intervalFromNow: NSTimeInterval, block: () -> ()) {
        let actor = NSTimerActor(block: block)
        self.init(timeInterval: intervalFromNow, target: actor, selector: #selector(fire), userInfo: nil, repeats: false)
    }
    
    convenience init(every interval: NSTimeInterval, block: () -> ()) {
        let actor = NSTimerActor(block: block)
        self.init(timeInterval: interval, target: actor, selector: #selector(fire), userInfo: nil, repeats: true)
    }

}