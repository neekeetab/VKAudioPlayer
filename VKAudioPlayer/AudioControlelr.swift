//
//  AudioController.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 7/19/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import MediaPlayer
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

class AudioController: NSObject {
    
    static let sharedAudioController = AudioController()
    
    private(set) var player = AVPlayer()
    private(set) var indexOfCurrentAudioItem: Int?
    private(set) var audioContext: AudioContext?
    private(set) var audioContextSection: AudioContextSection?
    // means currentAudioItem is played fully
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
    
    // MARK: Controls
    
    func playAudioItemFromContext(audioContext: AudioContext?, audioContextSection: AudioContextSection?, index: Int?) {
        
        // if can derive audioItem
        if let audioItem = self.audioItemForAudioContext(audioContext, audioContextSection: audioContextSection, index: index) {
            
            // if not cached and removed by owner -- we can't play it
            if audioItem.url == nil && audioItem.downloadStatus != AudioItemDownloadStatusCached {
                return
            }
            
            // reinit controller
            self.playedToEnd = false
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
                
                // update media center
                MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [
                    MPMediaItemPropertyTitle: audioItem.title,
                    MPMediaItemPropertyArtist: audioItem.artist,
                    MPMediaItemPropertyPlaybackDuration: audioItem.duration
                ]
                
                // post notification that we have started to play
                let notification = NSNotification(name: AudioControllerDidStartPlayingAudioItemNotification, object: nil, userInfo: [
                    "audioItem": playerItem.audioItem
                    ])
                NSNotificationCenter.defaultCenter().postNotification(notification)
            })
        }
    }
    
    @objc func resume() {
        player.play()
        if let audioItem = currentAudioItem {
            let notification = NSNotification(name: AudioControllerDidResumeAudioItemNotification, object: nil, userInfo: [
                "audioItem": audioItem
                ])
            NSNotificationCenter.defaultCenter().postNotification(notification)
        }
    }
    
    @objc func pause() {
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
    
    @objc func next() {
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
    
    @objc func prev() {
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

    private let volumeView = MPVolumeView()
    var volume: Float {
        set {
            for subview in volumeView.subviews {
                if subview.description.rangeOfString("MPVolumeSlider") != nil {
                    let slider = subview as! UISlider
                    slider.value = newValue
                    break
                }
            }
        }
        get {
            return AVAudioSession.sharedInstance().outputVolume
        }
    }
    
    private var _seekBackwardFlag = false
    func seekBackward() {
        _seekBackwardFlag = !_seekBackwardFlag
        if _seekBackwardFlag {
            player.rate = -10.0
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime().seconds
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo![MPNowPlayingInfoPropertyPlaybackRate] = -10.0
        } else {
            player.rate = 1.0
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime().seconds
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo![MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        }
    }
    
    private var _seekForwardFlag = false
    func seekForward() {
        _seekForwardFlag = !_seekForwardFlag
        if _seekForwardFlag {
            player.rate = 10.0
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime().seconds
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo![MPNowPlayingInfoPropertyPlaybackRate] = 10.0
            
        } else {
            player.rate = 1.0
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime().seconds
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo![MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        }
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
    
    // MARK: Command Center configuration
    
    private func configureCommandCenter() {
        
        let commandCenter = MPRemoteCommandCenter.sharedCommandCenter()
        
        commandCenter.previousTrackCommand.enabled = true;
        commandCenter.previousTrackCommand.addTarget(self, action: #selector(prev))
        
        commandCenter.nextTrackCommand.enabled = true
        commandCenter.nextTrackCommand.addTarget(self, action: #selector(next))
        
        commandCenter.playCommand.enabled = true
        commandCenter.playCommand.addTarget(self, action: #selector(resume))
        
        commandCenter.pauseCommand.enabled = true
        commandCenter.pauseCommand.addTarget(self, action: #selector(pause))
        
        commandCenter.seekForwardCommand.enabled = true
        commandCenter.seekForwardCommand.addTarget(self, action: #selector(seekForward))
        
        commandCenter.seekBackwardCommand.enabled = true
        commandCenter.seekBackwardCommand.addTarget(self, action: #selector(seekBackward))
        
    }
    
    // MARK:
    
    private override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playerItemDidPlayToEndNotificationHandler), name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        configureCommandCenter()
    }
    
}
