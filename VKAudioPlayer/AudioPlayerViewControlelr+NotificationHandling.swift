//
//  AudioPlayerViewControlelr+NotificationHandling.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 7/29/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import NAKPlaybackIndicatorView

extension AudioPlayerViewController {
    
    func audioContorllerWillStartPlayingAudioItemNotificationHandler(notification: NSNotification) {
        
        // need to update UI from main thread
        dispatch_async(dispatch_get_main_queue(), {
            let audioItem = notification.userInfo!["audioItem"] as! AudioItem
            self.popupItem.title = audioItem.title
            self.popupItem.subtitle = audioItem.artist
            if audioItem.downloadStatus == AudioItemDownloadStatusCached {
                self.downloadStatus = AudioItemDownloadStatusCached
            } else {
                self.downloadStatus = 0.0
            }

        })
        
    }
    
    func audioControllerDidStartPlayingAudioItemNotificationHandler(notification: NSNotification) {
        
        dispatch_async(dispatch_get_main_queue(), {
            let pausebutton = UIBarButtonItem(image: UIImage(named: "pause"), style: .Plain, target: self, action: #selector(self.playPauseButtonTapHandler))
            self.playPauseButton = pausebutton
        })
        
    }
    
    func audioControllerDidPauseAudioItemNotificationHandler(notification: NSNotification) {
       
        dispatch_async(dispatch_get_main_queue(), {
            let playButton = UIBarButtonItem(image: UIImage(named: "play"), style: .Plain, target: self, action: #selector(self.playPauseButtonTapHandler))
            self.playPauseButton = playButton
        })
        
    }
    
    func audioControllerDidResumeAudioItemNotificationHandler(notification: NSNotification) {
        
        dispatch_async(dispatch_get_main_queue(), {
            let pausebutton = UIBarButtonItem(image: UIImage(named: "pause"), style: .Plain, target: self, action: #selector(self.playPauseButtonTapHandler))
            self.playPauseButton = pausebutton
        })
        
    }
    
    func cacheControllerDidUpdateDownloadingProgressOfAudioItemNotificationHandler(notification: NSNotification) {
        
        let audioItem = notification.userInfo!["audioItem"] as! AudioItem
        let downloadStatus = notification.userInfo!["downloadStatus"] as! Float
        if audioItem == AudioController.sharedAudioController.currentAudioItem {
            dispatch_async(dispatch_get_main_queue(), {
                self.downloadStatus = downloadStatus
            })
            
        }
        
    }
    
    func audioControllerDidPlayAudioItemToEndNotificationHandler(notification: NSNotification) {
        
        dispatch_async(dispatch_get_main_queue(), {
            let playButton = UIBarButtonItem(image: UIImage(named: "play"), style: .Plain, target: self, action: #selector(self.playPauseButtonTapHandler))
            self.playPauseButton = playButton
        })
        
    }
    
    func subscribeToNotifications() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(audioContorllerWillStartPlayingAudioItemNotificationHandler), name: AudioContorllerWillStartPlayingAudioItemNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(audioControllerDidStartPlayingAudioItemNotificationHandler), name: AudioControllerDidStartPlayingAudioItemNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(audioControllerDidPauseAudioItemNotificationHandler), name: AudioControllerDidPauseAudioItemNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(audioControllerDidResumeAudioItemNotificationHandler), name: AudioControllerDidResumeAudioItemNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(cacheControllerDidUpdateDownloadingProgressOfAudioItemNotificationHandler), name: CacheControllerDidUpdateDownloadStatusOfAudioItemNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(audioControllerDidPlayAudioItemToEndNotificationHandler), name: AudioControllerDidPlayAudioItemToEndNotification, object: nil)
        
    }
    
}
    
