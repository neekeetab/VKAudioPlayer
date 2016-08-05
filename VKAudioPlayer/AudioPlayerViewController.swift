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

class AudioPlayerViewController: UIViewController {

    // MARK: IB
    
    @IBOutlet weak var progressSlider: BufferSlider!
    @IBOutlet weak var repeatButton: ToggleButton!
    @IBOutlet weak var downloadView: ACPDownloadView!
    @IBOutlet weak var playPauseButton: ToggleButton!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
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
    }
    @IBAction func progressSliderChangeValue(sender: AnyObject) {
        AudioController.sharedAudioController.seekToPart(sender.value)
    }
    
    @IBAction func changeVolume(sender: UISlider) {
        AudioController.sharedAudioController.volume = sender.value
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let repeatImage = UIImage(named: "repeat")
        let repeatOneImage = UIImage(named: "repeatOne")
        repeatButton.states = ["repeat", "repeatOne"]
        repeatButton.images = [repeatImage, repeatOneImage]
        
        // -------------------------------------------------
        
        let layer = ACPIndeterminateGoogleLayer()
        downloadView.setIndeterminateLayer(layer)
        let staticImages = ACPCustomStaticImages()
        downloadView.setImages(staticImages)
        downloadView.setActionForTap({ view in
            self.downloadCancelButtonTapHandler()
        })
        
        // -------------------------------------------------
        
        AudioController.sharedAudioController.setPeriodicTimeObserverBlock({ time1 in
            
            if self.progressSliderFlagEditing == false {
                let currentAudioItem = AudioController.sharedAudioController.currentAudioItem!
                let time = AudioController.sharedAudioController.player.currentTime()
                self.progressSlider.value = Float(time.seconds / Double(currentAudioItem.duration))
            }
            
        })
        
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
