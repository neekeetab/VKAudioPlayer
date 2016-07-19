//
//  AudioController.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 7/19/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import Foundation
import AVFoundation

enum AudioControllerRepeatMode {
    case Dont
    case One
    case All
}

class AudioController {
    
    static let sharedAudioController = AudioController()
    
    private var player: AVPlayer?
    
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
            player = nil
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
    
    func playAudioItemFromContext(audioContext: AudioContext, atIndext index: Int) {
        self.audioContext = audioContext
        
        let audioItem = audioContext.userAudio[index]
        PlayerItemFactory.sharedPlayerItemFactory.playerItemForAudioItem(audioItem, completionHandler: { playerItem, cached in
            self.player = AVPlayer(playerItem: playerItem)
            self.player?.play()
        })
    }
    
    func resume() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    // TODO:  next, prev
    
    private init() {}
    
}
