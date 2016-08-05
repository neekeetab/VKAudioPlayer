//
//  AudioPlayerViewController.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 5/28/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import UIKit
import LNPopupController
import ACPDownload
import BufferSlider
import AVFoundation

class AudioPlayerViewController: UIViewController {

    // MARK: IB
    
    @IBOutlet weak var progressSlider: BufferSlider!
    @IBOutlet weak var repeatButton: ToggleButton!
    @IBOutlet weak var downloadView: ACPDownloadView!
    @IBOutlet weak var playPauseButton: ToggleButton!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var playedLabel: UILabel!
    @IBOutlet weak var leftToPlayLabel: UILabel!
    
    @IBAction func prev(sender: AnyObject) {
        AudioController.sharedAudioController.prev()
    }
    
    @IBAction func next(sender: AnyObject) {
        AudioController.sharedAudioController.next()
    }
    
    @IBAction func playPause(sender: AnyObject) {
        if AudioController.sharedAudioController.paused {
            AudioController.sharedAudioController.resume()
        } else {
            AudioController.sharedAudioController.pause()
        }
    }

    var progressSliderFlagEditing = false
    @IBAction func progressSliderEditingBegin(sender: AnyObject) {
        progressSliderFlagEditing = true
    }
    @IBAction func progressSliderEditingEnd(sender: AnyObject) {
        // delay to allow player keep up
        delay(1.0, closure: {
            self.progressSliderFlagEditing = false
        })
        AudioController.sharedAudioController.seekToPart(sender.value)
    }
    @IBAction func progressSliderChangeValue(sender: AnyObject) {
        updateTimeLabelsWithPart(sender.value)
    }
    
