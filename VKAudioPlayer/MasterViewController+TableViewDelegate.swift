//
//  MasterViewController+TableViewDelegate.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 5/24/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import UIKit
import VK_ios_sdk

extension MasterViewController: UITableViewDelegate, UITableViewDataSource {
    
    func audioItemForIndexPath(indexPath: NSIndexPath) -> VKAudioItem {
        
        var audioItem: VKAudioItem
        if context.usersAudio.count != 0 && indexPath.section == 0 {
            audioItem = context.usersAudio[indexPath.row]
        } else {
            audioItem = context.globalAudio[indexPath.row]
        }
        
        return audioItem
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        audioStream.stop()
        audioStream.playFromURL(audioItemForIndexPath(indexPath).url)
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var count = 0
        if context.usersAudio.count != 0 {
            count += 1
        }
        if context.globalAudio.count != 0 {
            count += 1
        }
        return count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if context.usersAudio.count != 0 && section == 0 {
            return context.usersAudio.count
        }
        return context.globalAudio.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        let audioItem = audioItemForIndexPath(indexPath)
        cell.textLabel?.text = audioItem.title + " - " + audioItem.artist
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if context.usersAudio.count != 0 && section == 0 {
            return "My audios"
        }
        return "Global audios"
    }
    
}