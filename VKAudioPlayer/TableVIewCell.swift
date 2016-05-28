//
//  TableVIewCell.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 5/29/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import UIKit
import NAKPlaybackIndicatorView

class TableViewCell: UITableViewCell {

    @IBOutlet weak var playbackIndicator: NAKPlaybackIndicatorView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
