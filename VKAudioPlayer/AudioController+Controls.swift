//
//  AudioController+Controls.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 8/2/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

extension AudioController {

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
                
                // play it from main thread
                dispatch_async(dispatch_get_main_queue(), {
                    self.player.replaceCurrentItemWithPlayerItem(playerItem)
                    self.player.seekToTime(CMTime(seconds: 0, preferredTimescale: 1))
                    self.player.play()
                })
                
                // post notification that we have started to play
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
        
        // play next audioItem if exists, else play first audioItem
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
        
        // play previuos audioItem if it exists, else play last audioItem
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
    
}
