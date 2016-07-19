//
//  AudioController.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 7/19/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import Foundation

enum AudioControllerRepeatMode {
    case Dont
    case One
    case All
}

class AudioController {
    
    static let sharedAudioController = AudioController()
    
    private var _currentAudioItem: AudioItem?
    var currentAudioItem: AudioItem? {
        return _currentAudioItem
    }
    
    private var _audioContext: AudioContext?
    var audioContext: AudioContext? {
        get {
            return _audioContext
        }
        set {
            _audioContext = newValue
        }
    }
    
    var _repeatMode: AudioControllerRepeatMode = .Dont
    var repeatMode: AudioControllerRepeatMode {
        get {
            return _repeatMode
        }
        set {
            _repeatMode = newValue
        }
    }
    
    func playAudioItem(audioItem: AudioItem) {
        
    }
    
    func resume() {
        
    }
    
    func pause() {
        
    }
    
    // TODO:  next, prev
    
    private init() {}
    
}
