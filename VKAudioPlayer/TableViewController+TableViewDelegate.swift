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
        audioStream.stop()
        audioStream.playFromURL(audioItemForIndexPath(indexPath).url)
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
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("audioCell") as! TableViewCell
        
        if indexPath.row % 5 == 0 {
            cell.playbackIndicator.state = NAKPlaybackIndicatorViewState.Playing
        }
        
        let audioItem = audioItemForIndexPath(indexPath)
        
//        cell.textLabel?.text = audioItem.title + " - " + audioItem.artist
        
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
    
    override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "Remove"
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            context.usersAudio.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
}