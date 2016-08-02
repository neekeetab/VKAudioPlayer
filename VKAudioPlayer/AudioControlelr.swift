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
    // means that currentAudioItem is played fully
    private(set) var playedToEnd: Bool = false
    
    var repeatMode: AudioControllerRepeatMode = .All
    
    var paused: Bool {
        return !((player.rate != 0) && (player.error == nil))
    }
    
    // MARK: Helpers
    
    var currentAudioItem: AudioItem? {
        return audioItemForAudioContext(audioContext, audioContextSection: audioContextSection, index: indexOfCurrentAudioItem)
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
    
    // MARK: Control
    
    func playAudioItemFromContext(audioContext: AudioContext?, audioContextSection: AudioContextSection?, index: Int?) {
        
        // if can derive audioItem
        if let audioItem = audioItemForAudioContext(audioContext, audioContextSection: audioContextSection, index: index) {
            
            // if not cached and removed by owner -- we can't play it
            if audioItem.url == nil && audioItem.downloadStatus != AudioItemDownloadStatusCached {
                return
            }
            
            // reinit controller
            playedToEnd = false
            self.audioContext = audioContext
            self.audioContextSection = audioContextSection
            self.indexOfCurrentAudioItem = index
            
            // post notification that we are going to play an audioItem
            let notification = NSNotification(name: AudioContorllerWillStartPlayingAudioItemNotification, object: nil, userInfo: [
                "audioItem": audioItem
                ])
            NSNotificationCenter.defaultCenter().postNotification(notification)
            
            // get playerItem
            CacheController.sharedCacheController.playerItemForAudioItem(audioItem, completionHandler: { playerItem, cached in
                
                // play from main thread
                dispatch_async(dispatch_get_main_queue(), {
                    self.player.replaceCurrentItemWithPlayerItem(playerItem)
                    self.player.seekToTime(CMTime(seconds: 0, preferredTimescale: 1))
                    self.player.play()
                })
                
                // post notification that we are started to play
                let notification = NSNotification(name: AudioControllerDidStartPlayingAudioItemNotification, object: nil, userInfo: [
                    "audioItem": playerItem.audioItem
                    ])
                NSNotificationCenter.defaultCenter().postNotification(notification)
            })
        }
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
        
        // play next if exists, else play first
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
        
        // replay if track is being played for more then 3 sec
        let currentTime = player.currentItem?.currentTime()
        if currentTime?.seconds > 3.0 {
            replay()
            return
        }
        
        // play previuos if it exists, else play last
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
    
    // MARK: Notification handling
    
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
