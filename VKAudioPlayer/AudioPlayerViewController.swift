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

class AudioPlayerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: Buttons
        
    func reloadButtons() {
    
        self.popupItem.leftBarButtonItems = [ self.prevButton, self.playPauseButton, self.nextButton ]
        self.popupItem.rightBarButtonItems = [ self.downloadCancelButton ]

    }
    
    private var _playPausebutton: UIBarButtonItem!
    var playPauseButton: UIBarButtonItem {
        set {
            _playPausebutton = newValue
            reloadButtons()
        }
        get {
            return _playPausebutton
        }
    }
    
    private(set) var downloadView: ACPDownloadView!
    private var downloadCancelButton: UIBarButtonItem!
    private var prevButton: UIBarButtonItem!
    private var nextButton: UIBarButtonItem!

    // MARK: 
    
    private var _downloadStatus: Float = AudioItemDownloadStatusNotCached
    var downloadStatus: Float {
        set {
            _downloadStatus = newValue
            if _downloadStatus == AudioItemDownloadStatusNotCached {
                self.popupItem.progress = 0
                self.downloadView.setIndicatorStatus(.None)
            } else if _downloadStatus == AudioItemDownloadStatusCached {
                self.popupItem.progress = 0
                self.downloadView.setIndicatorStatus(.Completed)
            } else {
                self.popupItem.progress = _downloadStatus
                if _downloadStatus == 0 {
                    self.downloadView.setIndicatorStatus(.Indeterminate)
                } else {
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
        
        _playPausebutton = UIBarButtonItem(image: UIImage(named: "pause"), style: .Plain, target: self, action: #selector(playPauseButtonTapHandler))
        
        downloadView = ACPDownloadView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        let layer = ACPIndeterminateGoogleLayer()
        downloadView.setIndeterminateLayer(layer)
        downloadView.backgroundColor = UIColor.clearColor()
        downloadCancelButton = UIBarButtonItem(customView: downloadView)
        let staticImages = ACPCustomStaticImages()
        downloadView.setImages(staticImages)
        downloadView.setActionForTap({ view in
            self.downloadCancelButtonTapHandler()
        })
        
        prevButton =  UIBarButtonItem(image: UIImage(named: "prev"), style: .Plain, target: self, action: #selector(prevButtonTapHandler))
        
        nextButton = UIBarButtonItem(image: UIImage(named: "nextFwd"), style: .Plain, target: self, action: #selector(nextButtonTapHandler))
        
        reloadButtons()
        subscribeToNotifications()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
