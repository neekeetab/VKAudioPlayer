//
//  UIViewController+Messages.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 5/29/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import UIKit

extension TableViewController {
    
    func showError(message: String) {
        showMessage(message, title: "Error")
    }
    
    func showMessage(message: String, title: String) {

        let alertVC = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alertVC.addAction(action)
        
        if self.presentedViewController == searchController {
            searchController.presentViewController(alertVC, animated: true, completion: nil)
        } else {
            self.presentViewController(alertVC, animated: true, completion: nil)
        }
        
    }
    
}

