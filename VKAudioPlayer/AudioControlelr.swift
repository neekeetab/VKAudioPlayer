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
    private(set) var indexOfCurrentAudioItem: Int?
    private(set) var audioContext: AudioContext?
    private(set) var audioContextSection: AudioContextSection?
    private(set) var playedToEnd: Bool = false
    
    
    var currentAudioItem: AudioItem? {
        return audioItemForAudioContext(audioContext, audioContextSection: audioContextSection, index: indexOfCurrentAudioItem)
    }
    
    var _repeatMode: AudioControllerRepeatMode = .All
    var repeatMode: AudioControllerRepeatMode {
        get {
            return _repeatMode
        }
        set {
            _repeatMode = newValue
        }
    }
    
    func audioItemForAudioContext(audioContext: AudioContext?, audioContextSection: AudioContextSection?, index: Int?) -> AudioItem? {
        if audioContextSection == nil || index == nil || audioContext == nil || index! < 0{
            return nil
        }
        if audioContextSection == .GlobalAudio {
            if index! >= audioContext!.globalAudio.count {
                return nil
            }
            return audioContext!.globalAudio[index!]
        } else if audioContextSection == .UserAudio {
            if index! >= audioContext!.userAudio.count {
                return nil
            }
            return audioContext!.userAudio[index!]
        }
        return nil
    }
    
    func playAudioItemFromContext(audioContext: AudioContext?, audioContextSection: AudioContextSection?, index: Int?) {
        
        if let audioItem = audioItemForAudioContext(audioContext, audioContextSection: audioContextSection, index: index) {
            
            if audioItem.url == nil && audioItem.downloadStatus != AudioItemDownloadStatusCached {
                return
            }
            
            playedToEnd = false
            
            self.audioContext = audioContext
            self.audioContextSection = audioContextSection
            self.indexOfCurrentAudioItem = index
            
            // --------------------------------------------

            let notification = NSNotification(name: AudioContorllerWillStartPlayingAudioItemNotification, object: nil, userInfo: [
                "audioItem": audioItem
                ])
            NSNotificationCenter.defaultCenter().postNotification(notification)
            
            CacheController.sharedCacheController.playerItemForAudioItem(audioItem, completionHandler: { playerItem, cached in
                
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
    }
    
    var paused: Bool {
        return !((player.rate != 0) && (player.error == nil))
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
    
    func replay() {
        playAudioItemFromContext(audioContext, audioContextSection: audioContextSection, index: indexOfCurrentAudioItem)
    }
    
    func next() {
        if indexOfCurrentAudioItem == nil || audioContextSection == nil || audioContext == nil {
            return
        }
        if audioItemForAudioContext(audioContext, audioContextSection: audioContextSection, index: indexOfCurrentAudioItem! + 1) != nil {
            indexOfCurrentAudioItem! += 1
        } else {
            indexOfCurrentAudioItem = 0
        }
        playAudioItemFromContext(audioContext, audioContextSection: audioContextSection, index: indexOfCurrentAudioItem)
    }
    
    func prev() {
        if indexOfCurrentAudioItem == nil || audioContextSection == nil || audioContext == nil {
            return
        }
        if audioItemForAudioContext(audioContext, audioContextSection: audioContextSection, index: indexOfCurrentAudioItem! - 1) != nil {
            indexOfCurrentAudioItem! -= 1
        } else {
            switch audioContextSection! {
            case .GlobalAudio:
                indexOfCurrentAudioItem = audioContext!.globalAudio.count - 1
                break
                
            case .UserAudio:
                indexOfCurrentAudioItem = audioContext!.userAudio.count - 1
                break
            }
        }
        playAudioItemFromContext(audioContext, audioContextSection: audioContextSection, index: indexOfCurrentAudioItem)
    }
    
    // MARK: Notifications handling
    
    @objc private func playerItemDidPlayToEndNotificationHandler(notification: NSNotification) {
        
        playedToEnd = true
        
        switch repeatMode {
        case .Dont:
            let notification = NSNotification(name: AudioControllerDidPlayAudioItemToEndNotification, object: nil, userInfo: [
                "audioItem": currentAudioItem!
                ])
            NSNotificationCenter.defaultCenter().postNotification(notification)
            break
            
        case .One:
            replay()
            break
            
        case .All:
            next()
            break
        }
        
    }
    
    // MARK:
    
    private init() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playerItemDidPlayToEndNotificationHandler), name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        
    }
    
}
