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

enum AudioContextSection {
    case UserAudio
    case GlobalAudio
}

class AudioController {
    
    static let sharedAudioController = AudioController()
    
    private(set) var player = AVPlayer()
    private(set) var indexOfcurrentAudioItem: Int?
    private(set) var audioContext: AudioContext?
    private(set) var audioContextSection: AudioContextSection?
    
    var currentAudioItem: AudioItem? {
        return audioItemForAudioContextSection(audioContextSection, index: indexOfcurrentAudioItem)
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
    
    func audioItemForAudioContextSection(audioContextSection: AudioContextSection?, index: Int?) -> AudioItem? {
        if index == nil {
            return nil
        }
        if audioContextSection == .GlobalAudio {
            return audioContext?.globalAudio[index!]
        } else if audioContextSection == .UserAudio {
            return audioContext?.userAudio[index!]
        }
        return nil
    }
    
    func playAudioItemFromContext(audioContext: AudioContext, audioContextSection: AudioContextSection, index: Int) {
        self.audioContext = audioContext
        self.audioContextSection = audioContextSection
        self.indexOfcurrentAudioItem = index
    
        let audioItem = audioItemForAudioContextSection(audioContextSection, index: index)!
        CacheController.sharedCacheController.playerItemForAudioItem(audioItem, completionHandler: { playerItem, cached in
            
//            self.player = AVPlayer(playerItem: playerItem)
//            self.player.play()
            
            dispatch_async(dispatch_get_main_queue(), {
                self.player.replaceCurrentItemWithPlayerItem(playerItem)
                self.player.seekToTime(CMTime(seconds: 0, preferredTimescale: 1))
                self.player.play()
            })
            
            let notification = NSNotification(name: AudioControllerDidStartPlayingAudioItemNotification, object: nil, userInfo: [
                "audioItem": playerItem.audioItem
                ])
            NSNotificationCenter.defaultCenter().postNotification(notification)
        })
    }
    
    func resume() {
        player.play()
        if let audioItem = currentAudioItem {
            let notification = NSNotification(name: AudioControllerDidResumeAudioItemNotification, object: nil, userInfo: [
                "audioItem": audioItem
                ])
            NSNotificationCenter.defaultCenter().postNotification(notification)
        }
    }

    func pause() {
        player.pause()
        if let audioItem = currentAudioItem {
            let notification = NSNotification(name: AudioControllerDidPauseAudioItemNotification, object: nil, userInfo: [
                "audioItem": audioItem
                ])
            NSNotificationCenter.defaultCenter().postNotification(notification)
        }
    }
    
    // TODO:  next, prev
    
    private init() {}
    
}
