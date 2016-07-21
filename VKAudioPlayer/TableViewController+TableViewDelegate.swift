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
        
        audioPlayerViewController.popupItem.progress = 0.0
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        
        var audioContextSection: AudioContextSection!
        if indexPath.section == 0 {
            audioContextSection = .UserAudio
        } else {
            audioContextSection = .GlobalAudio
        }
        
        AudioController.sharedAudioController.playAudioItemFromContext(context, audioContextSection: audioContextSection, index: indexPath.row)
                
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
        
//        print(audioItemForIndexPath(indexPath).url)

        
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
        
        //
        cell.playing = false
        
        let audioItem = audioItemForIndexPath(indexPath)
        cell.audioItem = audioItemForIndexPath(indexPath)
        cell.title = audioItem.title
        cell.artist = audioItem.artist
        cell.downloaded = Storage.sharedStorage.objectIsCached(String(audioItem.id))

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