//
//  AudioCell.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 5/29/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import UIKit
import NAKPlaybackIndicatorView
import AddButton
import ACPDownload

protocol AudioCellDelegate: class {
    func addButtonPressed(sender: AudioCell)
    func downloadButtonPressed(sender: AudioCell)
    func cancelButtonPressed(sender: AudioCell)
}

class AudioCell: UITableViewCell {

    @IBOutlet private weak var statusView: UIView!
    @IBOutlet private weak var addButton: AddButton!
    @IBOutlet private weak var titleTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var artistLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    
    private var playbackIndicator: NAKPlaybackIndicatorView!
    private var downloadView: ACPDownloadView!
    
    var audioItem: AudioItem? 
    weak var delegate: AudioCellDelegate?
    
    // MARK: Helpers
    
    private func showPlaybackIndicator() {
        playbackIndicator.hidden = false
        downloadView.hidden = true
    }
    
    private func showDownloadView() {
        downloadView.hidden = false
        playbackIndicator.hidden = true
    }
    
    private func showAddButton() {
        addButton.alpha = 1
        addButton.hidden = false
        titleTrailingConstraint.constant = addButton.frame.size.width - 8
        setNeedsUpdateConstraints()
    }
    
    private func hideAddButton() {
        addButton.hidden = true
        titleTrailingConstraint.constant = 8
        setNeedsUpdateConstraints()
    }
    
    // MARK:
    
    private var _ownedByUser = true
    var ownedByUser: Bool {
        set {
            _ownedByUser = newValue
            if newValue == true {
                hideAddButton()
            } else {
                showAddButton()
            }
        }
        get {
            return _ownedByUser
        }
    }
    
    private var _playing = false
    var playing: Bool {
        set {
            _playing = newValue
            if newValue == true {
                showPlaybackIndicator()
            } else {
                showDownloadView()
            }
        }
        get {
            return _playing
        }
    }
    
    private var _paused = false
    var paused: Bool {
        set {
            _paused = newValue
            if newValue == true {
                playbackIndicator.state = .Paused
            } else {
                playbackIndicator.state = .Playing
            }
        }
        get {
            return _paused
        }
    }
    
    var artist: String? {
        set {
            artistLabel.text = newValue
        }
        get {
            return artistLabel.text
        }
    }
    
    var title: String? {
        set {
            titleLabel.text = newValue
        }
        get {
            return titleLabel.text
        }
    }
    
    var downloadStatus: Float? {
        set {
            if newValue != nil {
                if newValue! == AudioItemDownloadStatusCached {
                    downloadView.setIndicatorStatus(.Completed)
                    return
                }
                if newValue! == AudioItemDownloadStatusNotCached {
                    downloadView.setIndicatorStatus(.None)
                    return
                }
                if newValue! == 0.0 {
                    downloadView.setIndicatorStatus(.Indeterminate)
                    downloadView.setProgress(0, animated: false)
                    return
                }
                downloadView.setIndicatorStatus(.Running)
                downloadView.setProgress(newValue!, animated: true)
            }
        }
        get {
            return nil
        }
    }
    
    // MARK:
    
    @IBAction func addButtonPressed() {
        addButton.alpha = 0.3
        delegate?.addButtonPressed(self)
    }
    
    // MARK: Notification handlers
    
    @objc private func audioControllerDidStartPlayingAudioItemNotificationHandler(notification: NSNotification) {
        if let audioItemBeingPlayed = notification.userInfo?["audioItem"] as? AudioItem {
            dispatch_async(dispatch_get_main_queue(), {
                self.playing = audioItemBeingPlayed == self.audioItem!
//                if self.playing {
//                    self.downloadStatus = self.audioItem!.downloadStatus
//                }
            })
        }
    }
    
    @objc private func audioControllerDidPauseAudioItemNotificationHandler(notification: NSNotification) {
        if let pausedAudioItem = notification.userInfo?["audioItem"] as? AudioItem {
            if pausedAudioItem == audioItem {
                dispatch_async(dispatch_get_main_queue(), {
                    self.paused = true
                })
            }
        }
    }
    
