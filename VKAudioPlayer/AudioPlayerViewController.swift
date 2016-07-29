//
//  AudioPlayerViewController.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 5/28/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import UIKit
import LNPopupController

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
    
    private var _downloadCancelButton: UIBarButtonItem!
    var downloadCancelButton: UIBarButtonItem {
        set {
            _downloadCancelButton = newValue
            reloadButtons()
        }
        get {
            return _downloadCancelButton
        }
    }
    
    private var prevButton: UIBarButtonItem!
    private var nextButton: UIBarButtonItem!

    // MARK:
    
    init() {
        super.init(nibName: nil, bundle: nil)
        _playPausebutton = UIBarButtonItem(image: UIImage(named: "pause"), style: .Plain, target: self, action: #selector(playPauseButtonTapHandler))
        _downloadCancelButton = UIBarButtonItem(image: UIImage(named: "downloadButton"), style: .Plain, target: self, action: #selector(downloadCancelButtonTapHandler))
        prevButton =  UIBarButtonItem(image: UIImage(named: "prev"), style: .Plain, target: self, action: #selector(prevButtonTapHandler))
        nextButton = UIBarButtonItem(image: UIImage(named: "nextFwd"), style: .Plain, target: self, action: #selector(nextButtonTapHandler))
        reloadButtons()
        subscribeToNotifications()
    }

    
    // MARK:
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
