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
import AVFoundation

protocol AudioCellDelegate: class {
    func addButtonPressed(sender: AudioCell)
    func downloadButtonPressed(sender: AudioCell)
    func cancelButtonPressed(sender: AudioCell)
    func uncacheButtonPressed(sender: AudioCell)
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
                paused = AudioController.sharedAudioController.paused
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
    
    private var _enabled = true
    var enabled: Bool {
        set {
            _enabled = newValue
            if newValue == true {
                downloadView.userInteractionEnabled = true
                addButton.enabled = true
                contentView.alpha = 1.0
            } else {
                downloadView.userInteractionEnabled = false
                addButton.enabled = false
                contentView.alpha = 0.5
            }
        }
        get {
            return _enabled
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
        
    @objc private func cacheControllerDidUpdateDownloadStatusOfAudioItemNotificationHandler(notification: NSNotification) {
        if let updatedAudioItem = notification.userInfo?["audioItem"] as? AudioItem {
            if updatedAudioItem == audioItem {
                let downloadStatus = notification.userInfo?["downloadStatus"] as? Float
                dispatch_async(dispatch_get_main_queue(), {
                    self.downloadStatus = downloadStatus
                })
            }
        }
    }
    
    @objc private func playerItemDidPlayToEndNotificationHandler(notification: NSNotification) {
        let playerItem = notification.object as? AudioCachingPlayerItem
        if playerItem?.audioItem == self.audioItem {
            dispatch_async(dispatch_get_main_queue(), {
                self.playing = false
            })
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
            if self.audioItem!.downloadStatus == AudioItemDownloadStatusNotCached {
                downloadView.setIndicatorStatus(.Indeterminate)
                self.delegate?.downloadButtonPressed(self)
            } else if self.audioItem!.downloadStatus == AudioItemDownloadStatusCached {
                self.delegate?.uncacheButtonPressed(self)
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(cacheControllerDidUpdateDownloadStatusOfAudioItemNotificationHandler), name: CacheControllerDidUpdateDownloadStatusOfAudioItemNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playerItemDidPlayToEndNotificationHandler), name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
