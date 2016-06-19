//
//  TableVIewCell.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 5/29/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import UIKit
import NAKPlaybackIndicatorView
import AddButton

class TableViewCell: UITableViewCell {

    @IBOutlet weak var playbackIndicator: NAKPlaybackIndicatorView!
    @IBOutlet weak var addButton: AddButton!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    @IBAction func addButtonPressed(sender: AddButton) {
        
//        UIView.animateWithDuration(0.3, animations: {
//            sender.added = true
//        })
//        sender.enabled = false

        sender.alpha = 0.3
        
        
        delay(1.5, closure: {
            
            sender.alpha = 1
            sender.added = true
            delay(1, closure: {
                UIView.animateWithDuration(0.3, animations: {
                    sender.hidden = true
                })
            })
            
        })
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
