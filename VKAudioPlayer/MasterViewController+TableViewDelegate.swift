//
//  MasterViewController+TableViewDelegate.swift
//  VKAudioPlayer
//
//  Created by Nikitab Belousov on 5/24/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import UIKit
import VK_ios_sdk

extension MasterViewController: UITableViewDelegate, UITableViewDataSource {
    
    func audioItemForIndexPath(indexPath: NSIndexPath) -> VKAudioItem {
        
        var audioItem: VKAudioItem
        if userAudios.count != 0 && indexPath.section == 0 {
            audioItem = userAudios[indexPath.row]
        } else {
            audioItem = globalAudios[indexPath.row]
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
        if userAudios.count != 0 {
            count += 1
        }
        if globalAudios.count != 0 {
            count += 1
        }
        return count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if userAudios.count != 0 && section == 0 {
            return userAudios.count
        }
        return globalAudios.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        let audioItem = audioItemForIndexPath(indexPath)
        cell.textLabel?.text = audioItem.title + " - " + audioItem.artist
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if userAudios.count != 0 && section == 0 {
            return "My audios"
        }
        return "Global audios"
    }
    
}