    @objc private func audioControllerDidResumeAudioItemNotificationHandler(notification: NSNotification) {
        if let resumedAudioItem = notification.userInfo?["audioItem"] as? AudioItem {
            if resumedAudioItem == audioItem {
                dispatch_async(dispatch_get_main_queue(), {
                    self.paused = false
                })
            }
        }
    }
    
    @objc private func cacheControllerDidCacheAudioItemNotificationHandler(notification: NSNotification) {
        if let cachedAudioItem = notification.userInfo?["audioItem"] as? AudioItem {
            if cachedAudioItem == audioItem {
                dispatch_async(dispatch_get_main_queue(), {
                    self.downloadStatus = AudioItemDownloadStatusCached
                })
            }
        }
    }
    
    @objc private func cacheControllerDidCancelDownloadingAudioItemNotificationHandler(notification: NSNotification) {
        if let canceledAudioItem = notification.userInfo?["audioItem"] as? AudioItem {
            if canceledAudioItem == audioItem {
                dispatch_async(dispatch_get_main_queue(), {
                    self.downloadStatus = AudioItemDownloadStatusNotCached
                })
            }
        }
    }
    
    @objc private func cacheControllerDidUpdateDownloadingProgressOfAudioItemNotificationHandler(notification: NSNotification) {
        if let downloadingAudioItem = notification.userInfo?["audioItem"] as? AudioItem {
            if downloadingAudioItem == audioItem {
                let bytesDownloaded = notification.userInfo?["bytesDownloaded"] as? Int
                let bytesExpected = notification.userInfo?["bytesExpected"] as? Int
                dispatch_async(dispatch_get_main_queue(), {
                    self.downloadStatus = Float(Double(bytesDownloaded!)/Double(bytesExpected!))
                })
            }
        }
    }
        
    // MARK:
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        titleTrailingConstraint.constant = 8
        addButton.hidden = true
        
        // Download View
        
        downloadView = ACPDownloadView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        statusView.addSubview(downloadView)
        downloadView.center = CGPoint(x: statusView.frame.size.width/2, y: statusView.frame.size.height/2)
        downloadView.backgroundColor = UIColor.clearColor()
        downloadView.hidden = false
        
        let layer = ACPIndeterminateGoogleLayer()
        downloadView.setIndeterminateLayer(layer)
        
        let staticImages = ACPCustomStaticImages()
        staticImages.updateColor(tintColor)
        downloadView.setImages(staticImages)
            
        downloadView.setActionForTap({ downloadView, downloadStatus in
            self.delegate?.downloadButtonPressed(self)
            if downloadView.currentStatus == .None {
                downloadView.setIndicatorStatus(.Indeterminate)
            } else if downloadView.currentStatus == .Indeterminate || downloadView.currentStatus == .Running {
                self.delegate?.cancelButtonPressed(self)
            }
        })
        
        // Playback Indicator
        
        playbackIndicator = NAKPlaybackIndicatorView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        statusView.addSubview(playbackIndicator)
        playbackIndicator.state = .Playing
        playbackIndicator.backgroundColor = UIColor.whiteColor()
        playbackIndicator.hidden = true
    
        // Notifications
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(audioControllerDidStartPlayingAudioItemNotificationHandler), name: AudioControllerDidStartPlayingAudioItemNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(audioControllerDidPauseAudioItemNotificationHandler), name: AudioControllerDidPauseAudioItemNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(audioControllerDidResumeAudioItemNotificationHandler), name: AudioControllerDidResumeAudioItemNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(cacheControllerDidCacheAudioItemNotificationHandler), name: CacheControllerDidCacheAudioItemNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(cacheControllerDidCancelDownloadingAudioItemNotificationHandler), name: CacheControllerDidCancelDownloadingAudioItemNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(cacheControllerDidUpdateDownloadingProgressOfAudioItemNotificationHandler), name: CacheControllerDidUpdateDownloadingProgressOfAudioItemNotification, object: nil)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
