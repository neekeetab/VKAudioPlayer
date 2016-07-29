//
//  AudioPlayerViewControlelr+NotificationHandling.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 7/29/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import NAKPlaybackIndicatorView

extension AudioPlayerViewController {
    
    func audioControllerDidStartPlayingAudioItemNotificationHandler(notification: NSNotification) {
        
        // need to update UI from main thread
        dispatch_async(dispatch_get_main_queue(), {
            let audioItem = notification.userInfo!["audioItem"] as! AudioItem
            self.popupItem.title = audioItem.title
            self.popupItem.subtitle = audioItem.artist
            
            let progress = CacheController.sharedCacheController.downloadStatusForAudioItem(audioItem)
            if progress == AudioItemDownloadStatusCached || progress == AudioItemDownloadStatusNotCached {
                self.popupItem.progress = 0
            } else {
                self.popupItem.progress = progress
            }

        })
        
    }
    
    func audioControllerDidPauseAudioItemNotificationHandler(notification: NSNotification) {
       
        dispatch_async(dispatch_get_main_queue(), {
            let playButton = UIBarButtonItem(image: UIImage(named: "play"), style: .Plain, target: self, action: #selector(self.playPauseButtonTapHandler))
            self.playPauseButton = playButton
            self.reloadButtons()
        })
        
    }
    
    func audioControllerDidResumeAudioItemNotificationHandler(notification: NSNotification) {
        
        dispatch_async(dispatch_get_main_queue(), {
            let pausebutton = UIBarButtonItem(image: UIImage(named: "pause"), style: .Plain, target: self, action: #selector(self.playPauseButtonTapHandler))
            self.playPauseButton = pausebutton
            self.reloadButtons()
        })
        
    }
    
    func cacheControllerDidUpdateDownloadingProgressOfAudioItemNotificationHandler(notification: NSNotification) {
        
        let audioItem = notification.userInfo!["audioItem"] as! AudioItem
        let downloadStatus = notification.userInfo!["downloadStatus"] as! Float
        if audioItem == AudioController.sharedAudioController.currentAudioItem {
            dispatch_async(dispatch_get_main_queue(), {
                if downloadStatus == AudioItemDownloadStatusNotCached || downloadStatus == AudioItemDownloadStatusCached {
                    self.popupItem.progress = 0
                } else {
                    self.popupItem.progress = downloadStatus
                }
            })
        }
        
    }
    
    func subscribeToNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(audioControllerDidStartPlayingAudioItemNotificationHandler), name: AudioControllerDidStartPlayingAudioItemNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(audioControllerDidPauseAudioItemNotificationHandler), name: AudioControllerDidPauseAudioItemNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(audioControllerDidResumeAudioItemNotificationHandler), name: AudioControllerDidResumeAudioItemNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(cacheControllerDidUpdateDownloadingProgressOfAudioItemNotificationHandler), name: CacheControllerDidUpdateDownloadStatusOfAudioItemNotification, object: nil)
    }
    
}
    
