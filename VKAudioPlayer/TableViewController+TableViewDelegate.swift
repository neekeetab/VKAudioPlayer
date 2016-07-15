//
//  TableViewController+TableViewDelegate.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 5/24/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import UIKit
import VK_ios_sdk
import NAKPlaybackIndicatorView
import AVFoundation
import LNPopupController
import FreeStreamer

extension TableViewController {
    
    func audioItemForIndexPath(indexPath: NSIndexPath) -> VKAudioItem {
        if context.audioRequestDescription is UsersAudioRequestDescription {
            return context.usersAudio[indexPath.row]
        }
        if context.audioRequestDescription is SearchAudioRequestDescription {
            if indexPath.section == 0 {
                return context.usersAudio[indexPath.row]
            }
            if indexPath.section == 1 {
                return context.globalAudio[indexPath.row]
            }
        }
        return VKAudioItem()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! AudioCell
        cell.playing = true
        
        let playerItem = CachingPlayerItem(url: self.audioItemForIndexPath(indexPath).url)
        playerItem.delegate = self
        player = AVPlayer(playerItem: playerItem)
        self.player.play()
    
        // ----------------------------
        
        navigationController!.presentPopupBarWithContentViewController(audioPlayerViewController, animated: true, completion: {})
        
        let insets = UIEdgeInsetsMake(topLayoutGuide.length, 0, 40, 0)
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets
        
        navigationController?.popupContentView.popupCloseButton?.setImage(UIImage(named: "DismissChevron"), forState: .Normal)
        
        let pause = UIBarButtonItem(image: UIImage(named: "pause"), style: .Plain, target: nil, action: nil)
        let prev = UIBarButtonItem(image: UIImage(named: "prev"), style: .Plain, target: nil, action: nil)
        let next = UIBarButtonItem(image: UIImage(named: "nextFwd"), style: .Plain, target: nil, action: nil)
        let save = UIBarButtonItem(image: UIImage(named: "downloadButton"), style: .Plain, target: nil, action: nil)
//        let list = UIBarButtonItem(image: UIImage(named: "next"), style: .Plain, target: nil, action: nil)
        
        audioPlayerViewController.popupItem.leftBarButtonItems = [ prev, pause, next ]
        audioPlayerViewController.popupItem.rightBarButtonItems = [ save ]
        
        audioPlayerViewController.popupItem.subtitle = audioItemForIndexPath(indexPath).artist
        audioPlayerViewController.popupItem.title = audioItemForIndexPath(indexPath).title
        
        print(audioItemForIndexPath(indexPath).url)
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if context.audioRequestDescription is UsersAudioRequestDescription {
            return 1
        }
        if context.audioRequestDescription is SearchAudioRequestDescription {
            return 2
        }
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if context.audioRequestDescription is UsersAudioRequestDescription {
            return context.usersAudio.count
        }
        if context.audioRequestDescription is SearchAudioRequestDescription {
            if section == 0 {
                return context.usersAudio.count
            }
            if section == 1 {
                return context.globalAudio.count
            }
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> AudioCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("audioCell") as! AudioCell
        cell.delegate = self
        
        if indexPath.section == 0 {
            cell.ownedByUser = true
        }
        
        if indexPath.section == 1 {
            cell.ownedByUser = false
        }
        
        cell.downloaded = false
        cell.playing = false
        
        let audioItem = audioItemForIndexPath(indexPath)
        cell.titleLabel.text = audioItem.title
        cell.artistLabel.text = audioItem.artist
        
//        let audioStream1 = FSAudioStream(url: audioItem.url)
//        
//        print("\(audioItem.title) - \(audioStream1.cached)")
//        cell.downloaded = audioStream1.cached
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if context.audioRequestDescription is UsersAudioRequestDescription {
            return "My audios"
        }
        if context.audioRequestDescription is SearchAudioRequestDescription {
            if section == 0 {
                return "My audios"
            }
            if section == 1 {
                return "Global audios"
            }
        }
        return ""
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 0 {
            return true
        }
        return false
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            if editingStyle == .Delete {
                let audioItem = audioItemForIndexPath(indexPath)
                let request = VKRequest.deleteAudioRequest(audioItem)
                request.executeWithResultBlock({ response in
                    if response.success() {
                       self.showMessage("audio has been deleted!", title: "")
                    } else {
                        self.showError("unknown")
                    }
                    self.context.usersAudio.removeAtIndex(indexPath.row)
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    }, errorBlock: { error in
                        self.showError(error.description)
                })
            }
        }
    }
    
    override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "Remove"
    }
    
}