//
//  AudioPlayerViewController+ButtonsTapHandling.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 7/29/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import Foundation

extension AudioPlayerViewController {
    
    func playPauseButtonTapHandler() {
        
        if AudioController.sharedAudioController.paused {
            AudioController.sharedAudioController.resume()
        } else {
            AudioController.sharedAudioController.pause()
        }
        
    }
    
    func prevButtonTapHandler() {
        
    }
    
    func nextButtonTapHandler() {
        
    }
    
    func downloadCancelButtonTapHandler() {
        
    }
    
}
