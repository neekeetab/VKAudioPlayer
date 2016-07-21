//
//  ACPCustomStaticImages.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 7/21/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import ACPDownload

class ACPCustomStaticImages: ACPStaticImages {
    
    override func drawStatusComplete() {
        
        var frameContainer = CGRect()
        frameContainer.size.width = self.bounds.size.width;
        frameContainer.size.height = self.bounds.size.height;
        
        let bezierPath = UIBezierPath()
        
        let centerPoint = CGPoint(x: frameContainer.size.width / 2, y: frameContainer.size.height / 2)
        bezierPath.moveToPoint(centerPoint)
        
        let radius = min(CGRectGetMaxX(frameContainer) / 8, CGRectGetMaxY(frameContainer) / 8)
        bezierPath.addArcWithCenter(centerPoint, radius: radius, startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: true)
        
        UIColor.init(red: 0, green: 0.7, blue: 0, alpha: 1).setFill()
        bezierPath.closePath()
        bezierPath.fill()
        
    }
    
}

