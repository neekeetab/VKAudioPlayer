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

extension TableViewController {
    
    func audioItemForIndexPath(indexPath: NSIndexPath) -> AudioItem {
        if context.audioRequestDescription is UserAudioRequestDescription {
            return context.userAudio[indexPath.row]
        }
        if context.audioRequestDescription is SearchAudioRequestDescription {
            if indexPath.section == 0 {
                return context.userAudio[indexPath.row]
            }
            if indexPath.section == 1 {
                return context.globalAudio[indexPath.row]
            }
        }
        return AudioItem()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // -----------------------------
        
        let audioItem = audioItemForIndexPath(indexPath)
        
        if audioItem.url == nil && audioItem.downloadStatus != AudioItemDownloadStatusCached {
            showMessage("Audio is removed by copyright holder", title: "Can't play this item")
        }
        
        if AudioController.sharedAudioController.currentAudioItem == audioItem {
            return
        }
        
        var audioContextSection: AudioContextSection!
        if indexPath.section == 0 {
            audioContextSection = .UserAudio
        } else {
            audioContextSection = .GlobalAudio
        }
        
        AudioController.sharedAudioController.playAudioItemFromContext(context, audioContextSection: audioContextSection, index: indexPath.row)
        
        // ----------------------------
        
        if navigationController!.popupBar == nil {
            // when tapping for a first time
            
            navigationController!.presentPopupBarWithContentViewController(audioPlayerViewController, animated: true, completion: {})
            navigationController!.view.bringSubviewToFront(self.navigationController!.popupContentView)
            
            let insets = UIEdgeInsetsMake(topLayoutGuide.length, 0, 40, 0)
            tableView.contentInset = insets
            tableView.scrollIndicatorInsets = insets
        }
    
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if context.audioRequestDescription is UserAudioRequestDescription {
            return 1
        }
        if context.audioRequestDescription is SearchAudioRequestDescription {
            return 2
        }
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if context.audioRequestDescription is UserAudioRequestDescription {
            return context.userAudio.count
        }
        if context.audioRequestDescription is SearchAudioRequestDescription {
            if section == 0 {
                return context.userAudio.count
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
    
        let audioItem = audioItemForIndexPath(indexPath)
        cell.audioItem = audioItem
        cell.title = audioItem.title
        cell.artist = audioItem.artist
        cell.playing = audioItem.playing
        cell.downloadStatus = audioItem.downloadStatus
        cell.enabled = audioItem.url != nil || audioItem.downloadStatus == AudioItemDownloadStatusCached
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if context.audioRequestDescription is UserAudioRequestDescription {
            return "My audio"
        }
        if context.audioRequestDescription is SearchAudioRequestDescription {
            if section == 0 {
                return "My audio"
            }
            if section == 1 {
                return "Global audio"
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
                    self.context.userAudio.removeAtIndex(indexPath.row)
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