    @IBAction func changeVolume(sender: UISlider) {
        AudioController.sharedAudioController.volume = sender.value
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let repeatImage = UIImage(named: "repeat")
        let repeatOneImage = UIImage(named: "repeatOne")
        let repeatTransparentImage = UIImage(named: "repeatTransparent")
        repeatButton.states = ["repeat", "repeatOne", "dontRepeat"]
        repeatButton.images = [repeatImage, repeatOneImage, repeatTransparentImage]
        repeatButton.currentStateIndex = 0
        repeatButton.action = { _ in
            var repeatMode: AudioControllerRepeatMode!
            if self.repeatButton.currentStateIndex == 0 {
                repeatMode = .All
            } else if self.repeatButton.currentStateIndex == 1 {
                repeatMode = .One
            } else if self.repeatButton.currentStateIndex == 2 {
                repeatMode = .Dont
            }
            AudioController.sharedAudioController.repeatMode = repeatMode
        }
        
        // -------------------------------------------------
        
        let layer = ACPIndeterminateGoogleLayer()
        downloadView.setIndeterminateLayer(layer)
        let staticImages = ACPCustomStaticImages()
        downloadView.setImages(staticImages)
        downloadView.setActionForTap({ view in
            self.downloadCancelButtonTapHandler()
        })
        
        // -------------------------------------------------
        
        AudioController.sharedAudioController.setPeriodicTimeObserverBlock({ _ in
            
            if self.progressSliderFlagEditing == false {
                let currentAudioItem = AudioController.sharedAudioController.currentAudioItem!
                let time = AudioController.sharedAudioController.player.currentTime()
                let part = Float(time.seconds / Double(currentAudioItem.duration))
                self.progressSlider.value = part
                self.updateTimeLabelsWithPart(part)
            }
            
        })
        
        // -------------------------------------------------
    
        volumeSlider.value = AVAudioSession.sharedInstance().outputVolume
        AVAudioSession.sharedInstance().addObserver(self, forKeyPath: "outputVolume", options: .New, context: nil)
        
        // -------------------------------------------------
        
        
        
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "outputVolume" {
            volumeSlider.value = AVAudioSession.sharedInstance().outputVolume
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        // workaround to force animating the downloadView while in .Indeterminate state
        downloadView.setIndicatorStatus(downloadView.currentStatus)
        
    }
    
    // MARK: Bar Buttons
        
    func reloadBarButtons() {
    
        self.popupItem.leftBarButtonItems = [ self.prevBarButton, self.playPauseBarButton, self.nextBarButton ]
        self.popupItem.rightBarButtonItems = [ self.downloadCancelBarButton ]

    }
    
    private var _playPauseBarbutton: UIBarButtonItem!
    var playPauseBarButton: UIBarButtonItem {
        set {
            _playPauseBarbutton = newValue
            reloadBarButtons()
        }
        get {
            return _playPauseBarbutton
        }
    }
    
    private(set) var downloadBarView: ACPDownloadView!
    private var downloadCancelBarButton: UIBarButtonItem!
    private var prevBarButton: UIBarButtonItem!
    private var nextBarButton: UIBarButtonItem!

    // MARK: 
    
    func updateTimeLabelsWithPart(part: Float) {
        let audioItem = AudioController.sharedAudioController.currentAudioItem!
        let currentTime = Int(Double(progressSlider.value) * Double(audioItem.duration))
        let minutesPlayed = currentTime / 60
        let secondsPlayed = currentTime % 60
        self.playedLabel.text = String(format: "%d:%02d", minutesPlayed, secondsPlayed)
        let minutesToPlay = (audioItem.duration - currentTime) / 60
        let secondsToPlay = (audioItem.duration - currentTime) % 60
        self.leftToPlayLabel.text = String(format: "%d:%02d", minutesToPlay, secondsToPlay)
    }
    
    private var _downloadStatus: Float = AudioItemDownloadStatusNotCached
    var downloadStatus: Float {
        set {
            _downloadStatus = newValue
            if _downloadStatus == AudioItemDownloadStatusNotCached {
                self.popupItem.progress = 0
                self.downloadBarView.setIndicatorStatus(.None)
                self.downloadView.setIndicatorStatus(.None)
            } else if _downloadStatus == AudioItemDownloadStatusCached {
                self.popupItem.progress = 0
                self.progressSlider.bufferEndValue = 1
                self.downloadBarView.setIndicatorStatus(.Completed)
                self.downloadView.setIndicatorStatus(.Completed)
            } else {
                self.popupItem.progress = _downloadStatus
                if _downloadStatus == 0 {
                    self.downloadBarView.setIndicatorStatus(.Indeterminate)
                    self.downloadView.setIndicatorStatus(.Indeterminate)
                } else {
                    self.progressSlider.bufferEndValue = Double(_downloadStatus)
//                    self.downloadView.setProgress(_downloadStatus, animated: true)
//                    self.downloadView.setIndicatorStatus(.Running)
                }
            }
        }
        get {
            return _downloadStatus
        }
    }
    
    // MARK:
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        _playPauseBarbutton = UIBarButtonItem(image: UIImage(named: "pause"), style: .Plain, target: self, action: #selector(playPauseButtonTapHandler))
        
        downloadBarView = ACPDownloadView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        let layer = ACPIndeterminateGoogleLayer()
        downloadBarView.setIndeterminateLayer(layer)
        downloadBarView.backgroundColor = UIColor.clearColor()
        downloadCancelBarButton = UIBarButtonItem(customView: downloadBarView)
        let staticImages = ACPCustomStaticImages()
        downloadBarView.setImages(staticImages)
        downloadBarView.setActionForTap({ view in
            self.downloadCancelButtonTapHandler()
        })
        
        prevBarButton =  UIBarButtonItem(image: UIImage(named: "prev"), style: .Plain, target: self, action: #selector(prevButtonTapHandler))
        
        nextBarButton = UIBarButtonItem(image: UIImage(named: "nextFwd"), style: .Plain, target: self, action: #selector(nextButtonTapHandler))
        
        reloadBarButtons()
        subscribeToNotifications()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
